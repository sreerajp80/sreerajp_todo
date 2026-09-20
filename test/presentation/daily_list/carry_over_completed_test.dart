import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_todo/application/providers.dart';
import 'package:sreerajp_todo/core/utils/date_utils.dart';
import 'package:sreerajp_todo/core/utils/task_default_rules.dart';
import 'package:sreerajp_todo/data/dao/time_segment_dao.dart';
import 'package:sreerajp_todo/data/dao/todo_dao.dart';
import 'package:sreerajp_todo/data/dao/todo_history_dao.dart';
import 'package:sreerajp_todo/data/repositories/time_segment_repository_impl.dart';
import 'package:sreerajp_todo/data/repositories/todo_repository_impl.dart';
import 'package:sreerajp_todo/domain/usecases/move_todo.dart';
import 'package:sreerajp_todo/presentation/screens/daily_list/widgets/carry_over_sheet.dart';

import '../../helpers/test_database.dart';

void main() {
  setUpAll(initFfi);

  late TodoDao todoDao;
  late TimeSegmentDao timeSegmentDao;
  late TodoHistoryDao historyDao;
  late TodoRepositoryImpl todoRepo;
  late TimeSegmentRepositoryImpl timeSegmentRepo;
  late MoveTodo moveTodoUseCase;
  late ProviderContainer container;

  final today = todayAsIso();
  final target = parseIsoDate(today);
  final yesterday = dateTimeToIso(target.subtract(const Duration(days: 1)));
  final twoDaysAgo = dateTimeToIso(target.subtract(const Duration(days: 2)));

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

    container = ProviderContainer(
      overrides: [
        todoRepositoryProvider.overrideWithValue(todoRepo),
        timeSegmentRepositoryProvider.overrideWithValue(timeSegmentRepo),
        moveTodoProvider.overrideWithValue(moveTodoUseCase),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  TodoEntity createTestTodo({
    required String id,
    required String date,
    required String title,
    required TodoStatus status,
    String? sourceDate,
  }) {
    final now = DateTime.now().toUtc().toIso8601String();
    return TodoEntity(
      id: id,
      date: date,
      title: title,
      status: status,
      sourceDate: sourceDate,
      createdAt: now,
      updatedAt: now,
    );
  }

  group('Carry-over completed todos suppression and ID preservation', () {
    test(
      'findAllUnfinishedCandidates omits tasks completed on a more recent day',
      () async {
        // Setup:
        // Two days ago: task A is pending, task B is pending.
        final taskAOld = createTestTodo(
          id: 'task-a-old',
          date: twoDaysAgo,
          title: 'correct todo app mastery section',
          status: TodoStatus.pending,
        );
        final taskB = createTestTodo(
          id: 'task-b',
          date: twoDaysAgo,
          title: 'Developing Battery Soul Android App',
          status: TodoStatus.pending,
        );
        await todoDao.insert(taskAOld);
        await todoDao.insert(taskB);

        // Yesterday: task A was carried forward and COMPLETED.
        // Task C was created and is pending.
        final taskANew = createTestTodo(
          id: 'task-a-new',
          date: yesterday,
          title: 'correct todo app mastery section',
          status: TodoStatus.completed,
          sourceDate: twoDaysAgo,
        );
        final taskC = createTestTodo(
          id: 'task-c',
          date: yesterday,
          title: 'Develop Calculator app in flutter',
          status: TodoStatus.pending,
        );
        await todoDao.insert(taskANew);
        await todoDao.insert(taskC);

        // Scan unfinished candidates for today across 7 days:
        final candidates = await CarryOverSheet.findAllUnfinishedCandidates(
          container,
          targetDate: today,
          lookBackDays: 7,
        );

        final candidateTitles = candidates.map((t) => t.title).toList();

        // Task A was completed yesterday, so neither its yesterday nor two-days-ago
        // instances must ever be included in candidates!
        expect(
          candidateTitles.contains('correct todo app mastery section'),
          isFalse,
          reason: 'Completed task must not be brought forward',
        );

        // Pending tasks B and C should be included:
        expect(
          candidateTitles.contains('Develop Calculator app in flutter'),
          isTrue,
        );
        expect(
          candidateTitles.contains('Developing Battery Soul Android App'),
          isTrue,
        );
      },
    );

    test(
      'Carrying forward a task moves the task and preserves its todo ID and journey',
      () async {
        const originalId = 'unique-task-journey-id';
        final pendingTask = createTestTodo(
          id: originalId,
          date: yesterday,
          title: 'Develop Calculator app in flutter',
          status: TodoStatus.pending,
        );
        await todoDao.insert(pendingTask);

        // Move to today (carry forward)
        await moveTodoUseCase(originalId, today);

        // Verify it is on today with the exact same ID
        final movedTask = await todoRepo.getTodoById(originalId);
        expect(movedTask, isNotNull);
        expect(
          movedTask!.id,
          equals(originalId),
          reason: 'Todo ID must not change',
        );
        expect(movedTask.date, equals(today), reason: 'Date must be today');
        expect(
          movedTask.sourceDate,
          equals(yesterday),
          reason: 'Original sourceDate preserved',
        );

        // Verify task remains visible on yesterday as part of its multi-day journey
        final yesterdayTodos = await todoRepo.getTodosByDate(yesterday);
        expect(yesterdayTodos.any((t) => t.id == originalId), isTrue);

        // Complete the task on today
        await todoRepo.updateStatus(originalId, TodoStatus.completed);

        // When scanning for tomorrow, the completed task is NOT a candidate
        final tomorrow = dateTimeToIso(target.add(const Duration(days: 1)));
        final candidatesForTomorrow =
            await CarryOverSheet.findAllUnfinishedCandidates(
              container,
              targetDate: tomorrow,
              lookBackDays: 7,
            );
        expect(
          candidatesForTomorrow.any((t) => t.id == originalId),
          isFalse,
          reason: 'Completed task cannot be carried over to tomorrow',
        );
      },
    );

    test(
      'findCandidates returns empty when all tasks on previous days were completed',
      () async {
        final completedYesterday = createTestTodo(
          id: 'task-done-yesterday',
          date: yesterday,
          title: 'Meditation',
          status: TodoStatus.completed,
        );
        final oldPendingTwoDaysAgo = createTestTodo(
          id: 'task-done-old',
          date: twoDaysAgo,
          title: 'Meditation',
          status: TodoStatus.pending,
        );
        await todoDao.insert(completedYesterday);
        await todoDao.insert(oldPendingTwoDaysAgo);

        final candidates = await CarryOverSheet.findCandidates(
          container,
          targetDate: today,
          lookBack: CarryOverLookBack.lastSevenDays,
        );

        expect(candidates, isEmpty);
      },
    );

    test(
      'pendingAlertPayloadProvider omits tasks that were completed or dropped on more recent days',
      () async {
        final taskCompleted = createTestTodo(
          id: 'task-comp-yesterday',
          date: yesterday,
          title: 'correct todo app mastery section',
          status: TodoStatus.completed,
        );
        final legacyPending = createTestTodo(
          id: 'task-legacy-pending',
          date: twoDaysAgo,
          title: 'correct todo app mastery section',
          status: TodoStatus.pending,
        );
        final realPending = createTestTodo(
          id: 'real-pending',
          date: twoDaysAgo,
          title: 'Developing Battery Soul Android App',
          status: TodoStatus.pending,
        );

        await todoDao.insert(taskCompleted);
        await todoDao.insert(legacyPending);
        await todoDao.insert(realPending);

        final payload = await container.read(
          pendingAlertPayloadProvider.future,
        );

        final previousTitles = payload.previousTodos
            .map((t) => t.title)
            .toList();
        expect(
          previousTitles.contains('correct todo app mastery section'),
          isFalse,
          reason: 'Completed task must not show in pending alerts',
        );
        expect(
          previousTitles.contains('Developing Battery Soul Android App'),
          isTrue,
        );
      },
    );

    test('Dropped tasks are not resurrected from older days', () async {
      final taskDropped = createTestTodo(
        id: 'task-dropped',
        date: yesterday,
        title: 'Deprecated feature',
        status: TodoStatus.dropped,
      );
      final legacyPending = createTestTodo(
        id: 'task-legacy-dep',
        date: twoDaysAgo,
        title: 'Deprecated feature',
        status: TodoStatus.pending,
      );
      await todoDao.insert(taskDropped);
      await todoDao.insert(legacyPending);

      final candidates = await CarryOverSheet.findAllUnfinishedCandidates(
        container,
        targetDate: today,
        lookBackDays: 7,
      );

      expect(
        candidates.any((t) => t.title == 'Deprecated feature'),
        isFalse,
        reason: 'Dropped tasks must not be carried over',
      );
    });
  });
}
