import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_sqlcipher/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' as ffi;
import 'package:sqflite_sqlcipher/sqflite.dart' as sqlcipher;
import 'package:sreerajp_todo/core/constants/app_constants.dart';
import 'package:sreerajp_todo/data/database/migrations/migration_runner.dart';
import 'package:sreerajp_todo/data/database/migrations/migration_v1.dart';

class DatabaseService {
  DatabaseService();

  DatabaseService.forTesting(Database database, {String? databasePath})
    : _database = database,
      _resolvedDatabasePath = databasePath;

  Database? _database;
  String? _resolvedDatabasePath;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    final path = await databasePath;
    _database = await openDatabaseAt(
      path,
      version: kDatabaseVersion,
      onCreate: (db, version) async {
        await runMigrationV1(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        await runDatabaseMigrations(db, oldVersion, newVersion);
      },
      onOpen: (db) async {
        await db.rawQuery('PRAGMA journal_mode=WAL');
        await db.rawQuery('PRAGMA foreign_keys=ON');
      },
      singleInstance: true,
    );
    return _database!;
  }

  Future<String> get databasePath async {
    if (_resolvedDatabasePath != null) {
      return _resolvedDatabasePath!;
    }

    final documentsDir = await getApplicationDocumentsDirectory();
    _resolvedDatabasePath = p.join(documentsDir.path, kDatabaseName);
    return _resolvedDatabasePath!;
  }

  bool get _usesFfiRuntime =>
      Platform.isWindows ||
      Platform.isLinux ||
      Platform.environment['FLUTTER_TEST'] == 'true';

  Future<Database> openDatabaseAt(
    String path, {
    int? version,
    OnDatabaseConfigureFn? onConfigure,
    OnDatabaseCreateFn? onCreate,
    OnDatabaseVersionChangeFn? onUpgrade,
    OnDatabaseVersionChangeFn? onDowngrade,
    OnDatabaseOpenFn? onOpen,
    bool readOnly = false,
    bool singleInstance = false,
    String? password,
  }) async {
    if (_usesFfiRuntime) {
      if (password != null && password.isNotEmpty) {
        throw UnsupportedError(
          'Password-protected SQLite databases are not supported by the current desktop runtime.',
        );
      }

      return ffi.databaseFactoryFfi.openDatabase(
        path,
        options: ffi.OpenDatabaseOptions(
          version: version,
          onConfigure: onConfigure,
          onCreate: onCreate,
          onUpgrade: onUpgrade,
          onDowngrade: onDowngrade,
          onOpen: onOpen,
          readOnly: readOnly,
          singleInstance: singleInstance,
        ),
      );
    }

    return sqlcipher.openDatabase(
      path,
      version: version,
      onConfigure: onConfigure,
      onCreate: onCreate,
      onUpgrade: onUpgrade,
      onDowngrade: onDowngrade,
      onOpen: onOpen,
      readOnly: readOnly,
      singleInstance: singleInstance,
      password: password,
    );
  }

  Future<void> checkpoint() async {
    final db = await database;
    await db.rawQuery('PRAGMA wal_checkpoint(TRUNCATE)');
  }

  Future<void> migrateExternalDatabase(
    String path, {
    required int fromVersion,
  }) async {
    if (fromVersion >= kDatabaseVersion) {
      return;
    }

    final db = await openDatabaseAt(path, singleInstance: false);
    try {
      await runDatabaseMigrations(db, fromVersion, kDatabaseVersion);
    } finally {
      await db.close();
    }
  }

  Future<void> close() async {
    final db = _database;
    if (db != null && db.isOpen) {
      await db.close();
      _database = null;
    }
  }
}
