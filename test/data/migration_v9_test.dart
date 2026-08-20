import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sreerajp_todo/data/database/migrations/migration_v9.dart';

import '../helpers/test_database.dart';

void main() {
  setUpAll(initFfi);

  /// A `todos` table shaped the way it was before v9.
  ///
  /// Built by hand rather than by running the migration chain, because
  /// `migration_v1.dart` now creates the two new columns itself, so a chain
  /// run would arrive already upgraded and prove nothing.
  Future<Database> openPreV9Database() async {
    final db = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(version: 8, singleInstance: false),
    );
    await db.execute('''
      CREATE TABLE todos (
        id TEXT PRIMARY KEY,
        date TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        status TEXT NOT NULL DEFAULT 'pending',
        ported_to TEXT,
        source_date TEXT,
        recurrence_rule_id TEXT,
        sort_order INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        UNIQUE (date, title)
      )
    ''');
    return db;
  }

  Future<Set<String>> columnsOf(Database db, String table) async {
    final info = await db.rawQuery('PRAGMA table_info($table)');
    return info.map((row) => row['name'] as String).toSet();
  }

  Future<void> insertOldRow(Database db, String id) async {
    final now = DateTime.now().toUtc().toIso8601String();
    await db.insert('todos', {
      'id': id,
      'date': '2026-08-01',
      'title': 'Written before v9 $id',
      'status': 'pending',
      'sort_order': 0,
      'created_at': now,
      'updated_at': now,
    });
  }

  group('migration v9', () {
    test('adds priority and target_seconds to an older database', () async {
      final db = await openPreV9Database();
      final before = await columnsOf(db, 'todos');
      expect(before, isNot(contains('priority')));
      expect(before, isNot(contains('target_seconds')));

      await runMigrationV9(db);

      final after = await columnsOf(db, 'todos');
      expect(after, contains('priority'));
      expect(after, contains('target_seconds'));
      await db.close();
    });

    test(
      'rows written before the migration read as normal with no target',
      () async {
        final db = await openPreV9Database();
        await insertOldRow(db, 'old-1');

        await runMigrationV9(db);

        final rows = await db.query(
          'todos',
          where: 'id = ?',
          whereArgs: ['old-1'],
        );
        expect(rows.single['priority'], 'normal');
        expect(rows.single['target_seconds'], isNull);
        await db.close();
      },
    );

    test('running it twice is safe', () async {
      final db = await openPreV9Database();
      await runMigrationV9(db);
      await runMigrationV9(db);

      final after = await columnsOf(db, 'todos');
      expect(after, contains('priority'));
      expect(after, contains('target_seconds'));
      await db.close();
    });

    test(
      'a fresh database already has both columns and is at version 9',
      () async {
        final service = await createTestDatabaseService();
        final db = await service.database;

        final columns = await columnsOf(db, 'todos');
        expect(columns, contains('priority'));
        expect(columns, contains('target_seconds'));

        final version = await db.rawQuery('PRAGMA user_version');
        expect(version.single['user_version'], 9);
        await service.close();
      },
    );
  });
}
