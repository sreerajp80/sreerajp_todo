import 'package:sqflite_sqlcipher/sqlite_api.dart';
import 'package:sreerajp_todo/core/errors/exceptions.dart';
import 'package:sreerajp_todo/core/utils/date_utils.dart';
import 'package:sreerajp_todo/core/utils/duration_utils.dart';
import 'package:sreerajp_todo/data/dao/time_segment_dao.dart';
import 'package:sreerajp_todo/data/dao/todo_dao.dart';
import 'package:sreerajp_todo/data/dao/todo_history_dao.dart';
import 'package:sreerajp_todo/data/database/database_service.dart';
import 'package:sreerajp_todo/data/models/time_segment_entity.dart';
import 'package:sreerajp_todo/data/models/todo_entity.dart';
import 'package:sreerajp_todo/data/models/todo_history_entity.dart';
import 'package:sreerajp_todo/data/models/todo_status.dart';
import 'package:sreerajp_todo/domain/repositories/time_segment_repository.dart';
import 'package:uuid/uuid.dart';

class TimeSegmentRepositoryImpl implements TimeSegmentRepository {
  TimeSegmentRepositoryImpl(
    this._timeSegmentDao,
    this._todoDao,
    this._databaseService, {
    this.todoHistoryDao,
  });

  final TimeSegmentDao _timeSegmentDao;
  final TodoDao _todoDao;
  final DatabaseService _databaseService;
  final TodoHistoryDao? todoHistoryDao;

  static const _uuid = Uuid();

  Future<void> _logHistoryEvent({
    required String todoId,
    required TodoHistoryEventType eventType,
    required String description,
    String? metadata,
    String? eventTime,
  }) async {
    final historyDao = todoHistoryDao;
    if (historyDao == null) return;
    final nowIso = DateTime.now().toUtc().toIso8601String();
    final event = TodoHistoryEntity(
      id: _uuid.v4(),
      todoId: todoId,
      eventType: eventType,
      eventTime: eventTime ?? nowIso,
      description: description,
      metadata: metadata,
      createdAt: nowIso,
    );
    await historyDao.insert(event);
  }

  void _checkTerminalStatus(TodoStatus status) {
    if (status == TodoStatus.completed || status == TodoStatus.dropped) {
      throw const CompletedLockException();
    }
  }

  Future<void> _promoteTodoToWorking(
    TodoEntity todo, {
    required DatabaseExecutor executor,
  }) async {
    if (todo.status != TodoStatus.pending) {
      return;
    }

    await _todoDao.updateStatus(
      todo.id,
      TodoStatus.working,
      executor: executor,
    );
  }

  @override
  Future<void> startSegment(String todoId) async {
    final todo = await _todoDao.findById(todoId);
    if (todo == null) throw const TodoNotFoundException();

    if (isPastDate(todo.date)) {
      throw const DayLockedException();
    }

    _checkTerminalStatus(todo.status);

    final now = DateTime.now();
    final segment = TimeSegmentEntity(
      id: _uuid.v4(),
      todoId: todoId,
      startTime: now.toIso8601String(),
      createdAt: now.toUtc().toIso8601String(),
    );

    final db = await _databaseService.database;
    await db.transaction((txn) async {
      final running = await _timeSegmentDao.findRunningSegment(
        todoId,
        executor: txn,
      );
      if (running != null) {
        throw const SegmentAlreadyRunningException();
      }

      await _timeSegmentDao.insert(segment, executor: txn);
      await _promoteTodoToWorking(todo, executor: txn);
    });

    await _logHistoryEvent(
      todoId: todoId,
      eventType: TodoHistoryEventType.timerStarted,
      description: 'Timer started',
      metadata: '{"segment_id":"${segment.id}"}',
    );
  }

  @override
  Future<TimeSegmentEntity?> stopSegment(String todoId) async {
    return _closeRunning(todoId, DateTime.now());
  }

  @override
  Future<TimeSegmentEntity?> closeSegmentAt(String todoId, DateTime at) async {
    return _closeRunning(todoId, at);
  }

  /// Closes the open segment on [todoId] at [at] and returns it as stored.
  ///
  /// [at] is never allowed before the segment start, because a negative
  /// duration would poison every total. A cut-off that already passed before
  /// the timer began collapses to a zero-length segment instead.
  Future<TimeSegmentEntity?> _closeRunning(String todoId, DateTime at) async {
    final running = await _timeSegmentDao.findRunningSegment(todoId);
    if (running == null) return null;

    final startTime = DateTime.parse(running.startTime);
    final endTime = at.isBefore(startTime) ? startTime : at;

    await _timeSegmentDao.closeSegment(running.id, endTime);
    final saved = await _timeSegmentDao.findById(running.id);

    if (saved != null) {
      final dur = saved.durationSeconds ?? 0;
      await _logHistoryEvent(
        todoId: todoId,
        eventType: TodoHistoryEventType.timerStopped,
        description: 'Timer session completed (${dur}s)',
        metadata: '{"segment_id":"${saved.id}","duration_seconds":$dur}',
        eventTime: endTime.toUtc().toIso8601String(),
      );
    }

    return saved;
  }

