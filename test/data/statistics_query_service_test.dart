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
    test('returns per-day status counts and total time', () async {
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
          status: TodoStatus.working,
        ),
      );
      await todoDao.insert(
        makeTodo(
          id: 't3',
          date: '2026-03-20',
          title: 'C',
          status: TodoStatus.dropped,
        ),
      );
      await insertSegment('s1', 't1', 3600);
      await insertSegment('s2', 't2', 600);
      await insertSegment('s3', 't3', 1800);

      final stats = await statsService.getCountsPerDay();

      expect(stats, hasLength(2));
      expect(stats.first.date, '2026-03-21');
      expect(stats.first.total, 2);
      expect(stats.first.completed, 1);
      expect(stats.first.working, 1);
      expect(stats.first.pending, 0);
      expect(stats.first.totalSeconds, 4200);
      expect(stats.last.date, '2026-03-20');
      expect(stats.last.dropped, 1);
      expect(stats.last.totalSeconds, 1800);
    });

    test('respects pagination with 20 rows per page', () async {
      for (var i = 0; i < 25; i++) {
        final day = DateTime(2026, 3, 1).add(Duration(days: i));
        final dayString =
            '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
        await todoDao.insert(
          makeTodo(id: 'todo_$i', date: dayString, title: 'Task $i'),
        );
      }

      final page1 = await statsService.getCountsPerDay(limit: 20, offset: 0);
      final page2 = await statsService.getCountsPerDay(limit: 20, offset: 20);

      expect(page1, hasLength(20));
      expect(page2, hasLength(5));
      expect(page1.first.date, '2026-03-25');
      expect(page2.first.date, '2026-03-05');
    });

    test('filters by date range', () async {
      await todoDao.insert(makeTodo(id: 't1', date: '2026-03-19', title: 'A'));
      await todoDao.insert(makeTodo(id: 't2', date: '2026-03-20', title: 'B'));
      await todoDao.insert(makeTodo(id: 't3', date: '2026-03-21', title: 'C'));

      final stats = await statsService.getCountsPerDay(
        startDate: '2026-03-20',
        endDate: '2026-03-21',
      );

      expect(stats, hasLength(2));
      expect(stats.map((item) => item.date), ['2026-03-21', '2026-03-20']);
    });
  });

  group('getPerItemStats', () {
    test('aggregates appearances, statuses, and total time by title', () async {
      await todoDao.insert(
        makeTodo(
          id: 't1',
          date: '2026-03-20',
          title: 'Code',
          status: TodoStatus.completed,
        ),
      );
      await todoDao.insert(
        makeTodo(
          id: 't2',
          date: '2026-03-21',
          title: 'Code',
          status: TodoStatus.working,
        ),
      );
      await todoDao.insert(
        makeTodo(
          id: 't3',
          date: '2026-03-21',
          title: 'Read',
          status: TodoStatus.ported,
        ),
      );
      await insertSegment('s1', 't1', 1200);
      await insertSegment('s2', 't2', 1800);
      await insertSegment('s3', 't3', 900);

      final stats = await statsService.getPerItemStats();
      final code = stats.firstWhere((item) => item.title == 'Code');

      expect(code.appearances, 2);
      expect(code.completed, 1);
      expect(code.working, 1);
      expect(code.totalSeconds, 3000);
    });
  });

  group('getSummaryStats', () {
    test('separates productive and dropped time', () async {
      await todoDao.insert(
        makeTodo(
          id: 't1',
          date: '2026-03-20',
          title: 'Build',
          status: TodoStatus.completed,
        ),
      );
      await todoDao.insert(
        makeTodo(
          id: 't2',
          date: '2026-03-21',
          title: 'Discard',
          status: TodoStatus.dropped,
        ),
      );
      await todoDao.insert(
        makeTodo(
          id: 't3',
          date: '2026-03-21',
          title: 'Plan',
          status: TodoStatus.pending,
        ),
      );
      await insertSegment('s1', 't1', 3600);
      await insertSegment('s2', 't2', 1800);

      final summary = await statsService.getSummaryStats(
        startDate: '2026-03-20',
        endDate: '2026-03-21',
      );

      expect(summary.totalTodos, 3);
      expect(summary.avgCompletedPerDay, 0.5);
      expect(summary.avgTimePerDaySeconds, 2700);
      expect(summary.totalProductiveTimeSeconds, 3600);
      expect(summary.totalDroppedTimeSeconds, 1800);
    });
  });

  group('getTimeSeriesForTitle', () {
    test('returns time history ordered by date for one title', () async {
      await todoDao.insert(
        makeTodo(
          id: 't1',
          date: '2026-03-20',
          title: 'Code',
          status: TodoStatus.completed,
        ),
      );
      await todoDao.insert(
        makeTodo(
          id: 't2',
          date: '2026-03-21',
          title: 'Code',
          status: TodoStatus.working,
        ),
      );
      await todoDao.insert(
        makeTodo(id: 't3', date: '2026-03-21', title: 'Read'),
      );
      await insertSegment('s1', 't1', 1200);
      await insertSegment('s2', 't2', 2400);
      await insertSegment('s3', 't3', 600);

      final history = await statsService.getTimeSeriesForTitle('Code');

      expect(history, hasLength(2));
      expect(history.first.date, '2026-03-20');
      expect(history.first.totalSeconds, 1200);
      expect(history.last.date, '2026-03-21');
      expect(history.last.totalSeconds, 2400);
      expect(history.last.status, TodoStatus.working.toDbString());
    });
  });
}
