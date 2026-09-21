import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_todo/core/errors/exceptions.dart';
import 'package:sreerajp_todo/data/dao/time_segment_dao.dart';
import 'package:sreerajp_todo/data/dao/todo_dao.dart';
import 'package:sreerajp_todo/data/database/database_service.dart';
import 'package:sreerajp_todo/data/models/time_segment_entity.dart';
import 'package:sreerajp_todo/data/models/todo_entity.dart';
import 'package:sreerajp_todo/data/models/todo_status.dart';
import 'package:sreerajp_todo/data/repositories/time_segment_repository_impl.dart';
import 'package:sreerajp_todo/data/repositories/todo_repository_impl.dart';

import '../helpers/test_database.dart';

void main() {
  late DatabaseService databaseService;
  late TodoDao todoDao;
  late TimeSegmentDao timeSegmentDao;
  late TodoRepositoryImpl todoRepo;
  late TimeSegmentRepositoryImpl timeSegmentRepo;

  setUpAll(initFfi);

  setUp(() async {
    databaseService = await createTestDatabaseService();
    todoDao = TodoDao(databaseService);
    timeSegmentDao = TimeSegmentDao(databaseService);
    todoRepo = TodoRepositoryImpl(todoDao, timeSegmentDao: timeSegmentDao);
    timeSegmentRepo = TimeSegmentRepositoryImpl(
      timeSegmentDao,
      todoDao,
      databaseService,
    );
  });

  tearDown(() async {
    await databaseService.close();
  });

  TodoEntity makeTodo({
    required String id,
    required String date,
    required String title,
    TodoStatus status = TodoStatus.pending,
    String? sourceDate,
    int? targetSeconds,
  }) {
    final now = DateTime.now().toUtc().toIso8601String();
    return TodoEntity(
      id: id,
      date: date,
      title: title,
      status: status,
      sourceDate: sourceDate,
      targetSeconds: targetSeconds,
      createdAt: now,
      updatedAt: now,
    );
  }

  test(
    'incomplete task created on day 1 appears on both day 1 and day 2 when carried forward',
    () async {
      final todo = makeTodo(
        id: 'task-1',
        date: '2026-09-20',
        title: 'Continuous task',
        status: TodoStatus.pending,
      );
      await todoDao.insert(todo);

      // Query on Sept 20: visible on Sept 20
      final day1Todos = await todoDao.findByDate('2026-09-20');
      expect(day1Todos.length, 1);
      expect(day1Todos.first.id, 'task-1');
      expect(day1Todos.first.date, '2026-09-20');

      // When carried forward to Sept 21
      await todoRepo.moveTodo('task-1', '2026-09-21');

      // Query on Sept 21: visible on Sept 21 as pending
      final day2Todos = await todoDao.findByDate('2026-09-21');
      expect(day2Todos.length, 1);
      expect(day2Todos.first.id, 'task-1');
      expect(day2Todos.first.date, '2026-09-21');
      expect(day2Todos.first.sourceDate, '2026-09-20');
      expect(day2Todos.first.status, TodoStatus.pending);

      // Query on Sept 20: STILL visible on Sept 20 (sourceDate <= date AND date >= sourceDate)
      final day1After = await todoDao.findByDate('2026-09-20');
      expect(day1After.length, 1);
      expect(day1After.first.id, 'task-1');
    },
  );

  test(
    'completing a task on day 2 shows completed on day 2 and pending on day 1',
    () async {
      final todo = makeTodo(
        id: 'task-2',
        date: '2026-09-20',
        title: 'Multi-day work',
        status: TodoStatus.pending,
      );
      await todoDao.insert(todo);

      // On Sept 21, task is completed and date updated to 2026-09-21 with sourceDate 2026-09-20
      final updated = todo.copyWith(
        date: '2026-09-21',
        sourceDate: '2026-09-20',
        status: TodoStatus.completed,
      );
      await todoDao.update(updated);

      // Query on Sept 21: shows completed
      final day2Todos = await todoDao.findByDate('2026-09-21');
      expect(day2Todos.length, 1);
      expect(day2Todos.first.status, TodoStatus.completed);

      // Query on Sept 20: still visible, but status is pending snapshot!
      final day1Todos = await todoDao.findByDate('2026-09-20');
      expect(day1Todos.length, 1);
      expect(day1Todos.first.id, 'task-2');
      expect(day1Todos.first.status, TodoStatus.pending);
    },
  );

  test(
    'time segments query separates today elapsed time from total lifetime time',
    () async {
      final todo = makeTodo(
        id: 'task-3',
        date: '2026-09-20',
        title: 'Time tracking task',
      );
      await todoDao.insert(todo);

      // Insert 15m segment on Sept 20
      await timeSegmentDao.insert(
        const TimeSegmentEntity(
          id: 'seg-1',
          todoId: 'task-3',
          startTime: '2026-09-20T10:00:00.000Z',
          endTime: '2026-09-20T10:15:00.000Z',
          durationSeconds: 900,
          createdAt: '2026-09-20T10:15:00.000Z',
        ),
      );

      // Insert 20m segment on Sept 21
      await timeSegmentDao.insert(
        const TimeSegmentEntity(
          id: 'seg-2',
          todoId: 'task-3',
          startTime: '2026-09-21T11:00:00.000Z',
          endTime: '2026-09-21T11:20:00.000Z',
          durationSeconds: 1200,
          createdAt: '2026-09-21T11:20:00.000Z',
        ),
      );

      final day1Elapsed = await timeSegmentRepo.getElapsedSecondsOnDate(
        'task-3',
        '2026-09-20',
      );
      final day2Elapsed = await timeSegmentRepo.getElapsedSecondsOnDate(
        'task-3',
        '2026-09-21',
      );
      final totalElapsed = await timeSegmentRepo.getTotalElapsedSeconds(
        'task-3',
      );

      expect(day1Elapsed, 900);
      expect(day2Elapsed, 1200);
      expect(totalElapsed, 2100);

      // Check hasSegmentsBeforeDate on Sept 21 -> true
      expect(
        await timeSegmentRepo.hasSegmentsBeforeDate('task-3', '2026-09-21'),
        isTrue,
      );
      // Check hasSegmentsBeforeDate on Sept 20 -> false
      expect(
        await timeSegmentRepo.hasSegmentsBeforeDate('task-3', '2026-09-20'),
        isFalse,
      );
    },
  );

  test(
    'renaming task across active dates throws MultiDayDuplicateTitleException on clash',
    () async {
      // On Sept 20, create "Write Report"
      final taskA = makeTodo(
        id: 'task-a',
        date: '2026-09-20',
        title: 'Write Report',
      );
      await todoDao.insert(taskA);

      // On Sept 21, task B is created and carried forward
      final taskB = makeTodo(
        id: 'task-b',
        date: '2026-09-21',
        sourceDate: '2026-09-20',
        title: 'Draft Notes',
      );
      await todoDao.insert(taskB);

      // Attempting to rename task B to "Write Report" on Sept 21 clashes with task A on Sept 20
      expect(
        () => todoRepo.updateTodo(
          taskB.copyWith(title: 'Write Report'),
          bypassLock: true,
        ),
        throwsA(
          isA<MultiDayDuplicateTitleException>().having(
            (e) => e.conflictingDate,
            'conflictingDate',
            '2026-09-20',
          ),
        ),
      );
    },
  );

  test(
    'deleteTodoFromDate drops task from today onwards and preserves past records',
    () async {
      final todo = makeTodo(
        id: 'task-del',
        date: '2026-09-21',
        sourceDate: '2026-09-20',
        title: 'To be dropped today',
      );
      await todoDao.insert(todo);

      // Insert past segment on Sept 20
      await timeSegmentDao.insert(
        const TimeSegmentEntity(
          id: 'seg-past',
          todoId: 'task-del',
          startTime: '2026-09-20T10:00:00.000Z',
          endTime: '2026-09-20T10:30:00.000Z',
          durationSeconds: 1800,
          createdAt: '2026-09-20T10:30:00.000Z',
        ),
      );

      // Remove from Sept 21 only
      await todoRepo.deleteTodoFromDate(
        'task-del',
        '2026-09-21',
        bypassLock: true,
      );

      // Sept 21 query: task is gone!
      final day2Todos = await todoDao.findByDate('2026-09-21');
      expect(day2Todos.any((t) => t.id == 'task-del'), isFalse);

      // Sept 20 query: task is preserved in history with dropped status and time segment intact!
      final day1Todos = await todoDao.findByDate('2026-09-20');
      expect(day1Todos.any((t) => t.id == 'task-del'), isTrue);
      final pastSegment = await timeSegmentDao.findById('seg-past');
      expect(pastSegment, isNotNull);
    },
  );
}
