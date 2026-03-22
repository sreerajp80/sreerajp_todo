import 'package:sreerajp_todo/data/database/database_service.dart';
import 'package:sreerajp_todo/data/models/todo_entity.dart';

class TodoDao {
  TodoDao(this._databaseService);

  final DatabaseService _databaseService;

  Future<void> insert(TodoEntity todo) async {
    final db = await _databaseService.database;
    await db.insert('todos', todo.toMap());
  }

  Future<void> update(TodoEntity todo) async {
    final db = await _databaseService.database;
    final now = DateTime.now().toUtc().toIso8601String();
    final updated = todo.copyWith(updatedAt: now);
    await db.update(
      'todos',
      updated.toMap(),
      where: 'id = ?',
      whereArgs: [updated.id],
    );
  }

  Future<void> delete(String id) async {
    final db = await _databaseService.database;
    await db.delete('todos', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<TodoEntity>> findByDate(String date) async {
    final db = await _databaseService.database;
    final maps = await db.query(
      'todos',
      where: 'date = ?',
      whereArgs: [date],
      orderBy: 'sort_order ASC, created_at ASC',
    );
    return maps.map(TodoEntity.fromMap).toList();
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
    return TodoEntity.fromMap(maps.first);
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

  Future<List<TodoEntity>> searchByTitle(String query, {int limit = 50}) async {
    final db = await _databaseService.database;
    final maps = await db.query(
      'todos',
      where: 'title LIKE ?',
      whereArgs: ['%$query%'],
      limit: limit,
      orderBy: 'date DESC, sort_order ASC',
    );
    return maps.map(TodoEntity.fromMap).toList();
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
        await txn.insert('todos', todo.toMap());
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
