import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sreerajp_todo/data/models/todo_entity.dart';
import 'package:sreerajp_todo/data/models/todo_status.dart';

part 'daily_todo_state.freezed.dart';

@freezed
class DailyTodoState with _$DailyTodoState {
  const factory DailyTodoState({
    @Default([]) List<TodoEntity> todos,
    @Default(false) bool isLoading,
    String? error,
    @Default([]) List<UndoEntry> undoStack,
    @Default({}) Set<String> selectedIds,
    @Default(false) bool isMultiSelectMode,
  }) = _DailyTodoState;
}

@freezed
class UndoEntry with _$UndoEntry {
  const factory UndoEntry({
    required String todoId,
    required TodoStatus oldStatus,
    required TodoStatus newStatus,
    String? copiedTodoId,
    String? sourceDate,
    String? targetDate,
    // Set for a move, so undo can put the todo back on every day it covered.
    // `previousSourceDate` may be null, so `isMove` marks the entry as a move.
    @Default(false) bool isMove,
    String? previousSourceDate,
    required DateTime timestamp,
  }) = _UndoEntry;
}
