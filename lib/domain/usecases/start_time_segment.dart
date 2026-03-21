import 'package:sreerajp_todo/core/errors/exceptions.dart';
import 'package:sreerajp_todo/core/utils/date_utils.dart';
import 'package:sreerajp_todo/data/models/todo_status.dart';
import 'package:sreerajp_todo/domain/repositories/time_segment_repository.dart';
import 'package:sreerajp_todo/domain/repositories/todo_repository.dart';

class StartTimeSegment {
  StartTimeSegment(this._todoRepository, this._timeSegmentRepository);

  final TodoRepository _todoRepository;
  final TimeSegmentRepository _timeSegmentRepository;

  /// Validates all preconditions and starts a new time segment.
  ///
  /// Throws [TodoNotFoundException] if the todo does not exist.
  /// Throws [DayLockedException] if the todo's date is in the past.
  /// Throws [CompletedLockException] if the todo is completed or dropped.
  /// Throws [SegmentAlreadyRunningException] if a segment is already running.
  Future<void> call(String todoId) async {
    final todo = await _todoRepository.getTodoById(todoId);
    if (todo == null) throw const TodoNotFoundException();

    if (isPastDate(todo.date)) throw const DayLockedException();

    if (todo.status == TodoStatus.completed ||
        todo.status == TodoStatus.dropped) {
      throw const CompletedLockException();
    }

    final running = await _timeSegmentRepository.getRunningSegment(todoId);
    if (running != null) throw const SegmentAlreadyRunningException();

    await _timeSegmentRepository.startSegment(todoId);
  }
}
