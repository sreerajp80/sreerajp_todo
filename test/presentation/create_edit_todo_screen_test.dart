import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_todo/application/providers.dart';
import 'package:sreerajp_todo/core/constants/app_strings.dart';
import 'package:sreerajp_todo/data/models/todo_entity.dart';
import 'package:sreerajp_todo/data/models/todo_status.dart';
import 'package:sreerajp_todo/domain/repositories/todo_repository.dart';
import 'package:sreerajp_todo/presentation/screens/create_edit_todo/create_edit_todo_screen.dart';

import '../helpers/test_fixtures.dart';

class _FakeTodoRepository implements TodoRepository {
  _FakeTodoRepository(this.todo);

  final TodoEntity todo;

  @override
  Future<void> createTodo(TodoEntity todo) async {}

  @override
  Future<void> deleteTodo(String id, {bool bypassLock = false}) async {}

  @override
  Future<List<String>> getAutocompleteSuggestions(String prefix) async =>
      const [];

  @override
  Future<TodoEntity?> getTodoById(String id) async =>
      id == todo.id ? todo : null;

  @override
  Future<List<TodoEntity>> getTodosByDate(String date) async =>
      date == todo.date ? [todo] : const [];

  @override
  Future<void> reorderTodos(
    List<TodoEntity> todos, {
    bool bypassLock = false,
  }) async {}

  @override
  Future<List<TodoEntity>> searchByTitle(
    String query, {
    int limit = 50,
  }) async => const [];

  @override
  Future<bool> titleExistsOnDate(
    String title,
    String date, {
    String? excludeId,
  }) async => false;

  @override
  Future<void> updateStatus(
    String id,
    TodoStatus status, {
    String? portedTo,
    bool bypassLock = false,
  }) async {}

  @override
  Future<void> updateTodo(TodoEntity todo, {bool bypassLock = false}) async {}

  @override
  Future<int> maxSortOrder(String date) async => 0;

  @override
  Future<void> bulkCreateTodos(List<TodoEntity> todos) async {}

  @override
  Future<int> deleteAllByRecurrenceRuleId(String recurrenceRuleId) async => 0;
}

void main() {
  testWidgets('status options stay visible on narrow edit screens', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final todo = buildTodo(
      id: 'active-todo',
      date: dateOffsetIso(0),
      title: 'Testing',
      description: 'Visible statuses',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          todoRepositoryProvider.overrideWithValue(_FakeTodoRepository(todo)),
        ],
        child: const MaterialApp(
          home: CreateEditTodoScreen(todoId: 'active-todo'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final droppedRect = tester.getRect(find.text(AppStrings.statusDropped));
    final portedRect = tester.getRect(find.text(AppStrings.statusPorted));

    expect(droppedRect.right, lessThanOrEqualTo(320));
    expect(portedRect.right, lessThanOrEqualTo(320));
  });
  testWidgets('past-day todo details screen is read only', (tester) async {
    final todo = buildTodo(
      id: 'past-todo',
      date: dateOffsetIso(-1),
      title: 'Testing',
      description: 'Locked details',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          todoRepositoryProvider.overrideWithValue(_FakeTodoRepository(todo)),
        ],
        child: const MaterialApp(
          home: CreateEditTodoScreen(todoId: 'past-todo'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text(AppStrings.viewTodo), findsOneWidget);
    expect(find.text(AppStrings.readOnlyPastDate), findsOneWidget);
    expect(
      find.widgetWithText(TextFormField, AppStrings.titleHint),
      findsOneWidget,
    );
    expect(
      find.widgetWithText(TextFormField, AppStrings.descriptionHint),
      findsOneWidget,
    );
    expect(find.widgetWithText(FilledButton, AppStrings.save), findsNothing);

    final textFields = tester.widgetList<TextFormField>(
      find.byType(TextFormField),
    );
    expect(textFields.every((field) => field.enabled == false), isTrue);
  });
}
