import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sreerajp_todo/data/database/migrations/migration_v11.dart';

import '../helpers/test_database.dart';

void main() {
  setUpAll(initFfi);

  Future<Database> openPreV11Database() async {
    final db = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(version: 10, singleInstance: false),
    );
    await db.execute('''
      CREATE TABLE time_segments (
        id TEXT PRIMARY KEY,
        todo_id TEXT NOT NULL,
        start_time TEXT NOT NULL,
        end_time TEXT,
        duration_seconds INTEGER,
        interrupted INTEGER NOT NULL DEFAULT 0,
        manual INTEGER NOT NULL DEFAULT 0,
        notes TEXT,
        created_at TEXT NOT NULL
      )
    ''');
    return db;
  }

  Future<Set<String>> columnsOf(Database db, String table) async {
    final info = await db.rawQuery('PRAGMA table_info($table)');
    return info.map((row) => row['name'] as String).toSet();
  }

  group('migration v11', () {
    test('adds the edit-marker columns to time_segments', () async {
      final db = await openPreV11Database();

      await runMigrationV11(db);

      final columns = await columnsOf(db, 'time_segments');
      expect(columns, contains('edited_after_completion'));
      expect(columns, contains('times_edited_at'));

      await db.close();
    });

    test('existing rows default to not edited', () async {
      final db = await openPreV11Database();
      await db.insert('time_segments', {
        'id': 'seg-old',
        'todo_id': 'todo-old',
        'start_time': '2026-03-21T09:00:00.000',
        'end_time': '2026-03-21T10:00:00.000',
        'duration_seconds': 3600,
        'created_at': '2026-03-21T09:00:00.000Z',
      });

      await runMigrationV11(db);

      final rows = await db.query(
        'time_segments',
        where: 'id = ?',
        whereArgs: ['seg-old'],
      );
      expect(rows.single['edited_after_completion'], 0);
      expect(rows.single['times_edited_at'], isNull);

      await db.close();
    });

    test('running migration v11 twice is idempotent and safe', () async {
      final db = await openPreV11Database();

      await runMigrationV11(db);
      await runMigrationV11(db);

      final columns = await columnsOf(db, 'time_segments');
      expect(columns, contains('edited_after_completion'));
      expect(columns, contains('times_edited_at'));

      await db.close();
    });

    test('fresh database is at version 11 with the new columns', () async {
      final service = await createTestDatabaseService();
      final db = await service.database;

      final columns = await columnsOf(db, 'time_segments');
      expect(columns, contains('edited_after_completion'));
      expect(columns, contains('times_edited_at'));

      final version = await db.rawQuery('PRAGMA user_version');
      expect(version.single['user_version'], 11);

      await service.close();
    });
  });
}
