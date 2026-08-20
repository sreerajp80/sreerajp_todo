import 'package:sqflite_sqlcipher/sqlite_api.dart';
import 'package:sreerajp_todo/core/constants/app_constants.dart';
import 'package:sreerajp_todo/core/utils/indic_search_utils.dart';
import 'package:sreerajp_todo/data/dao/sub_task_dao.dart';
import 'package:sreerajp_todo/data/dao/task_dependency_dao.dart';
import 'package:sreerajp_todo/data/dao/todo_search_index_dao.dart';
import 'package:sreerajp_todo/data/database/database_service.dart';
import 'package:sreerajp_todo/data/models/todo_entity.dart';
import 'package:sreerajp_todo/data/models/todo_search_result.dart';
import 'package:sreerajp_todo/data/models/todo_status.dart';

class TodoDao {
  TodoDao(
    this._databaseService, {
    SubTaskDao? subTaskDao,
    TaskDependencyDao? taskDependencyDao,
  }) : _subTaskDao = subTaskDao ?? SubTaskDao(_databaseService),
       _taskDependencyDao =
           taskDependencyDao ?? TaskDependencyDao(_databaseService);

  final DatabaseService _databaseService;
  final SubTaskDao _subTaskDao;
  final TaskDependencyDao _taskDependencyDao;

  SubTaskDao get subTaskDao => _subTaskDao;
  TaskDependencyDao get taskDependencyDao => _taskDependencyDao;

  Future<void> insert(TodoEntity todo, {DatabaseExecutor? executor}) async {
    final db = executor ?? await _databaseService.database;
    await db.insert('todos', todo.toMap());
    await reindexTodoInIndex(db, todo.id);
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
    await reindexTodoInIndex(db, updated.id);
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

  /// Distinct titles starting with [prefix], capped at [limit].
  ///
  /// The cap is a real SQL `LIMIT`, so a smaller setting reads fewer rows
  /// rather than trimming a full list in Dart. The full title list is never
  /// held in memory.
  Future<List<String>> getAllDistinctTitles(
    String prefix, {
    int limit = kAutocompleteLimit,
  }) async {
    final db = await _databaseService.database;
    final maps = await db.rawQuery(
      'SELECT DISTINCT title FROM todos WHERE title LIKE ? LIMIT ?',
      ['$prefix%', limit],
    );
    return maps.map((m) => m['title'] as String).toList();
  }

  Future<List<TodoEntity>> searchByTitle(String query, {int limit = 50}) async {
    final db = await _databaseService.database;
    final ftsQuery = buildFtsMatchQuery(query);
    if (ftsQuery.isEmpty) return [];

    List<Map<String, dynamic>> maps;
    try {
      maps = await db.rawQuery(
        '''
        SELECT t.*
        FROM todos_fts fts
        JOIN todos t ON t.id = fts.todo_id
        WHERE todos_fts MATCH ?
        ORDER BY bm25(todos_fts), t.date DESC, t.sort_order ASC
        LIMIT ?
        ''',
        [ftsQuery, limit],
      );
    } catch (_) {
      // Last-resort fallback if the index is unavailable. Folding cannot be
      // applied inside SQL here, so this matches raw text only.
      final normalized = foldForSearch(query);
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

  /// Same search as [searchByTitle], but each hit also carries the segment
  /// note that matched, when the hit came from a note.
  Future<List<TodoSearchResult>> searchWithMatchedNotes(
    String query, {
    int limit = 50,
  }) async {
    final todos = await searchByTitle(query, limit: limit);
    if (todos.isEmpty) return [];

    final tokens = foldForSearch(
      query,
    ).split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();
    if (tokens.isEmpty) {
      return todos.map((t) => TodoSearchResult(todo: t)).toList();
    }

    final db = await _databaseService.database;
    final results = <TodoSearchResult>[];

    for (final todo in todos) {
      // Only look for a note when the visible text does not already explain
      // the hit, so the subtitle keeps showing the description where it can.
      final visible = foldForSearch('${todo.title} ${todo.description ?? ''}');
      final explained = tokens.every(visible.contains);
      if (explained) {
        results.add(TodoSearchResult(todo: todo));
        continue;
      }

      results.add(
        TodoSearchResult(
          todo: todo,
          matchedNote: await _findMatchingNote(db, todo.id, tokens),
        ),
      );
    }

    return results;
  }

  Future<String?> _findMatchingNote(
    DatabaseExecutor db,
    String todoId,
    List<String> tokens,
  ) async {
    final maps = await db.query(
      'time_segments',
      columns: ['notes'],
      where: "todo_id = ? AND notes IS NOT NULL AND notes != ''",
      whereArgs: [todoId],
      orderBy: 'start_time ASC',
    );

    for (final map in maps) {
      final note = map['notes'] as String;
      final folded = foldForSearch(note);
      if (tokens.any(folded.contains)) return note;
    }
    return null;
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
