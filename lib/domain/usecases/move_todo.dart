import 'package:sreerajp_todo/core/errors/exceptions.dart';
import 'package:sreerajp_todo/core/utils/unicode_utils.dart';
import 'package:sreerajp_todo/domain/repositories/time_segment_repository.dart';
import 'package:sreerajp_todo/domain/repositories/todo_repository.dart';

class MoveTodoResult {
  const MoveTodoResult({
    required this.todoId,
    required this.fromDate,
    required this.toDate,
  });

  final String todoId;
  final String fromDate;
  final String toDate;
}

class MoveTodo {
  MoveTodo(this._todoRepository, this._timeSegmentRepository);

  final TodoRepository _todoRepository;
  final TimeSegmentRepository _timeSegmentRepository;

  /// Moves a todo to [targetDate].
  ///
  /// 1. Stops any running timer on the todo.
  /// 2. Updates the todo's date to [targetDate].
  /// 3. Records a move event in the task's history log.
  Future<MoveTodoResult> call(String todoId, String targetDate) async {
    final todo = await _todoRepository.getTodoById(todoId);
    if (todo == null) {
      throw const TodoNotFoundException();
    }

    final fromDate = todo.date;
    if (fromDate == targetDate) {
      return MoveTodoResult(
        todoId: todoId,
        fromDate: fromDate,
        toDate: targetDate,
      );
    }

    final normalizedTitle = nfcNormalize(todo.title);
    if (await _todoRepository.titleExistsOnDate(
      normalizedTitle,
      targetDate,
      excludeId: todoId,
    )) {
      throw const DuplicateTitleException();
    }

    final running = await _timeSegmentRepository.getRunningSegment(todoId);
    if (running != null) {
      await _timeSegmentRepository.stopSegment(todoId);
    }

    await _todoRepository.moveTodo(todoId, targetDate);

    return MoveTodoResult(
      todoId: todoId,
      fromDate: fromDate,
      toDate: targetDate,
    );
  }
}
