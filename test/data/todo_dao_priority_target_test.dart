import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_todo/data/dao/todo_dao.dart';
import 'package:sreerajp_todo/data/database/database_service.dart';
import 'package:sreerajp_todo/data/models/todo_entity.dart';
import 'package:sreerajp_todo/data/models/todo_priority.dart';

import '../helpers/test_database.dart';

void main() {
  late DatabaseService databaseService;
  late TodoDao todoDao;

  setUpAll(initFfi);

  setUp(() async {
    databaseService = await createTestDatabaseService();
    todoDao = TodoDao(databaseService);
  });

  tearDown(() async {
    await databaseService.close();
  });

  TodoEntity makeTodo({
    String id = 'todo-1',
    String date = '2026-08-19',
    String title = 'Test Todo',
    TodoPriority priority = TodoPriority.normal,
    int? targetSeconds,
  }) {
    final now = DateTime.now().toUtc().toIso8601String();
    return TodoEntity(
      id: id,
      date: date,
      title: title,
      priority: priority,
      targetSeconds: targetSeconds,
      createdAt: now,
      updatedAt: now,
    );
  }

  group('priority column', () {
    test('is written and read back', () async {
      await todoDao.insert(makeTodo(priority: TodoPriority.urgent));

      final result = await todoDao.findById('todo-1');
      expect(result!.priority, TodoPriority.urgent);
    });

    test('defaults to normal when nothing is chosen', () async {
      await todoDao.insert(makeTodo());

      final result = await todoDao.findById('todo-1');
      expect(result!.priority, TodoPriority.normal);
    });

    test('survives an update', () async {
      await todoDao.insert(makeTodo(priority: TodoPriority.low));
      final stored = await todoDao.findById('todo-1');
      await todoDao.update(stored!.copyWith(priority: TodoPriority.high));

      final updated = await todoDao.findById('todo-1');
      expect(updated!.priority, TodoPriority.high);
    });

    test('an unknown stored value reads as normal instead of throwing', () {
      expect(TodoPriority.fromDbString('sideways'), TodoPriority.normal);
      expect(TodoPriority.fromDbString(null), TodoPriority.normal);
    });
  });

  group('target_seconds column', () {
    test('null means no target', () async {
      await todoDao.insert(makeTodo());

      final result = await todoDao.findById('todo-1');
      expect(result!.targetSeconds, isNull);
    });

    test('is written and read back', () async {
      await todoDao.insert(makeTodo(targetSeconds: 5400));

      final result = await todoDao.findById('todo-1');
      expect(result!.targetSeconds, 5400);
    });

    test('can be cleared by an update', () async {
      await todoDao.insert(makeTodo(targetSeconds: 3600));
      final stored = await todoDao.findById('todo-1');
      await todoDao.update(stored!.copyWith(targetSeconds: null));

      final updated = await todoDao.findById('todo-1');
      expect(updated!.targetSeconds, isNull);
    });
  });

  group('getAllDistinctTitles limit', () {
    setUp(() async {
      for (var i = 0; i < 30; i++) {
        await todoDao.insert(
          makeTodo(
            id: 'id-$i',
            title: 'Task ${i.toString().padLeft(2, '0')}',
            date: '2026-08-19',
          ),
        );
      }
    });

    test('honours a smaller limit', () async {
      final results = await todoDao.getAllDistinctTitles('Task', limit: 5);
      expect(results, hasLength(5));
    });

    test('honours a larger limit', () async {
      final results = await todoDao.getAllDistinctTitles('Task', limit: 50);
      expect(results, hasLength(30));
    });

    test('falls back to the standard cap when no limit is given', () async {
      final results = await todoDao.getAllDistinctTitles('Task');
      expect(results, hasLength(20));
    });
  });
}
