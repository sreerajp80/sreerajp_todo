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
  }) : _database = database,
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
    final db = await openDatabaseAt(path, password: key, singleInstance: false);
    try {
      await runDatabaseMigrations(db, fromVersion, kDatabaseVersion);
    } finally {
      await db.close();
    }
  }

  /// Gives the database a brand new encryption key.
  ///
  /// The order matters. The database is rekeyed first, then the new key is
  /// stored. If storing fails the database is put straight back on the old
  /// key, so the app is never left holding a database it cannot open.
  ///
  /// Returns true only when both steps worked. Never logs either key.
  Future<bool> rotateDatabaseKey() async {
    final db = await database;
    final oldKey = await _databaseKeyService.getOrCreateDatabaseKey();
    final newKey = _databaseKeyService.generateKeyHex();

    // Flush the write-ahead log first, so nothing is left encrypted with the
    // old key in a side file.
    await db.rawQuery('PRAGMA wal_checkpoint(TRUNCATE)');

    try {
      await db.rawQuery("PRAGMA rekey = '$newKey'");
    } catch (_) {
      return false;
    }

    final stored = await _databaseKeyService.storeDatabaseKey(newKey);
    if (!stored) {
      try {
        await db.rawQuery("PRAGMA rekey = '$oldKey'");
      } catch (_) {
        // Nothing further can be done from here. The caller shows the failure
        // and tells the user to restore the backup they were asked to take.
      }
      return false;
    }

    // Reopen so every later query uses a connection that knows the new key.
    await close();
    await database;
    return true;
  }

  Future<void> close() async {
    final db = _database;
    if (db != null && db.isOpen) {
      await db.close();
      _database = null;
    }
  }
}
