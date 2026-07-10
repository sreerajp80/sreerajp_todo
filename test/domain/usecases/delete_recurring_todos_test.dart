import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_todo/core/utils/date_utils.dart';
import 'package:sreerajp_todo/data/dao/recurrence_rule_dao.dart';
import 'package:sreerajp_todo/data/dao/todo_dao.dart';
import 'package:sreerajp_todo/data/database/database_service.dart';
import 'package:sreerajp_todo/data/models/recurrence_rule_entity.dart';
import 'package:sreerajp_todo/data/models/todo_entity.dart';
import 'package:sreerajp_todo/data/models/todo_status.dart';
import 'package:sreerajp_todo/data/repositories/recurrence_rule_repository_impl.dart';
import 'package:sreerajp_todo/data/repositories/todo_repository_impl.dart';
import 'package:sreerajp_todo/domain/usecases/delete_recurring_todos.dart';
import 'package:sreerajp_todo/domain/usecases/generate_recurring_tasks.dart';

import '../../helpers/test_database.dart';

void main() {
  late DatabaseService databaseService;
  late RecurrenceRuleDao ruleDao;
  late TodoDao todoDao;
  late RecurrenceRuleRepositoryImpl ruleRepo;
  late TodoRepositoryImpl todoRepo;
  late DeleteRecurringTodos useCase;

  setUpAll(initFfi);

  setUp(() async {
    databaseService = await createTestDatabaseService();
    ruleDao = RecurrenceRuleDao(databaseService);
    todoDao = TodoDao(databaseService);
    ruleRepo = RecurrenceRuleRepositoryImpl(ruleDao);
    todoRepo = TodoRepositoryImpl(todoDao);
    useCase = DeleteRecurringTodos(todoRepo, ruleRepo);
  });

  tearDown(() async {
    await databaseService.close();
  });

  String nowUtc() => DateTime.now().toUtc().toIso8601String();

  RecurrenceRuleEntity makeRule({String id = 'rule-1'}) {
    final now = nowUtc();
    return RecurrenceRuleEntity(
      id: id,
      title: 'Daily Task',
      rrule: 'FREQ=DAILY',
      startDate: todayAsIso(),
      active: true,
      createdAt: now,
      updatedAt: now,
    );
  }

  TodoEntity makeTodo({
    required String id,
    required String date,
    required String ruleId,
  }) {
    final now = nowUtc();
    return TodoEntity(
      id: id,
      date: date,
      title: 'Daily Task',
      status: TodoStatus.pending,
      recurrenceRuleId: ruleId,
      sortOrder: 0,
      createdAt: now,
      updatedAt: now,
    );
  }

  test('all() deletes every occurrence and removes the rule', () async {
    await ruleDao.insert(makeRule());
    final today = DateTime.now();
    final d0 = dateTimeToIso(DateTime(today.year, today.month, today.day));
    final d1 = dateTimeToIso(
      DateTime(today.year, today.month, today.day).add(const Duration(days: 1)),
    );
    await todoRepo.createTodo(makeTodo(id: 't0', date: d0, ruleId: 'rule-1'));
    await todoRepo.createTodo(makeTodo(id: 't1', date: d1, ruleId: 'rule-1'));

    final count = await useCase.all('rule-1');

    expect(count, 2);
    expect(await todoRepo.getTodoById('t0'), isNull);
    expect(await todoRepo.getTodoById('t1'), isNull);
    expect(await ruleRepo.findById('rule-1'), isNull);
  });

  test('all() rule no longer regenerates tasks after deletion', () async {
    await ruleDao.insert(makeRule());
    final generate = GenerateRecurringTasks(ruleRepo, todoRepo);
    await generate.call();

    await useCase.all('rule-1');
    // A second generation pass (simulating an app relaunch) must create nothing.
    final regenerated = await generate.call();

    expect(regenerated, 0);
    expect(await ruleRepo.findActive(), isEmpty);
  });

  test(
    'thisAndFuture() deletes today + future but preserves past occurrences',
    () async {
      await ruleDao.insert(makeRule());
      final today = DateTime.now();
      final past = dateTimeToIso(DateTime(today.year, today.month, today.day - 1));
      final todayIso = dateTimeToIso(
        DateTime(today.year, today.month, today.day),
      );
      final future = dateTimeToIso(
        DateTime(today.year, today.month, today.day).add(const Duration(days: 1)),
      );
      // bypassLock so the past-dated row can be seeded directly via the DAO.
      await todoDao.insert(makeTodo(id: 'past', date: past, ruleId: 'rule-1'));
      await todoRepo.createTodo(
        makeTodo(id: 'today', date: todayIso, ruleId: 'rule-1'),
      );
      await todoRepo.createTodo(
        makeTodo(id: 'future', date: future, ruleId: 'rule-1'),
      );

      final count = await useCase.thisAndFuture('rule-1');

      expect(count, 2);
      expect(await todoRepo.getTodoById('past'), isNotNull);
      expect(await todoRepo.getTodoById('today'), isNull);
      expect(await todoRepo.getTodoById('future'), isNull);
    },
  );

  test(
    'thisAndFuture() ends the rule so it stops regenerating',
    () async {
      await ruleDao.insert(makeRule());
      final generate = GenerateRecurringTasks(ruleRepo, todoRepo);
      await generate.call();

      await useCase.thisAndFuture('rule-1');
      final regenerated = await generate.call();

      expect(regenerated, 0);

      final today = DateTime.now();
      final expectedEnd = dateTimeToIso(
        DateTime(today.year, today.month, today.day - 1),
      );
      final rule = await ruleRepo.findById('rule-1');
      expect(rule, isNotNull);
      expect(rule!.endDate, expectedEnd);
    },
  );
}