  @override
  Future<List<TimeSegmentEntity>> getAllRunningSegments() {
    return _timeSegmentDao.findAllRunningSegments();
  }

  @override
  Future<List<String>> stopAllRunningSegments({String? exceptTodoId}) async {
    final running = await _timeSegmentDao.findAllRunningSegments();
    final stopped = <String>[];
    final now = DateTime.now();

    for (final segment in running) {
      if (segment.todoId == exceptTodoId) continue;
      final startTime = DateTime.parse(segment.startTime);
      final endTime = now.isBefore(startTime) ? startTime : now;
      await _timeSegmentDao.closeSegment(segment.id, endTime);
      stopped.add(segment.todoId);
    }
    return stopped;
  }

  @override
  Future<void> deleteSegment(String segmentId) async {
    final segment = await _timeSegmentDao.findById(segmentId);
    if (segment == null) return;

    final todo = await _todoDao.findById(segment.todoId);
    if (todo != null && isPastDate(todo.date)) {
      throw const DayLockedException();
    }

    await _timeSegmentDao.delete(segmentId);

    if (todo != null) {
      final startDt = DateTime.parse(segment.startTime);
      final endDt = segment.endTime != null
          ? DateTime.parse(segment.endTime!)
          : null;
      final dur =
          segment.durationSeconds ??
          (endDt != null ? endDt.difference(startDt).inSeconds : 0);
      final timeRange = endDt != null
          ? '${_clock(startDt)} -> ${_clock(endDt)}'
          : _clock(startDt);
      await _logHistoryEvent(
        todoId: segment.todoId,
        eventType: TodoHistoryEventType.edited,
        description:
            'Time segment deleted: $timeRange (${formatDuration(dur)})',
        metadata: '{"segment_id":"$segmentId","action":"deleted"}',
        eventTime: DateTime.now().toUtc().toIso8601String(),
      );
    }
  }

  @override
  Future<void> restoreSegment(TimeSegmentEntity segment) async {
    final todo = await _todoDao.findById(segment.todoId);
    if (todo != null && isPastDate(todo.date)) {
      throw const DayLockedException();
    }

    await _timeSegmentDao.insert(segment);

    if (todo != null) {
      final startDt = DateTime.parse(segment.startTime);
      final endDt = segment.endTime != null
          ? DateTime.parse(segment.endTime!)
          : null;
      final dur =
          segment.durationSeconds ??
          (endDt != null ? endDt.difference(startDt).inSeconds : 0);
      final timeRange = endDt != null
          ? '${_clock(startDt)} -> ${_clock(endDt)}'
          : _clock(startDt);
      await _logHistoryEvent(
        todoId: segment.todoId,
        eventType: TodoHistoryEventType.edited,
        description:
            'Time segment restored: $timeRange (${formatDuration(dur)})',
        metadata: '{"segment_id":"${segment.id}","action":"restored"}',
        eventTime: DateTime.now().toUtc().toIso8601String(),
      );
    }
  }

  @override
  Future<List<TimeSegmentEntity>> getSegments(String todoId) {
    return _timeSegmentDao.findByTodoId(todoId);
  }

  @override
  Future<TimeSegmentEntity?> getRunningSegment(String todoId) {
    return _timeSegmentDao.findRunningSegment(todoId);
  }

  @override
  Future<void> insertManualSegment(TimeSegmentEntity segment) async {
    final todo = await _todoDao.findById(segment.todoId);
    if (todo == null) throw const TodoNotFoundException();

    if (isPastDate(todo.date)) {
      throw const DayLockedException();
    }

    _checkTerminalStatus(todo.status);

    if (segment.endTime == null) {
      throw ArgumentError('Manual segments must have an end time.');
    }

    final db = await _databaseService.database;
    await db.transaction((txn) async {
      final overlaps = await _timeSegmentDao.hasOverlap(
        todoId: segment.todoId,
        startTime: segment.startTime,
        endTime: segment.endTime!,
        executor: txn,
      );
      if (overlaps) {
        throw const SegmentOverlapException();
      }

      await _timeSegmentDao.insert(segment, executor: txn);
      await _promoteTodoToWorking(todo, executor: txn);
    });

    final dur = segment.durationSeconds ?? 0;
    await _logHistoryEvent(
      todoId: segment.todoId,
      eventType: TodoHistoryEventType.manualSegmentAdded,
      description: 'Manual time recorded (${dur}s)',
      metadata: '{"segment_id":"${segment.id}","duration_seconds":$dur}',
      eventTime: segment.startTime,
    );
  }

