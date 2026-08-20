import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sreerajp_todo/core/constants/app_constants.dart';
import 'package:sreerajp_todo/application/providers.dart';
import 'package:sreerajp_todo/core/utils/date_utils.dart';
import 'package:sreerajp_todo/data/models/todo_entity.dart';
import 'package:sreerajp_todo/data/models/todo_search_result.dart';
import 'package:sreerajp_todo/data/models/todo_status.dart';
import 'package:sreerajp_todo/domain/repositories/todo_repository.dart';
import 'package:sreerajp_todo/l10n/app_localizations.dart';
import 'package:sreerajp_todo/presentation/screens/create_edit_todo/create_edit_todo_screen.dart';

import '../helpers/test_fixtures.dart';
import '../helpers/test_l10n.dart';

class _FakeTodoRepository implements TodoRepository {
  _FakeTodoRepository(this.todo);

  final TodoEntity todo;

  @override
  Future<void> createTodo(TodoEntity todo) async {}

  @override
  Future<void> deleteTodo(String id, {bool bypassLock = false}) async {}

  @override
  Future<List<String>> getAutocompleteSuggestions(
    String prefix, {
    int limit = kAutocompleteLimit,
  }) async => const [];

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
  Future<List<TodoSearchResult>> searchWithMatchedNotes(
    String query, {
    int limit = 50,
  }) async => (await searchByTitle(
    query,
    limit: limit,
  )).map((todo) => TodoSearchResult(todo: todo)).toList();
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
  Future<void> toggleSubTask(
    String todoId,
    String subTaskId,
    bool isCompleted, {
    bool bypassLock = false,
  }) async {}

  @override
  Future<List<TodoEntity>> getPendingPrerequisites(String todoId) async => [];

  @override
  Future<bool> isTodoBlocked(String todoId) async => false;

  @override
  Future<int> deleteAllByRecurrenceRuleId(String recurrenceRuleId) async => 0;

  @override
  Future<int> deleteByRecurrenceRuleIdFromDate(
    String recurrenceRuleId,
    String fromDate,
  ) async => 0;
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
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: CreateEditTodoScreen(todoId: 'active-todo'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Priority and target time now sit above the status card, so it starts
    // below the fold on a 320 dp screen.
    await tester.dragUntilVisible(
      find.text(testL10n.statusDropped),
      find.byType(ListView),
      const Offset(0, -120),
    );
    await tester.pumpAndSettle();

    final droppedRect = tester.getRect(find.text(testL10n.statusDropped));
    final portedRect = tester.getRect(find.text(testL10n.statusPorted));

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
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: CreateEditTodoScreen(todoId: 'past-todo'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text(testL10n.viewTodo), findsOneWidget);
    expect(find.text(testL10n.readOnlyPastDate), findsOneWidget);
    expect(
      find.widgetWithText(TextFormField, testL10n.titleHint),
      findsOneWidget,
    );
    expect(
      find.widgetWithText(TextFormField, testL10n.descriptionHint),
      findsOneWidget,
    );
    expect(find.widgetWithText(FilledButton, testL10n.save), findsNothing);

    final textFields = tester.widgetList<TextFormField>(
      find.byType(TextFormField),
    );
    expect(textFields.every((field) => field.enabled == false), isTrue);
  });

  testWidgets('repeat sheet "For N days" resolves to start + (N - 1)', (
    tester,
  ) async {
    final todo = buildTodo(id: 'unused', date: dateOffsetIso(0));
    // A new task opens on the saved task defaults, so the preference store has
    // to be present even when every default is left alone.
    SharedPreferences.setMockInitialValues(const {});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          todoRepositoryProvider.overrideWithValue(_FakeTodoRepository(todo)),
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: CreateEditTodoScreen(date: dateOffsetIso(0)),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Open the custom recurrence sheet via the "Repeat…" segment.
    final repeatSegment = find.text(testL10n.repeatConfigure);
    await tester.dragUntilVisible(
      repeatSegment,
      find.byType(ListView),
      const Offset(0, -100),
    );
    await tester.tap(repeatSegment);
    await tester.pumpAndSettle();

    // Default "Ends" mode is Never — no end-date helper text yet.
    expect(find.textContaining('${testL10n.endDate}:'), findsNothing);

    // Switch to the "For" (N days) end condition.
    await tester.tap(find.text(testL10n.endsAfterDays).last);
    await tester.pumpAndSettle();

    // Default day count is 7, so the inclusive end date is start + 6 days.
    final expectedEnd = formatDateFromIso(dateOffsetIso(6));
    expect(find.text('${testL10n.endDate}: $expectedEnd'), findsOneWidget);
  });
}
