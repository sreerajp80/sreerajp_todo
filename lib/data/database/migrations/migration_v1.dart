import 'package:sqflite_sqlcipher/sqflite.dart';

Future<void> runMigrationV1(Database db) async {
  await db.execute('''
    CREATE TABLE recurrence_rules (
      id TEXT PRIMARY KEY,
      title TEXT NOT NULL,
      description TEXT,
      rrule TEXT NOT NULL,
      start_date TEXT NOT NULL,
      end_date TEXT,
      active INTEGER NOT NULL DEFAULT 1,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    )
  ''');

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
      UNIQUE (date, title),
      FOREIGN KEY (recurrence_rule_id) REFERENCES recurrence_rules (id) ON DELETE SET NULL
    )
  ''');

  await db.execute('''
    CREATE TABLE time_segments (
      id TEXT PRIMARY KEY,
      todo_id TEXT NOT NULL,
      start_time TEXT NOT NULL,
      end_time TEXT,
      duration_seconds INTEGER,
      interrupted INTEGER NOT NULL DEFAULT 0,
      manual INTEGER NOT NULL DEFAULT 0,
      created_at TEXT NOT NULL,
      FOREIGN KEY (todo_id) REFERENCES todos (id) ON DELETE CASCADE
    )
  ''');

  await db.execute('CREATE INDEX idx_todos_date ON todos (date)');
  await db.execute('CREATE INDEX idx_todos_title ON todos (title)');
  await db.execute('CREATE INDEX idx_todos_status ON todos (status)');
  await db.execute(
    'CREATE INDEX idx_todos_recurrence ON todos (recurrence_rule_id)',
  );
  await db.execute(
    'CREATE INDEX idx_time_segments_todo_id ON time_segments (todo_id)',
  );
}
