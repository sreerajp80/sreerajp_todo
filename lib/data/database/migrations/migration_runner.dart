import 'package:sqflite_sqlcipher/sqlite_api.dart';
import 'package:sreerajp_todo/data/database/migrations/migration_v1.dart';

Future<void> runDatabaseMigrations(
  Database db,
  int oldVersion,
  int newVersion,
) async {
  if (oldVersion < 1 && newVersion >= 1) {
    final existingTables = await db.rawQuery('''
      SELECT COUNT(*) AS count
      FROM sqlite_master
      WHERE type = 'table'
        AND name IN ('recurrence_rules', 'todos', 'time_segments')
    ''');

    final countValue = existingTables.first['count'];
    final tableCount = countValue is int
        ? countValue
        : countValue is num
        ? countValue.toInt()
        : 0;

    if (tableCount == 0) {
      await runMigrationV1(db);
    }

    await db.rawQuery('PRAGMA user_version = 1');
  }
}
