import 'package:sqflite_sqlcipher/sqlite_api.dart';
import 'package:sreerajp_todo/data/database/database_service.dart';
import 'package:sreerajp_todo/data/models/sub_task_item.dart';

class SubTaskDao {
  SubTaskDao(this._databaseService);

  final DatabaseService _databaseService;

  Future<void> insert(
    SubTaskItem item, {
    DatabaseExecutor? executor,
  }) async {
    final db = executor ?? await _databaseService.database;
    await db.insert('sub_tasks', item.toMap());
  }

  Future<List<SubTaskItem>> findByTodoId(
    String todoId, {
    DatabaseExecutor? executor,
  }) async {
    final db = executor ?? await _databaseService.database;
    final maps = await db.query(
      'sub_tasks',
      where: 'todo_id = ?',
      whereArgs: [todoId],
      orderBy: 'sort_order ASC, created_at ASC',
    );
    return maps.map(SubTaskItem.fromMap).toList();
  }

  Future<void> saveAllForTodo(
    String todoId,
    List<SubTaskItem> subTasks, {
    DatabaseExecutor? executor,
  }) async {
    final db = executor ?? await _databaseService.database;
    await db.delete('sub_tasks', where: 'todo_id = ?', whereArgs: [todoId]);
    for (var i = 0; i < subTasks.length; i++) {
      final item = subTasks[i].copyWith(todoId: todoId, sortOrder: i);
      await db.insert('sub_tasks', item.toMap());
    }
  }

  Future<void> toggleSubTask(
    String subTaskId,
    bool isCompleted,
    String updatedAt, {
    DatabaseExecutor? executor,
  }) async {
    final db = executor ?? await _databaseService.database;
    await db.update(
      'sub_tasks',
      {
        'is_completed': isCompleted ? 1 : 0,
        'updated_at': updatedAt,
      },
      where: 'id = ?',
      whereArgs: [subTaskId],
    );
  }

  Future<void> deleteByTodoId(
    String todoId, {
    DatabaseExecutor? executor,
  }) async {
    final db = executor ?? await _databaseService.database;
    await db.delete('sub_tasks', where: 'todo_id = ?', whereArgs: [todoId]);
  }
}
