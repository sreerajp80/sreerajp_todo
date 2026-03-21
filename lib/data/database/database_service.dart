import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:sreerajp_todo/core/constants/app_constants.dart';
import 'package:sreerajp_todo/data/database/migrations/migration_v1.dart';

class DatabaseService {
  DatabaseService();

  DatabaseService.forTesting(Database database) : _database = database;

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDir = await getApplicationDocumentsDirectory();
    final path = join(documentsDir.path, kDatabaseName);

    return openDatabase(
      path,
      version: kDatabaseVersion,
      onCreate: (db, version) async {
        await runMigrationV1(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // Future migrations go here
      },
      onOpen: (db) async {
        await db.execute('PRAGMA journal_mode=WAL');
        await db.execute('PRAGMA foreign_keys=ON');
      },
    );
  }

  Future<void> close() async {
    final db = _database;
    if (db != null && db.isOpen) {
      await db.close();
      _database = null;
    }
  }
}
