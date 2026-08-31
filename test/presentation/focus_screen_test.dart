import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sreerajp_todo/application/providers.dart';
import 'package:sreerajp_todo/core/constants/app_constants.dart';
import 'package:sreerajp_todo/data/models/sub_task_item.dart';
import 'package:sreerajp_todo/data/models/time_segment_entity.dart';
import 'package:sreerajp_todo/data/models/todo_entity.dart';
import 'package:sreerajp_todo/data/models/todo_history_entity.dart';
import 'package:sreerajp_todo/data/models/todo_search_result.dart';
import 'package:sreerajp_todo/data/models/todo_status.dart';
import 'package:sreerajp_todo/domain/repositories/time_segment_repository.dart';
import 'package:sreerajp_todo/domain/repositories/todo_repository.dart';
import 'package:sreerajp_todo/l10n/app_localizations.dart';
import 'package:sreerajp_todo/presentation/screens/focus/focus_screen.dart';

import '../helpers/test_fixtures.dart';
import '../helpers/test_l10n.dart';

/// Remembers the sub-task ticks so the test can check the Focus view really
/// writes through the repository layer.
class _FakeTodoRepository implements TodoRepository {
  _FakeTodoRepository(this._todos);

  final List<TodoEntity> _todos;
  final List<String> toggledSubTaskIds = [];

  @override
  Future<void> createTodo(TodoEntity todo) async => _todos.add(todo);

  @override
  Future<void> deleteTodo(String id, {bool bypassLock = false}) async =>
      _todos.removeWhere((todo) => todo.id == id);

  @override
  Future<List<String>> getAutocompleteSuggestions(
    String prefix, {
    int limit = kAutocompleteLimit,
  }) async => const [];

  @override
  Future<TodoEntity?> getTodoById(String id) async {
    try {
      return _todos.firstWhere((todo) => todo.id == id);
    } on StateError {
      return null;
    }
  }

  @override
  Future<List<TodoEntity>> getTodosByDate(String date) async =>
      _todos.where((todo) => todo.date == date).toList();

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
  Future<void> toggleSubTask(
    String todoId,
    String subTaskId,
    bool isCompleted, {
    bool bypassLock = false,
  }) async {
    toggledSubTaskIds.add(subTaskId);
  }

  @override
  Future<List<TodoEntity>> getPendingPrerequisites(String todoId) async =>
      const [];

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

class _FakeTimeSegmentRepository implements TimeSegmentRepository {
  _FakeTimeSegmentRepository({this.running});

  /// The open segment, if the task is being timed right now.
  TimeSegmentEntity? running;

  @override
  Future<List<TimeSegmentEntity>> getSegments(String todoId) async =>
      running == null ? const [] : [running!];

  @override
  Future<TimeSegmentEntity?> getRunningSegment(String todoId) async => running;

  @override
  Future<void> insertManualSegment(TimeSegmentEntity segment) async {}

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
  Future<TimeSegmentEntity?> stopSegment(String todoId) async {
    running = null;
    return null;
  }

  @override
  Future<TimeSegmentEntity?> closeSegmentAt(String todoId, DateTime at) async =>
      null;

  @override
  Future<List<TimeSegmentEntity>> getAllRunningSegments() async =>
      running == null ? const [] : [running!];

  @override
  Future<List<String>> stopAllRunningSegments({String? exceptTodoId}) async =>
      const [];

  @override
  Future<void> deleteSegment(String segmentId) async {}

  @override
  Future<void> restoreSegment(TimeSegmentEntity segment) async {}
}

void main() {
  late TodoEntity todo;
  late _FakeTodoRepository todoRepository;
  late _FakeTimeSegmentRepository timeSegmentRepository;
  late SharedPreferences prefs;

  SubTaskItem buildSubTask(String id, String title, {bool done = false}) {
    final now = DateTime.now().toUtc().toIso8601String();
    return SubTaskItem(
      id: id,
      todoId: 'todo-1',
      title: title,
      isCompleted: done,
      createdAt: now,
      updatedAt: now,
    );
  }

  setUp(() async {
    todo =
        buildTodo(
          id: 'todo-1',
          title: 'Write the report',
          description: 'The quarterly one',
        ).copyWith(
          subTasks: [
            buildSubTask('sub-1', 'Collect the numbers'),
            buildSubTask('sub-2', 'Draw the chart', done: true),
          ],
        );
    todoRepository = _FakeTodoRepository([todo]);
    timeSegmentRepository = _FakeTimeSegmentRepository(
      running: buildSegment(
        id: 'seg-1',
        todoId: 'todo-1',
        start: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
    );
    SharedPreferences.setMockInitialValues(const {});
    prefs = await SharedPreferences.getInstance();
  });

  Future<void> pumpFocus(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          todoRepositoryProvider.overrideWithValue(todoRepository),
          timeSegmentRepositoryProvider.overrideWithValue(
            timeSegmentRepository,
          ),
          // A fixed live time keeps the once-a-second ticker out of the test.
          liveTimerProvider.overrideWith(
            (ref, todoId) => Stream<int>.value(300),
          ),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: FocusScreen(todoId: 'todo-1'),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
  }

  testWidgets('shows the task, its description and the running label', (
    tester,
  ) async {
    await pumpFocus(tester);

    expect(find.text('Write the report'), findsOneWidget);
    expect(find.text('The quarterly one'), findsOneWidget);
    expect(find.text(testL10n.focusRunningNow), findsOneWidget);
  });

  testWidgets('shows the steps with their progress', (tester) async {
    await pumpFocus(tester);

    expect(find.text(testL10n.focusSteps), findsOneWidget);
    expect(find.text('1/2'), findsOneWidget);
    expect(find.text('Collect the numbers'), findsOneWidget);
    expect(find.text('Draw the chart'), findsOneWidget);
  });

  testWidgets('ticking a step writes through the repository', (tester) async {
    await pumpFocus(tester);

    await tester.ensureVisible(find.text('Collect the numbers'));
    await tester.pump();
    await tester.tap(find.text('Collect the numbers'));
    await tester.pump();
    await tester.pump();

    expect(todoRepository.toggledSubTaskIds, ['sub-1']);
  });

  testWidgets('offers pause and stop while the timer runs', (tester) async {
    await pumpFocus(tester);

    expect(find.text(testL10n.pauseTimer), findsOneWidget);
    expect(find.text(testL10n.stopTimer), findsOneWidget);
    expect(find.text(testL10n.startTimer), findsNothing);
  });

  testWidgets('offers start when no timer is running', (tester) async {
    timeSegmentRepository.running = null;

    await pumpFocus(tester);

    expect(find.text(testL10n.startTimer), findsOneWidget);
    expect(find.text(testL10n.pauseTimer), findsNothing);
  });

  testWidgets('a past day is read only', (tester) async {
    todoRepository = _FakeTodoRepository([
      todo.copyWith(date: dateOffsetIso(-3)),
    ]);
    timeSegmentRepository.running = null;

    await pumpFocus(tester);

    expect(find.text(testL10n.startTimer), findsNothing);
    final checkbox = tester.widget<CheckboxListTile>(
      find.byType(CheckboxListTile).first,
    );
    expect(checkbox.onChanged, isNull);
  });

  testWidgets('a missing task says so instead of crashing', (tester) async {
    todoRepository = _FakeTodoRepository([]);

    await pumpFocus(tester);

    expect(find.text(testL10n.errorTodoNotFound), findsOneWidget);
  });
}
