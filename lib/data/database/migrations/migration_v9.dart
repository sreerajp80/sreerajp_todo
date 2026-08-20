import 'package:sqflite_sqlcipher/sqlite_api.dart';

/// Database Migration V9: task priority and target time.
///
/// Two new columns on `todos`:
///  * `priority` — TEXT, not null, `'normal'` for every existing row.
///  * `target_seconds` — INTEGER, nullable. Null means "no target set".
///
/// Both are added with a `PRAGMA table_info` guard so the migration is safe to
/// run twice, matching the style of `migration_v8.dart`.
Future<void> runMigrationV9(Database db) async {
  await _addColumnIfMissing(
    db,
    table: 'todos',
    column: 'priority',
    definition: "TEXT NOT NULL DEFAULT 'normal'",
  );
  await _addColumnIfMissing(
    db,
    table: 'todos',
    column: 'target_seconds',
    definition: 'INTEGER',
  );

  // Sorting a day by priority reads this column for every row of one date, so
  // it is paired with the date the same way the status index is used.
  await db.execute(
    'CREATE INDEX IF NOT EXISTS idx_todos_priority ON todos (date, priority)',
  );
}

Future<void> _addColumnIfMissing(
  Database db, {
  required String table,
  required String column,
  required String definition,
}) async {
  final List<Map<String, Object?>> columns = await db.rawQuery(
    'PRAGMA table_info($table)',
  );
  final bool exists = columns.any(
    (Map<String, Object?> info) => info['name'] == column,
  );
  if (exists) return;

  await db.execute('ALTER TABLE $table ADD COLUMN $column $definition');
}
