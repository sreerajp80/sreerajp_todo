import 'package:sqflite_sqlcipher/sqlite_api.dart';
import 'package:sreerajp_todo/data/database/database_service.dart';
import 'package:sreerajp_todo/data/models/todo_entity.dart';

class TaskDependencyDao {
  TaskDependencyDao(this._databaseService);

  final DatabaseService _databaseService;

  Future<List<String>> getPrerequisiteIdsForTodo(
    String blockedTodoId, {
    DatabaseExecutor? executor,
  }) async {
    final db = executor ?? await _databaseService.database;
    final maps = await db.query(
      'task_dependencies',
      columns: ['prerequisite_todo_id'],
      where: 'blocked_todo_id = ?',
      whereArgs: [blockedTodoId],
    );
    return maps.map((m) => m['prerequisite_todo_id'] as String).toList();
  }

  Future<void> setPrerequisitesForTodo(
    String blockedTodoId,
    List<String> prerequisiteTodoIds, {
    DatabaseExecutor? executor,
  }) async {
    final db = executor ?? await _databaseService.database;
    await db.delete(
      'task_dependencies',
      where: 'blocked_todo_id = ?',
      whereArgs: [blockedTodoId],
    );
    for (final prereqId in prerequisiteTodoIds) {
      if (prereqId == blockedTodoId) continue;
      await db.insert('task_dependencies', {
        'blocked_todo_id': blockedTodoId,
        'prerequisite_todo_id': prereqId,
      });
    }
  }

  /// Returns list of prerequisite todos that are NOT completed.
  Future<List<TodoEntity>> getPendingPrerequisites(
    String blockedTodoId, {
    DatabaseExecutor? executor,
  }) async {
    final db = executor ?? await _databaseService.database;
    final maps = await db.rawQuery(
      '''
      SELECT t.* FROM todos t
      JOIN task_dependencies td ON t.id = td.prerequisite_todo_id
      WHERE td.blocked_todo_id = ? AND t.status != 'completed'
      ''',
      [blockedTodoId],
    );
    return maps.map(TodoEntity.fromMap).toList();
  }

  Future<void> deleteByTodoId(
    String todoId, {
    DatabaseExecutor? executor,
  }) async {
    final db = executor ?? await _databaseService.database;
    await db.delete(
      'task_dependencies',
      where: 'blocked_todo_id = ? OR prerequisite_todo_id = ?',
      whereArgs: [todoId, todoId],
    );
  }
}
