import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_todo/data/dao/todo_dao.dart';
import 'package:sreerajp_todo/data/database/database_service.dart';
import 'package:sreerajp_todo/data/models/todo_entity.dart';
import 'package:sreerajp_todo/data/models/todo_status.dart';

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
    String date = '2026-03-21',
    String title = 'Test Todo',
    String? description,
    TodoStatus status = TodoStatus.pending,
    int sortOrder = 0,
  }) {
    final now = DateTime.now().toUtc().toIso8601String();
    return TodoEntity(
      id: id,
      date: date,
      title: title,
      description: description,
      status: status,
      sortOrder: sortOrder,
      createdAt: now,
      updatedAt: now,
    );
  }

  group('insert and findByDate', () {
    test('inserts a todo and retrieves it by date', () async {
      final todo = makeTodo();
      await todoDao.insert(todo);

      final results = await todoDao.findByDate('2026-03-21');
      expect(results, hasLength(1));
      expect(results.first.id, 'todo-1');
      expect(results.first.title, 'Test Todo');
      expect(results.first.status, TodoStatus.pending);
    });

    test('returns empty list for date with no todos', () async {
      final results = await todoDao.findByDate('2026-01-01');
      expect(results, isEmpty);
    });

    test('orders results by sort_order then created_at', () async {
      await todoDao.insert(makeTodo(id: 'a', title: 'C', sortOrder: 2));
      await todoDao.insert(makeTodo(id: 'b', title: 'A', sortOrder: 0));
      await todoDao.insert(makeTodo(id: 'c', title: 'B', sortOrder: 1));

      final results = await todoDao.findByDate('2026-03-21');
      expect(results.map((t) => t.id).toList(), ['b', 'c', 'a']);
    });
  });

  group('findById', () {
    test('returns todo when found', () async {
      await todoDao.insert(makeTodo());
      final result = await todoDao.findById('todo-1');
      expect(result, isNotNull);
      expect(result!.title, 'Test Todo');
    });

    test('returns null when not found', () async {
      final result = await todoDao.findById('nonexistent');
      expect(result, isNull);
    });
  });

  group('update', () {
    test('updates fields and bumps updated_at', () async {
      final todo = makeTodo();
      await todoDao.insert(todo);

      final before = await todoDao.findById('todo-1');
      final originalUpdatedAt = before!.updatedAt;

      await Future<void>.delayed(const Duration(milliseconds: 10));

      final modified = before.copyWith(title: 'Updated Title');
      await todoDao.update(modified);

      final after = await todoDao.findById('todo-1');
      expect(after!.title, 'Updated Title');
      expect(after.updatedAt, isNot(originalUpdatedAt));
    });
  });

  group('delete', () {
    test('removes the todo', () async {
      await todoDao.insert(makeTodo());
      await todoDao.delete('todo-1');

      final result = await todoDao.findById('todo-1');
      expect(result, isNull);
    });

    test('cascades to time_segments on delete', () async {
      await todoDao.insert(makeTodo());
      final db = await databaseService.database;
      await db.insert('time_segments', {
        'id': 'seg-1',
        'todo_id': 'todo-1',
        'start_time': DateTime.now().toIso8601String(),
        'interrupted': 0,
        'manual': 0,
        'created_at': DateTime.now().toUtc().toIso8601String(),
      });

      await todoDao.delete('todo-1');

      final segments = await db.query(
        'time_segments',
        where: 'todo_id = ?',
        whereArgs: ['todo-1'],
      );
      expect(segments, isEmpty);
    });
  });

  group('existsTitleOnDate', () {
    test('returns true when title exists on date', () async {
      await todoDao.insert(makeTodo(title: 'My Task'));
      final exists = await todoDao.existsTitleOnDate(
        'My Task',
        '2026-03-21',
      );
      expect(exists, isTrue);
    });

    test('returns false when title does not exist', () async {
      final exists = await todoDao.existsTitleOnDate(
        'No Such Task',
        '2026-03-21',
      );
      expect(exists, isFalse);
    });

    test('returns false when title exists on different date', () async {
      await todoDao.insert(makeTodo(title: 'My Task', date: '2026-03-20'));
      final exists = await todoDao.existsTitleOnDate(
        'My Task',
        '2026-03-21',
      );
      expect(exists, isFalse);
    });

    test('excludes the specified id', () async {
      await todoDao.insert(makeTodo(title: 'My Task'));
      final exists = await todoDao.existsTitleOnDate(
        'My Task',
        '2026-03-21',
        excludeId: 'todo-1',
      );
      expect(exists, isFalse);
    });

    test('returns true when another todo has the title (excludeId)', () async {
      await todoDao.insert(makeTodo(id: 'todo-1', title: 'Shared Title'));
      await todoDao.insert(makeTodo(id: 'todo-2', title: 'Other Title'));
      final exists = await todoDao.existsTitleOnDate(
        'Shared Title',
        '2026-03-21',
        excludeId: 'todo-2',
      );
      expect(exists, isTrue);
    });
  });

  group('title uniqueness constraint', () {
    test('throws on duplicate (date, title)', () async {
      await todoDao.insert(makeTodo(id: 'a', title: 'Same'));
      expect(
        () => todoDao.insert(makeTodo(id: 'b', title: 'Same')),
        throwsA(isA<Exception>()),
      );
    });

    test('allows same title on different dates', () async {
      await todoDao.insert(
        makeTodo(id: 'a', title: 'Same', date: '2026-03-20'),
      );
      await todoDao.insert(
        makeTodo(id: 'b', title: 'Same', date: '2026-03-21'),
      );

      final day20 = await todoDao.findByDate('2026-03-20');
      final day21 = await todoDao.findByDate('2026-03-21');
      expect(day20, hasLength(1));
      expect(day21, hasLength(1));
    });
  });

  group('getAllDistinctTitles', () {
    test('returns titles matching prefix', () async {
      await todoDao.insert(makeTodo(id: 'a', title: 'Buy groceries'));
      await todoDao.insert(
        makeTodo(
          id: 'b',
          title: 'Buy milk',
          date: '2026-03-20',
        ),
      );
      await todoDao.insert(
        makeTodo(id: 'c', title: 'Read book', date: '2026-03-19'),
      );

      final results = await todoDao.getAllDistinctTitles('Buy');
      expect(results, hasLength(2));
      expect(results, containsAll(['Buy groceries', 'Buy milk']));
    });

    test('returns empty list when no match', () async {
      await todoDao.insert(makeTodo(title: 'Something'));
      final results = await todoDao.getAllDistinctTitles('zzz');
      expect(results, isEmpty);
    });

    test('limits results to 20', () async {
      for (var i = 0; i < 25; i++) {
        await todoDao.insert(
          makeTodo(
            id: 'id-$i',
            title: 'Task $i',
            date: '2026-01-${(i + 1).toString().padLeft(2, '0')}',
          ),
        );
      }
      final results = await todoDao.getAllDistinctTitles('Task');
      expect(results.length, lessThanOrEqualTo(20));
    });
  });

  group('searchByTitle', () {
    test('returns todos matching substring', () async {
      await todoDao.insert(makeTodo(id: 'a', title: 'Buy groceries'));
      await todoDao.insert(
        makeTodo(id: 'b', title: 'Read book', date: '2026-03-20'),
      );
      await todoDao.insert(
        makeTodo(id: 'c', title: 'Buy milk', date: '2026-03-19'),
      );

      final results = await todoDao.searchByTitle('Buy');
      expect(results, hasLength(2));
    });

    test('respects limit', () async {
      for (var i = 0; i < 10; i++) {
        await todoDao.insert(
          makeTodo(
            id: 'id-$i',
            title: 'Task $i',
            date: '2026-01-${(i + 1).toString().padLeft(2, '0')}',
          ),
        );
      }
      final results = await todoDao.searchByTitle('Task', limit: 3);
      expect(results, hasLength(3));
    });
  });

  group('updateSortOrders', () {
    test('batch updates sort orders in a transaction', () async {
      await todoDao.insert(makeTodo(id: 'a', title: 'A', sortOrder: 0));
      await todoDao.insert(makeTodo(id: 'b', title: 'B', sortOrder: 1));
      await todoDao.insert(makeTodo(id: 'c', title: 'C', sortOrder: 2));

      final todos = await todoDao.findByDate('2026-03-21');
      final reordered = [
        todos[2].copyWith(sortOrder: 0),
        todos[0].copyWith(sortOrder: 1),
        todos[1].copyWith(sortOrder: 2),
      ];
      await todoDao.updateSortOrders(reordered);

      final updated = await todoDao.findByDate('2026-03-21');
      expect(updated[0].id, 'c');
      expect(updated[1].id, 'a');
      expect(updated[2].id, 'b');
    });
  });
}
