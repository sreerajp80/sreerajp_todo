import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sreerajp_todo/core/constants/app_constants.dart';
import 'package:sreerajp_todo/data/database/database_service.dart';
import 'package:sreerajp_todo/data/database/migrations/migration_v1.dart';

bool _ffiInitialized = false;

void initFfi() {
  if (!_ffiInitialized) {
    sqfliteFfiInit();
    _ffiInitialized = true;
  }
}

Future<DatabaseService> createTestDatabaseService() async {
  initFfi();

  final db = await databaseFactoryFfi.openDatabase(
    inMemoryDatabasePath,
    options: OpenDatabaseOptions(
      version: 1,
      singleInstance: false,
      onCreate: (db, version) async {
        await runMigrationV1(db);
      },
      onOpen: (db) async {
        await db.rawQuery('PRAGMA foreign_keys=ON');
      },
    ),
  );

  return DatabaseService.forTesting(db);
}

Future<DatabaseService> createFileBackedTestDatabaseService(
  Directory directory,
) async {
  initFfi();

  final dbPath = p.join(directory.path, kDatabaseName);
  final db = await databaseFactoryFfi.openDatabase(
    dbPath,
    options: OpenDatabaseOptions(
      version: 1,
      singleInstance: false,
      onCreate: (db, version) async {
        await runMigrationV1(db);
      },
      onOpen: (db) async {
        await db.rawQuery('PRAGMA journal_mode=WAL');
        await db.rawQuery('PRAGMA foreign_keys=ON');
      },
    ),
  );

  return DatabaseService.forTesting(db, databasePath: dbPath);
}
