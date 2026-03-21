import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_todo/core/errors/exceptions.dart';
import 'package:sreerajp_todo/data/dao/time_segment_dao.dart';
import 'package:sreerajp_todo/data/dao/todo_dao.dart';
import 'package:sreerajp_todo/data/models/todo_entity.dart';
import 'package:sreerajp_todo/data/models/todo_status.dart';
import 'package:sreerajp_todo/data/repositories/time_segment_repository_impl.dart';
import 'package:sreerajp_todo/data/repositories/todo_repository_impl.dart';
import 'package:sreerajp_todo/domain/usecases/port_todo.dart';

import '../../helpers/test_database.dart';

String _todayIso() {
  final now = DateTime.now();
  return '${now.year.toString().padLeft(4, '0')}-'
      '${now.month.toString().padLeft(2, '0')}-'
      '${now.day.toString().padLeft(2, '0')}';
}

String _tomorrowIso() {
  final t = DateTime.now().add(const Duration(days: 1));
  return '${t.year.toString().padLeft(4, '0')}-'
      '${t.month.toString().padLeft(2, '0')}-'
      '${t.day.toString().padLeft(2, '0')}';
}

void main() {
  late TodoDao todoDao;
  late TimeSegmentDao timeSegmentDao;
  late TodoRepositoryImpl todoRepo;
  late TimeSegmentRepositoryImpl timeSegmentRepo;
  late PortTodo useCase;

  setUp(() async {
    final dbService = await createTestDatabaseService();
    todoDao = TodoDao(dbService);
    timeSegmentDao = TimeSegmentDao(dbService);
    todoRepo = TodoRepositoryImpl(todoDao);
    timeSegmentRepo = TimeSegmentRepositoryImpl(timeSegmentDao, todoDao);
    useCase = PortTodo(todoRepo, timeSegmentRepo);
  });

  TodoEntity makeTodo({required String id, required String title}) {
    final now = DateTime.now().toUtc().toIso8601String();
    return TodoEntity(
      id: id,
      date: _todayIso(),
      title: title,
      sortOrder: 0,
      createdAt: now,
      updatedAt: now,
    );
  }

  test('creates copy on target date and marks source as ported', () async {
    await todoRepo.createTodo(makeTodo(id: 'pt-1', title: 'Port Me'));

    final result = await useCase('pt-1', _tomorrowIso());

    expect(result.oldStatus, TodoStatus.pending);
    expect(result.copiedTodoId, isNotEmpty);

    final source = await todoRepo.getTodoById('pt-1');
    expect(source?.status, TodoStatus.ported);
    expect(source?.portedTo, _tomorrowIso());

    final copy = await todoRepo.getTodoById(result.copiedTodoId);
    expect(copy, isNotNull);
    expect(copy?.date, _tomorrowIso());
    expect(copy?.title, 'Port Me');
    expect(copy?.status, TodoStatus.pending);
    expect(copy?.sourceDate, _todayIso());
  });

  test('throws DuplicateTitleException if title exists on target date',
      () async {
    await todoRepo.createTodo(makeTodo(id: 'pt-2', title: 'Duplicate Port'));

    final existingOnTarget = TodoEntity(
      id: 'existing-on-target',
      date: _tomorrowIso(),
      title: 'Duplicate Port',
      sortOrder: 0,
      createdAt: DateTime.now().toUtc().toIso8601String(),
      updatedAt: DateTime.now().toUtc().toIso8601String(),
    );
    await todoRepo.createTodo(existingOnTarget);

    expect(
      () => useCase('pt-2', _tomorrowIso()),
      throwsA(isA<DuplicateTitleException>()),
    );
  });

  test('throws DayLockedException if target date is today or past', () async {
    await todoRepo.createTodo(makeTodo(id: 'pt-3', title: 'Past Port'));

    expect(
      () => useCase('pt-3', _todayIso()),
      throwsA(isA<DayLockedException>()),
    );
  });

  test('stops running timer on source before porting', () async {
    await todoRepo.createTodo(makeTodo(id: 'pt-4', title: 'Timer Port'));
    await timeSegmentRepo.startSegment('pt-4');

    await useCase('pt-4', _tomorrowIso());

    final running = await timeSegmentRepo.getRunningSegment('pt-4');
    expect(running, isNull);
  });
}
