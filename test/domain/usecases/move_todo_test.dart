import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_todo/core/errors/exceptions.dart';
import 'package:sreerajp_todo/data/dao/time_segment_dao.dart';
import 'package:sreerajp_todo/data/dao/todo_dao.dart';
import 'package:sreerajp_todo/data/dao/todo_history_dao.dart';
import 'package:sreerajp_todo/data/models/todo_entity.dart';
import 'package:sreerajp_todo/data/models/todo_history_entity.dart';
import 'package:sreerajp_todo/data/models/todo_status.dart';
import 'package:sreerajp_todo/data/repositories/time_segment_repository_impl.dart';
import 'package:sreerajp_todo/data/repositories/todo_repository_impl.dart';
import 'package:sreerajp_todo/domain/usecases/move_todo.dart';

import '../../helpers/test_database.dart';

String _todayIso() {
  final now = DateTime.now();
  return '${now.year.toString().padLeft(4, '0')}-'
      '${now.month.toString().padLeft(2, '0')}-'
      '${now.day.toString().padLeft(2, '0')}';
}

String _tomorrowIso() {
  final t = DateTime.now().add(const Duration(days: 1));
  return '${t.year.toString().padLeft(4, '0')}-'
      '${t.month.toString().padLeft(2, '0')}-'
      '${t.day.toString().padLeft(2, '0')}';
}

void main() {
  setUpAll(initFfi);

  late TodoDao todoDao;
  late TimeSegmentDao timeSegmentDao;
  late TodoHistoryDao historyDao;
  late TodoRepositoryImpl todoRepo;
  late TimeSegmentRepositoryImpl timeSegmentRepo;
  late MoveTodo moveTodoUseCase;

  setUp(() async {
    final dbService = await createTestDatabaseService();
    todoDao = TodoDao(dbService);
    timeSegmentDao = TimeSegmentDao(dbService);
    historyDao = TodoHistoryDao(dbService);
    todoRepo = TodoRepositoryImpl(
      todoDao,
      todoHistoryDao: historyDao,
      timeSegmentDao: timeSegmentDao,
    );
    timeSegmentRepo = TimeSegmentRepositoryImpl(
      timeSegmentDao,
      todoDao,
      dbService,
      todoHistoryDao: historyDao,
    );
    moveTodoUseCase = MoveTodo(todoRepo, timeSegmentRepo);
  });

  TodoEntity makeTodo({
    required String id,
    required String title,
    String? date,
    TodoStatus status = TodoStatus.pending,
  }) {
    final now = DateTime.now().toUtc().toIso8601String();
    return TodoEntity(
      id: id,
      date: date ?? _todayIso(),
      title: title,
      status: status,
      sortOrder: 0,
      createdAt: now,
      updatedAt: now,
    );
  }

  group('MoveTodo', () {
    test(
      'moves todo to target date directly and removes from previous day',
      () async {
        final todo = makeTodo(
          id: 'task-1',
          title: 'Plan future work',
          date: '2026-08-28',
        );
        await todoDao.insert(todo);

        final result = await moveTodoUseCase('task-1', _todayIso());
        expect(result.todoId, 'task-1');
        expect(result.fromDate, '2026-08-28');
        expect(result.toDate, _todayIso());

        // Task is no longer on previous day
        final prevTodos = await todoRepo.getTodosByDate('2026-08-28');
        expect(prevTodos.where((t) => t.id == 'task-1'), isEmpty);

        // Task is now on today with same ID
        final todayTodos = await todoRepo.getTodosByDate(_todayIso());
        final movedTodo = todayTodos.firstWhere((t) => t.id == 'task-1');
        expect(movedTodo.date, _todayIso());
        expect(movedTodo.title, 'Plan future work');

        // History is recorded
        final history = await todoRepo.getHistoryForTodo('task-1');
        expect(
          history.any((e) => e.eventType == TodoHistoryEventType.moved),
          isTrue,
        );
        final moveEvent = history.firstWhere(
          (e) => e.eventType == TodoHistoryEventType.moved,
        );
        expect(moveEvent.description, contains('2026-08-28'));
        expect(moveEvent.description, contains(_todayIso()));
      },
    );

    test('stops running timer when moving todo', () async {
      final todo = makeTodo(id: 'task-timer', title: 'Timing task');
      await todoDao.insert(todo);

      await timeSegmentRepo.startSegment('task-timer');
      final runningBefore = await timeSegmentRepo.getRunningSegment(
        'task-timer',
      );
      expect(runningBefore, isNotNull);

      await moveTodoUseCase('task-timer', _tomorrowIso());

      final runningAfter = await timeSegmentRepo.getRunningSegment(
        'task-timer',
      );
      expect(runningAfter, isNull);
    });

    test(
      'throws DuplicateTitleException if title already exists on target date',
      () async {
        final todo1 = makeTodo(
          id: 't-1',
          title: 'Duplicate Name',
          date: '2026-08-28',
        );
        final todo2 = makeTodo(
          id: 't-2',
          title: 'Duplicate Name',
          date: _todayIso(),
        );
        await todoDao.insert(todo1);
        await todoDao.insert(todo2);

        expect(
          () => moveTodoUseCase('t-1', _todayIso()),
          throwsA(isA<DuplicateTitleException>()),
        );
      },
    );

    test(
      'moved task history keeps original creation time and records moved time',
      () async {
        const originalCreationTime = '2026-08-25T08:30:00.000Z';
        const originalTodo = TodoEntity(
          id: 'task-orig',
          date: '2026-08-25',
          title: 'Preserve Creation Time Task',
          status: TodoStatus.pending,
          sortOrder: 0,
          createdAt: originalCreationTime,
          updatedAt: originalCreationTime,
        );
        await todoDao.insert(originalTodo);
        await todoRepo.logHistoryEvent(
          todoId: 'task-orig',
          eventType: TodoHistoryEventType.created,
          description: 'Task created for 2026-08-25',
          eventTime: originalCreationTime,
        );

        // Move to target date
        await moveTodoUseCase('task-orig', _todayIso());

        final history = await todoRepo.getHistoryForTodo('task-orig');
        expect(history.length, greaterThanOrEqualTo(2));

        final createdEvent = history.firstWhere(
          (e) => e.eventType == TodoHistoryEventType.created,
        );
        final movedEvent = history.firstWhere(
          (e) => e.eventType == TodoHistoryEventType.moved,
        );

        // Creation time must be original time
        expect(createdEvent.eventTime, originalCreationTime);
        expect(createdEvent.description, contains('2026-08-25'));

        // Moved time is later and records from/to
        expect(movedEvent.eventTime, isNot(originalCreationTime));
        expect(movedEvent.description, contains('2026-08-25'));
        expect(movedEvent.description, contains(_todayIso()));
      },
    );
  });
}
