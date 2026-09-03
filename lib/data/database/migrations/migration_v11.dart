import 'package:sqflite_sqlcipher/sqlite_api.dart';

/// Database Migration V11: mark segments whose times were edited.
///
/// `time_segments` gains two columns:
///  * `edited_after_completion` — 1 once the start/end times were changed while
///    the parent todo was already completed or dropped. The flag is sticky: it
///    is never cleared, so an edit made after the task was finished stays
///    visible for good.
///  * `times_edited_at` — ISO 8601 UTC timestamp of the last time edit, set for
///    every time edit whether the task was finished or not.
///
/// Both are added only when missing, so re-running the migration is safe.
Future<void> runMigrationV11(Database db) async {
  final List<Map<String, Object?>> columns = await db.rawQuery(
    'PRAGMA table_info(time_segments)',
  );
  final existing = columns
      .map((Map<String, Object?> column) => column['name'])
      .toSet();

  if (!existing.contains('edited_after_completion')) {
    await db.execute(
      'ALTER TABLE time_segments '
      'ADD COLUMN edited_after_completion INTEGER NOT NULL DEFAULT 0',
    );
  }

  if (!existing.contains('times_edited_at')) {
    await db.execute(
      'ALTER TABLE time_segments ADD COLUMN times_edited_at TEXT',
    );
  }
}
