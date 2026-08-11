import 'package:sqflite_sqlcipher/sqlite_api.dart';

Future<void> runMigrationV5(Database db) async {
  await db.execute('''
    CREATE TABLE IF NOT EXISTS daily_reflections (
      date TEXT PRIMARY KEY,
      reflection_note TEXT NOT NULL,
      completed_seconds INTEGER NOT NULL DEFAULT 0,
      dropped_seconds INTEGER NOT NULL DEFAULT 0,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    )
  ''');

  await db.execute('''
    CREATE TABLE IF NOT EXISTS daily_intentions (
      date TEXT PRIMARY KEY,
      intention_text TEXT NOT NULL,
      created_at TEXT NOT NULL
    )
  ''');
}
