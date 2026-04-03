import 'package:sreerajp_todo/core/constants/app_constants.dart';
import 'package:sreerajp_todo/core/utils/unicode_utils.dart';
import 'package:sreerajp_todo/data/database/database_service.dart';
import 'package:sreerajp_todo/data/models/statistics_models.dart';

class StatisticsQueryService {
  StatisticsQueryService(this._databaseService);

  final DatabaseService _databaseService;

  Future<List<DayStats>> getCountsPerDay({
    int limit = kStatisticsPageSize,
    int offset = 0,
    String? startDate,
    String? endDate,
  }) async {
    final db = await _databaseService.database;
    final filter = _buildTodoFilter(startDate: startDate, endDate: endDate);
    final maps = await db.rawQuery(
      '''
      SELECT
        t.date AS date,
        COUNT(*) AS total,
        SUM(CASE WHEN t.status = 'completed' THEN 1 ELSE 0 END) AS completed,
        SUM(CASE WHEN t.status = 'dropped' THEN 1 ELSE 0 END) AS dropped,
        SUM(CASE WHEN t.status = 'ported' THEN 1 ELSE 0 END) AS ported,
        SUM(CASE WHEN t.status = 'pending' THEN 1 ELSE 0 END) AS pending,
        SUM(CASE WHEN t.status = 'working' THEN 1 ELSE 0 END) AS working,
        COALESCE(SUM(COALESCE(seg.total_seconds, 0)), 0) AS total_seconds
      FROM todos t
      LEFT JOIN (
        SELECT todo_id, SUM(duration_seconds) AS total_seconds
        FROM time_segments
        WHERE duration_seconds IS NOT NULL
        GROUP BY todo_id
      ) seg ON seg.todo_id = t.id
      ${filter.whereClause}
      GROUP BY t.date
      ORDER BY t.date DESC
      LIMIT ? OFFSET ?
      ''',
      [...filter.args, limit, offset],
    );

    return maps
        .map(
          (map) => DayStats(
            date: map['date'] as String,
            total: _toInt(map['total']),
            completed: _toInt(map['completed']),
            dropped: _toInt(map['dropped']),
            ported: _toInt(map['ported']),
            pending: _toInt(map['pending']),
            working: _toInt(map['working']),
            totalSeconds: _toInt(map['total_seconds']),
          ),
        )
        .toList();
  }

  Future<int> getDayCount({String? startDate, String? endDate}) async {
    final db = await _databaseService.database;
    final filter = _buildTodoFilter(startDate: startDate, endDate: endDate);
    final maps = await db.rawQuery('''
      SELECT COUNT(*) AS total
      FROM (
        SELECT t.date
        FROM todos t
        ${filter.whereClause}
        GROUP BY t.date
      ) grouped_days
      ''', filter.args);

    return _toInt(maps.first['total']);
  }

  Future<List<TodoTimeStats>> getPerItemStats({
    int limit = kStatisticsPageSize,
    int offset = 0,
    String? startDate,
    String? endDate,
    String? titleQuery,
  }) async {
    final db = await _databaseService.database;
    final filter = _buildTodoFilter(
      startDate: startDate,
      endDate: endDate,
      titleQuery: titleQuery,
    );
    final maps = await db.rawQuery(
      '''
      SELECT
        t.title AS title,
        COUNT(*) AS appearances,
        SUM(CASE WHEN t.status = 'completed' THEN 1 ELSE 0 END) AS completed,
        SUM(CASE WHEN t.status = 'dropped' THEN 1 ELSE 0 END) AS dropped,
        SUM(CASE WHEN t.status = 'ported' THEN 1 ELSE 0 END) AS ported,
        SUM(CASE WHEN t.status = 'pending' THEN 1 ELSE 0 END) AS pending,
        SUM(CASE WHEN t.status = 'working' THEN 1 ELSE 0 END) AS working,
        COALESCE(SUM(COALESCE(seg.total_seconds, 0)), 0) AS total_seconds
      FROM todos t
      LEFT JOIN (
        SELECT todo_id, SUM(duration_seconds) AS total_seconds
        FROM time_segments
        WHERE duration_seconds IS NOT NULL
        GROUP BY todo_id
      ) seg ON seg.todo_id = t.id
      ${filter.whereClause}
      GROUP BY t.title
      ORDER BY total_seconds DESC, t.title COLLATE NOCASE ASC
      LIMIT ? OFFSET ?
      ''',
      [...filter.args, limit, offset],
    );

    return maps
        .map(
          (map) => TodoTimeStats(
            title: map['title'] as String,
            appearances: _toInt(map['appearances']),
            completed: _toInt(map['completed']),
            dropped: _toInt(map['dropped']),
            ported: _toInt(map['ported']),
            pending: _toInt(map['pending']),
            working: _toInt(map['working']),
            totalSeconds: _toInt(map['total_seconds']),
          ),
        )
        .toList();
  }

  Future<List<TodoTimeStats>> getTimePerTodoPerDay({
    int limit = kStatisticsPageSize,
    int offset = 0,
    String? startDate,
    String? endDate,
    String? titleQuery,
  }) {
    return getPerItemStats(
      limit: limit,
      offset: offset,
      startDate: startDate,
      endDate: endDate,
      titleQuery: titleQuery,
    );
  }

  Future<int> getPerItemCount({
    String? startDate,
    String? endDate,
    String? titleQuery,
  }) async {
    final db = await _databaseService.database;
    final filter = _buildTodoFilter(
      startDate: startDate,
      endDate: endDate,
      titleQuery: titleQuery,
    );
    final maps = await db.rawQuery('''
      SELECT COUNT(*) AS total
      FROM (
        SELECT t.title
        FROM todos t
        ${filter.whereClause}
        GROUP BY t.title
      ) grouped_titles
      ''', filter.args);

    return _toInt(maps.first['total']);
  }

