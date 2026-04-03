import 'package:sqflite_sqlcipher/sqlite_api.dart';
import 'package:sreerajp_todo/core/errors/exceptions.dart';
import 'package:sreerajp_todo/core/utils/date_utils.dart';
import 'package:sreerajp_todo/data/dao/time_segment_dao.dart';
import 'package:sreerajp_todo/data/dao/todo_dao.dart';
import 'package:sreerajp_todo/data/database/database_service.dart';
import 'package:sreerajp_todo/data/models/time_segment_entity.dart';
import 'package:sreerajp_todo/data/models/todo_entity.dart';
import 'package:sreerajp_todo/data/models/todo_status.dart';
import 'package:sreerajp_todo/domain/repositories/time_segment_repository.dart';
import 'package:uuid/uuid.dart';

class TimeSegmentRepositoryImpl implements TimeSegmentRepository {
  TimeSegmentRepositoryImpl(
    this._timeSegmentDao,
    this._todoDao,
    this._databaseService,
  );

  final TimeSegmentDao _timeSegmentDao;
  final TodoDao _todoDao;
  final DatabaseService _databaseService;

  static const _uuid = Uuid();

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
  }

  @override
  Future<void> stopSegment(String todoId) async {
    final running = await _timeSegmentDao.findRunningSegment(todoId);
    if (running == null) return;

    await _timeSegmentDao.closeSegment(running.id, DateTime.now());
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
  }

  @override
  Future<void> repairOrphanedSegments(String todayDate) async {
    final orphans = await _timeSegmentDao.findAllOrphanedSegments(todayDate);

    for (final orphan in orphans) {
      final startTime = DateTime.parse(orphan.startTime);
      await _timeSegmentDao.closeSegment(
        orphan.id,
        startTime,
        interrupted: true,
      );
    }
  }
}
