import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_todo/core/utils/date_utils.dart';
import 'package:sreerajp_todo/core/utils/unicode_utils.dart';
import 'package:sreerajp_todo/data/dao/recurrence_rule_dao.dart';
import 'package:sreerajp_todo/data/dao/todo_dao.dart';
import 'package:sreerajp_todo/data/database/database_service.dart';
import 'package:sreerajp_todo/data/models/recurrence_rule_entity.dart';
import 'package:sreerajp_todo/data/models/todo_entity.dart';
import 'package:sreerajp_todo/data/models/todo_status.dart';
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
    useCase = GenerateRecurringTasks(ruleDao, todoDao);
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
  });
}
