import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_todo/core/utils/date_utils.dart';
import 'package:sreerajp_todo/data/dao/recurrence_rule_dao.dart';
import 'package:sreerajp_todo/data/dao/todo_dao.dart';
import 'package:sreerajp_todo/data/database/database_service.dart';
import 'package:sreerajp_todo/data/models/recurrence_rule_entity.dart';
import 'package:sreerajp_todo/data/models/sub_task_item.dart';
import 'package:sreerajp_todo/data/models/todo_entity.dart';
import 'package:sreerajp_todo/data/models/todo_priority.dart';
import 'package:sreerajp_todo/data/models/todo_status.dart';
import 'package:sreerajp_todo/data/repositories/recurrence_rule_repository_impl.dart';
import 'package:sreerajp_todo/data/repositories/todo_repository_impl.dart';
import 'package:sreerajp_todo/domain/usecases/generate_recurring_tasks.dart';
import 'package:sreerajp_todo/domain/usecases/update_recurring_todos.dart';

import '../../helpers/test_database.dart';

void main() {
  late DatabaseService databaseService;
  late RecurrenceRuleDao ruleDao;
  late TodoDao todoDao;
  late RecurrenceRuleRepositoryImpl ruleRepo;
  late TodoRepositoryImpl todoRepo;
  late GenerateRecurringTasks generateRecurringTasks;
  late UpdateRecurringTodos useCase;

  setUpAll(initFfi);

  setUp(() async {
    databaseService = await createTestDatabaseService();
    ruleDao = RecurrenceRuleDao(databaseService);
    todoDao = TodoDao(databaseService);
    ruleRepo = RecurrenceRuleRepositoryImpl(ruleDao);
    todoRepo = TodoRepositoryImpl(todoDao);
    generateRecurringTasks = GenerateRecurringTasks(ruleRepo, todoRepo);
    useCase = UpdateRecurringTodos(todoRepo, ruleRepo, generateRecurringTasks);
  });

  tearDown(() async {
    await databaseService.close();
  });

  String nowUtc() => DateTime.now().toUtc().toIso8601String();

  RecurrenceRuleEntity makeRule({
    String id = 'rule-1',
    String title = 'Daily Task',
    String rrule = 'FREQ=DAILY',
  }) {
    final now = nowUtc();
    return RecurrenceRuleEntity(
      id: id,
      title: title,
      rrule: rrule,
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
    String title = 'Daily Task',
    TodoStatus status = TodoStatus.pending,
  }) {
    final now = nowUtc();
    return TodoEntity(
      id: id,
      date: date,
      title: title,
      status: status,
      priority: TodoPriority.normal,
      recurrenceRuleId: ruleId,
      sortOrder: 0,
      createdAt: now,
      updatedAt: now,
    );
  }

  group('UpdateRecurringTodos', () {
    test('thisInstanceOnly modifies only the selected instance', () async {
      final rule = makeRule();
      await ruleRepo.insert(rule);

      const pastDate = '2026-08-01';
      final today = todayAsIso();
      const futureDate = '2026-09-20';

      final pastTodo = makeTodo(id: 't-past', date: pastDate, ruleId: rule.id);
      final todayTodo = makeTodo(id: 't-today', date: today, ruleId: rule.id);
      final futureTodo = makeTodo(
        id: 't-future',
        date: futureDate,
        ruleId: rule.id,
      );

      await todoDao.insert(pastTodo);
      await todoRepo.createTodo(todayTodo);
      await todoRepo.createTodo(futureTodo);

      final updatedToday = todayTodo.copyWith(
        title: 'Updated Today Only',
        priority: TodoPriority.high,
      );

      await useCase.execute(
        baseTodo: todayTodo,
        updatedTodo: updatedToday,
        updatedRule: rule,
        target: RecurringEditTarget.thisInstanceOnly,
      );

      // Today is updated
      final reloadedToday = await todoRepo.getTodoById('t-today');
      expect(reloadedToday?.title, 'Updated Today Only');
      expect(reloadedToday?.priority, TodoPriority.high);
      expect(reloadedToday?.recurrenceRuleId, rule.id);

      // Past and future instances are unchanged
      final reloadedPast = await todoRepo.getTodoById('t-past');
      expect(reloadedPast?.title, 'Daily Task');
      final reloadedFuture = await todoRepo.getTodoById('t-future');
      expect(reloadedFuture?.title, 'Daily Task');

      // Rule is unchanged
      final reloadedRule = await ruleRepo.findById(rule.id);
      expect(reloadedRule?.title, 'Daily Task');
    });

    test(
      'allFutureInstances updates rule and future instances, leaving past instances untouched',
      () async {
        final rule = makeRule();
        await ruleRepo.insert(rule);

        const pastDate = '2026-08-01';
        final today = todayAsIso();
        const futureDate = '2026-09-20';

        final pastTodo = makeTodo(
          id: 't-past',
          date: pastDate,
          ruleId: rule.id,
        );
        final todayTodo = makeTodo(id: 't-today', date: today, ruleId: rule.id);
        final futureTodo = makeTodo(
          id: 't-future',
          date: futureDate,
          ruleId: rule.id,
        );

        await todoDao.insert(pastTodo);
        await todoRepo.createTodo(todayTodo);
        await todoRepo.createTodo(futureTodo);

        final updatedToday = todayTodo.copyWith(
          title: 'New Future Title',
          priority: TodoPriority.urgent,
          subTasks: [
            SubTaskItem(
              id: 'sub-1',
              todoId: 't-today',
              title: 'Subtask 1',
              isCompleted: false,
              createdAt: nowUtc(),
              updatedAt: nowUtc(),
            ),
          ],
        );
        final updatedRule = rule.copyWith(title: 'New Future Title');

        await useCase.execute(
          baseTodo: todayTodo,
          updatedTodo: updatedToday,
          updatedRule: updatedRule,
          target: RecurringEditTarget.allFutureInstances,
        );

        // Today updated
        final reloadedToday = await todoRepo.getTodoById('t-today');
        expect(reloadedToday?.title, 'New Future Title');
        expect(reloadedToday?.priority, TodoPriority.urgent);
        expect(reloadedToday?.subTasks.length, 1);

        // Future updated
        final reloadedFuture = await todoRepo.getTodoById('t-future');
        expect(reloadedFuture?.title, 'New Future Title');
        expect(reloadedFuture?.priority, TodoPriority.urgent);
        expect(reloadedFuture?.subTasks.length, 1);

        // Past untouched
        final reloadedPast = await todoRepo.getTodoById('t-past');
        expect(reloadedPast?.title, 'Daily Task');
        expect(reloadedPast?.priority, TodoPriority.normal);

        // Rule updated
        final reloadedRule = await ruleRepo.findById(rule.id);
        expect(reloadedRule?.title, 'New Future Title');
      },
    );

    test(
      'allInstances updates past, present, and future instances and rule',
      () async {
        final rule = makeRule();
        await ruleRepo.insert(rule);

        const pastDate = '2026-08-01';
        final today = todayAsIso();
        const futureDate = '2026-09-20';

        final pastTodo = makeTodo(
          id: 't-past',
          date: pastDate,
          ruleId: rule.id,
        );
        final todayTodo = makeTodo(id: 't-today', date: today, ruleId: rule.id);
        final futureTodo = makeTodo(
          id: 't-future',
          date: futureDate,
          ruleId: rule.id,
        );

        await todoDao.insert(pastTodo);
        await todoRepo.createTodo(todayTodo);
        await todoRepo.createTodo(futureTodo);

        final updatedToday = todayTodo.copyWith(
          title: 'New All Title',
          priority: TodoPriority.low,
        );
        final updatedRule = rule.copyWith(title: 'New All Title');

        await useCase.execute(
          baseTodo: todayTodo,
          updatedTodo: updatedToday,
          updatedRule: updatedRule,
          target: RecurringEditTarget.allInstances,
        );

        final reloadedToday = await todoRepo.getTodoById('t-today');
        expect(reloadedToday?.title, 'New All Title');

        final reloadedPast = await todoRepo.getTodoById('t-past');
        expect(reloadedPast?.title, 'New All Title');
        expect(reloadedPast?.priority, TodoPriority.low);

        final reloadedFuture = await todoRepo.getTodoById('t-future');
        expect(reloadedFuture?.title, 'New All Title');
        expect(reloadedFuture?.priority, TodoPriority.low);

        final reloadedRule = await ruleRepo.findById(rule.id);
        expect(reloadedRule?.title, 'New All Title');
      },
    );

    test(
      'allFutureInstances with repeat removed ends the rule and unlinks today',
      () async {
        final rule = makeRule();
        await ruleRepo.insert(rule);

        final today = todayAsIso();
        const futureDate = '2026-09-20';

        final todayTodo = makeTodo(id: 't-today', date: today, ruleId: rule.id);
        final futureTodo = makeTodo(
          id: 't-future',
          date: futureDate,
          ruleId: rule.id,
        );

        await todoRepo.createTodo(todayTodo);
        await todoRepo.createTodo(futureTodo);

        await useCase.execute(
          baseTodo: todayTodo,
          updatedTodo: todayTodo.copyWith(title: 'Stopped Repeating'),
          updatedRule: null,
          target: RecurringEditTarget.allFutureInstances,
        );

        final reloadedToday = await todoRepo.getTodoById('t-today');
        expect(reloadedToday?.title, 'Stopped Repeating');
        expect(reloadedToday?.recurrenceRuleId, isNull);

        // Future pending instance was deleted
        final reloadedFuture = await todoRepo.getTodoById('t-future');
        expect(reloadedFuture, isNull);

        // Rule has endDate set
        final reloadedRule = await ruleRepo.findById(rule.id);
        expect(reloadedRule?.endDate, isNotNull);
      },
    );
  });
}
