import 'package:sqflite_sqlcipher/sqlite_api.dart';
import 'package:sreerajp_todo/data/database/database_service.dart';
import 'package:sreerajp_todo/data/models/backup_log_entity.dart';

class BackupLogsDao {
  BackupLogsDao(this._databaseService);

  final DatabaseService _databaseService;

  Future<void> insertLog(
    BackupLogEntity log, {
    DatabaseExecutor? executor,
  }) async {
    final db = executor ?? await _databaseService.database;
    await db.insert(
      'backup_logs',
      log.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<BackupLogEntity>> getAllLogs({
    int limit = 50,
    DatabaseExecutor? executor,
  }) async {
    final db = executor ?? await _databaseService.database;
    final maps = await db.query(
      'backup_logs',
      orderBy: 'timestamp DESC',
      limit: limit,
    );
    return maps.map(BackupLogEntity.fromMap).toList();
  }

  Future<BackupLogEntity?> getLatestLog({
    DatabaseExecutor? executor,
  }) async {
    final db = executor ?? await _databaseService.database;
    final maps = await db.query(
      'backup_logs',
      orderBy: 'timestamp DESC',
      limit: 1,
    );
    if (maps.isEmpty) {
      return null;
    }
    return BackupLogEntity.fromMap(maps.first);
  }

  Future<void> clearLogs({
    DatabaseExecutor? executor,
  }) async {
    final db = executor ?? await _databaseService.database;
    await db.delete('backup_logs');
  }
}
