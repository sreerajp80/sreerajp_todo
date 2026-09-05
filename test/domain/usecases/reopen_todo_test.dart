import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_todo/core/errors/exceptions.dart';
import 'package:sreerajp_todo/data/dao/time_segment_dao.dart';
import 'package:sreerajp_todo/data/dao/todo_dao.dart';
import 'package:sreerajp_todo/data/models/todo_entity.dart';
import 'package:sreerajp_todo/data/models/todo_status.dart';
import 'package:sreerajp_todo/data/repositories/time_segment_repository_impl.dart';
import 'package:sreerajp_todo/data/repositories/todo_repository_impl.dart';
import 'package:sreerajp_todo/domain/usecases/mark_todo_completed.dart';
import 'package:sreerajp_todo/domain/usecases/reopen_todo.dart';

import '../../helpers/test_database.dart';

void main() {
  late TodoDao todoDao;
  late TimeSegmentDao timeSegmentDao;
  late TodoRepositoryImpl todoRepo;
  late TimeSegmentRepositoryImpl timeSegmentRepo;
  late MarkTodoCompleted markCompleted;
  late ReopenTodo reopenTodo;

  setUp(() async {
    final dbService = await createTestDatabaseService();
    todoDao = TodoDao(dbService);
    timeSegmentDao = TimeSegmentDao(dbService);
    todoRepo = TodoRepositoryImpl(todoDao);
    timeSegmentRepo = TimeSegmentRepositoryImpl(
      timeSegmentDao,
      todoDao,
      dbService,
    );
    markCompleted = MarkTodoCompleted(todoRepo, timeSegmentRepo);
    reopenTodo = ReopenTodo(todoRepo, timeSegmentRepo);
  });

  String todayIso() {
    final now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }

  String yesterdayIso() {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return '${yesterday.year.toString().padLeft(4, '0')}-'
        '${yesterday.month.toString().padLeft(2, '0')}-'
        '${yesterday.day.toString().padLeft(2, '0')}';
  }

  TodoEntity makeTodo({
    String? id,
    String? date,
    TodoStatus status = TodoStatus.pending,
  }) {
    final now = DateTime.now().toUtc().toIso8601String();
    return TodoEntity(
      id: id ?? 'todo-1',
      date: date ?? todayIso(),
      title: 'Task ${id ?? '1'}',
      status: status,
      sortOrder: 0,
      createdAt: now,
      updatedAt: now,
    );
  }

  test(
    'reopening completed task with no time segments reverts to pending',
    () async {
      await todoRepo.createTodo(makeTodo(id: 'rt-1'));
      await markCompleted('rt-1');

      final completedTodo = await todoRepo.getTodoById('rt-1');
      expect(completedTodo?.status, TodoStatus.completed);

      final oldStatus = await reopenTodo('rt-1');
      expect(oldStatus, TodoStatus.completed);

      final reopened = await todoRepo.getTodoById('rt-1');
      expect(reopened?.status, TodoStatus.pending);
    },
  );

  test(
    'reopening completed task with tracked segments reverts to working',
    () async {
      await todoRepo.createTodo(makeTodo(id: 'rt-2'));
      await timeSegmentRepo.startSegment('rt-2');
      await markCompleted('rt-2');

      final completedTodo = await todoRepo.getTodoById('rt-2');
      expect(completedTodo?.status, TodoStatus.completed);

      final oldStatus = await reopenTodo('rt-2');
      expect(oldStatus, TodoStatus.completed);

      final reopened = await todoRepo.getTodoById('rt-2');
      expect(reopened?.status, TodoStatus.working);
    },
  );

  test(
    'reopening completed task on past date throws DayLockedException',
    () async {
      // Insert directly into DAO to bypass day lock check on creation
      final pastTodo = makeTodo(
        id: 'rt-past',
        date: yesterdayIso(),
        status: TodoStatus.completed,
      );
      await todoDao.insert(pastTodo);

      expect(() => reopenTodo('rt-past'), throwsA(isA<DayLockedException>()));
    },
  );

  test('reopening non-existent todo throws TodoNotFoundException', () async {
    expect(
      () => reopenTodo('non-existent'),
      throwsA(isA<TodoNotFoundException>()),
    );
  });
}
