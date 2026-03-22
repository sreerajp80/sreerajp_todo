import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_todo/application/providers.dart';
import 'package:sreerajp_todo/core/constants/app_constants.dart';
import 'package:sreerajp_todo/core/constants/app_strings.dart';
import 'package:sreerajp_todo/data/models/time_segment_entity.dart';
import 'package:sreerajp_todo/data/models/todo_entity.dart';
import 'package:sreerajp_todo/data/models/todo_status.dart';
import 'package:sreerajp_todo/domain/repositories/time_segment_repository.dart';
import 'package:sreerajp_todo/domain/repositories/todo_repository.dart';
import 'package:sreerajp_todo/domain/usecases/copy_todos.dart';
import 'package:sreerajp_todo/domain/usecases/mark_todo_completed.dart';
import 'package:sreerajp_todo/domain/usecases/mark_todo_dropped.dart';
import 'package:sreerajp_todo/domain/usecases/port_todo.dart';
import 'package:sreerajp_todo/domain/usecases/start_time_segment.dart';
import 'package:sreerajp_todo/presentation/screens/daily_list/daily_list_screen.dart';
import 'package:sreerajp_todo/presentation/shared/widgets/undo_status_snackbar.dart';

import '../helpers/test_fixtures.dart';

class InMemoryTodoRepository implements TodoRepository {
  InMemoryTodoRepository(List<TodoEntity> initialTodos)
    : _todos = [...initialTodos];

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
  Future<List<TodoEntity>> getTodosByDate(String date) async {
    final todos = _todos.where((todo) => todo.date == date).toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return todos;
  }

  @override
  Future<void> reorderTodos(
    List<TodoEntity> todos, {
    bool bypassLock = false,
  }) async {
    for (final todo in todos) {
      final index = _todos.indexWhere((item) => item.id == todo.id);
      if (index >= 0) {
        _todos[index] = todo;
      }
    }
  }

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
  }) async {
    return _todos.any(
      (todo) =>
          todo.date == date && todo.title == title && todo.id != excludeId,
    );
  }

  @override
  Future<void> updateStatus(
    String id,
    TodoStatus status, {
    String? portedTo,
    bool bypassLock = false,
  }) async {
    final index = _todos.indexWhere((todo) => todo.id == id);
    if (index < 0) {
      return;
    }
    _todos[index] = _todos[index].copyWith(
      status: status,
      portedTo: portedTo,
      updatedAt: DateTime.now().toUtc().toIso8601String(),
    );
  }

  @override
  Future<void> updateTodo(TodoEntity todo, {bool bypassLock = false}) async {
    final index = _todos.indexWhere((item) => item.id == todo.id);
    if (index >= 0) {
      _todos[index] = todo;
    }
  }
}

class FakeTimeSegmentRepository implements TimeSegmentRepository {
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

class _UndoSnackBarHarness extends StatelessWidget {
  const _UndoSnackBarHarness({required this.onUndo});

  final VoidCallback onUndo;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MediaQuery(
        data: const MediaQueryData(accessibleNavigation: false),
        child: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: TextButton(
                onPressed: () {
                  showUndoSnackBar(
                    context,
                    message: 'Undo status test',
                    onUndo: onUndo,
                  );
                },
                child: const Text('Show'),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  late InMemoryTodoRepository todoRepository;
  late FakeTimeSegmentRepository timeSegmentRepository;
  late String date;
  late TodoEntity todo;

  setUp(() {
    date = dateOffsetIso(0);
    todo = buildTodo(id: 'todo-1', date: date, title: 'Undo task');
    todoRepository = InMemoryTodoRepository([todo]);
    timeSegmentRepository = FakeTimeSegmentRepository();
  });

  Future<void> pumpDailyList(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          todoRepositoryProvider.overrideWithValue(todoRepository),
          timeSegmentRepositoryProvider.overrideWithValue(
            timeSegmentRepository,
          ),
          markTodoCompletedProvider.overrideWithValue(
            MarkTodoCompleted(todoRepository, timeSegmentRepository),
          ),
          markTodoDroppedProvider.overrideWithValue(
            MarkTodoDropped(todoRepository, timeSegmentRepository),
          ),
          portTodoProvider.overrideWithValue(
            PortTodo(todoRepository, timeSegmentRepository),
          ),
          copyTodosProvider.overrideWithValue(CopyTodos(todoRepository)),
          startTimeSegmentProvider.overrideWithValue(
            StartTimeSegment(todoRepository, timeSegmentRepository),
          ),
        ],
        child: MaterialApp(home: DailyListScreen(date: date)),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> markTodoCompletedFromMenu(WidgetTester tester) async {
    await tester.tap(find.byTooltip(AppStrings.openTaskActions));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppStrings.statusCompleted).last);
    await tester.pumpAndSettle();
  }

  testWidgets('shows a snackbar after a status change', (tester) async {
    await pumpDailyList(tester);

    await markTodoCompletedFromMenu(tester);

    expect(
      find.text('${AppStrings.statusChangedTo} ${AppStrings.statusCompleted}'),
      findsOneWidget,
    );
  });

  testWidgets('tapping Undo reverts the status', (tester) async {
    await pumpDailyList(tester);

    await markTodoCompletedFromMenu(tester);
    await tester.tap(find.text(AppStrings.undo));
    await tester.pumpAndSettle();

    final restored = await todoRepository.getTodoById(todo.id);
    expect(restored?.status, TodoStatus.pending);
    expect(find.text(AppStrings.statusPending), findsOneWidget);
  });

  testWidgets('snackbar auto-dismisses after the configured timeout', (
    tester,
  ) async {
    var undoCalls = 0;

    await tester.pumpWidget(_UndoSnackBarHarness(onUndo: () => undoCalls++));

    await tester.tap(find.text('Show'));
    await tester.pump();

    expect(find.text('Undo status test'), findsOneWidget);

    final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
    expect(snackBar.duration, const Duration(seconds: kUndoTimeoutSeconds));
    expect(undoCalls, 0);
  });

  testWidgets('persistent undo button is visible when the stack is not empty', (
    tester,
  ) async {
    await pumpDailyList(tester);

    await markTodoCompletedFromMenu(tester);

    expect(find.byIcon(Icons.undo), findsOneWidget);
  });
}
