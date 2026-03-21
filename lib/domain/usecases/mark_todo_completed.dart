import 'package:sreerajp_todo/data/models/todo_status.dart';
import 'package:sreerajp_todo/domain/repositories/time_segment_repository.dart';
import 'package:sreerajp_todo/domain/repositories/todo_repository.dart';

class MarkTodoCompleted {
  MarkTodoCompleted(this._todoRepository, this._timeSegmentRepository);

  final TodoRepository _todoRepository;
  final TimeSegmentRepository _timeSegmentRepository;

  /// Closes any running time segment, then sets status to completed.
  /// Returns the previous [TodoStatus] for undo support.
  Future<TodoStatus> call(String todoId) async {
    final todo = await _todoRepository.getTodoById(todoId);
    if (todo == null) {
      throw StateError('Todo not found: $todoId');
    }

    final oldStatus = todo.status;

    final running = await _timeSegmentRepository.getRunningSegment(todoId);
    if (running != null) {
      await _timeSegmentRepository.stopSegment(todoId);
    }

    await _todoRepository.updateStatus(todoId, TodoStatus.completed);
    return oldStatus;
  }
}
