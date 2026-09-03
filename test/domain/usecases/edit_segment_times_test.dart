import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_todo/core/errors/exceptions.dart';
import 'package:sreerajp_todo/data/dao/time_segment_dao.dart';
import 'package:sreerajp_todo/data/dao/todo_dao.dart';
import 'package:sreerajp_todo/data/dao/todo_history_dao.dart';
import 'package:sreerajp_todo/data/models/time_segment_entity.dart';
import 'package:sreerajp_todo/data/models/todo_entity.dart';
import 'package:sreerajp_todo/data/models/todo_history_entity.dart';
import 'package:sreerajp_todo/data/models/todo_status.dart';
import 'package:sreerajp_todo/data/repositories/time_segment_repository_impl.dart';

import '../../helpers/test_database.dart';

String _isoDate(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

void main() {
  late TodoDao todoDao;
  late TimeSegmentDao segmentDao;
  late TodoHistoryDao historyDao;
  late TimeSegmentRepositoryImpl segmentRepo;

  setUpAll(initFfi);

  setUp(() async {
    final dbService = await createTestDatabaseService();
    todoDao = TodoDao(dbService);
    segmentDao = TimeSegmentDao(dbService);
    historyDao = TodoHistoryDao(dbService);
    segmentRepo = TimeSegmentRepositoryImpl(
      segmentDao,
      todoDao,
      dbService,
      todoHistoryDao: historyDao,
    );
  });

  /// Inserts a todo plus one closed segment on the same day and returns the
  /// day the todo sits on.
  Future<DateTime> seed({
    required String todoId,
    required String segmentId,
    required TodoStatus status,
    int daysAgo = 0,
    DateTime? start,
    DateTime? end,
  }) async {
    final now = DateTime.now();
    final day = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: daysAgo));
    final nowIso = now.toUtc().toIso8601String();

    await todoDao.insert(
      TodoEntity(
        id: todoId,
        date: _isoDate(day),
        title: 'Task $todoId',
        status: status,
        sortOrder: 0,
        createdAt: nowIso,
        updatedAt: nowIso,
      ),
    );

    final segStart = start ?? DateTime(day.year, day.month, day.day, 9, 0);
    final segEnd = end ?? DateTime(day.year, day.month, day.day, 10, 0);
    await segmentDao.insert(
      TimeSegmentEntity(
        id: segmentId,
        todoId: todoId,
        startTime: segStart.toIso8601String(),
        endTime: segEnd.toIso8601String(),
        durationSeconds: segEnd.difference(segStart).inSeconds,
        createdAt: nowIso,
      ),
    );

    return day;
  }

  test('edits times on a completed task and marks the segment', () async {
    final day = await seed(
      todoId: 'done-1',
      segmentId: 'seg-1',
      status: TodoStatus.completed,
    );

    final newStart = DateTime(day.year, day.month, day.day, 9, 15);
    final newEnd = DateTime(day.year, day.month, day.day, 10, 30);
    await segmentRepo.updateSegmentTimes('seg-1', newStart, newEnd);

    final saved = await segmentDao.findById('seg-1');
    expect(saved!.startTime, newStart.toIso8601String());
    expect(saved.endTime, newEnd.toIso8601String());
    expect(saved.durationSeconds, 4500);
    expect(saved.editedAfterCompletion, isTrue);
    expect(saved.timesEditedAt, isNotNull);
  });

  test('edits times on a dropped task and marks the segment', () async {
    final day = await seed(
      todoId: 'drop-1',
      segmentId: 'seg-drop',
      status: TodoStatus.dropped,
    );

    await segmentRepo.updateSegmentTimes(
      'seg-drop',
      DateTime(day.year, day.month, day.day, 9, 30),
      DateTime(day.year, day.month, day.day, 10, 0),
    );

    final saved = await segmentDao.findById('seg-drop');
    expect(saved!.editedAfterCompletion, isTrue);
  });

  test('writes one edited history row naming old and new times', () async {
    final day = await seed(
      todoId: 'done-2',
      segmentId: 'seg-2',
      status: TodoStatus.completed,
    );

    await segmentRepo.updateSegmentTimes(
      'seg-2',
      DateTime(day.year, day.month, day.day, 9, 15),
      DateTime(day.year, day.month, day.day, 10, 30),
    );

    final history = await historyDao.findByTodoId('done-2');
    final edits = history
        .where((e) => e.eventType == TodoHistoryEventType.edited)
        .toList();
    expect(edits, hasLength(1));

    final event = edits.single;
    expect(event.description, contains('after completion'));
    expect(event.description, contains('09:00 -> 10:00'));
    expect(event.description, contains('09:15 -> 10:30'));
    expect(event.description, contains('01:15:00'));
    expect(event.metadata, contains('"after_completion":true'));
    expect(event.metadata, contains('"duration_seconds":4500'));
  });

  test('an open task keeps the plain edited description', () async {
    final day = await seed(
      todoId: 'open-1',
      segmentId: 'seg-open',
      status: TodoStatus.working,
    );

    await segmentRepo.updateSegmentTimes(
      'seg-open',
      DateTime(day.year, day.month, day.day, 9, 15),
      DateTime(day.year, day.month, day.day, 10, 0),
    );

    final saved = await segmentDao.findById('seg-open');
    expect(saved!.editedAfterCompletion, isFalse);
    expect(saved.timesEditedAt, isNotNull);

    final history = await historyDao.findByTodoId('open-1');
    final event = history.firstWhere(
      (e) => e.eventType == TodoHistoryEventType.edited,
    );
    expect(event.description, isNot(contains('after completion')));
    expect(event.metadata, contains('"after_completion":false'));
  });

  test('a completed task on a past day is still day-locked', () async {
    final day = await seed(
      todoId: 'done-old',
      segmentId: 'seg-old',
      status: TodoStatus.completed,
      daysAgo: 1,
    );

    expect(
      () => segmentRepo.updateSegmentTimes(
        'seg-old',
        DateTime(day.year, day.month, day.day, 9, 15),
        DateTime(day.year, day.month, day.day, 10, 30),
      ),
      throwsA(isA<DayLockedException>()),
    );
  });

  test('an overlapping edit on a completed task is refused', () async {
    final day = await seed(
      todoId: 'done-3',
      segmentId: 'seg-3a',
      status: TodoStatus.completed,
    );
    await segmentDao.insert(
      TimeSegmentEntity(
        id: 'seg-3b',
        todoId: 'done-3',
        startTime: DateTime(
          day.year,
          day.month,
          day.day,
          11,
          0,
        ).toIso8601String(),
        endTime: DateTime(
          day.year,
          day.month,
          day.day,
          12,
          0,
        ).toIso8601String(),
        durationSeconds: 3600,
        createdAt: DateTime.now().toUtc().toIso8601String(),
      ),
    );

    expect(
      () => segmentRepo.updateSegmentTimes(
        'seg-3a',
        DateTime(day.year, day.month, day.day, 9, 0),
        DateTime(day.year, day.month, day.day, 11, 30),
      ),
      throwsA(isA<SegmentOverlapException>()),
    );
  });

  test('an end before the start is refused on a completed task', () async {
    final day = await seed(
      todoId: 'done-4',
      segmentId: 'seg-4',
      status: TodoStatus.completed,
    );

    expect(
      () => segmentRepo.updateSegmentTimes(
        'seg-4',
        DateTime(day.year, day.month, day.day, 10, 0),
        DateTime(day.year, day.month, day.day, 9, 0),
      ),
      throwsArgumentError,
    );
  });
}
