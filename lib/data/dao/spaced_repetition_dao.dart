import 'package:sqflite_sqlcipher/sqlite_api.dart';
import 'package:sreerajp_todo/core/utils/unicode_utils.dart';
import 'package:sreerajp_todo/data/database/database_service.dart';
import 'package:sreerajp_todo/data/models/spaced_repetition_item_entity.dart';

class SpacedRepetitionDao {
  SpacedRepetitionDao(this._databaseService);

  final DatabaseService _databaseService;

  Future<void> insert(
    SpacedRepetitionItemEntity item, {
    DatabaseExecutor? executor,
  }) async {
    final db = executor ?? await _databaseService.database;
    final normalized = item.copyWith(
      title: nfcNormalize(item.title),
      description: item.description != null
          ? nfcNormalize(item.description!)
          : null,
    );
    await db.insert('spaced_repetition_items', normalized.toMap());
  }

  Future<void> update(
    SpacedRepetitionItemEntity item, {
    DatabaseExecutor? executor,
  }) async {
    final db = executor ?? await _databaseService.database;
    final now = DateTime.now().toUtc().toIso8601String();
    final normalized = item.copyWith(
      title: nfcNormalize(item.title),
      description: item.description != null
          ? nfcNormalize(item.description!)
          : null,
      updatedAt: now,
    );
    await db.update(
      'spaced_repetition_items',
      normalized.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<void> delete(String id, {DatabaseExecutor? executor}) async {
    final db = executor ?? await _databaseService.database;
    await db.delete(
      'spaced_repetition_items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<SpacedRepetitionItemEntity?> findById(
    String id, {
    DatabaseExecutor? executor,
  }) async {
    final db = executor ?? await _databaseService.database;
    final maps = await db.query(
      'spaced_repetition_items',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return SpacedRepetitionItemEntity.fromMap(maps.first);
  }

  Future<SpacedRepetitionItemEntity?> findByTitle(
    String title, {
    DatabaseExecutor? executor,
  }) async {
    final db = executor ?? await _databaseService.database;
    final normalizedTitle = nfcNormalize(title);
    final maps = await db.query(
      'spaced_repetition_items',
      where: 'title = ?',
      whereArgs: [normalizedTitle],
    );
    if (maps.isEmpty) return null;
    return SpacedRepetitionItemEntity.fromMap(maps.first);
  }

  Future<List<SpacedRepetitionItemEntity>> findDueOnOrBefore(
    String dateStr, {
    DatabaseExecutor? executor,
  }) async {
    final db = executor ?? await _databaseService.database;
    final maps = await db.query(
      'spaced_repetition_items',
      where: 'active = 1 AND next_review_date <= ?',
      whereArgs: [dateStr],
      orderBy: 'next_review_date ASC',
    );
    return maps.map(SpacedRepetitionItemEntity.fromMap).toList();
  }

  Future<List<SpacedRepetitionItemEntity>> findAllActive({
    DatabaseExecutor? executor,
  }) async {
    final db = executor ?? await _databaseService.database;
    final maps = await db.query(
      'spaced_repetition_items',
      where: 'active = 1',
      orderBy: 'next_review_date ASC',
    );
    return maps.map(SpacedRepetitionItemEntity.fromMap).toList();
  }

  Future<List<SpacedRepetitionItemEntity>> findAll({
    DatabaseExecutor? executor,
  }) async {
    final db = executor ?? await _databaseService.database;
    final maps = await db.query(
      'spaced_repetition_items',
      orderBy: 'created_at DESC',
    );
    return maps.map(SpacedRepetitionItemEntity.fromMap).toList();
  }
}
