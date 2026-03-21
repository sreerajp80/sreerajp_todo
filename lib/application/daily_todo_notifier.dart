import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sreerajp_todo/application/daily_todo_state.dart';
import 'package:sreerajp_todo/core/constants/app_constants.dart';
import 'package:sreerajp_todo/core/errors/exceptions.dart';
import 'package:sreerajp_todo/data/models/todo_entity.dart';
import 'package:sreerajp_todo/data/models/todo_status.dart';
import 'package:sreerajp_todo/domain/repositories/todo_repository.dart';
import 'package:sreerajp_todo/domain/usecases/copy_todos.dart';
import 'package:sreerajp_todo/domain/usecases/mark_todo_completed.dart';
import 'package:sreerajp_todo/domain/usecases/mark_todo_dropped.dart';
import 'package:sreerajp_todo/domain/usecases/port_todo.dart';

class DailyTodoNotifier extends StateNotifier<DailyTodoState> {
  DailyTodoNotifier({
    required this.date,
    required TodoRepository todoRepository,
    required MarkTodoCompleted markTodoCompleted,
    required MarkTodoDropped markTodoDropped,
    required PortTodo portTodo,
    required CopyTodos copyTodos,
  })  : _todoRepository = todoRepository,
        _markTodoCompleted = markTodoCompleted,
        _markTodoDropped = markTodoDropped,
        _portTodo = portTodo,
        _copyTodos = copyTodos,
        super(const DailyTodoState()) {
    loadTodos();
  }

  final String date;
  final TodoRepository _todoRepository;
  final MarkTodoCompleted _markTodoCompleted;
  final MarkTodoDropped _markTodoDropped;
  final PortTodo _portTodo;
  final CopyTodos _copyTodos;

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
      final todos = await _todoRepository.getTodosByDate(date);
      state = state.copyWith(todos: todos, isLoading: false);
    } on Exception catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> createTodo(TodoEntity todo) async {
    try {
      await _todoRepository.createTodo(todo);
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
      await _todoRepository.updateTodo(todo);
      await loadTodos();
    } on DuplicateTitleException {
      rethrow;
    } on DayLockedException {
      rethrow;
    } on Exception catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteTodo(String id) async {
    try {
      await _todoRepository.deleteTodo(id);
      await loadTodos();
    } on DayLockedException {
      rethrow;
    } on Exception catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> markCompleted(String todoId) async {
    try {
      final oldStatus = await _markTodoCompleted(todoId);
      _pushUndo(UndoEntry(
        todoId: todoId,
        oldStatus: oldStatus,
        newStatus: TodoStatus.completed,
        timestamp: DateTime.now(),
      ));
      await loadTodos();
    } on Exception catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> markDropped(String todoId) async {
    try {
      final oldStatus = await _markTodoDropped(todoId);
      _pushUndo(UndoEntry(
        todoId: todoId,
        oldStatus: oldStatus,
        newStatus: TodoStatus.dropped,
        timestamp: DateTime.now(),
      ));
      await loadTodos();
    } on Exception catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> portTodo(String todoId, String targetDate) async {
    try {
      final result = await _portTodo(todoId, targetDate);
      _pushUndo(UndoEntry(
        todoId: todoId,
        oldStatus: result.oldStatus,
        newStatus: TodoStatus.ported,
        copiedTodoId: result.copiedTodoId,
        timestamp: DateTime.now(),
      ));
      await loadTodos();
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
    return _copyTodos(todoIds, targetDate);
  }

  Future<void> bulkMarkCompleted(Set<String> ids) async {
    try {
      for (final id in ids) {
        final oldStatus = await _markTodoCompleted(id);
        _pushUndo(UndoEntry(
          todoId: id,
          oldStatus: oldStatus,
          newStatus: TodoStatus.completed,
          timestamp: DateTime.now(),
        ));
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
        final oldStatus = await _markTodoDropped(id);
        _pushUndo(UndoEntry(
          todoId: id,
          oldStatus: oldStatus,
          newStatus: TodoStatus.dropped,
          timestamp: DateTime.now(),
        ));
      }
      clearSelection();
      await loadTodos();
    } on Exception catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> undoLastStatusChange() async {
    if (state.undoStack.isEmpty) return;

    final entry = state.undoStack.last;
    final newStack = state.undoStack.sublist(0, state.undoStack.length - 1);
    state = state.copyWith(undoStack: newStack);

    try {
      if (entry.copiedTodoId != null) {
        await _todoRepository.deleteTodo(
          entry.copiedTodoId!,
          bypassLock: true,
        );
      }

      await _todoRepository.updateStatus(
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
      await _todoRepository.reorderTodos(reordered);
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
    state = state.copyWith(
      selectedIds: ids,
      isMultiSelectMode: ids.isNotEmpty,
    );
  }

  void selectAll() {
    final ids = state.todos.map((t) => t.id).toSet();
    state = state.copyWith(selectedIds: ids, isMultiSelectMode: true);
  }

  void clearSelection() {
    state = state.copyWith(
      selectedIds: {},
      isMultiSelectMode: false,
    );
  }
}
