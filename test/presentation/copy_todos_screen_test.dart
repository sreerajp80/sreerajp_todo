import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sreerajp_todo/application/providers.dart';
import 'package:sreerajp_todo/core/constants/app_constants.dart';
import 'package:sreerajp_todo/data/models/todo_entity.dart';
import 'package:sreerajp_todo/data/models/todo_history_entity.dart';
import 'package:sreerajp_todo/data/models/todo_search_result.dart';
import 'package:sreerajp_todo/data/models/todo_status.dart';
import 'package:sreerajp_todo/domain/repositories/todo_repository.dart';
import 'package:sreerajp_todo/domain/usecases/copy_todos.dart';
import 'package:sreerajp_todo/l10n/app_localizations.dart';
import 'package:sreerajp_todo/presentation/screens/copy_todos/copy_todos_screen.dart';

import '../helpers/test_fixtures.dart';

class _InMemoryRepo implements TodoRepository {
  _InMemoryRepo(this.todos);
  final List<TodoEntity> todos;

  @override
  Future<List<TodoEntity>> getTodosByDate(String date) async {
    return todos.where((t) => t.date == date).toList();
  }

  @override
  Future<TodoEntity?> getTodoById(String id) async {
    try {
      return todos.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> createTodo(TodoEntity todo) async {
    todos.add(todo);
  }

  @override
  Future<void> updateTodo(TodoEntity todo, {bool bypassLock = false}) async {
    final idx = todos.indexWhere((t) => t.id == todo.id);
    if (idx >= 0) todos[idx] = todo;
  }

  @override
  Future<void> deleteTodo(String id, {bool bypassLock = false}) async {
    todos.removeWhere((t) => t.id == id);
  }

  @override
  Future<bool> titleExistsOnDate(
    String title,
    String date, {
    String? excludeId,
  }) async {
    return todos.any(
      (t) => t.date == date && t.title == title && t.id != excludeId,
    );
  }

  @override
  Future<List<String>> getAutocompleteSuggestions(
    String prefix, {
    int limit = kAutocompleteLimit,
  }) async => [];

  @override
  Future<List<TodoEntity>> searchByTitle(
    String query, {
    int limit = 50,
  }) async => [];

  @override
  Future<List<TodoSearchResult>> searchWithMatchedNotes(
    String query, {
    int limit = 50,
  }) async => [];

  @override
  Future<void> toggleSubTask(
    String todoId,
    String subTaskId,
    bool isCompleted, {
    bool bypassLock = false,
  }) async {}

  @override
  Future<void> reorderTodos(
    List<TodoEntity> todos, {
    bool bypassLock = false,
  }) async {}

  @override
  Future<void> updateStatus(
    String id,
    TodoStatus status, {
    String? portedTo,
    bool bypassLock = false,
  }) async {}

  @override
  Future<void> bulkCreateTodos(List<TodoEntity> todos) async {
    this.todos.addAll(todos);
  }

  @override
  Future<int> deleteAllByRecurrenceRuleId(String recurrenceRuleId) async => 0;

  @override
  Future<int> deleteByRecurrenceRuleIdFromDate(
    String recurrenceRuleId,
    String fromDate,
  ) async => 0;

  @override
  Future<List<TodoEntity>> getTodosByRecurrenceRuleId(
    String recurrenceRuleId,
  ) async =>
      todos.where((t) => t.recurrenceRuleId == recurrenceRuleId).toList();

  @override
  Future<List<TodoEntity>> getTodosByRecurrenceRuleIdFromDate(
    String recurrenceRuleId,
    String fromDate,
  ) async => todos
      .where(
        (t) =>
            t.recurrenceRuleId == recurrenceRuleId &&
            t.date.compareTo(fromDate) >= 0,
      )
      .toList();

  @override
  Future<bool> existsRuleInstanceOnDate(
    String recurrenceRuleId,
    String date,
  ) async => todos.any(
    (t) => t.recurrenceRuleId == recurrenceRuleId && t.date == date,
  );

  @override
  Future<List<TodoEntity>> getPendingPrerequisites(String todoId) async => [];

  @override
  Future<bool> isTodoBlocked(String todoId) async => false;

  @override
  Future<int> maxSortOrder(String date) async => todos.length;

  @override
  Future<void> moveTodo(String todoId, String targetDate) async {}

  @override
  Future<List<TodoHistoryEntity>> getHistoryForTodo(String todoId) async => [];

  @override
  Future<void> logHistoryEvent({
    required String todoId,
    required TodoHistoryEventType eventType,
    required String description,
    String? metadata,
    String? eventTime,
  }) async {}
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('CopyTodosScreen loads source tasks and allows selection', (
    tester,
  ) async {
    final todos = [
      buildTodo(id: 't1', title: 'Task 1', date: '2026-08-27'),
      buildTodo(id: 't2', title: 'Task 2', date: '2026-08-27'),
    ];
    final repo = _InMemoryRepo(todos);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          todoRepositoryProvider.overrideWithValue(repo),
          copyTodosProvider.overrideWithValue(CopyTodos(repo)),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: CopyTodosScreen(fromDate: '2026-08-27'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Task 1'), findsOneWidget);
    expect(find.text('Task 2'), findsOneWidget);

    // Tap checkbox for Task 1
    await tester.tap(find.text('Task 1'));
    await tester.pumpAndSettle();

    // Next button should be enabled
    expect(find.widgetWithText(FilledButton, 'Next'), findsOneWidget);
  });
}
