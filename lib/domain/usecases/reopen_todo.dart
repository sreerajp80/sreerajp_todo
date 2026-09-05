import 'package:sreerajp_todo/core/errors/exceptions.dart';
import 'package:sreerajp_todo/core/utils/date_utils.dart';
import 'package:sreerajp_todo/data/models/todo_status.dart';
import 'package:sreerajp_todo/domain/repositories/time_segment_repository.dart';
import 'package:sreerajp_todo/domain/repositories/todo_repository.dart';

class ReopenTodo {
  ReopenTodo(this._todoRepository, this._timeSegmentRepository);

  final TodoRepository _todoRepository;
  final TimeSegmentRepository _timeSegmentRepository;

  /// Reopens a completed or dropped todo back to working (if segments exist) or pending.
  /// Throws [DayLockedException] if the todo date is in the past.
  /// Throws [TodoNotFoundException] if the todo does not exist.
  /// Returns the previous [TodoStatus] for undo support.
  Future<TodoStatus> call(String todoId) async {
    final todo = await _todoRepository.getTodoById(todoId);
    if (todo == null) {
      throw const TodoNotFoundException();
    }

    if (isPastDate(todo.date)) {
      throw const DayLockedException();
    }

    final oldStatus = todo.status;
    final segments = await _timeSegmentRepository.getSegments(todoId);
    final newStatus = segments.isNotEmpty
        ? TodoStatus.working
        : TodoStatus.pending;

    await _todoRepository.updateStatus(todoId, newStatus);
    return oldStatus;
  }
}
