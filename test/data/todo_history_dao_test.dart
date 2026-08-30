import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_todo/data/dao/todo_dao.dart';
import 'package:sreerajp_todo/data/dao/todo_history_dao.dart';
import 'package:sreerajp_todo/data/models/todo_entity.dart';
import 'package:sreerajp_todo/data/models/todo_history_entity.dart';
import 'package:sreerajp_todo/data/models/todo_status.dart';

import '../helpers/test_database.dart';

void main() {
  setUpAll(initFfi);

  late TodoHistoryDao historyDao;
  late TodoDao todoDao;

  setUp(() async {
    final dbService = await createTestDatabaseService();
    historyDao = TodoHistoryDao(dbService);
    todoDao = TodoDao(dbService);
  });

  TodoEntity createTestTodo({required String id, required String title}) {
    final now = DateTime.now().toUtc().toIso8601String();
    return TodoEntity(
      id: id,
      date: '2026-08-29',
      title: title,
      status: TodoStatus.pending,
      sortOrder: 0,
      createdAt: now,
      updatedAt: now,
    );
  }

  group('TodoHistoryDao', () {
    test(
      'inserts and retrieves history records ordered by event_time asc',
      () async {
        final todo = createTestTodo(id: 'todo-1', title: 'Task with history');
        await todoDao.insert(todo);

        const event1 = TodoHistoryEntity(
          id: 'hist-1',
          todoId: 'todo-1',
          eventType: TodoHistoryEventType.created,
          eventTime: '2026-08-29T08:00:00.000Z',
          description: 'Task created',
          createdAt: '2026-08-29T08:00:00.000Z',
        );

        const event2 = TodoHistoryEntity(
          id: 'hist-2',
          todoId: 'todo-1',
          eventType: TodoHistoryEventType.timerStarted,
          eventTime: '2026-08-29T08:30:00.000Z',
          description: 'Timer started',
          createdAt: '2026-08-29T08:30:00.000Z',
        );

        const event3 = TodoHistoryEntity(
          id: 'hist-3',
          todoId: 'todo-1',
          eventType: TodoHistoryEventType.moved,
          eventTime: '2026-08-29T09:00:00.000Z',
          description: 'Moved to 2026-08-30',
          metadata: '{"from_date":"2026-08-29","to_date":"2026-08-30"}',
          createdAt: '2026-08-29T09:00:00.000Z',
        );

        // Insert in arbitrary order
        await historyDao.insert(event2);
        await historyDao.insert(event3);
        await historyDao.insert(event1);

        final results = await historyDao.findByTodoId('todo-1');
        expect(results.length, 3);
        expect(results[0].id, 'hist-1');
        expect(results[0].eventType, TodoHistoryEventType.created);
        expect(results[1].id, 'hist-2');
        expect(results[1].eventType, TodoHistoryEventType.timerStarted);
        expect(results[2].id, 'hist-3');
        expect(results[2].eventType, TodoHistoryEventType.moved);
        expect(results[2].metadata, contains('2026-08-30'));
      },
    );

    test('deletes history when todo is deleted via cascade', () async {
      final todo = createTestTodo(id: 'todo-2', title: 'Task to delete');
      await todoDao.insert(todo);

      const event = TodoHistoryEntity(
        id: 'hist-del-1',
        todoId: 'todo-2',
        eventType: TodoHistoryEventType.created,
        eventTime: '2026-08-29T08:00:00.000Z',
        description: 'Task created',
        createdAt: '2026-08-29T08:00:00.000Z',
      );
      await historyDao.insert(event);

      final before = await historyDao.findByTodoId('todo-2');
      expect(before.length, 1);

      await historyDao.deleteByTodoId('todo-2');
      final after = await historyDao.findByTodoId('todo-2');
      expect(after, isEmpty);
    });
  });
}
