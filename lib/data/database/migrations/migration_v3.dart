import 'package:sqflite_sqlcipher/sqlite_api.dart';

Future<void> runMigrationV3(Database db) async {
  await db.execute('''
    CREATE VIRTUAL TABLE IF NOT EXISTS todos_fts USING fts5(
      todo_id UNINDEXED,
      title,
      description,
      tokenize = 'unicode61'
    )
  ''');

  await db.execute('''
    INSERT INTO todos_fts(todo_id, title, description)
    SELECT id, title, COALESCE(description, '') FROM todos
  ''');

  await db.execute('''
    CREATE TRIGGER IF NOT EXISTS todos_after_insert AFTER INSERT ON todos BEGIN
      INSERT INTO todos_fts(todo_id, title, description)
      VALUES (new.id, new.title, COALESCE(new.description, ''));
    END;
  ''');

  await db.execute('''
    CREATE TRIGGER IF NOT EXISTS todos_after_delete AFTER DELETE ON todos BEGIN
      DELETE FROM todos_fts WHERE todo_id = old.id;
    END;
  ''');

  await db.execute('''
    CREATE TRIGGER IF NOT EXISTS todos_after_update AFTER UPDATE ON todos BEGIN
      UPDATE todos_fts
      SET title = new.title,
          description = COALESCE(new.description, '')
      WHERE todo_id = new.id;
    END;
  ''');
}
