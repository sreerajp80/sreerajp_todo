import 'package:sqflite_sqlcipher/sqlite_api.dart';

Future<void> runMigrationV4(Database db) async {
  await db.execute('''
    CREATE TABLE IF NOT EXISTS sub_tasks (
      id TEXT PRIMARY KEY,
      todo_id TEXT NOT NULL,
      title TEXT NOT NULL,
      is_completed INTEGER NOT NULL DEFAULT 0,
      sort_order INTEGER NOT NULL DEFAULT 0,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      FOREIGN KEY (todo_id) REFERENCES todos (id) ON DELETE CASCADE
    )
  ''');

  await db.execute('''
    CREATE TABLE IF NOT EXISTS task_dependencies (
      blocked_todo_id TEXT NOT NULL,
      prerequisite_todo_id TEXT NOT NULL,
      PRIMARY KEY (blocked_todo_id, prerequisite_todo_id),
      FOREIGN KEY (blocked_todo_id) REFERENCES todos (id) ON DELETE CASCADE,
      FOREIGN KEY (prerequisite_todo_id) REFERENCES todos (id) ON DELETE CASCADE
    )
  ''');

  await db.execute(
    'CREATE INDEX IF NOT EXISTS idx_sub_tasks_todo_id ON sub_tasks (todo_id)',
  );
  await db.execute(
    'CREATE INDEX IF NOT EXISTS idx_task_deps_blocked ON task_dependencies (blocked_todo_id)',
  );
  await db.execute(
    'CREATE INDEX IF NOT EXISTS idx_task_deps_prereq ON task_dependencies (prerequisite_todo_id)',
  );
}