  @override
  Future<void> updateSegmentNotes(String segmentId, String? notes) async {
    final segments = await _timeSegmentDao.findById(segmentId);
    if (segments == null) return;

    final todo = await _todoDao.findById(segments.todoId);
    if (todo == null) throw const TodoNotFoundException();

    // Day lock still applies: a past day stays read-only. The terminal status
    // lock is not applied here, because writing a note does not add tracked
    // time to a finished task.
    if (isPastDate(todo.date)) {
      throw const DayLockedException();
    }

    await _timeSegmentDao.updateNotes(segmentId, notes);
  }

  @override
  Future<void> updateSegmentTimes(
    String segmentId,
    DateTime newStart,
    DateTime newEnd,
  ) async {
    final segment = await _timeSegmentDao.findById(segmentId);
    if (segment == null) return;

    final todo = await _todoDao.findById(segment.todoId);
    if (todo == null) throw const TodoNotFoundException();

    if (isPastDate(todo.date)) {
      throw const DayLockedException();
    }

    // The terminal-status lock is deliberately NOT applied here. Correcting a
    // wrong start or end time on a finished task does not add new tracked
    // time, it fixes what is already recorded. The edit is marked on the
    // segment and written to the task history instead, so it stays visible.

    // Running segments must be stopped before their times can be edited.
    if (segment.endTime == null) {
      throw const SegmentAlreadyRunningException();
    }

    if (!newEnd.isAfter(newStart)) {
      throw ArgumentError('Start time must be before end time.');
    }

    // Check overlap with other segments of the same todo, excluding self.
    final overlaps = await _timeSegmentDao.hasOverlap(
      todoId: segment.todoId,
      startTime: newStart.toIso8601String(),
      endTime: newEnd.toIso8601String(),
      excludeId: segmentId,
    );
    if (overlaps) {
      throw const SegmentOverlapException();
    }

    final afterCompletion =
        todo.status == TodoStatus.completed ||
        todo.status == TodoStatus.dropped;
    final editedAt = DateTime.now();

    await _timeSegmentDao.updateTimes(
      segmentId,
      newStart,
      newEnd,
      markEditedAfterCompletion: afterCompletion,
      editedAt: editedAt,
    );

    final oldStart = DateTime.parse(segment.startTime);
    final oldEnd = DateTime.parse(segment.endTime!);
    final dur = newEnd.difference(newStart).inSeconds;
    final prefix = afterCompletion
        ? 'Segment time edited after completion'
        : 'Segment time edited';
    final description =
        '$prefix: ${_clock(oldStart)} -> ${_clock(oldEnd)} changed to '
        '${_clock(newStart)} -> ${_clock(newEnd)} (${formatDuration(dur)})';

    await _logHistoryEvent(
      todoId: segment.todoId,
      eventType: TodoHistoryEventType.edited,
      description: description,
      metadata:
          '{"segment_id":"$segmentId"'
          ',"old_start":"${segment.startTime}"'
          ',"old_end":"${segment.endTime}"'
          ',"new_start":"${newStart.toIso8601String()}"'
          ',"new_end":"${newEnd.toIso8601String()}"'
          ',"duration_seconds":$dur'
          ',"after_completion":$afterCompletion}',
      eventTime: editedAt.toUtc().toIso8601String(),
    );
  }

  /// Local wall-clock `HH:MM` used in history descriptions. The data layer has
  /// no access to the app locale, so this stays a plain 24-hour label.
  static String _clock(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Future<void> repairOrphanedSegments(
    String todayDate, {
    DateTime? Function(DateTime segmentStart)? closeAt,
  }) async {
    final orphans = await _timeSegmentDao.findAllOrphanedSegments(todayDate);

    for (final orphan in orphans) {
      final startTime = DateTime.parse(orphan.startTime);

      // With auto-stop on we know when the timer should have stopped, so the
      // real worked time is kept. Without it we fall back to the original
      // zero-length close, because any other guess would invent time the user
      // never tracked.
      final cutoff = closeAt?.call(startTime);
      final endTime = (cutoff != null && !cutoff.isBefore(startTime))
          ? cutoff
          : startTime;

      await _timeSegmentDao.closeSegment(orphan.id, endTime, interrupted: true);
    }
  }
}
