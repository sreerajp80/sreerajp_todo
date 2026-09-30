import 'package:sreerajp_todo/core/errors/exceptions.dart';
import 'package:sreerajp_todo/domain/repositories/time_segment_repository.dart';
import 'package:sreerajp_todo/domain/repositories/todo_repository.dart';

class UndoMoveTodo {
  UndoMoveTodo(this._todoRepository, this._timeSegmentRepository);

  final TodoRepository _todoRepository;
  final TimeSegmentRepository _timeSegmentRepository;

  /// Puts a moved todo back exactly where it was before the move.
  ///
  /// Restores both [originalDate] and [originalSourceDate], so a multi-day
  /// task shows again on every day it covered. Unlike a normal move, this may
  /// go back to a past day, because it only reverses the user's last move.
  ///
  /// Throws [TodoNotFoundException] if the todo does not exist.
  /// Throws [DuplicateTitleException] if [originalDate] now has a todo with
  /// the same title.
  Future<void> call({
    required String todoId,
    required String originalDate,
    required String? originalSourceDate,
  }) async {
    final todo = await _todoRepository.getTodoById(todoId);
    if (todo == null) {
      throw const TodoNotFoundException();
    }

    final running = await _timeSegmentRepository.getRunningSegment(todoId);
    if (running != null) {
      await _timeSegmentRepository.stopSegment(todoId);
    }

    await _todoRepository.restoreMove(
      todoId,
      originalDate: originalDate,
      originalSourceDate: originalSourceDate,
    );
  }
}
