import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_todo/data/dao/recurrence_rule_dao.dart';
import 'package:sreerajp_todo/data/database/database_service.dart';
import 'package:sreerajp_todo/data/models/recurrence_rule_entity.dart';

import '../helpers/test_database.dart';

void main() {
  late DatabaseService databaseService;
  late RecurrenceRuleDao ruleDao;

  setUpAll(initFfi);

  setUp(() async {
    databaseService = await createTestDatabaseService();
    ruleDao = RecurrenceRuleDao(databaseService);
  });

  tearDown(() async {
    await databaseService.close();
  });

  RecurrenceRuleEntity makeRule({
    String id = 'rule-1',
    String title = 'Daily Standup',
    String? description,
    String rrule = 'FREQ=DAILY',
    String startDate = '2026-03-01',
    String? endDate,
    bool active = true,
  }) {
    final now = DateTime.now().toUtc().toIso8601String();
    return RecurrenceRuleEntity(
      id: id,
      title: title,
      description: description,
      rrule: rrule,
      startDate: startDate,
      endDate: endDate,
      active: active,
      createdAt: now,
      updatedAt: now,
    );
  }

  group('insert and findById', () {
    test('inserts and retrieves a rule', () async {
      await ruleDao.insert(makeRule());

      final result = await ruleDao.findById('rule-1');
      expect(result, isNotNull);
      expect(result!.title, 'Daily Standup');
      expect(result.rrule, 'FREQ=DAILY');
      expect(result.active, isTrue);
    });

    test('returns null for nonexistent id', () async {
      final result = await ruleDao.findById('nonexistent');
      expect(result, isNull);
    });
  });

  group('findAll', () {
    test('returns all rules ordered by created_at desc', () async {
      await ruleDao.insert(makeRule(id: 'r1', title: 'First'));
      await Future<void>.delayed(const Duration(milliseconds: 10));
      await ruleDao.insert(makeRule(id: 'r2', title: 'Second'));

      final results = await ruleDao.findAll();
      expect(results, hasLength(2));
      expect(results.first.id, 'r2');
    });
  });

  group('findActive', () {
    test('returns only active rules', () async {
      await ruleDao.insert(makeRule(id: 'active-1', active: true));
      await ruleDao.insert(
        makeRule(id: 'inactive-1', title: 'Inactive', active: false),
      );

      final results = await ruleDao.findActive();
      expect(results, hasLength(1));
      expect(results.first.id, 'active-1');
    });

    test('returns empty when no active rules', () async {
      await ruleDao.insert(makeRule(active: false));
      final results = await ruleDao.findActive();
      expect(results, isEmpty);
    });
  });

  group('update', () {
    test('updates fields and bumps updated_at', () async {
      await ruleDao.insert(makeRule());
      final before = await ruleDao.findById('rule-1');
      final originalUpdatedAt = before!.updatedAt;

      await Future<void>.delayed(const Duration(milliseconds: 10));

      final modified = before.copyWith(
        title: 'Weekly Review',
        rrule: 'FREQ=WEEKLY',
      );
      await ruleDao.update(modified);

      final after = await ruleDao.findById('rule-1');
      expect(after!.title, 'Weekly Review');
      expect(after.rrule, 'FREQ=WEEKLY');
      expect(after.updatedAt, isNot(originalUpdatedAt));
    });
  });

  group('delete', () {
    test('removes the rule', () async {
      await ruleDao.insert(makeRule());
      await ruleDao.delete('rule-1');

      final result = await ruleDao.findById('rule-1');
      expect(result, isNull);
    });

    test('sets recurrence_rule_id to null on linked todos', () async {
      await ruleDao.insert(makeRule());

      final db = await databaseService.database;
      final now = DateTime.now().toUtc().toIso8601String();
      await db.insert('todos', {
        'id': 'todo-linked',
        'date': '2026-03-21',
        'title': 'Linked Todo',
        'status': 'pending',
        'recurrence_rule_id': 'rule-1',
        'sort_order': 0,
        'created_at': now,
        'updated_at': now,
      });

      await ruleDao.delete('rule-1');

      final todo = await db.query(
        'todos',
        where: 'id = ?',
        whereArgs: ['todo-linked'],
      );
      expect(todo.first['recurrence_rule_id'], isNull);
    });
  });
}
