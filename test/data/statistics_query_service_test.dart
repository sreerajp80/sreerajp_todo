import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_todo/data/dao/statistics_query_service.dart';
import 'package:sreerajp_todo/data/dao/todo_dao.dart';
import 'package:sreerajp_todo/data/database/database_service.dart';
import 'package:sreerajp_todo/data/models/todo_entity.dart';
import 'package:sreerajp_todo/data/models/todo_status.dart';

import '../helpers/test_database.dart';

void main() {
  late DatabaseService databaseService;
  late TodoDao todoDao;
  late StatisticsQueryService statsService;

  setUpAll(initFfi);

  setUp(() async {
    databaseService = await createTestDatabaseService();
    todoDao = TodoDao(databaseService);
    statsService = StatisticsQueryService(databaseService);
  });

  tearDown(() async {
    await databaseService.close();
  });

  TodoEntity makeTodo({
    required String id,
    required String date,
    required String title,
    TodoStatus status = TodoStatus.pending,
  }) {
    final now = DateTime.now().toUtc().toIso8601String();
    return TodoEntity(
      id: id,
      date: date,
      title: title,
      status: status,
      sortOrder: 0,
      createdAt: now,
      updatedAt: now,
    );
  }

  Future<void> insertSegment(
    String id,
    String todoId,
    int durationSeconds,
  ) async {
    final db = await databaseService.database;
    final start = DateTime(2026, 3, 21, 9, 0, 0);
    final end = start.add(Duration(seconds: durationSeconds));
    await db.insert('time_segments', {
      'id': id,
      'todo_id': todoId,
      'start_time': start.toIso8601String(),
      'end_time': end.toIso8601String(),
      'duration_seconds': durationSeconds,
      'interrupted': 0,
      'manual': 0,
      'created_at': DateTime.now().toUtc().toIso8601String(),
    });
  }

  group('getCountsPerDay', () {
    test('returns per-day status counts', () async {
      await todoDao.insert(
        makeTodo(
          id: 't1',
          date: '2026-03-21',
          title: 'A',
          status: TodoStatus.completed,
        ),
      );
      await todoDao.insert(
        makeTodo(
          id: 't2',
          date: '2026-03-21',
          title: 'B',
          status: TodoStatus.pending,
        ),
      );
      await todoDao.insert(
        makeTodo(
          id: 't3',
          date: '2026-03-21',
          title: 'C',
          status: TodoStatus.dropped,
        ),
      );
      await todoDao.insert(
        makeTodo(
          id: 't4',
          date: '2026-03-20',
          title: 'D',
          status: TodoStatus.ported,
        ),
      );

      final stats = await statsService.getCountsPerDay();
      expect(stats, hasLength(2));

      final day21 = stats.firstWhere((s) => s.date == '2026-03-21');
      expect(day21.total, 3);
      expect(day21.completed, 1);
      expect(day21.pending, 1);
      expect(day21.dropped, 1);
      expect(day21.ported, 0);

      final day20 = stats.firstWhere((s) => s.date == '2026-03-20');
      expect(day20.total, 1);
      expect(day20.ported, 1);
    });

    test('returns empty list when no todos', () async {
      final stats = await statsService.getCountsPerDay();
      expect(stats, isEmpty);
    });

    test('respects limit and offset', () async {
      for (var i = 1; i <= 5; i++) {
        await todoDao.insert(
          makeTodo(
            id: 't$i',
            date: '2026-03-${(20 + i).toString().padLeft(2, '0')}',
            title: 'Task $i',
          ),
        );
      }

      final page1 = await statsService.getCountsPerDay(limit: 2, offset: 0);
      expect(page1, hasLength(2));
      expect(page1.first.date, '2026-03-25');

      final page2 = await statsService.getCountsPerDay(limit: 2, offset: 2);
      expect(page2, hasLength(2));
      expect(page2.first.date, '2026-03-23');
    });
  });

  group('getTimePerTodoPerDay', () {
    test('returns time aggregated per todo per day', () async {
      await todoDao.insert(
        makeTodo(id: 't1', date: '2026-03-21', title: 'Code'),
      );
      await insertSegment('s1', 't1', 3600);
      await insertSegment('s2', 't1', 1800);

      final stats = await statsService.getTimePerTodoPerDay();
      expect(stats, hasLength(1));
      expect(stats.first.title, 'Code');
      expect(stats.first.totalSeconds, 5400);
    });

    test('returns empty when no segments', () async {
      await todoDao.insert(
        makeTodo(id: 't1', date: '2026-03-21', title: 'Code'),
      );
      final stats = await statsService.getTimePerTodoPerDay();
      expect(stats, isEmpty);
    });
  });

  group('getTimePerTodo', () {
    test('filters by title', () async {
      await todoDao.insert(
        makeTodo(id: 't1', date: '2026-03-21', title: 'Code'),
      );
      await todoDao.insert(
        makeTodo(id: 't2', date: '2026-03-21', title: 'Review'),
      );
      await insertSegment('s1', 't1', 3600);
      await insertSegment('s2', 't2', 900);

      final stats = await statsService.getTimePerTodo('Code');
      expect(stats, hasLength(1));
      expect(stats.first.title, 'Code');
      expect(stats.first.totalSeconds, 3600);
    });

    test('returns empty when title has no segments', () async {
      await todoDao.insert(
        makeTodo(id: 't1', date: '2026-03-21', title: 'Code'),
      );
      final stats = await statsService.getTimePerTodo('Code');
      expect(stats, isEmpty);
    });
  });
}
