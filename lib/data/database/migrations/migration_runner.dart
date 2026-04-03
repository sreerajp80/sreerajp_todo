import 'package:sqflite_sqlcipher/sqlite_api.dart';
import 'package:sreerajp_todo/data/database/migrations/migration_v1.dart';
import 'package:sreerajp_todo/data/database/migrations/migration_v2.dart';

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

    await db.execute('PRAGMA user_version = 1');
  }

  if (oldVersion < 2 && newVersion >= 2) {
    await runMigrationV2(db);
    await db.execute('PRAGMA user_version = 2');
  }
}
