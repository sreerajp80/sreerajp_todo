import 'package:sqflite_sqlcipher/sqlite_api.dart';

/// Database Migration V10: Task history and activity log table.
///
/// Creates `todo_history` table storing timestamped lifecycle events:
///  * `id` — Primary key UUID
///  * `todo_id` — Foreign key referencing `todos(id)` ON DELETE CASCADE
///  * `event_type` — String identifying event type (created, moved, timer_started, timer_stopped, timer_paused, manual_segment_added, status_changed, subtask_toggled, edited)
///  * `event_time` — ISO 8601 UTC timestamp of event occurrence
///  * `description` — Human readable summary text
///  * `metadata` — Optional JSON serialized metadata payload
///  * `created_at` — Record creation timestamp
Future<void> runMigrationV10(Database db) async {
  await db.execute('''
    CREATE TABLE IF NOT EXISTS todo_history (
      id TEXT PRIMARY KEY,
      todo_id TEXT NOT NULL,
      event_type TEXT NOT NULL,
      event_time TEXT NOT NULL,
      description TEXT NOT NULL,
      metadata TEXT,
      created_at TEXT NOT NULL,
      FOREIGN KEY (todo_id) REFERENCES todos (id) ON DELETE CASCADE
    )
  ''');

  await db.execute('''
    CREATE INDEX IF NOT EXISTS idx_todo_history_todo_id 
    ON todo_history (todo_id, event_time ASC)
  ''');
}
