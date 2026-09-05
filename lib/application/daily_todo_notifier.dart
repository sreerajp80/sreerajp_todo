import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sreerajp_todo/application/daily_todo_state.dart';
import 'package:sreerajp_todo/core/constants/app_constants.dart';
import 'package:sreerajp_todo/core/errors/exceptions.dart';
import 'package:sreerajp_todo/data/models/recall_confidence.dart';
import 'package:sreerajp_todo/data/models/todo_entity.dart';
import 'package:sreerajp_todo/data/models/todo_status.dart';
import 'package:sreerajp_todo/domain/repositories/todo_repository.dart';
import 'package:sreerajp_todo/domain/usecases/complete_srs_todo.dart';
import 'package:sreerajp_todo/domain/usecases/copy_todos.dart';
import 'package:sreerajp_todo/domain/usecases/delete_recurring_todos.dart';
import 'package:sreerajp_todo/domain/usecases/mark_todo_completed.dart';
import 'package:sreerajp_todo/domain/usecases/mark_todo_dropped.dart';
import 'package:sreerajp_todo/domain/usecases/move_todo.dart';
import 'package:sreerajp_todo/domain/usecases/port_todo.dart';
import 'package:sreerajp_todo/domain/usecases/reopen_todo.dart';

class DailyTodoNotifier extends StateNotifier<DailyTodoState> {
  DailyTodoNotifier({
    required this.date,
    required this.todoRepository,
    required this.markTodoCompleted,
    required this.markTodoDropped,
    required this.portTodoUseCase,
    required this.copyTodosUseCase,
    required this.deleteRecurringTodos,
    MoveTodo? moveTodoUseCase,
    ReopenTodo? reopenTodoUseCase,
    this.onDataChanged,
    this.onTimerStopped,
  }) : moveTodoUseCase =
           moveTodoUseCase ??
           MoveTodo(
             todoRepository,
             // fallback if not directly passed in test
             portTodoUseCase.timeSegmentRepository,
           ),
       reopenTodoUseCase =
           reopenTodoUseCase ??
           ReopenTodo(todoRepository, portTodoUseCase.timeSegmentRepository),
       super(const DailyTodoState()) {
    loadTodos();
  }

  final String date;
  final TodoRepository todoRepository;
  final MarkTodoCompleted markTodoCompleted;
  final MarkTodoDropped markTodoDropped;
  final PortTodo portTodoUseCase;
  final CopyTodos copyTodosUseCase;
  final DeleteRecurringTodos deleteRecurringTodos;
  final MoveTodo moveTodoUseCase;
  final ReopenTodo reopenTodoUseCase;
  final void Function()? onDataChanged;
  final void Function(String todoId)? onTimerStopped;

  Timer? _undoInactivityTimer;

  @override
  void dispose() {
    _undoInactivityTimer?.cancel();
    super.dispose();
  }

  void _resetInactivityTimer() {
    _undoInactivityTimer?.cancel();
    _undoInactivityTimer = Timer(
      const Duration(minutes: kUndoInactivityClearMinutes),
      () {
        if (mounted) {
          state = state.copyWith(undoStack: []);
        }
      },
    );
  }

  void _pushUndo(UndoEntry entry) {
    var stack = [...state.undoStack, entry];
    if (stack.length > kUndoStackSize) {
      stack = stack.sublist(stack.length - kUndoStackSize);
    }
    state = state.copyWith(undoStack: stack);
    _resetInactivityTimer();
  }

