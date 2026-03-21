import 'package:sreerajp_todo/data/database/database_service.dart';
import 'package:sreerajp_todo/data/models/statistics_models.dart';

class StatisticsQueryService {
  StatisticsQueryService(this._databaseService);

  final DatabaseService _databaseService;

  Future<List<DayStats>> getCountsPerDay({
    int limit = 50,
    int offset = 0,
  }) async {
    final db = await _databaseService.database;
    final maps = await db.rawQuery(
      '''
      SELECT date,
        COUNT(*) as total,
        SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END) as completed,
        SUM(CASE WHEN status = 'dropped' THEN 1 ELSE 0 END) as dropped,
        SUM(CASE WHEN status = 'ported' THEN 1 ELSE 0 END) as ported,
        SUM(CASE WHEN status = 'pending' THEN 1 ELSE 0 END) as pending
      FROM todos
      GROUP BY date
      ORDER BY date DESC
      LIMIT ? OFFSET ?
      ''',
      [limit, offset],
    );

    return maps
        .map(
          (m) => DayStats(
            date: m['date'] as String,
            total: m['total'] as int,
            completed: m['completed'] as int,
            dropped: m['dropped'] as int,
            ported: m['ported'] as int,
            pending: m['pending'] as int,
          ),
        )
        .toList();
  }

  Future<List<TodoTimeStats>> getTimePerTodoPerDay({
    int limit = 50,
    int offset = 0,
  }) async {
    final db = await _databaseService.database;
    final maps = await db.rawQuery(
      '''
      SELECT t.title, t.date,
        COALESCE(SUM(ts.duration_seconds), 0) as total_seconds
      FROM time_segments ts
      JOIN todos t ON ts.todo_id = t.id
      WHERE ts.duration_seconds IS NOT NULL
      GROUP BY t.title, t.date
      ORDER BY t.date DESC
      LIMIT ? OFFSET ?
      ''',
      [limit, offset],
    );

    return maps
        .map(
          (m) => TodoTimeStats(
            title: m['title'] as String,
            date: m['date'] as String,
            totalSeconds: m['total_seconds'] as int,
          ),
        )
        .toList();
  }

  Future<List<TodoTimeStats>> getTimePerTodo(
    String title, {
    int limit = 50,
    int offset = 0,
  }) async {
    final db = await _databaseService.database;
    final maps = await db.rawQuery(
      '''
      SELECT t.title, t.date,
        COALESCE(SUM(ts.duration_seconds), 0) as total_seconds
      FROM time_segments ts
      JOIN todos t ON ts.todo_id = t.id
      WHERE ts.duration_seconds IS NOT NULL AND t.title = ?
      GROUP BY t.title, t.date
      ORDER BY t.date DESC
      LIMIT ? OFFSET ?
      ''',
      [title, limit, offset],
    );

    return maps
        .map(
          (m) => TodoTimeStats(
            title: m['title'] as String,
            date: m['date'] as String,
            totalSeconds: m['total_seconds'] as int,
          ),
        )
        .toList();
  }
}
