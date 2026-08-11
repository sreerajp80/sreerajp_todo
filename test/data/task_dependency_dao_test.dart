import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_todo/data/dao/task_dependency_dao.dart';
import 'package:sreerajp_todo/data/dao/todo_dao.dart';
import 'package:sreerajp_todo/data/database/database_service.dart';
import 'package:sreerajp_todo/data/models/todo_entity.dart';
import 'package:sreerajp_todo/data/models/todo_status.dart';

import '../helpers/test_database.dart';

void main() {
  late DatabaseService databaseService;
  late TodoDao todoDao;
  late TaskDependencyDao taskDependencyDao;

  setUpAll(initFfi);

  setUp(() async {
    databaseService = await createTestDatabaseService();
    todoDao = TodoDao(databaseService);
    taskDependencyDao = TaskDependencyDao(databaseService);

    final now = DateTime.now().toUtc().toIso8601String();
    await todoDao.insert(
      TodoEntity(
        id: 'task-a',
        date: '2026-08-10',
        title: 'Task A',
        status: TodoStatus.pending,
        createdAt: now,
        updatedAt: now,
      ),
    );
    await todoDao.insert(
      TodoEntity(
        id: 'task-b',
        date: '2026-08-10',
        title: 'Task B',
        status: TodoStatus.pending,
        createdAt: now,
        updatedAt: now,
      ),
    );
  });

  tearDown(() async {
    await databaseService.close();
  });

  group('TaskDependencyDao', () {
    test('setPrerequisitesForTodo and getPrerequisiteIdsForTodo', () async {
      await taskDependencyDao.setPrerequisitesForTodo('task-b', ['task-a']);
      final prereqIds = await taskDependencyDao.getPrerequisiteIdsForTodo('task-b');
      expect(prereqIds, equals(['task-a']));
    });

    test('getPendingPrerequisites returns uncompleted prerequisites', () async {
      await taskDependencyDao.setPrerequisitesForTodo('task-b', ['task-a']);
      var pending = await taskDependencyDao.getPendingPrerequisites('task-b');
      expect(pending, hasLength(1));
      expect(pending.first.id, 'task-a');

      // Complete task A
      await todoDao.updateStatus('task-a', TodoStatus.completed);
      pending = await taskDependencyDao.getPendingPrerequisites('task-b');
      expect(pending, isEmpty);
    });

    test('cascade deletion deletes dependencies when prerequisite task is deleted', () async {
      await taskDependencyDao.setPrerequisitesForTodo('task-b', ['task-a']);
      await todoDao.delete('task-a');

      final prereqIds = await taskDependencyDao.getPrerequisiteIdsForTodo('task-b');
      expect(prereqIds, isEmpty);
    });
  });
}
