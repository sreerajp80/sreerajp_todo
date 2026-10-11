import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_todo/data/dao/todo_dao.dart';
import 'package:sreerajp_todo/data/dao/todo_search_index_dao.dart';
import 'package:sreerajp_todo/data/database/database_service.dart';
import 'package:sreerajp_todo/domain/entities/todo_entity.dart';
import 'package:sreerajp_todo/domain/entities/todo_status.dart';

import '../../helpers/test_database.dart';

void main() {
  setUpAll(initFfi);

  late DatabaseService dbService;
  late TodoDao todoDao;
  late TodoSearchIndexDao indexDao;

  setUp(() async {
    dbService = await createTestDatabaseService();
    todoDao = TodoDao(dbService);
    indexDao = TodoSearchIndexDao(dbService);
  });

  TodoEntity todo(String id, String title, {String? description}) {
    const now = '2026-10-05T08:00:00.000Z';
    return TodoEntity(
      id: id,
      date: '2026-10-05',
      title: title,
      description: description,
      status: TodoStatus.pending,
      sortOrder: 0,
      createdAt: now,
      updatedAt: now,
    );
  }

  Future<List<Map<String, Object?>>> indexRows([String? todoId]) async {
    final db = await dbService.database;
    return db.query(
      kTodosFtsTable,
      where: todoId == null ? null : 'todo_id = ?',
      whereArgs: todoId == null ? null : <Object?>[todoId],
    );
  }

  Future<void> addSegmentNote(String id, String todoId, String note) async {
    final db = await dbService.database;
    await db.insert('time_segments', <String, Object?>{
      'id': id,
      'todo_id': todoId,
      'start_time': '2026-10-05T09:00:00.000Z',
      'end_time': '2026-10-05T09:30:00.000Z',
      'duration_seconds': 1800,
      'created_at': '2026-10-05T09:00:00.000Z',
      'notes': note,
    });
  }

  group('TodoSearchIndexDao', () {
    test('reindexTodo stores folded title, description and notes', () async {
      await todoDao.insert(
        todo('t1', 'Write REPORT', description: 'Quarterly  Numbers'),
      );
      await addSegmentNote('s1', 't1', 'First Draft');
      await addSegmentNote('s2', 't1', 'Final Review');

      await indexDao.reindexTodo('t1');

      final rows = await indexRows('t1');
      expect(rows, hasLength(1));
      expect(rows.single['title'], 'write report');
      expect(rows.single['description'], 'quarterly numbers');
      expect(rows.single['notes'], 'first draft final review');
    });

    test('reindexTodo leaves no row for a todo that does not exist', () async {
      await indexDao.reindexTodo('missing');

      expect(await indexRows('missing'), isEmpty);
    });

    test('reindexTodo replaces the old row instead of adding one', () async {
      await todoDao.insert(todo('t1', 'Old title'));
      await indexDao.reindexTodo('t1');
      await indexDao.reindexTodo('t1');

      expect(await indexRows('t1'), hasLength(1));
    });

    test('removeTodo drops the index row', () async {
      await todoDao.insert(todo('t1', 'Remove me'));
      await indexDao.reindexTodo('t1');

      await indexDao.removeTodo('t1');

      expect(await indexRows('t1'), isEmpty);
    });

    test('rebuildAll indexes every todo again', () async {
      await todoDao.insert(todo('t1', 'Alpha'));
      await todoDao.insert(todo('t2', 'Beta'));
      final db = await dbService.database;
      await db.delete(kTodosFtsTable);

      await indexDao.rebuildAll();

      final rows = await indexRows();
      expect(rows.map((r) => r['todo_id']), unorderedEquals(['t1', 't2']));
    });

    test('uses the given executor inside a transaction', () async {
      await todoDao.insert(todo('t1', 'In a transaction'));
      final db = await dbService.database;

      await db.transaction((txn) async {
        await indexDao.removeTodo('t1', executor: txn);
        await indexDao.reindexTodo('t1', executor: txn);
      });

      expect(await indexRows('t1'), hasLength(1));
    });
  });
}
