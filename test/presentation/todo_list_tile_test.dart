import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_todo/application/providers.dart';
import 'package:sreerajp_todo/core/constants/app_strings.dart';
import 'package:sreerajp_todo/data/models/time_segment_entity.dart';
import 'package:sreerajp_todo/data/models/todo_entity.dart';
import 'package:sreerajp_todo/data/models/todo_status.dart';
import 'package:sreerajp_todo/domain/repositories/time_segment_repository.dart';
import 'package:sreerajp_todo/domain/repositories/todo_repository.dart';
import 'package:sreerajp_todo/domain/usecases/start_time_segment.dart';
import 'package:sreerajp_todo/presentation/screens/daily_list/widgets/todo_list_tile.dart';

import '../helpers/test_fixtures.dart';

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
  Future<List<String>> getAutocompleteSuggestions(String prefix) async =>
      const [];

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

class _FakeTimeSegmentRepository implements TimeSegmentRepository {
  @override
  Future<List<TimeSegmentEntity>> getSegments(String todoId) async => const [];

  @override
  Future<TimeSegmentEntity?> getRunningSegment(String todoId) async => null;

  @override
  Future<void> insertManualSegment(TimeSegmentEntity segment) async {}

  @override
  Future<void> repairOrphanedSegments(String todayDate) async {}

  @override
  Future<void> startSegment(String todoId) async {}

  @override
  Future<void> stopSegment(String todoId) async {}
}

void main() {
  late TodoEntity todo;
  late _FakeTodoRepository todoRepository;
  late _FakeTimeSegmentRepository timeSegmentRepository;

  setUp(() {
    todo = buildTodo(id: 'todo-1', title: 'Locked task');
    todoRepository = _FakeTodoRepository([todo]);
    timeSegmentRepository = _FakeTimeSegmentRepository();
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
          todoRepositoryProvider.overrideWithValue(todoRepository),
          timeSegmentRepositoryProvider.overrideWithValue(
            timeSegmentRepository,
          ),
          startTimeSegmentProvider.overrideWithValue(
            StartTimeSegment(todoRepository, timeSegmentRepository),
          ),
        ],
        child: MaterialApp(
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
    expect(
      find.bySemanticsLabel(AppStrings.completeAction),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel(AppStrings.dropAction), findsOneWidget);
    expect(find.bySemanticsLabel(AppStrings.startTimer), findsOneWidget);

    await tester.tap(find.bySemanticsLabel(AppStrings.completeAction));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel(AppStrings.dropAction));
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
      final inkWells = tester.widgetList<InkWell>(find.byType(InkWell)).toList();
      final mainInkWell = inkWells.firstWhere(
        (iw) => iw.onTap != null && iw.onLongPress == null,
      );
      expect(mainInkWell.onLongPress, isNull);
      expect(editCalls, 1);
      expect(longPressCalls, 0);
      // No compact action buttons for past days
      expect(find.byIcon(Icons.check_circle_outline), findsNothing);
      expect(find.byTooltip(AppStrings.openTaskActions), findsNothing);
      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    },
  );
}
