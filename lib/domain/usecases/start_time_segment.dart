import 'package:sreerajp_todo/core/errors/exceptions.dart';
import 'package:sreerajp_todo/core/utils/date_utils.dart';
import 'package:sreerajp_todo/data/models/todo_status.dart';
import 'package:sreerajp_todo/domain/repositories/time_segment_repository.dart';
import 'package:sreerajp_todo/domain/repositories/todo_repository.dart';

class StartTimeSegment {
  StartTimeSegment(
    this._todoRepository,
    this._timeSegmentRepository, {
    bool Function()? singleTimer,
  }) : _singleTimer = singleTimer ?? _allowManyTimers;

  final TodoRepository _todoRepository;
  final TimeSegmentRepository _timeSegmentRepository;

  /// Read fresh on every call so a settings change takes effect at once.
  final bool Function() _singleTimer;

  static bool _allowManyTimers() => false;

  /// Validates all preconditions and starts a new time segment.
  ///
  /// When the "only one timer at a time" setting is on, any timer running on a
  /// different todo is stopped first, and the ids stopped are returned so the
  /// caller can tell the user. Otherwise the returned list is empty.
  ///
  /// The rule lives here rather than in a widget so every path that starts a
  /// timer obeys it.
  ///
  /// Throws [TodoNotFoundException] if the todo does not exist.
  /// Throws [DayLockedException] if the todo's date is in the past.
  /// Throws [CompletedLockException] if the todo is completed or dropped.
  /// Throws [SegmentAlreadyRunningException] if a segment is already running.
  Future<List<String>> call(String todoId) async {
    final todo = await _todoRepository.getTodoById(todoId);
    if (todo == null) throw const TodoNotFoundException();

    if (isPastDate(todo.date)) throw const DayLockedException();

    if (todo.status == TodoStatus.completed ||
        todo.status == TodoStatus.dropped) {
      throw const CompletedLockException();
    }

    final running = await _timeSegmentRepository.getRunningSegment(todoId);
    if (running != null) throw const SegmentAlreadyRunningException();

    // Stop other timers only after this todo has passed every check, so a
    // refused start never leaves the user with their previous timer stopped.
    var stopped = const <String>[];
    if (_singleTimer()) {
      stopped = await _timeSegmentRepository.stopAllRunningSegments(
        exceptTodoId: todoId,
      );
    }

    await _timeSegmentRepository.startSegment(todoId);
    return stopped;
  }
}
