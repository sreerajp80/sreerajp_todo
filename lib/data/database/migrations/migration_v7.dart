import 'package:sqflite_sqlcipher/sqlite_api.dart';

/// Database Migration V7: Adds `backup_logs` table for automated health dashboard
/// and diagnostic execution logging.
Future<void> runMigrationV7(Database db) async {
  await db.execute('''
    CREATE TABLE IF NOT EXISTS backup_logs (
      id TEXT PRIMARY KEY,
      timestamp TEXT NOT NULL,
      status TEXT NOT NULL,
      file_path TEXT NOT NULL,
      file_size_bytes INTEGER NOT NULL DEFAULT 0,
      trigger_type TEXT NOT NULL,
      diagnostic_message TEXT NOT NULL DEFAULT '',
      created_at TEXT NOT NULL
    )
  ''');

  await db.execute('''
    CREATE INDEX IF NOT EXISTS idx_backup_logs_timestamp
    ON backup_logs(timestamp DESC)
  ''');
}
