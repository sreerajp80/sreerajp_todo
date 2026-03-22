import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_todo/data/dao/time_segment_dao.dart';
import 'package:sreerajp_todo/data/dao/todo_dao.dart';
import 'package:sreerajp_todo/data/database/database_service.dart';
import 'package:sreerajp_todo/data/models/time_segment_entity.dart';
import 'package:sreerajp_todo/data/models/todo_entity.dart';

import '../helpers/test_database.dart';

void main() {
  late DatabaseService databaseService;
  late TodoDao todoDao;
  late TimeSegmentDao segmentDao;

  setUpAll(initFfi);

  setUp(() async {
    databaseService = await createTestDatabaseService();
    todoDao = TodoDao(databaseService);
    segmentDao = TimeSegmentDao(databaseService);
  });

  tearDown(() async {
    await databaseService.close();
  });

  Future<void> insertParentTodo({
    String id = 'todo-1',
    String date = '2026-03-21',
  }) async {
    final now = DateTime.now().toUtc().toIso8601String();
    await todoDao.insert(
      TodoEntity(
        id: id,
        date: date,
        title: 'Todo $id',
        sortOrder: 0,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  TimeSegmentEntity makeSegment({
    String id = 'seg-1',
    String todoId = 'todo-1',
    DateTime? startTime,
    DateTime? endTime,
    int? durationSeconds,
    bool interrupted = false,
    bool manual = false,
  }) {
    final start = startTime ?? DateTime(2026, 3, 21, 9, 0, 0);
    return TimeSegmentEntity(
      id: id,
      todoId: todoId,
      startTime: start.toIso8601String(),
      endTime: endTime?.toIso8601String(),
      durationSeconds: durationSeconds,
      interrupted: interrupted,
      manual: manual,
      createdAt: DateTime.now().toUtc().toIso8601String(),
    );
  }

  group('insert and findByTodoId', () {
    test('inserts a segment and retrieves by todo id', () async {
      await insertParentTodo();
      await segmentDao.insert(makeSegment());

      final results = await segmentDao.findByTodoId('todo-1');
      expect(results, hasLength(1));
      expect(results.first.id, 'seg-1');
      expect(results.first.todoId, 'todo-1');
    });

    test('orders by start_time ascending', () async {
      await insertParentTodo();
      await segmentDao.insert(
        makeSegment(id: 'seg-a', startTime: DateTime(2026, 3, 21, 11, 0)),
      );
      await segmentDao.insert(
        makeSegment(id: 'seg-b', startTime: DateTime(2026, 3, 21, 9, 0)),
      );

      final results = await segmentDao.findByTodoId('todo-1');
      expect(results[0].id, 'seg-b');
      expect(results[1].id, 'seg-a');
    });

    test('returns empty list when todo has no segments', () async {
      await insertParentTodo();
      final results = await segmentDao.findByTodoId('todo-1');
      expect(results, isEmpty);
    });
  });

  group('closeSegment', () {
    test('sets end_time and computes duration_seconds', () async {
      await insertParentTodo();
      final start = DateTime(2026, 3, 21, 9, 0, 0);
      final end = DateTime(2026, 3, 21, 9, 30, 0);

      await segmentDao.insert(makeSegment(startTime: start));
      await segmentDao.closeSegment('seg-1', end);

      final segments = await segmentDao.findByTodoId('todo-1');
      expect(segments.first.endTime, end.toIso8601String());
      expect(segments.first.durationSeconds, 1800);
    });

    test('sets interrupted flag when requested', () async {
      await insertParentTodo();
      final start = DateTime(2026, 3, 21, 9, 0, 0);

      await segmentDao.insert(makeSegment(startTime: start));
      await segmentDao.closeSegment('seg-1', start, interrupted: true);

      final segments = await segmentDao.findByTodoId('todo-1');
      expect(segments.first.durationSeconds, 0);
      expect(segments.first.interrupted, isTrue);
    });

    test('does nothing for nonexistent segment id', () async {
      await segmentDao.closeSegment('nonexistent', DateTime.now());
    });
  });

  group('findRunningSegment', () {
    test('returns open segment (end_time IS NULL)', () async {
      await insertParentTodo();
      await segmentDao.insert(makeSegment());

      final running = await segmentDao.findRunningSegment('todo-1');
      expect(running, isNotNull);
      expect(running!.endTime, isNull);
    });

    test('returns null when all segments are closed', () async {
      await insertParentTodo();
      final start = DateTime(2026, 3, 21, 9, 0, 0);
      final end = DateTime(2026, 3, 21, 9, 30, 0);

      await segmentDao.insert(
        makeSegment(startTime: start, endTime: end, durationSeconds: 1800),
      );

      final running = await segmentDao.findRunningSegment('todo-1');
      expect(running, isNull);
    });

    test('returns null when no segments exist', () async {
      await insertParentTodo();
      final running = await segmentDao.findRunningSegment('todo-1');
      expect(running, isNull);
    });
  });

  group('findAllOrphanedSegments', () {
    test('detects orphaned segments on past-date todos', () async {
      await insertParentTodo(id: 'past-todo', date: '2026-03-19');
      await insertParentTodo(id: 'today-todo', date: '2026-03-21');

      await segmentDao.insert(makeSegment(id: 'orphan', todoId: 'past-todo'));
      await segmentDao.insert(makeSegment(id: 'current', todoId: 'today-todo'));

      final orphans = await segmentDao.findAllOrphanedSegments('2026-03-21');
      expect(orphans, hasLength(1));
      expect(orphans.first.id, 'orphan');
    });

    test('does not include closed segments', () async {
      await insertParentTodo(id: 'past-todo', date: '2026-03-19');
      final start = DateTime(2026, 3, 19, 9, 0, 0);
      final end = DateTime(2026, 3, 19, 9, 30, 0);

      await segmentDao.insert(
        makeSegment(
          id: 'closed',
          todoId: 'past-todo',
          startTime: start,
          endTime: end,
          durationSeconds: 1800,
        ),
      );

      final orphans = await segmentDao.findAllOrphanedSegments('2026-03-21');
      expect(orphans, isEmpty);
    });

    test('returns empty when no orphans', () async {
      final orphans = await segmentDao.findAllOrphanedSegments('2026-03-21');
      expect(orphans, isEmpty);
    });
  });

  group('deleteByTodoId', () {
    test('removes all segments for a todo', () async {
      await insertParentTodo();
      await segmentDao.insert(makeSegment(id: 'seg-1'));
      await segmentDao.insert(makeSegment(id: 'seg-2'));

      await segmentDao.deleteByTodoId('todo-1');
      final results = await segmentDao.findByTodoId('todo-1');
      expect(results, isEmpty);
    });
  });

  group('cascade delete', () {
    test('deleting a todo also deletes its segments', () async {
      await insertParentTodo();
      await segmentDao.insert(makeSegment(id: 'seg-1'));
      await segmentDao.insert(makeSegment(id: 'seg-2'));

      await todoDao.delete('todo-1');
      final results = await segmentDao.findByTodoId('todo-1');
      expect(results, isEmpty);
    });
  });
}
