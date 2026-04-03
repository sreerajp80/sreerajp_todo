import 'package:sqflite_sqlcipher/sqlite_api.dart';

Future<void> runMigrationV2(Database db) async {
  await db.execute('''
    UPDATE todos
    SET status = 'working'
    WHERE status = 'pending'
      AND EXISTS (
        SELECT 1
        FROM time_segments ts
        WHERE ts.todo_id = todos.id
      )
  ''');
}
