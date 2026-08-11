import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_sqlcipher/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' as ffi;
import 'package:sqflite_sqlcipher/sqflite.dart' as sqlcipher;
import 'package:sreerajp_todo/core/constants/app_constants.dart';
import 'package:sreerajp_todo/data/database/database_key_service.dart';
import 'package:sreerajp_todo/data/database/migrations/migration_runner.dart';

class DatabaseService {
  DatabaseService({DatabaseKeyService? databaseKeyService})
      : _databaseKeyService = databaseKeyService ?? DatabaseKeyService();

  DatabaseService.forTesting(
    Database database, {
    String? databasePath,
    DatabaseKeyService? databaseKeyService,
  })  : _database = database,
        _resolvedDatabasePath = databasePath,
        _databaseKeyService = databaseKeyService ?? DatabaseKeyService();

  final DatabaseKeyService _databaseKeyService;
  Database? _database;
  String? _resolvedDatabasePath;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    final path = await databasePath;
    final key = await _databaseKeyService.getOrCreateDatabaseKey();

    try {
      _database = await openDatabaseAt(
        path,
        version: kDatabaseVersion,
        password: key,
        onCreate: (db, version) async {
          await runDatabaseMigrations(db, 0, version);
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
    } catch (e) {
      final dbFile = File(path);
      if (await dbFile.exists()) {
        try {
          final unencryptedDb = await openDatabaseAt(
            path,
            singleInstance: false,
          );
          try {
            await unencryptedDb.rawQuery("PRAGMA rekey = '$key'");
          } finally {
            await unencryptedDb.close();
          }

          _database = await openDatabaseAt(
            path,
            version: kDatabaseVersion,
            password: key,
            onCreate: (db, version) async {
              await runDatabaseMigrations(db, 0, version);
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
        } catch (_) {
          rethrow;
        }
      }
      rethrow;
    }

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
      Future<void> effectiveOnOpen(Database db) async {
        if (password != null && password.isNotEmpty) {
          try {
            await db.rawQuery("PRAGMA key = '$password'");
          } catch (_) {}
        }
        if (onOpen != null) {
          await onOpen(db);
        }
      }

      return ffi.databaseFactoryFfi.openDatabase(
        path,
        options: ffi.OpenDatabaseOptions(
          version: version,
          onConfigure: onConfigure,
          onCreate: onCreate,
          onUpgrade: onUpgrade,
          onDowngrade: onDowngrade,
          onOpen: effectiveOnOpen,
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

    final key = await _databaseKeyService.getOrCreateDatabaseKey();
    final db = await openDatabaseAt(
      path,
      password: key,
      singleInstance: false,
    );
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

