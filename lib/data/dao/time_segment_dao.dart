import 'package:sqflite_sqlcipher/sqlite_api.dart';
import 'package:sreerajp_todo/core/utils/unicode_utils.dart';
import 'package:sreerajp_todo/data/dao/todo_search_index_dao.dart';
import 'package:sreerajp_todo/data/database/database_service.dart';
import 'package:sreerajp_todo/data/models/time_segment_entity.dart';

class TimeSegmentDao {
  TimeSegmentDao(this._databaseService);

  final DatabaseService _databaseService;

  Future<void> insert(
    TimeSegmentEntity segment, {
    DatabaseExecutor? executor,
  }) async {
    final db = executor ?? await _databaseService.database;
    await db.insert('time_segments', segment.toMap());
    if (segment.notes != null && segment.notes!.isNotEmpty) {
      await reindexTodoInIndex(db, segment.todoId);
    }
  }

  /// Replaces the note on one segment. Pass null or an empty string to clear
  /// it. The parent todo is reindexed so the note becomes searchable.
  Future<void> updateNotes(String segId, String? notes) async {
    final db = await _databaseService.database;
    final trimmed = notes?.trim() ?? '';
    final stored = trimmed.isEmpty ? null : nfcNormalize(trimmed);

    final maps = await db.query(
      'time_segments',
      columns: ['todo_id'],
      where: 'id = ?',
      whereArgs: [segId],
      limit: 1,
    );
    if (maps.isEmpty) return;

    await db.update(
      'time_segments',
      {'notes': stored},
      where: 'id = ?',
      whereArgs: [segId],
    );
    await reindexTodoInIndex(db, maps.first['todo_id'] as String);
  }

  /// Replaces the start and end time of a closed segment and recomputes its
  /// duration. The parent todo is reindexed afterwards.
  ///
  /// Only call this on segments that already have an end_time. Running
  /// segments (end_time IS NULL) must be stopped first.
  Future<void> updateTimes(
    String segId,
    DateTime newStart,
    DateTime newEnd,
  ) async {
    final db = await _databaseService.database;

    final maps = await db.query(
      'time_segments',
      columns: ['todo_id'],
      where: 'id = ?',
      whereArgs: [segId],
      limit: 1,
    );
    if (maps.isEmpty) return;

    final durationSeconds = newEnd.difference(newStart).inSeconds;

    await db.update(
      'time_segments',
      {
        'start_time': newStart.toIso8601String(),
        'end_time': newEnd.toIso8601String(),
        'duration_seconds': durationSeconds,
      },
      where: 'id = ?',
      whereArgs: [segId],
    );
    await reindexTodoInIndex(db, maps.first['todo_id'] as String);
  }

  Future<void> closeSegment(
    String segId,
    DateTime endTime, {
    bool interrupted = false,
  }) async {
    final db = await _databaseService.database;
    final maps = await db.query(
      'time_segments',
      where: 'id = ?',
      whereArgs: [segId],
      limit: 1,
    );
    if (maps.isEmpty) return;

    final segment = TimeSegmentEntity.fromMap(maps.first);
    final startTime = DateTime.parse(segment.startTime);
    final durationSeconds = endTime.difference(startTime).inSeconds;

    final updateData = <String, dynamic>{
      'end_time': endTime.toIso8601String(),
      'duration_seconds': durationSeconds,
    };
    if (interrupted) {
      updateData['interrupted'] = 1;
    }

    await db.update(
      'time_segments',
      updateData,
      where: 'id = ?',
      whereArgs: [segId],
    );
  }

  Future<TimeSegmentEntity?> findById(
    String segId, {
    DatabaseExecutor? executor,
  }) async {
    final db = executor ?? await _databaseService.database;
    final maps = await db.query(
      'time_segments',
      where: 'id = ?',
      whereArgs: [segId],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return TimeSegmentEntity.fromMap(maps.first);
  }

  Future<List<TimeSegmentEntity>> findByTodoId(String todoId) async {
    final db = await _databaseService.database;
    final maps = await db.query(
      'time_segments',
      where: 'todo_id = ?',
      whereArgs: [todoId],
      orderBy: 'start_time ASC',
    );
    return maps.map(TimeSegmentEntity.fromMap).toList();
  }

  Future<TimeSegmentEntity?> findRunningSegment(
    String todoId, {
    DatabaseExecutor? executor,
  }) async {
    final db = executor ?? await _databaseService.database;
    final maps = await db.query(
      'time_segments',
      where: 'todo_id = ? AND end_time IS NULL',
      whereArgs: [todoId],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return TimeSegmentEntity.fromMap(maps.first);
  }

  /// Finds segments with no end_time on todos whose date is before [todayDate].
  Future<List<TimeSegmentEntity>> findAllOrphanedSegments(
    String todayDate,
  ) async {
    final db = await _databaseService.database;
    final maps = await db.rawQuery(
      '''
      SELECT ts.* FROM time_segments ts
      JOIN todos t ON ts.todo_id = t.id
      WHERE ts.end_time IS NULL AND t.date < ?
      ''',
      [todayDate],
    );
    return maps.map(TimeSegmentEntity.fromMap).toList();
  }

  /// Returns true if [startTime, endTime] overlaps any existing segment
  /// for the given [todoId]. Excludes [excludeId] if provided.
  Future<bool> hasOverlap({
    required String todoId,
    required String startTime,
    required String endTime,
    String? excludeId,
    DatabaseExecutor? executor,
  }) async {
    final db = executor ?? await _databaseService.database;
    final excludeClause = excludeId != null ? 'AND id != ?' : '';
    final args = <dynamic>[todoId, endTime, startTime];
    if (excludeId != null) args.add(excludeId);

    final result = await db.rawQuery('''
      SELECT COUNT(*) as cnt FROM time_segments
      WHERE todo_id = ?
        AND start_time < ?
        AND end_time > ?
        $excludeClause
      ''', args);
    final count = result.first['cnt'] as int;
    return count > 0;
  }

  /// Every open segment in the database, whatever todo it belongs to.
  ///
  /// Used by the "only one timer at a time" setting, which must stop a timer
  /// running on a different todo before a new one starts.
  Future<List<TimeSegmentEntity>> findAllRunningSegments({
    DatabaseExecutor? executor,
  }) async {
    final db = executor ?? await _databaseService.database;
    final maps = await db.query(
      'time_segments',
      where: 'end_time IS NULL',
      orderBy: 'start_time ASC',
    );
    return maps.map(TimeSegmentEntity.fromMap).toList();
  }

  /// Removes one segment by id and reindexes its parent todo, so a note that
  /// was on the segment stops showing up in search.
  Future<void> delete(String segId) async {
    final db = await _databaseService.database;
    final maps = await db.query(
      'time_segments',
      columns: ['todo_id'],
      where: 'id = ?',
      whereArgs: [segId],
      limit: 1,
    );
    if (maps.isEmpty) return;

    await db.delete('time_segments', where: 'id = ?', whereArgs: [segId]);
    await reindexTodoInIndex(db, maps.first['todo_id'] as String);
  }

  Future<void> deleteByTodoId(String todoId) async {
    final db = await _databaseService.database;
    await db.delete('time_segments', where: 'todo_id = ?', whereArgs: [todoId]);
    await reindexTodoInIndex(db, todoId);
  }
}
