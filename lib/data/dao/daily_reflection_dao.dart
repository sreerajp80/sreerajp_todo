import 'package:sqflite_sqlcipher/sqlite_api.dart';
import 'package:sreerajp_todo/data/database/database_service.dart';
import 'package:sreerajp_todo/data/models/daily_intention_entity.dart';
import 'package:sreerajp_todo/data/models/daily_reflection_entity.dart';

class DailyReflectionDao {
  DailyReflectionDao(this._databaseService);

  final DatabaseService _databaseService;

  Future<DailyReflectionEntity?> findReflectionByDate(
    String date, {
    DatabaseExecutor? executor,
  }) async {
    final db = executor ?? await _databaseService.database;
    final maps = await db.query(
      'daily_reflections',
      where: 'date = ?',
      whereArgs: [date],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return DailyReflectionEntity.fromMap(maps.first);
  }

  Future<void> saveReflection(
    DailyReflectionEntity reflection, {
    DatabaseExecutor? executor,
  }) async {
    final db = executor ?? await _databaseService.database;
    await db.insert(
      'daily_reflections',
      reflection.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<DailyIntentionEntity?> findIntentionByDate(
    String date, {
    DatabaseExecutor? executor,
  }) async {
    final db = executor ?? await _databaseService.database;
    final maps = await db.query(
      'daily_intentions',
      where: 'date = ?',
      whereArgs: [date],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return DailyIntentionEntity.fromMap(maps.first);
  }

  Future<void> saveIntention(
    DailyIntentionEntity intention, {
    DatabaseExecutor? executor,
  }) async {
    final db = executor ?? await _databaseService.database;
    await db.insert(
      'daily_intentions',
      intention.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