  Future<List<TitleTimePoint>> getTimeSeriesForTitle(String title) async {
    final db = await _databaseService.database;
    final normalizedTitle = nfcNormalize(title);
    final maps = await db.rawQuery(
      '''
      SELECT
        t.title AS title,
        t.date AS date,
        t.status AS status,
        COALESCE(SUM(ts.duration_seconds), 0) AS total_seconds
      FROM todos t
      LEFT JOIN time_segments ts
        ON ts.todo_id = t.id
        AND ts.duration_seconds IS NOT NULL
      WHERE t.title = ?
      GROUP BY t.title, t.date, t.status
      ORDER BY t.date ASC
      ''',
      [normalizedTitle],
    );

    return maps
        .map(
          (map) => TitleTimePoint(
            title: map['title'] as String,
            date: map['date'] as String,
            status: map['status'] as String?,
            totalSeconds: _toInt(map['total_seconds']),
          ),
        )
        .toList();
  }

  Future<SummaryStats> getSummaryStats({
    String? startDate,
    String? endDate,
  }) async {
    final db = await _databaseService.database;
    final todoFilter = _buildTodoFilter(startDate: startDate, endDate: endDate);
    final segmentFilter = _buildSegmentFilter(
      startDate: startDate,
      endDate: endDate,
    );
    final productiveFilter = _buildSegmentFilter(
      startDate: startDate,
      endDate: endDate,
      status: 'completed',
    );
    final droppedFilter = _buildSegmentFilter(
      startDate: startDate,
      endDate: endDate,
      status: 'dropped',
    );

    final totalTodoMaps = await db.rawQuery(
      'SELECT COUNT(*) AS total FROM todos t ${todoFilter.whereClause}',
      todoFilter.args,
    );
    final completedMaps = await db.rawQuery('''
      SELECT COALESCE(
        SUM(CASE WHEN t.status = 'completed' THEN 1 ELSE 0 END),
        0
      ) AS completed_total
      FROM todos t
      ${todoFilter.whereClause}
      ''', todoFilter.args);
    final totalTimeMaps = await db.rawQuery('''
      SELECT COALESCE(SUM(ts.duration_seconds), 0) AS total_seconds
      FROM time_segments ts
      JOIN todos t ON ts.todo_id = t.id
      ${segmentFilter.whereClause}
      ''', segmentFilter.args);
    final productiveMaps = await db.rawQuery('''
      SELECT COALESCE(SUM(ts.duration_seconds), 0) AS productive_seconds
      FROM time_segments ts
      JOIN todos t ON ts.todo_id = t.id
      ${productiveFilter.whereClause}
      ''', productiveFilter.args);
    final droppedMaps = await db.rawQuery('''
      SELECT COALESCE(SUM(ts.duration_seconds), 0) AS dropped_seconds
      FROM time_segments ts
      JOIN todos t ON ts.todo_id = t.id
      ${droppedFilter.whereClause}
      ''', droppedFilter.args);
    final dayCount = await getDayCount(startDate: startDate, endDate: endDate);

    final totalTodos = _toInt(totalTodoMaps.first['total']);
    final completedTotal = _toInt(completedMaps.first['completed_total']);
    final totalTimeSeconds = _toInt(totalTimeMaps.first['total_seconds']);
    final productiveSeconds = _toInt(
      productiveMaps.first['productive_seconds'],
    );
    final droppedSeconds = _toInt(droppedMaps.first['dropped_seconds']);

    return SummaryStats(
      totalTodos: totalTodos,
      avgCompletedPerDay: dayCount == 0 ? 0 : completedTotal / dayCount,
      avgTimePerDaySeconds: dayCount == 0 ? 0 : totalTimeSeconds ~/ dayCount,
      totalProductiveTimeSeconds: productiveSeconds,
      totalDroppedTimeSeconds: droppedSeconds,
    );
  }

  _QueryFilter _buildTodoFilter({
    String? startDate,
    String? endDate,
    String? titleQuery,
  }) {
    final clauses = <String>[];
    final args = <Object?>[];

    if (startDate != null && startDate.isNotEmpty) {
      clauses.add('t.date >= ?');
      args.add(startDate);
    }
    if (endDate != null && endDate.isNotEmpty) {
      clauses.add('t.date <= ?');
      args.add(endDate);
    }
    if (titleQuery != null && titleQuery.isNotEmpty) {
      clauses.add('instr(t.title, ?) > 0');
      args.add(nfcNormalize(titleQuery));
    }

    return _QueryFilter(clauses: clauses, args: args);
  }

  _QueryFilter _buildSegmentFilter({
    String? startDate,
    String? endDate,
    String? status,
  }) {
    final clauses = <String>['ts.duration_seconds IS NOT NULL'];
    final args = <Object?>[];

    if (status != null && status.isNotEmpty) {
      clauses.add('t.status = ?');
      args.add(status);
    }
    if (startDate != null && startDate.isNotEmpty) {
      clauses.add('t.date >= ?');
      args.add(startDate);
    }
    if (endDate != null && endDate.isNotEmpty) {
      clauses.add('t.date <= ?');
      args.add(endDate);
    }

    return _QueryFilter(clauses: clauses, args: args);
  }

  int _toInt(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse('$value') ?? 0;
  }
}

class _QueryFilter {
  _QueryFilter({required this.clauses, required this.args});

  final List<String> clauses;
  final List<Object?> args;

  String get whereClause =>
      clauses.isEmpty ? '' : 'WHERE ${clauses.join(' AND ')}';
}
