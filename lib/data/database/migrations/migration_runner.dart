import 'package:sqflite_sqlcipher/sqlite_api.dart';
import 'package:sreerajp_todo/data/database/migrations/migration_v1.dart';
import 'package:sreerajp_todo/data/database/migrations/migration_v2.dart';
import 'package:sreerajp_todo/data/database/migrations/migration_v3.dart';
import 'package:sreerajp_todo/data/database/migrations/migration_v4.dart';
import 'package:sreerajp_todo/data/database/migrations/migration_v5.dart';
import 'package:sreerajp_todo/data/database/migrations/migration_v6.dart';
import 'package:sreerajp_todo/data/database/migrations/migration_v7.dart';
import 'package:sreerajp_todo/data/database/migrations/migration_v8.dart';
import 'package:sreerajp_todo/data/database/migrations/migration_v9.dart';
import 'package:sreerajp_todo/data/database/migrations/migration_v10.dart';
import 'package:sreerajp_todo/data/database/migrations/migration_v11.dart';

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

  if (oldVersion < 3 && newVersion >= 3) {
    await runMigrationV3(db);
    await db.execute('PRAGMA user_version = 3');
  }

  if (oldVersion < 4 && newVersion >= 4) {
    await runMigrationV4(db);
    await db.execute('PRAGMA user_version = 4');
  }

  if (oldVersion < 5 && newVersion >= 5) {
    await runMigrationV5(db);
    await db.execute('PRAGMA user_version = 5');
  }

  if (oldVersion < 6 && newVersion >= 6) {
    await runMigrationV6(db);
    await db.execute('PRAGMA user_version = 6');
  }

  if (oldVersion < 7 && newVersion >= 7) {
    await runMigrationV7(db);
    await db.execute('PRAGMA user_version = 7');
  }

  if (oldVersion < 8 && newVersion >= 8) {
    await runMigrationV8(db);
    await db.execute('PRAGMA user_version = 8');
  }

  if (oldVersion < 9 && newVersion >= 9) {
    await runMigrationV9(db);
    await db.execute('PRAGMA user_version = 9');
  }

  if (oldVersion < 10 && newVersion >= 10) {
    await runMigrationV10(db);
    await db.execute('PRAGMA user_version = 10');
  }

  if (oldVersion < 11 && newVersion >= 11) {
    await runMigrationV11(db);
    await db.execute('PRAGMA user_version = 11');
  }
}
