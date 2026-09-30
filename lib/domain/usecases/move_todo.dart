import 'package:sreerajp_todo/core/errors/exceptions.dart';
import 'package:sreerajp_todo/core/utils/date_utils.dart';
import 'package:sreerajp_todo/core/utils/unicode_utils.dart';
import 'package:sreerajp_todo/domain/repositories/time_segment_repository.dart';
import 'package:sreerajp_todo/domain/repositories/todo_repository.dart';

class MoveTodoResult {
  const MoveTodoResult({
    required this.todoId,
    required this.fromDate,
    required this.toDate,
    this.detached = false,
    this.previousSourceDate,
  });

  final String todoId;
  final String fromDate;
  final String toDate;
  final bool detached;

  /// The todo's start date before the move, so undo can put it back.
  final String? previousSourceDate;
}

class MoveTodo {
  MoveTodo(this._todoRepository, this._timeSegmentRepository);

  final TodoRepository _todoRepository;
  final TimeSegmentRepository _timeSegmentRepository;

  /// Moves a todo to [targetDate].
  ///
  /// Throws [DayLockedException] when [targetDate] is before today. Undo uses
  /// `UndoMoveTodo` instead, which may go back to a past day.
  ///
  /// 1. Stops any running timer on the todo.
  /// 2. Updates the todo's date to [targetDate].
  /// 3. Records a move event in the task's history log.
  ///
  /// Set [detach] for an explicit move, so the todo no longer shows on its
  /// old date. Leave it false for carry-over.
  Future<MoveTodoResult> call(
    String todoId,
    String targetDate, {
    bool detach = false,
  }) async {
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
        detached: detach,
        previousSourceDate: todo.sourceDate,
      );
    }

    if (isPastDate(targetDate)) {
      throw const DayLockedException(
        'Cannot move a task to a day in the past.',
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

    await _todoRepository.moveTodo(todoId, targetDate, detach: detach);

    return MoveTodoResult(
      todoId: todoId,
      fromDate: fromDate,
      toDate: targetDate,
      detached: detach,
      previousSourceDate: todo.sourceDate,
    );
  }
}
