import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sreerajp_todo/data/database/migrations/migration_v10.dart';

import '../helpers/test_database.dart';

void main() {
  setUpAll(initFfi);

  Future<Database> openPreV10Database() async {
    final db = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(version: 9, singleInstance: false),
    );
    await db.execute('''
      CREATE TABLE todos (
        id TEXT PRIMARY KEY,
        date TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        status TEXT NOT NULL DEFAULT 'pending',
        priority TEXT NOT NULL DEFAULT 'normal',
        target_seconds INTEGER,
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

  group('migration v10', () {
    test('creates todo_history table and index', () async {
      final db = await openPreV10Database();

      await runMigrationV10(db);

      final columns = await columnsOf(db, 'todo_history');
      expect(columns, contains('id'));
      expect(columns, contains('todo_id'));
      expect(columns, contains('event_type'));
      expect(columns, contains('event_time'));
      expect(columns, contains('description'));
      expect(columns, contains('metadata'));
      expect(columns, contains('created_at'));

      await db.close();
    });

    test('running migration v10 twice is idempotent and safe', () async {
      final db = await openPreV10Database();
      await runMigrationV10(db);
      await runMigrationV10(db);

      final columns = await columnsOf(db, 'todo_history');
      expect(columns, contains('id'));
      expect(columns, contains('todo_id'));
      await db.close();
    });

    test(
      'fresh database is at version 10 and has todo_history table',
      () async {
        final service = await createTestDatabaseService();
        final db = await service.database;

        final columns = await columnsOf(db, 'todo_history');
        expect(columns, contains('id'));
        expect(columns, contains('todo_id'));

        final version = await db.rawQuery('PRAGMA user_version');
        expect(version.single['user_version'], 10);
        await service.close();
      },
    );
  });
}
