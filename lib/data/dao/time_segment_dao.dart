import 'package:sreerajp_todo/data/database/database_service.dart';
import 'package:sreerajp_todo/data/models/time_segment_entity.dart';

class TimeSegmentDao {
  TimeSegmentDao(this._databaseService);

  final DatabaseService _databaseService;

  Future<void> insert(TimeSegmentEntity segment) async {
    final db = await _databaseService.database;
    await db.insert('time_segments', segment.toMap());
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

  Future<TimeSegmentEntity?> findRunningSegment(String todoId) async {
    final db = await _databaseService.database;
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
  }) async {
    final db = await _databaseService.database;
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

  Future<void> deleteByTodoId(String todoId) async {
    final db = await _databaseService.database;
    await db.delete('time_segments', where: 'todo_id = ?', whereArgs: [todoId]);
  }
}
