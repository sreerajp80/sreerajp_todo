import 'package:sqflite_sqlcipher/sqlite_api.dart';
import 'package:sreerajp_todo/data/database/database_service.dart';
import 'package:sreerajp_todo/data/models/todo_history_entity.dart';

class TodoHistoryDao {
  TodoHistoryDao(this._databaseService);

  final DatabaseService _databaseService;

  Future<void> insert(
    TodoHistoryEntity history, {
    DatabaseExecutor? executor,
  }) async {
    final db = executor ?? await _databaseService.database;
    await db.insert('todo_history', history.toMap());
  }

  Future<List<TodoHistoryEntity>> findByTodoId(
    String todoId, {
    DatabaseExecutor? executor,
  }) async {
    final db = executor ?? await _databaseService.database;
    final maps = await db.query(
      'todo_history',
      where: 'todo_id = ?',
      whereArgs: [todoId],
      orderBy: 'event_time ASC, created_at ASC',
    );
    return maps.map(TodoHistoryEntity.fromMap).toList();
  }

  Future<void> deleteByTodoId(
    String todoId, {
    DatabaseExecutor? executor,
  }) async {
    final db = executor ?? await _databaseService.database;
    await db.delete('todo_history', where: 'todo_id = ?', whereArgs: [todoId]);
  }
}
