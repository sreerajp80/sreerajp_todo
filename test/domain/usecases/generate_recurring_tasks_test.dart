import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_todo/core/utils/date_utils.dart';
import 'package:sreerajp_todo/core/utils/unicode_utils.dart';
import 'package:sreerajp_todo/data/dao/recurrence_rule_dao.dart';
import 'package:sreerajp_todo/data/dao/todo_dao.dart';
import 'package:sreerajp_todo/data/database/database_service.dart';
import 'package:sreerajp_todo/domain/entities/recurrence_rule_entity.dart';
import 'package:sreerajp_todo/domain/entities/sub_task_item.dart';
import 'package:sreerajp_todo/domain/entities/todo_entity.dart';
import 'package:sreerajp_todo/domain/entities/todo_priority.dart';
import 'package:sreerajp_todo/domain/entities/todo_status.dart';
import 'package:sreerajp_todo/data/repositories/recurrence_rule_repository_impl.dart';
import 'package:sreerajp_todo/data/repositories/todo_repository_impl.dart';
import 'package:sreerajp_todo/domain/usecases/generate_recurring_tasks.dart';

import '../../helpers/test_database.dart';

void main() {
  late DatabaseService databaseService;
  late RecurrenceRuleDao ruleDao;
  late TodoDao todoDao;
  late GenerateRecurringTasks useCase;

  setUpAll(initFfi);

  setUp(() async {
    databaseService = await createTestDatabaseService();
    ruleDao = RecurrenceRuleDao(databaseService);
    todoDao = TodoDao(databaseService);
    useCase = GenerateRecurringTasks(
      RecurrenceRuleRepositoryImpl(ruleDao),
      TodoRepositoryImpl(todoDao),
    );
  });

  tearDown(() async {
    await databaseService.close();
  });

  String nowUtc() => DateTime.now().toUtc().toIso8601String();

  RecurrenceRuleEntity makeRule({
    String id = 'rule-1',
    String title = 'Daily Task',
    String? description,
    String rrule = 'FREQ=DAILY',
    String? startDate,
    String? endDate,
    bool active = true,
  }) {
    final now = nowUtc();
    return RecurrenceRuleEntity(
      id: id,
      title: title,
      description: description,
      rrule: rrule,
      startDate: startDate ?? todayAsIso(),
      endDate: endDate,
      active: active,
      createdAt: now,
      updatedAt: now,
    );
  }

  group('GenerateRecurringTasks', () {
    test('daily rule generates 8 tasks (today + 7 days)', () async {
      await ruleDao.insert(makeRule());

      final count = await useCase.call();
      expect(count, 8);

      final today = DateTime.now();
      for (var i = 0; i <= 7; i++) {
        final date = dateTimeToIso(
          DateTime(today.year, today.month, today.day).add(Duration(days: i)),
        );
        final todos = await todoDao.findByDate(date);
        expect(
          todos.where((t) => t.title == 'Daily Task').length,
          1,
          reason: 'Should have task on $date',
        );
        expect(todos.first.recurrenceRuleId, 'rule-1');
        expect(todos.first.status, TodoStatus.pending);
      }
    });

    test('weekly rule (Mon, Thu) generates correct subset', () async {
      await ruleDao.insert(
        makeRule(
          rrule: 'FREQ=WEEKLY;BYDAY=MO,TH',
          title: 'Weekly Meeting',
          startDate: '2020-01-01',
        ),
      );

      final count = await useCase.call();

      final today = DateTime.now();
      var expectedCount = 0;
      for (var i = 0; i <= 7; i++) {
        final d = DateTime(
          today.year,
          today.month,
          today.day,
        ).add(Duration(days: i));
        if (d.weekday == DateTime.monday || d.weekday == DateTime.thursday) {
          expectedCount++;
          final date = dateTimeToIso(d);
          final todos = await todoDao.findByDate(date);
          expect(
            todos.where((t) => t.title == 'Weekly Meeting').isNotEmpty,
            isTrue,
            reason: 'Should have task on $date (weekday=${d.weekday})',
          );
        }
      }
      expect(count, expectedCount);
    });

    test('duplicate detection: does not regenerate existing task', () async {
      await ruleDao.insert(makeRule());

      final firstRun = await useCase.call();
      expect(firstRun, 8);

      final secondRun = await useCase.call();
      expect(secondRun, 0, reason: 'All tasks already exist');

      final todos = await todoDao.findByDate(todayAsIso());
      expect(
        todos.where((t) => t.title == 'Daily Task').length,
        1,
        reason: 'Should have exactly one task, not a duplicate',
      );
    });

    test('paused rule (active=0) generates zero tasks', () async {
      await ruleDao.insert(makeRule(active: false));

      final count = await useCase.call();
      expect(count, 0);
    });

    test('rule with end_date in the past generates zero tasks', () async {
      await ruleDao.insert(
        makeRule(startDate: '2025-01-01', endDate: '2025-12-31'),
      );

      final count = await useCase.call();
      expect(count, 0);
    });

    test(
      'rule with end_date within window generates tasks only up to end_date',
      () async {
        final today = DateTime.now();
        final threeDaysFromNow = DateTime(
          today.year,
          today.month,
          today.day,
        ).add(const Duration(days: 3));
        final endDate = dateTimeToIso(threeDaysFromNow);

        await ruleDao.insert(makeRule(endDate: endDate));

        final count = await useCase.call();
        expect(count, 4, reason: 'today + 3 more days = 4 tasks');

        final dayAfterEnd = dateTimeToIso(
          threeDaysFromNow.add(const Duration(days: 1)),
        );
        final todosAfterEnd = await todoDao.findByDate(dayAfterEnd);
        expect(
          todosAfterEnd.where((t) => t.title == 'Daily Task').isEmpty,
          isTrue,
          reason: 'No tasks after end_date',
        );
      },
    );

    test(
      'NFC normalisation: decomposed title matches existing composed title',
      () async {
        // Insert a todo with NFC-composed title
        final todayStr = todayAsIso();
        final composedTitle = nfcNormalize('café');
        final now = nowUtc();
        await todoDao.insert(
          TodoEntity(
            id: 'existing-1',
            date: todayStr,
            title: composedTitle,
            status: TodoStatus.pending,
            sortOrder: 0,
            createdAt: now,
            updatedAt: now,
          ),
        );

        // Create a rule with decomposed title 'café' (e + combining acute)
        const decomposedTitle = 'caf\u0065\u0301';
        await ruleDao.insert(makeRule(title: decomposedTitle));

        final count = await useCase.call();

        final todayTodos = await todoDao.findByDate(todayStr);
        final matchingTodos = todayTodos
            .where((t) => t.title == composedTitle)
            .toList();
        expect(
          matchingTodos.length,
          1,
          reason: 'Should not duplicate because NFC-normalised titles match',
        );

        // Other days should still get the task (7 tasks, today skipped)
        expect(count, 7);
      },
    );

    test('generated tasks are appended at end of sort order', () async {
      final todayStr = todayAsIso();
      final now = nowUtc();

      await todoDao.insert(
        TodoEntity(
          id: 'manual-1',
          date: todayStr,
          title: 'Existing Task',
          status: TodoStatus.pending,
          sortOrder: 5,
          createdAt: now,
          updatedAt: now,
        ),
      );

      await ruleDao.insert(makeRule());
      await useCase.call();

      final todos = await todoDao.findByDate(todayStr);
      final generated = todos.firstWhere((t) => t.title == 'Daily Task');
      expect(generated.sortOrder, greaterThan(5));
    });

    test('multiple rules generate tasks independently', () async {
      await ruleDao.insert(
        makeRule(id: 'rule-a', title: 'Task A', rrule: 'FREQ=DAILY'),
      );
      await ruleDao.insert(
        makeRule(id: 'rule-b', title: 'Task B', rrule: 'FREQ=DAILY'),
      );

      final count = await useCase.call();
      expect(count, 16, reason: '8 days × 2 rules = 16 tasks');

      final todayTodos = await todoDao.findByDate(todayAsIso());
      expect(todayTodos.where((t) => t.title == 'Task A').length, 1);
      expect(todayTodos.where((t) => t.title == 'Task B').length, 1);
    });

    test('older rule without series values: new instances copy the '
        'existing instance', () async {
      final todayStr = todayAsIso();
      final now = nowUtc();
      await ruleDao.insert(makeRule());
      await todoDao.insert(
        TodoEntity(
          id: 'first',
          date: todayStr,
          title: 'Daily Task',
          priority: TodoPriority.high,
          targetSeconds: 1800,
          recurrenceRuleId: 'rule-1',
          subTasks: [
            SubTaskItem(
              id: 'st-1',
              todoId: 'first',
              title: 'Step one',
              isCompleted: true,
              createdAt: now,
              updatedAt: now,
            ),
            SubTaskItem(
              id: 'st-2',
              todoId: 'first',
              title: 'Step two',
              sortOrder: 1,
              createdAt: now,
              updatedAt: now,
            ),
          ],
          createdAt: now,
          updatedAt: now,
        ),
      );

      final count = await useCase.call();
      expect(count, 7, reason: 'Today already exists');

      final today = DateTime.now();
      final tomorrow = dateTimeToIso(
        DateTime(today.year, today.month, today.day + 1),
      );
      final generated = (await todoDao.findByDate(tomorrow))
          .firstWhere((t) => t.title == 'Daily Task');
      expect(generated.priority, TodoPriority.high);
      expect(generated.targetSeconds, 1800);
      expect(generated.subTasks.map((s) => s.title), ['Step one', 'Step two']);
      for (final st in generated.subTasks) {
        expect(st.isCompleted, isFalse);
        expect(st.todoId, generated.id);
        expect(st.id, isNot(anyOf('st-1', 'st-2')));
      }

      // The original instance keeps its own sub-tasks untouched.
      final original = await todoDao.findById('first');
      expect(original!.subTasks.length, 2);
      expect(original.subTasks.first.isCompleted, isTrue);
    });

    test('with no existing instance, defaults are used', () async {
      await ruleDao.insert(makeRule());
      await useCase.call();

      final generated = (await todoDao.findByDate(todayAsIso()))
          .firstWhere((t) => t.title == 'Daily Task');
      expect(generated.priority, TodoPriority.normal);
      expect(generated.targetSeconds, isNull);
      expect(generated.subTasks, isEmpty);
    });

    test('new instances use the series values stored on the rule', () async {
      await ruleDao.insert(
        makeRule().copyWith(
          priority: TodoPriority.urgent,
          targetSeconds: 900,
          subTaskTitles: ['Warm up', 'Practice'],
        ),
      );

      await useCase.call();

      final generated = (await todoDao.findByDate(todayAsIso()))
          .firstWhere((t) => t.title == 'Daily Task');
      expect(generated.priority, TodoPriority.urgent);
      expect(generated.targetSeconds, 900);
      expect(generated.subTasks.map((s) => s.title), ['Warm up', 'Practice']);
      for (final st in generated.subTasks) {
        expect(st.isCompleted, isFalse);
        expect(st.todoId, generated.id);
      }
    });

    test('a one-off edit of the latest occurrence is not copied', () async {
      // The series says "low". The latest occurrence was edited on its own
      // to "urgent" with an extra sub-task.
      await ruleDao.insert(
        makeRule().copyWith(
          priority: TodoPriority.low,
          targetSeconds: null,
          subTaskTitles: const [],
        ),
      );
      final now = nowUtc();
      await todoDao.insert(
        TodoEntity(
          id: 'edited-once',
          date: todayAsIso(),
          title: 'Daily Task',
          status: TodoStatus.pending,
          priority: TodoPriority.urgent,
          targetSeconds: 3600,
          recurrenceRuleId: 'rule-1',
          subTasks: [
            SubTaskItem(
              id: 'st-x',
              todoId: 'edited-once',
              title: 'Only today',
              createdAt: now,
              updatedAt: now,
            ),
          ],
          createdAt: now,
          updatedAt: now,
        ),
      );

      await useCase.call();

      final today = DateTime.now();
      final tomorrow = dateTimeToIso(
        DateTime(today.year, today.month, today.day + 1),
      );
      final generated = (await todoDao.findByDate(tomorrow))
          .firstWhere((t) => t.title == 'Daily Task');
      expect(generated.priority, TodoPriority.low);
      expect(generated.targetSeconds, isNull);
      expect(generated.subTasks, isEmpty);
    });
  });
}
