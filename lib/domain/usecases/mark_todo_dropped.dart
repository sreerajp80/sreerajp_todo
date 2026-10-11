import 'package:sreerajp_todo/core/errors/exceptions.dart';
import 'package:sreerajp_todo/domain/entities/todo_status.dart';
import 'package:sreerajp_todo/domain/repositories/time_segment_repository.dart';
import 'package:sreerajp_todo/domain/repositories/todo_repository.dart';

class MarkTodoDropped {
  MarkTodoDropped(this._todoRepository, this._timeSegmentRepository);

  final TodoRepository _todoRepository;
  final TimeSegmentRepository _timeSegmentRepository;

  /// Closes any running time segment, then sets status to dropped.
  /// Returns the previous [TodoStatus] for undo support.
  Future<TodoStatus> call(String todoId) async {
    final todo = await _todoRepository.getTodoById(todoId);
    if (todo == null) {
      throw const TodoNotFoundException();
    }

    final oldStatus = todo.status;

    final running = await _timeSegmentRepository.getRunningSegment(todoId);
    if (running != null) {
      await _timeSegmentRepository.stopSegment(todoId);
    }

    await _todoRepository.updateStatus(todoId, TodoStatus.dropped);
    return oldStatus;
  }
}
