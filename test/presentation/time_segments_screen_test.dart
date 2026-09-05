import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sreerajp_todo/application/providers.dart';
import 'package:sreerajp_todo/core/utils/date_utils.dart';
import 'package:sreerajp_todo/data/models/time_segment_entity.dart';
import 'package:sreerajp_todo/data/models/todo_entity.dart';
import 'package:sreerajp_todo/data/models/todo_history_entity.dart';
import 'package:sreerajp_todo/data/models/todo_priority.dart';
import 'package:sreerajp_todo/data/models/todo_search_result.dart';
import 'package:sreerajp_todo/data/models/todo_status.dart';
import 'package:sreerajp_todo/domain/repositories/time_segment_repository.dart';
import 'package:sreerajp_todo/domain/repositories/todo_repository.dart';
import 'package:sreerajp_todo/l10n/app_localizations.dart';
import 'package:sreerajp_todo/presentation/screens/time_segments/time_segments_screen.dart';

import '../helpers/test_l10n.dart';

class _FakeTodoRepo implements TodoRepository {
  _FakeTodoRepo(this.todo);
  final TodoEntity todo;

  @override
  Future<TodoEntity?> getTodoById(String id) async =>
      id == todo.id ? todo : null;
  @override
  Future<List<TodoEntity>> getTodosByDate(String date) async => [todo];
  @override
  Future<void> createTodo(TodoEntity todo) async {}
  @override
  Future<void> updateTodo(TodoEntity todo, {bool bypassLock = false}) async {}
  @override
  Future<void> deleteTodo(String id, {bool bypassLock = false}) async {}
  @override
  Future<List<String>> getAutocompleteSuggestions(
    String prefix, {
    int limit = 50,
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
  Future<void> reorderTodos(
    List<TodoEntity> todos, {
    bool bypassLock = false,
  }) async {}
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
  @override
  Future<List<TodoEntity>> getTodosByRecurrenceRuleId(
    String recurrenceRuleId,
  ) async => [];
  @override
  Future<List<TodoEntity>> getTodosByRecurrenceRuleIdFromDate(
    String recurrenceRuleId,
    String fromDate,
  ) async => [];
  @override
  Future<bool> existsRuleInstanceOnDate(
    String recurrenceRuleId,
    String date,
  ) async => false;
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

class _FakeTimeSegmentRepo implements TimeSegmentRepository {
  _FakeTimeSegmentRepo(this.segments);
  List<TimeSegmentEntity> segments;
  bool deleteCalled = false;
  bool restoreCalled = false;

  @override
  Future<List<TimeSegmentEntity>> getSegments(String todoId) async => segments;
  @override
  Future<TimeSegmentEntity?> getRunningSegment(String todoId) async => null;
  @override
  Future<void> insertManualSegment(TimeSegmentEntity segment) async {
    segments.add(segment);
  }

  @override
  Future<void> updateSegmentNotes(String segmentId, String? notes) async {}
  @override
  Future<void> updateSegmentTimes(
    String segmentId,
    DateTime newStart,
    DateTime newEnd,
  ) async {}
  @override
  Future<void> repairOrphanedSegments(
    String todayDate, {
    DateTime? Function(DateTime segmentStart)? closeAt,
  }) async {}
  @override
  Future<void> startSegment(String todoId) async {}
  @override
  Future<TimeSegmentEntity?> stopSegment(String todoId) async => null;
  @override
  Future<TimeSegmentEntity?> closeSegmentAt(String todoId, DateTime at) async =>
      null;
  @override
  Future<List<TimeSegmentEntity>> getAllRunningSegments() async => [];
  @override
  Future<List<String>> stopAllRunningSegments({String? exceptTodoId}) async =>
      [];
  @override
  Future<void> deleteSegment(String segmentId) async {
    deleteCalled = true;
    segments.removeWhere((s) => s.id == segmentId);
  }

  @override
  Future<void> restoreSegment(TimeSegmentEntity segment) async {
    restoreCalled = true;
    segments.add(segment);
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets(
    'deleting time segment shows confirmation dialog and undo snackbar',
    (tester) async {
      final now = DateTime.now();
      final today = todayAsIso();
      final todo = TodoEntity(
        id: 'todo-1',
        date: today,
        title: 'Active Task',
        status: TodoStatus.pending,
        priority: TodoPriority.normal,
        createdAt: now.toUtc().toIso8601String(),
        updatedAt: now.toUtc().toIso8601String(),
      );

      final segment = TimeSegmentEntity(
        id: 'seg-1',
        todoId: 'todo-1',
        startTime: DateTime(
          now.year,
          now.month,
          now.day,
          9,
          0,
        ).toIso8601String(),
        endTime: DateTime(
          now.year,
          now.month,
          now.day,
          9,
          30,
        ).toIso8601String(),
        durationSeconds: 1800,
        createdAt: now.toUtc().toIso8601String(),
      );

      final fakeTimeRepo = _FakeTimeSegmentRepo([segment]);
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            todoRepositoryProvider.overrideWithValue(_FakeTodoRepo(todo)),
            timeSegmentRepositoryProvider.overrideWithValue(fakeTimeRepo),
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: TimeSegmentsScreen(todoId: 'todo-1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify delete button is present
      final deleteButton = find.byIcon(Icons.delete_outline_rounded);
      expect(deleteButton, findsOneWidget);

      // Tap delete button
      await tester.tap(deleteButton);
      await tester.pumpAndSettle();

      // Verify confirmation dialog
      expect(find.text(testL10n.confirmDeleteSegment), findsOneWidget);
      expect(find.text(testL10n.confirmDeleteSegmentBody), findsOneWidget);

      // Confirm deletion
      await tester.tap(find.widgetWithText(FilledButton, testL10n.delete));
      await tester.pumpAndSettle();

      expect(fakeTimeRepo.deleteCalled, isTrue);

      // SnackBar with undo should be visible
      expect(find.text(testL10n.timeSegmentDeleted), findsOneWidget);
      final undoButton = find.widgetWithText(SnackBarAction, testL10n.undo);
      expect(undoButton, findsOneWidget);

      // Tap Undo
      await tester.tap(undoButton);
      await tester.pumpAndSettle();

      expect(fakeTimeRepo.restoreCalled, isTrue);
    },
  );

  testWidgets('delete button is not present on past-day tasks', (tester) async {
    final now = DateTime.now();
    const pastDate = '2026-08-01';
    final todo = TodoEntity(
      id: 'todo-past',
      date: pastDate,
      title: 'Past Task',
      status: TodoStatus.completed,
      priority: TodoPriority.normal,
      createdAt: now.toUtc().toIso8601String(),
      updatedAt: now.toUtc().toIso8601String(),
    );

    final segment = TimeSegmentEntity(
      id: 'seg-past',
      todoId: 'todo-past',
      startTime: DateTime(2026, 8, 1, 9, 0).toIso8601String(),
      endTime: DateTime(2026, 8, 1, 9, 30).toIso8601String(),
      durationSeconds: 1800,
      createdAt: now.toUtc().toIso8601String(),
    );

    final fakeTimeRepo = _FakeTimeSegmentRepo([segment]);
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          todoRepositoryProvider.overrideWithValue(_FakeTodoRepo(todo)),
          timeSegmentRepositoryProvider.overrideWithValue(fakeTimeRepo),
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: TimeSegmentsScreen(todoId: 'todo-past'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify delete button is NOT present on past days
    expect(find.byIcon(Icons.delete_outline_rounded), findsNothing);
  });
}
