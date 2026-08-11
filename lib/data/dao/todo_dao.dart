import 'package:sqflite_sqlcipher/sqlite_api.dart';
import 'package:sreerajp_todo/core/utils/unicode_utils.dart';
import 'package:sreerajp_todo/data/dao/sub_task_dao.dart';
import 'package:sreerajp_todo/data/dao/task_dependency_dao.dart';
import 'package:sreerajp_todo/data/database/database_service.dart';
import 'package:sreerajp_todo/data/models/todo_entity.dart';
import 'package:sreerajp_todo/data/models/todo_status.dart';

class TodoDao {
  TodoDao(
    this._databaseService, {
    SubTaskDao? subTaskDao,
    TaskDependencyDao? taskDependencyDao,
  })  : _subTaskDao = subTaskDao ?? SubTaskDao(_databaseService),
        _taskDependencyDao =
            taskDependencyDao ?? TaskDependencyDao(_databaseService);

  final DatabaseService _databaseService;
  final SubTaskDao _subTaskDao;
  final TaskDependencyDao _taskDependencyDao;

  SubTaskDao get subTaskDao => _subTaskDao;
  TaskDependencyDao get taskDependencyDao => _taskDependencyDao;

  String _buildFtsQuery(String query) {
    final normalized = nfcNormalize(query).trim();
    if (normalized.isEmpty) return '';

    if (normalized.startsWith('"') &&
        normalized.endsWith('"') &&
        normalized.length > 2) {
      final phrase = normalized
          .substring(1, normalized.length - 1)
          .replaceAll('"', '""');
      return '"$phrase"';
    }

    final cleaned = normalized.replaceAll(RegExp(r'["*\^:()\-+]'), ' ');
    final words = cleaned.split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
    if (words.isEmpty) return '';
    return words.map((w) => '$w*').join(' AND ');
  }

  Future<void> insert(TodoEntity todo, {DatabaseExecutor? executor}) async {
    final db = executor ?? await _databaseService.database;
    await db.insert('todos', todo.toMap());
    if (todo.subTasks.isNotEmpty) {
      await _subTaskDao.saveAllForTodo(todo.id, todo.subTasks, executor: db);
    }
    if (todo.prerequisiteTodoIds.isNotEmpty) {
      await _taskDependencyDao.setPrerequisitesForTodo(
        todo.id,
        todo.prerequisiteTodoIds,
        executor: db,
      );
    }
  }

  Future<void> update(TodoEntity todo, {DatabaseExecutor? executor}) async {
    final db = executor ?? await _databaseService.database;
    final now = DateTime.now().toUtc().toIso8601String();
    final updated = todo.copyWith(updatedAt: now);
    await db.update(
      'todos',
      updated.toMap(),
      where: 'id = ?',
      whereArgs: [updated.id],
    );
    await _subTaskDao.saveAllForTodo(
      updated.id,
      updated.subTasks,
      executor: db,
    );
    await _taskDependencyDao.setPrerequisitesForTodo(
      updated.id,
      updated.prerequisiteTodoIds,
      executor: db,
    );
  }

