import 'package:sqflite_sqlcipher/sqlite_api.dart';

Future<void> runMigrationV6(Database db) async {
  await db.execute('''
    CREATE TABLE IF NOT EXISTS spaced_repetition_items (
      id TEXT PRIMARY KEY,
      title TEXT NOT NULL UNIQUE,
      description TEXT,
      level INTEGER NOT NULL DEFAULT 1,
      ease_factor REAL NOT NULL DEFAULT 2.5,
      interval_days INTEGER NOT NULL DEFAULT 1,
      next_review_date TEXT NOT NULL,
      last_reviewed_at TEXT,
      active INTEGER NOT NULL DEFAULT 1,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    )
  ''');

  final columns = await db.rawQuery('PRAGMA table_info(todos)');
  final hasColumn = columns.any(
    (c) => c['name'] == 'spaced_repetition_item_id',
  );
  if (!hasColumn) {
    await db.execute('''
      ALTER TABLE todos ADD COLUMN spaced_repetition_item_id TEXT
    ''');
  }

  await db.execute(
    'CREATE INDEX IF NOT EXISTS idx_srs_items_next_review ON spaced_repetition_items (next_review_date)',
  );
  await db.execute(
    'CREATE INDEX IF NOT EXISTS idx_todos_srs_item_id ON todos (spaced_repetition_item_id)',
  );
}
