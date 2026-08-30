import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sreerajp_todo/core/constants/app_constants.dart';
import 'package:sreerajp_todo/application/providers.dart';
import 'package:sreerajp_todo/data/models/time_segment_entity.dart';
import 'package:sreerajp_todo/data/models/todo_entity.dart';
import 'package:sreerajp_todo/data/models/todo_history_entity.dart';
import 'package:sreerajp_todo/data/models/todo_search_result.dart';
import 'package:sreerajp_todo/data/models/todo_status.dart';
import 'package:sreerajp_todo/domain/repositories/time_segment_repository.dart';
import 'package:sreerajp_todo/domain/repositories/todo_repository.dart';
import 'package:sreerajp_todo/domain/usecases/start_time_segment.dart';
import 'package:sreerajp_todo/l10n/app_localizations.dart';
import 'package:sreerajp_todo/presentation/screens/daily_list/widgets/todo_list_tile.dart';

import '../helpers/test_fixtures.dart';
import '../helpers/test_l10n.dart';

class _FakeTodoRepository implements TodoRepository {
  _FakeTodoRepository(this._todos);

  final List<TodoEntity> _todos;

  @override
  Future<void> createTodo(TodoEntity todo) async {
    _todos.add(todo);
  }

  @override
  Future<void> deleteTodo(String id, {bool bypassLock = false}) async {
    _todos.removeWhere((todo) => todo.id == id);
  }

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
  }) async =>
      _todos.where((todo) => todo.title.contains(query)).take(limit).toList();

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
  @override
  Future<List<TimeSegmentEntity>> getSegments(String todoId) async => const [];

  @override
  Future<TimeSegmentEntity?> getRunningSegment(String todoId) async => null;

  @override
  Future<void> insertManualSegment(TimeSegmentEntity segment) async {}

  @override
  Future<void> updateSegmentNotes(String segmentId, String? notes) async {}

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
  Future<List<TimeSegmentEntity>> getAllRunningSegments() async => const [];

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

  setUp(() async {
    todo = buildTodo(id: 'todo-1', title: 'Locked task');
    todoRepository = _FakeTodoRepository([todo]);
    timeSegmentRepository = _FakeTimeSegmentRepository();
    SharedPreferences.setMockInitialValues(const {});
    prefs = await SharedPreferences.getInstance();
  });

  Future<void> pumpTile(
    WidgetTester tester, {
    required bool isPast,
    required VoidCallback onEdit,
    required VoidCallback onLongPress,
    VoidCallback? onComplete,
    VoidCallback? onDrop,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          todoRepositoryProvider.overrideWithValue(todoRepository),
          timeSegmentRepositoryProvider.overrideWithValue(
            timeSegmentRepository,
          ),
          startTimeSegmentProvider.overrideWithValue(
            StartTimeSegment(todoRepository, timeSegmentRepository),
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: TodoListTile(
              todo: todo,
              isPast: isPast,
              isSelected: false,
              isMultiSelectMode: false,
              onTap: () {},
              onLongPress: onLongPress,
              onComplete: onComplete ?? () {},
              onDrop: onDrop ?? () {},
              onPort: () {},
              onCopy: () {},
              onEdit: onEdit,
              onDelete: () {},
              onViewSegments: () {},
              animationIndex: 0,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('current-day todo opens edit on tap', (tester) async {
    var editCalls = 0;

    await pumpTile(
      tester,
      isPast: false,
      onEdit: () => editCalls++,
      onLongPress: () {},
    );

    await tester.tap(find.text(todo.title));
    await tester.pumpAndSettle();

    expect(editCalls, 1);
  });

  testWidgets('current-day todo shows quick task strip actions', (
    tester,
  ) async {
    var completeCalls = 0;
    var dropCalls = 0;

    await pumpTile(
      tester,
      isPast: false,
      onEdit: () {},
      onLongPress: () {},
      onComplete: () => completeCalls++,
      onDrop: () => dropCalls++,
    );

    // Compact icon-only action buttons (complete, drop, play/stop)
    expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
    expect(find.byIcon(Icons.cancel_outlined), findsOneWidget);
    expect(find.byIcon(Icons.play_circle_fill_rounded), findsOneWidget);
    expect(find.bySemanticsLabel(testL10n.completeAction), findsOneWidget);
    expect(find.bySemanticsLabel(testL10n.dropAction), findsOneWidget);
    expect(find.bySemanticsLabel(testL10n.startTimer), findsOneWidget);

    await tester.tap(find.bySemanticsLabel(testL10n.completeAction));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel(testL10n.dropAction));
    await tester.pumpAndSettle();

    expect(completeCalls, 1);
    expect(dropCalls, 1);
  });

  testWidgets(
    'past-day todo opens read-only details on tap and disables long press',
    (tester) async {
      var editCalls = 0;
      var longPressCalls = 0;

      await pumpTile(
        tester,
        isPast: true,
        onEdit: () => editCalls++,
        onLongPress: () => longPressCalls++,
      );

      await tester.tap(find.text(todo.title));
      await tester.pumpAndSettle();

      // The main tile InkWell should have onLongPress disabled for past days
      final inkWells = tester
          .widgetList<InkWell>(find.byType(InkWell))
          .toList();
      final mainInkWell = inkWells.firstWhere(
        (iw) => iw.onTap != null && iw.onLongPress == null,
      );
      expect(mainInkWell.onLongPress, isNull);
      expect(editCalls, 1);
      expect(longPressCalls, 0);
      // No compact action buttons for past days
      expect(find.byIcon(Icons.check_circle_outline), findsNothing);
      expect(find.byTooltip(testL10n.openTaskActions), findsNothing);
      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    },
  );
}