  Future<void> loadTodos() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final todos = await todoRepository.getTodosByDate(date);
      state = state.copyWith(todos: todos, isLoading: false);
    } on Exception catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> createTodo(TodoEntity todo) async {
    try {
      await todoRepository.createTodo(todo);
      await loadTodos();
    } on DuplicateTitleException {
      rethrow;
    } on DayLockedException {
      rethrow;
    } on Exception catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateTodo(TodoEntity todo) async {
    try {
      await todoRepository.updateTodo(todo);
      await loadTodos();
    } on DuplicateTitleException {
      rethrow;
    } on DayLockedException {
      rethrow;
    } on Exception catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> toggleSubTask(
    String todoId,
    String subTaskId,
    bool isCompleted,
  ) async {
    try {
      await todoRepository.toggleSubTask(todoId, subTaskId, isCompleted);
      await loadTodos();
    } on DayLockedException {
      rethrow;
    } on Exception catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteTodo(String id) async {
    try {
      await todoRepository.deleteTodo(id, bypassLock: true);
      await loadTodos();
      onDataChanged?.call();
    } on Exception catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<int> deleteAllByRecurrenceRuleId(String recurrenceRuleId) async {
    try {
      final count = await deleteRecurringTodos.all(recurrenceRuleId);
      await loadTodos();
      onDataChanged?.call();
      return count;
    } on Exception catch (e) {
      state = state.copyWith(error: e.toString());
      return 0;
    }
  }

  Future<int> deleteFutureByRecurrenceRuleId(String recurrenceRuleId) async {
    try {
      final count = await deleteRecurringTodos.thisAndFuture(recurrenceRuleId);
      await loadTodos();
      onDataChanged?.call();
      return count;
    } on Exception catch (e) {
      state = state.copyWith(error: e.toString());
      return 0;
    }
  }

  Future<void> markCompleted(String todoId) async {
    try {
      final oldStatus = await markTodoCompleted(todoId);
      onTimerStopped?.call(todoId);
      _pushUndo(
        UndoEntry(
          todoId: todoId,
          oldStatus: oldStatus,
          newStatus: TodoStatus.completed,
          timestamp: DateTime.now(),
        ),
      );
      await loadTodos();
    } on Exception catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> markSrsCompleted(
    String todoId,
    RecallConfidence confidence,
    CompleteSrsTodo completeSrsTodo,
  ) async {
    try {
      final oldStatus = await completeSrsTodo(todoId, confidence);
      onTimerStopped?.call(todoId);
      _pushUndo(
        UndoEntry(
          todoId: todoId,
          oldStatus: oldStatus,
          newStatus: TodoStatus.completed,
          timestamp: DateTime.now(),
        ),
      );
      await loadTodos();
    } on Exception catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> markDropped(String todoId) async {
    try {
      final oldStatus = await markTodoDropped(todoId);
      onTimerStopped?.call(todoId);
      _pushUndo(
        UndoEntry(
          todoId: todoId,
          oldStatus: oldStatus,
          newStatus: TodoStatus.dropped,
          timestamp: DateTime.now(),
        ),
      );
      await loadTodos();
    } on Exception catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> reopenTodo(String todoId) async {
    try {
      final oldStatus = await reopenTodoUseCase(todoId);
      final todo = await todoRepository.getTodoById(todoId);
      final newStatus = todo?.status ?? TodoStatus.pending;
      _pushUndo(
        UndoEntry(
          todoId: todoId,
          oldStatus: oldStatus,
          newStatus: newStatus,
          timestamp: DateTime.now(),
        ),
      );
      await loadTodos();
    } on DayLockedException {
      rethrow;
    } on Exception catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> portTodo(String todoId, String targetDate) async {
    await moveTodo(todoId, targetDate);
  }

  Future<void> moveTodo(String todoId, String targetDate) async {
    try {
      final todo = await todoRepository.getTodoById(todoId);
      final oldStatus = todo?.status ?? TodoStatus.pending;

      final result = await moveTodoUseCase(todoId, targetDate);
      _pushUndo(
        UndoEntry(
          todoId: todoId,
          oldStatus: oldStatus,
          newStatus: TodoStatus.pending,
          sourceDate: result.fromDate,
          targetDate: result.toDate,
          timestamp: DateTime.now(),
        ),
      );
      await loadTodos();
      onDataChanged?.call();
    } on DuplicateTitleException {
      rethrow;
    } on DayLockedException {
      rethrow;
    } on Exception catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<CopyTodosResult> copyTodos(
    List<String> todoIds,
    String targetDate,
  ) async {
    return copyTodosUseCase(todoIds, targetDate);
  }

  Future<void> bulkMarkCompleted(Set<String> ids) async {
    try {
      for (final id in ids) {
        final oldStatus = await markTodoCompleted(id);
        onTimerStopped?.call(id);
        _pushUndo(
          UndoEntry(
            todoId: id,
            oldStatus: oldStatus,
            newStatus: TodoStatus.completed,
            timestamp: DateTime.now(),
          ),
        );
      }
      clearSelection();
      await loadTodos();
    } on Exception catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> bulkMarkDropped(Set<String> ids) async {
    try {
      for (final id in ids) {
        final oldStatus = await markTodoDropped(id);
        onTimerStopped?.call(id);
        _pushUndo(
          UndoEntry(
            todoId: id,
            oldStatus: oldStatus,
            newStatus: TodoStatus.dropped,
            timestamp: DateTime.now(),
          ),
        );
      }
      clearSelection();
      await loadTodos();
    } on Exception catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> bulkReopen(Set<String> ids) async {
    try {
      for (final id in ids) {
        final oldStatus = await reopenTodoUseCase(id);
        final todo = await todoRepository.getTodoById(id);
        final newStatus = todo?.status ?? TodoStatus.pending;
        _pushUndo(
          UndoEntry(
            todoId: id,
            oldStatus: oldStatus,
            newStatus: newStatus,
            timestamp: DateTime.now(),
          ),
        );
      }
      clearSelection();
      await loadTodos();
    } on DayLockedException {
      rethrow;
    } on Exception catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> undoLastStatusChange() async {
    if (state.undoStack.isEmpty) return;

    final entry = state.undoStack.last;
    final newStack = state.undoStack.sublist(0, state.undoStack.length - 1);
    state = state.copyWith(undoStack: newStack);

    try {
      if (entry.sourceDate != null && entry.targetDate != null) {
        await moveTodoUseCase(entry.todoId, entry.sourceDate!);
        await loadTodos();
        onDataChanged?.call();
        return;
      }

      if (entry.copiedTodoId != null) {
        await todoRepository.deleteTodo(entry.copiedTodoId!, bypassLock: true);
      }

      await todoRepository.updateStatus(
        entry.todoId,
        entry.oldStatus,
        portedTo: null,
      );
      await loadTodos();
    } on Exception catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    var adjustedNewIndex = newIndex;
    if (oldIndex < adjustedNewIndex) {
      adjustedNewIndex -= 1;
    }

    final todos = [...state.todos];
    final item = todos.removeAt(oldIndex);
    todos.insert(adjustedNewIndex, item);

    final reordered = <TodoEntity>[];
    for (var i = 0; i < todos.length; i++) {
      reordered.add(todos[i].copyWith(sortOrder: i));
    }

    state = state.copyWith(todos: reordered);

    try {
      await todoRepository.reorderTodos(reordered);
    } on Exception catch (e) {
      state = state.copyWith(error: e.toString());
      await loadTodos();
    }
  }

  void toggleSelect(String id) {
    final ids = {...state.selectedIds};
    if (ids.contains(id)) {
      ids.remove(id);
    } else {
      ids.add(id);
    }
    state = state.copyWith(selectedIds: ids, isMultiSelectMode: ids.isNotEmpty);
  }

  void selectAll() {
    final ids = state.todos.map((t) => t.id).toSet();
    state = state.copyWith(selectedIds: ids, isMultiSelectMode: true);
  }

  void clearSelection() {
    state = state.copyWith(selectedIds: {}, isMultiSelectMode: false);
  }
}
