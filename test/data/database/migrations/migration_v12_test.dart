import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sreerajp_todo/core/constants/app_constants.dart';
import 'package:sreerajp_todo/data/database/migrations/migration_v12.dart';
import 'package:sreerajp_todo/domain/entities/recurrence_rule_entity.dart';
import 'package:sreerajp_todo/domain/entities/todo_priority.dart';

import '../../../helpers/test_database.dart';

void main() {
  setUpAll(initFfi);

  Future<Database> openPreV12Database() async {
    final db = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(version: 11, singleInstance: false),
    );
    await db.execute('''
      CREATE TABLE recurrence_rules (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        rrule TEXT NOT NULL,
        start_date TEXT NOT NULL,
        end_date TEXT,
        active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
    return db;
  }

  Future<Set<String>> columnsOf(Database db, String table) async {
    final info = await db.rawQuery('PRAGMA table_info($table)');
    return info.map((row) => row['name'] as String).toSet();
  }

  group('migration v12', () {
    test('adds the series columns to recurrence_rules', () async {
      final db = await openPreV12Database();

      await runMigrationV12(db);

      final columns = await columnsOf(db, 'recurrence_rules');
      expect(
        columns,
        containsAll(['priority', 'target_seconds', 'sub_task_titles']),
      );

      await db.close();
    });

    test('existing rules keep null series values', () async {
      final db = await openPreV12Database();
      await db.insert('recurrence_rules', {
        'id': 'rule-old',
        'title': 'Old rule',
        'rrule': 'FREQ=DAILY',
        'start_date': '2026-03-21',
        'created_at': '2026-03-21T09:00:00.000Z',
        'updated_at': '2026-03-21T09:00:00.000Z',
      });

      await runMigrationV12(db);

      final rows = await db.query('recurrence_rules');
      final rule = RecurrenceRuleEntity.fromMap(rows.single);
      expect(rule.hasSeriesValues, isFalse);
      expect(rule.priority, isNull);
      expect(rule.targetSeconds, isNull);
      expect(rule.subTaskTitles, isNull);

      await db.close();
    });

    test('running migration v12 twice is safe', () async {
      final db = await openPreV12Database();

      await runMigrationV12(db);
      await runMigrationV12(db);

      final columns = await columnsOf(db, 'recurrence_rules');
      expect(columns, contains('sub_task_titles'));

      await db.close();
    });

    test('fresh database is at the current version with the columns', () async {
      final service = await createTestDatabaseService();
      final db = await service.database;

      final columns = await columnsOf(db, 'recurrence_rules');
      expect(
        columns,
        containsAll(['priority', 'target_seconds', 'sub_task_titles']),
      );
      final version = await db.rawQuery('PRAGMA user_version');
      expect(version.single['user_version'], kDatabaseVersion);
      expect(kDatabaseVersion, 12);

      await service.close();
    });
  });

  group('RecurrenceRuleEntity series values', () {
    test('round-trip through toMap and fromMap', () {
      const rule = RecurrenceRuleEntity(
        id: 'r1',
        title: 'Read',
        rrule: 'FREQ=DAILY',
        startDate: '2026-09-28',
        priority: TodoPriority.high,
        targetSeconds: 1800,
        subTaskTitles: ['Chapter', 'Notes'],
        createdAt: 'c',
        updatedAt: 'u',
      );

      final back = RecurrenceRuleEntity.fromMap(rule.toMap());

      expect(back.priority, TodoPriority.high);
      expect(back.targetSeconds, 1800);
      expect(back.subTaskTitles, ['Chapter', 'Notes']);
      expect(back.hasSeriesValues, isTrue);
    });

    test('fromMap reads an older map without the new keys', () {
      final rule = RecurrenceRuleEntity.fromMap({
        'id': 'r1',
        'title': 'Read',
        'description': null,
        'rrule': 'FREQ=DAILY',
        'start_date': '2026-09-28',
        'end_date': null,
        'active': 1,
        'created_at': 'c',
        'updated_at': 'u',
      });

      expect(rule.hasSeriesValues, isFalse);
      expect(rule.subTaskTitles, isNull);
    });

    test('fromMap ignores broken sub-task JSON', () {
      final rule = RecurrenceRuleEntity.fromMap({
        'id': 'r1',
        'title': 'Read',
        'rrule': 'FREQ=DAILY',
        'start_date': '2026-09-28',
        'active': 1,
        'priority': 'low',
        'sub_task_titles': 'not json',
        'created_at': 'c',
        'updated_at': 'u',
      });

      expect(rule.priority, TodoPriority.low);
      expect(rule.subTaskTitles, isNull);
    });
  });
}