  Future<void> updateStatus(
    String id,
    TodoStatus status, {
    String? portedTo,
    DatabaseExecutor? executor,
  }) async {
    final db = executor ?? await _databaseService.database;
    await db.update(
      'todos',
      {
        'status': status.toDbString(),
        'ported_to': status == TodoStatus.ported ? portedTo : null,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> delete(String id) async {
    final db = await _databaseService.database;
    await db.delete('todos', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteByRecurrenceRuleId(String recurrenceRuleId) async {
    final db = await _databaseService.database;
    return db.delete(
      'todos',
      where: 'recurrence_rule_id = ?',
      whereArgs: [recurrenceRuleId],
    );
  }

  Future<int> deleteByRecurrenceRuleIdFromDate(
    String recurrenceRuleId,
    String fromDate,
  ) async {
    final db = await _databaseService.database;
    return db.delete(
      'todos',
      where: 'recurrence_rule_id = ? AND date >= ?',
      whereArgs: [recurrenceRuleId, fromDate],
    );
  }

  Future<List<TodoEntity>> findByDate(String date) async {
    final db = await _databaseService.database;
    final maps = await db.query(
      'todos',
      where: 'date = ?',
      whereArgs: [date],
      orderBy: 'sort_order ASC, created_at ASC',
    );
    final todos = <TodoEntity>[];
    for (final map in maps) {
      final id = map['id'] as String;
      final subTasks = await _subTaskDao.findByTodoId(id, executor: db);
      final prereqIds = await _taskDependencyDao.getPrerequisiteIdsForTodo(
        id,
        executor: db,
      );
      todos.add(
        TodoEntity.fromMap(
          map,
          subTasks: subTasks,
          prerequisiteTodoIds: prereqIds,
        ),
      );
    }
    return todos;
  }

  Future<TodoEntity?> findById(String id) async {
    final db = await _databaseService.database;
    final maps = await db.query(
      'todos',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    final subTasks = await _subTaskDao.findByTodoId(id, executor: db);
    final prereqIds = await _taskDependencyDao.getPrerequisiteIdsForTodo(
      id,
      executor: db,
    );
    return TodoEntity.fromMap(
      maps.first,
      subTasks: subTasks,
      prerequisiteTodoIds: prereqIds,
    );
  }

  Future<bool> existsTitleOnDate(
    String title,
    String date, {
    String? excludeId,
  }) async {
    final db = await _databaseService.database;
    final where = excludeId != null
        ? 'title = ? AND date = ? AND id != ?'
        : 'title = ? AND date = ?';
    final whereArgs = excludeId != null
        ? [title, date, excludeId]
        : [title, date];
    final result = await db.query(
      'todos',
      where: where,
      whereArgs: whereArgs,
      limit: 1,
    );
    return result.isNotEmpty;
  }

  Future<List<String>> getAllDistinctTitles(String prefix) async {
    final db = await _databaseService.database;
    final maps = await db.rawQuery(
      'SELECT DISTINCT title FROM todos WHERE title LIKE ? LIMIT 20',
      ['$prefix%'],
    );
    return maps.map((m) => m['title'] as String).toList();
  }

  Future<List<TodoEntity>> searchByTitle(
    String query, {
    int limit = 50,
  }) async {
    final db = await _databaseService.database;
    final ftsQuery = _buildFtsQuery(query);
    if (ftsQuery.isEmpty) return [];

    List<Map<String, dynamic>> maps;
    try {
      maps = await db.rawQuery(
        '''
        SELECT t.*
        FROM todos_fts fts
        JOIN todos t ON t.id = fts.todo_id
        WHERE todos_fts MATCH ?
        ORDER BY t.date DESC, t.sort_order ASC
        LIMIT ?
        ''',
        [ftsQuery, limit],
      );
    } catch (_) {
      final normalized = nfcNormalize(query).trim();
      maps = await db.query(
        'todos',
        where: 'title LIKE ? OR description LIKE ?',
        whereArgs: ['%$normalized%', '%$normalized%'],
        limit: limit,
        orderBy: 'date DESC, sort_order ASC',
      );
    }

    final todos = <TodoEntity>[];
    for (final map in maps) {
      final id = map['id'] as String;
      final subTasks = await _subTaskDao.findByTodoId(id, executor: db);
      final prereqIds = await _taskDependencyDao.getPrerequisiteIdsForTodo(
        id,
        executor: db,
      );
      todos.add(
        TodoEntity.fromMap(
          map,
          subTasks: subTasks,
          prerequisiteTodoIds: prereqIds,
        ),
      );
    }
    return todos;
  }

  Future<int> maxSortOrder(String date) async {
    final db = await _databaseService.database;
    final result = await db.rawQuery(
      'SELECT MAX(sort_order) AS max_order FROM todos WHERE date = ?',
      [date],
    );
    final value = result.first['max_order'];
    if (value == null) return -1;
    return value as int;
  }

  Future<void> bulkInsert(List<TodoEntity> todos) async {
    if (todos.isEmpty) return;
    final db = await _databaseService.database;
    await db.transaction((txn) async {
      for (final todo in todos) {
        await insert(todo, executor: txn);
      }
    });
  }

  Future<void> updateSortOrders(List<TodoEntity> todos) async {
    final db = await _databaseService.database;
    final now = DateTime.now().toUtc().toIso8601String();
    await db.transaction((txn) async {
      for (final todo in todos) {
        await txn.update(
          'todos',
          {'sort_order': todo.sortOrder, 'updated_at': now},
          where: 'id = ?',
          whereArgs: [todo.id],
        );
      }
    });
  }
}
