import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_todo/data/dao/sub_task_dao.dart';
import 'package:sreerajp_todo/data/dao/todo_dao.dart';
import 'package:sreerajp_todo/data/database/database_service.dart';
import 'package:sreerajp_todo/data/models/sub_task_item.dart';
import 'package:sreerajp_todo/data/models/todo_entity.dart';

import '../helpers/test_database.dart';

void main() {
  late DatabaseService databaseService;
  late TodoDao todoDao;
  late SubTaskDao subTaskDao;

  setUpAll(initFfi);

  setUp(() async {
    databaseService = await createTestDatabaseService();
    todoDao = TodoDao(databaseService);
    subTaskDao = SubTaskDao(databaseService);

    final now = DateTime.now().toUtc().toIso8601String();
    await todoDao.insert(
      TodoEntity(
        id: 'todo-1',
        date: '2026-08-10',
        title: 'Parent Task',
        createdAt: now,
        updatedAt: now,
      ),
    );
  });

  tearDown(() async {
    await databaseService.close();
  });

  group('SubTaskDao', () {
    test('insert and findByTodoId', () async {
      final now = DateTime.now().toUtc().toIso8601String();
      final item = SubTaskItem(
        id: 'sub-1',
        todoId: 'todo-1',
        title: 'Step 1',
        sortOrder: 0,
        createdAt: now,
        updatedAt: now,
      );
      await subTaskDao.insert(item);

      final list = await subTaskDao.findByTodoId('todo-1');
      expect(list, hasLength(1));
      expect(list.first.title, 'Step 1');
      expect(list.first.isCompleted, isFalse);
    });

    test('toggleSubTask updates completion state', () async {
      final now = DateTime.now().toUtc().toIso8601String();
      final item = SubTaskItem(
        id: 'sub-1',
        todoId: 'todo-1',
        title: 'Step 1',
        sortOrder: 0,
        createdAt: now,
        updatedAt: now,
      );
      await subTaskDao.insert(item);

      await subTaskDao.toggleSubTask('sub-1', true, now);
      final updatedList = await subTaskDao.findByTodoId('todo-1');
      expect(updatedList.first.isCompleted, isTrue);
    });

    test('saveAllForTodo replaces sub-tasks for todo', () async {
      final now = DateTime.now().toUtc().toIso8601String();
      final items = [
        SubTaskItem(
          id: 'sub-1',
          todoId: 'todo-1',
          title: 'Step 1',
          sortOrder: 0,
          createdAt: now,
          updatedAt: now,
        ),
        SubTaskItem(
          id: 'sub-2',
          todoId: 'todo-1',
          title: 'Step 2',
          sortOrder: 1,
          createdAt: now,
          updatedAt: now,
        ),
      ];
      await subTaskDao.saveAllForTodo('todo-1', items);

      final list = await subTaskDao.findByTodoId('todo-1');
      expect(list, hasLength(2));
      expect(list[0].title, 'Step 1');
      expect(list[1].title, 'Step 2');
    });

    test('cascade deletion deletes sub-tasks when parent todo is deleted', () async {
      final now = DateTime.now().toUtc().toIso8601String();
      await subTaskDao.insert(
        SubTaskItem(
          id: 'sub-1',
          todoId: 'todo-1',
          title: 'Step 1',
          sortOrder: 0,
          createdAt: now,
          updatedAt: now,
        ),
      );
      await todoDao.delete('todo-1');

      final list = await subTaskDao.findByTodoId('todo-1');
      expect(list, isEmpty);
    });
  });
}
