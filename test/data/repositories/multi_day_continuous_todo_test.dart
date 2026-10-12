import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_todo/core/errors/exceptions.dart';
import 'package:sreerajp_todo/core/utils/date_utils.dart';
import 'package:sreerajp_todo/data/dao/time_segment_dao.dart';
import 'package:sreerajp_todo/data/dao/todo_dao.dart';
import 'package:sreerajp_todo/data/database/database_service.dart';
import 'package:sreerajp_todo/domain/entities/time_segment_entity.dart';
import 'package:sreerajp_todo/domain/entities/todo_entity.dart';
import 'package:sreerajp_todo/domain/entities/todo_status.dart';
import 'package:sreerajp_todo/data/repositories/time_segment_repository_impl.dart';
import 'package:sreerajp_todo/data/repositories/todo_repository_impl.dart';

import '../../helpers/test_database.dart';

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

  /// Today plus [days], so moves never target a locked past day.
  String dayFromToday(int days) {
    final now = DateTime.now();
    return dateTimeToIso(DateTime(now.year, now.month, now.day + days));
  }

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

  test('incomplete task created on day 1 appears on both day 1 and day 2 when carried forward', () async {
    final day1 = dayFromToday(-1);
    final day2 = dayFromToday(0);
    final todo = makeTodo(
      id: 'task-1',
      date: day1,
      title: 'Continuous task',
      status: TodoStatus.pending,
    );
    await todoDao.insert(todo);

    // Query on day 1: visible on day 1
    final day1Todos = await todoDao.findByDate(day1);
    expect(day1Todos.length, 1);
    expect(day1Todos.first.id, 'task-1');
    expect(day1Todos.first.date, day1);

    // When carried forward to day 2
    await todoRepo.moveTodo('task-1', day2);

    // Query on day 2: visible on day 2 as pending
    final day2Todos = await todoDao.findByDate(day2);
    expect(day2Todos.length, 1);
    expect(day2Todos.first.id, 'task-1');
    expect(day2Todos.first.date, day2);
    expect(day2Todos.first.sourceDate, day1);
    expect(day2Todos.first.status, TodoStatus.pending);

    // Query on day 1: STILL visible on day 1 (sourceDate <= date AND date >= sourceDate)
    final day1After = await todoDao.findByDate(day1);
    expect(day1After.length, 1);
    expect(day1After.first.id, 'task-1');
  });

  test(
    'an explicit move (detach) removes the task from the old date',
    () async {
      final oldDate = dayFromToday(-1);
      final newDate = dayFromToday(2);
      final todo = makeTodo(
        id: 'task-move',
        date: oldDate,
        title: 'Moved task',
        status: TodoStatus.pending,
      );
      await todoDao.insert(todo);

      await todoRepo.moveTodo('task-move', newDate, detach: true);

      final newDay = await todoDao.findByDate(newDate);
      expect(newDay.map((t) => t.id), contains('task-move'));

      final oldDay = await todoDao.findByDate(oldDate);
      expect(oldDay.where((t) => t.id == 'task-move'), isEmpty);

      // Days in between do not show it either.
      final middleDay = await todoDao.findByDate(dayFromToday(0));
      expect(middleDay.where((t) => t.id == 'task-move'), isEmpty);
    },
  );

  test('a move to a past day is refused', () async {
    await todoDao.insert(
      makeTodo(id: 'task-past', date: dayFromToday(0), title: 'Past move'),
    );

    expect(
      () => todoRepo.moveTodo('task-past', dayFromToday(-1)),
      throwsA(isA<DayLockedException>()),
    );
  });

  test('restoreMove puts back the date and start date exactly', () async {
    final start = dayFromToday(-2);
    final current = dayFromToday(0);
    await todoDao.insert(
      makeTodo(
        id: 'task-undo',
        date: current,
        title: 'Undo me',
        sourceDate: start,
      ),
    );

    await todoRepo.moveTodo('task-undo', dayFromToday(3), detach: true);
    expect((await todoDao.findById('task-undo'))!.sourceDate, isNull);

    await todoRepo.restoreMove(
      'task-undo',
      originalDate: current,
      originalSourceDate: start,
    );

    final restored = await todoDao.findById('task-undo');
    expect(restored!.date, current);
    expect(restored.sourceDate, start);
    // Visible again on the day it started.
    final firstDay = await todoDao.findByDate(start);
    expect(firstDay.map((t) => t.id), contains('task-undo'));
  });

  test('restoreMove may go back to a past day', () async {
    final yesterday = dayFromToday(-1);
    await todoDao.insert(
      makeTodo(id: 'task-back', date: yesterday, title: 'Carried'),
    );
    await todoRepo.moveTodo('task-back', dayFromToday(0));

    await todoRepo.restoreMove(
      'task-back',
      originalDate: yesterday,
      originalSourceDate: null,
    );

    final restored = await todoDao.findById('task-back');
    expect(restored!.date, yesterday);
    expect(restored.sourceDate, isNull);
  });

  test('restoreMove refuses a duplicate title on the old day', () async {
    final today = dayFromToday(0);
    await todoDao.insert(makeTodo(id: 'a', date: today, title: 'Same'));
    await todoRepo.moveTodo('a', dayFromToday(1), detach: true);
    await todoDao.insert(makeTodo(id: 'b', date: today, title: 'Same'));

    expect(
      () => todoRepo.restoreMove(
        'a',
        originalDate: today,
        originalSourceDate: null,
      ),
      throwsA(isA<DuplicateTitleException>()),
    );
  });

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

  test('renaming task across active dates throws MultiDayDuplicateTitleException on clash', () async {
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
  });

  test('deleteTodoFromDate drops task from today onwards and preserves past records', () async {
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
  });
}
