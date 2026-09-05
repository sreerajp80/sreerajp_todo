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

  Future<TimeSegmentEntity> seedSegment({
    required String todoId,
    required String segmentId,
    int daysAgo = 0,
  }) async {
    final now = DateTime.now();
    final day = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: daysAgo));
    final dateStr = _isoDate(day);
    final nowIso = now.toUtc().toIso8601String();

    await todoDao.insert(
      TodoEntity(
        id: todoId,
        date: dateStr,
        title: 'Task $todoId',
        status: TodoStatus.pending,
        sortOrder: 0,
        createdAt: nowIso,
        updatedAt: nowIso,
      ),
    );

    final start = DateTime(day.year, day.month, day.day, 10, 0);
    final end = DateTime(day.year, day.month, day.day, 10, 30);
    final seg = TimeSegmentEntity(
      id: segmentId,
      todoId: todoId,
      startTime: start.toIso8601String(),
      endTime: end.toIso8601String(),
      durationSeconds: 1800,
      createdAt: nowIso,
    );
    await segmentDao.insert(seg);
    return seg;
  }

  group('TimeSegmentRepository.deleteSegment', () {
    test('deletes segment on today task and records history event', () async {
      final seg = await seedSegment(
        todoId: 't-today',
        segmentId: 'seg-1',
        daysAgo: 0,
      );

      await segmentRepo.deleteSegment(seg.id);

      final found = await segmentDao.findById(seg.id);
      expect(found, isNull);

      final history = await historyDao.findByTodoId('t-today');
      expect(
        history.any(
          (h) =>
              h.eventType == TodoHistoryEventType.edited &&
              h.description.contains('Time segment deleted'),
        ),
        isTrue,
      );
    });

    test(
      'throws DayLockedException when deleting segment on past task',
      () async {
        final seg = await seedSegment(
          todoId: 't-past',
          segmentId: 'seg-2',
          daysAgo: 2,
        );

        expect(
          () => segmentRepo.deleteSegment(seg.id),
          throwsA(isA<DayLockedException>()),
        );

        // Segment still exists in DB
        final found = await segmentDao.findById(seg.id);
        expect(found, isNotNull);
      },
    );

    test('restores segment on today task and records history event', () async {
      final seg = await seedSegment(
        todoId: 't-restore',
        segmentId: 'seg-3',
        daysAgo: 0,
      );
      await segmentRepo.deleteSegment(seg.id);
      expect(await segmentDao.findById(seg.id), isNull);

      await segmentRepo.restoreSegment(seg);

      final restored = await segmentDao.findById(seg.id);
      expect(restored, isNotNull);
      expect(restored?.id, seg.id);

      final history = await historyDao.findByTodoId('t-restore');
      expect(
        history.any(
          (h) =>
              h.eventType == TodoHistoryEventType.edited &&
              h.description.contains('Time segment restored'),
        ),
        isTrue,
      );
    });

    test(
      'throws DayLockedException when restoring segment on past task',
      () async {
        final seg = await seedSegment(
          todoId: 't-past-restore',
          segmentId: 'seg-4',
          daysAgo: 2,
        );

        expect(
          () => segmentRepo.restoreSegment(seg),
          throwsA(isA<DayLockedException>()),
        );
      },
    );
  });
}
