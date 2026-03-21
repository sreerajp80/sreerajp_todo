import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_todo/data/dao/todo_dao.dart';
import 'package:sreerajp_todo/data/models/todo_entity.dart';
import 'package:sreerajp_todo/data/models/todo_status.dart';
import 'package:sreerajp_todo/data/repositories/todo_repository_impl.dart';
import 'package:sreerajp_todo/domain/usecases/copy_todos.dart';

import '../../helpers/test_database.dart';

void main() {
  late TodoDao todoDao;
  late TodoRepositoryImpl todoRepo;
  late CopyTodos useCase;

  setUp(() async {
    final dbService = await createTestDatabaseService();
    todoDao = TodoDao(dbService);
    todoRepo = TodoRepositoryImpl(todoDao);
    useCase = CopyTodos(todoRepo);
  });

  String todayIso() {
    final now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }

  String tomorrowIso() {
    final t = DateTime.now().add(const Duration(days: 1));
    return '${t.year.toString().padLeft(4, '0')}-'
        '${t.month.toString().padLeft(2, '0')}-'
        '${t.day.toString().padLeft(2, '0')}';
  }

  TodoEntity makeTodo({required String id, required String title}) {
    final now = DateTime.now().toUtc().toIso8601String();
    return TodoEntity(
      id: id,
      date: todayIso(),
      title: title,
      sortOrder: 0,
      createdAt: now,
      updatedAt: now,
    );
  }

  test('copies non-conflicting todos to target date', () async {
    await todoRepo.createTodo(makeTodo(id: 'c-1', title: 'Task A'));
    await todoRepo.createTodo(makeTodo(id: 'c-2', title: 'Task B'));

    final result = await useCase(['c-1', 'c-2'], tomorrowIso());

    expect(result.copied, hasLength(2));
    expect(result.skipped, isEmpty);

    final targetTodos = await todoRepo.getTodosByDate(tomorrowIso());
    expect(targetTodos, hasLength(2));
    expect(targetTodos.every((t) => t.status == TodoStatus.pending), isTrue);
    expect(targetTodos.every((t) => t.sourceDate == todayIso()), isTrue);
  });

  test('skips conflicting titles on target date', () async {
    await todoRepo.createTodo(makeTodo(id: 'c-3', title: 'Task C'));
    await todoRepo.createTodo(makeTodo(id: 'c-4', title: 'Task D'));

    final existing = TodoEntity(
      id: 'existing-c',
      date: tomorrowIso(),
      title: 'Task C',
      sortOrder: 0,
      createdAt: DateTime.now().toUtc().toIso8601String(),
      updatedAt: DateTime.now().toUtc().toIso8601String(),
    );
    await todoRepo.createTodo(existing);

    final result = await useCase(['c-3', 'c-4'], tomorrowIso());

    expect(result.copied, hasLength(1));
    expect(result.copied.first.title, 'Task D');
    expect(result.skipped, hasLength(1));
    expect(result.skipped.first.title, 'Task C');
  });

  test('copied todos have fresh IDs', () async {
    await todoRepo.createTodo(makeTodo(id: 'c-5', title: 'Task E'));

    final result = await useCase(['c-5'], tomorrowIso());

    expect(result.copied.first.id, isNot('c-5'));
  });
}
