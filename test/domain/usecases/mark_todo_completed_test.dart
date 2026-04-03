import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_todo/data/dao/time_segment_dao.dart';
import 'package:sreerajp_todo/data/dao/todo_dao.dart';
import 'package:sreerajp_todo/data/models/todo_entity.dart';
import 'package:sreerajp_todo/data/models/todo_status.dart';
import 'package:sreerajp_todo/data/repositories/time_segment_repository_impl.dart';
import 'package:sreerajp_todo/data/repositories/todo_repository_impl.dart';
import 'package:sreerajp_todo/domain/usecases/mark_todo_completed.dart';

import '../../helpers/test_database.dart';

void main() {
  late TodoDao todoDao;
  late TimeSegmentDao timeSegmentDao;
  late TodoRepositoryImpl todoRepo;
  late TimeSegmentRepositoryImpl timeSegmentRepo;
  late MarkTodoCompleted useCase;

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
    useCase = MarkTodoCompleted(todoRepo, timeSegmentRepo);
  });

  String todayIso() {
    final now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }

  TodoEntity makeTodo({String? id, TodoStatus status = TodoStatus.pending}) {
    final now = DateTime.now().toUtc().toIso8601String();
    return TodoEntity(
      id: id ?? 'todo-1',
      date: todayIso(),
      title: 'Task ${id ?? '1'}',
      status: status,
      sortOrder: 0,
      createdAt: now,
      updatedAt: now,
    );
  }

  test('sets status to completed and returns old status', () async {
    await todoRepo.createTodo(makeTodo(id: 'mc-1'));

    final oldStatus = await useCase('mc-1');
    expect(oldStatus, TodoStatus.pending);

    final updated = await todoRepo.getTodoById('mc-1');
    expect(updated?.status, TodoStatus.completed);
  });

  test('closes running time segment before completing', () async {
    await todoRepo.createTodo(makeTodo(id: 'mc-2'));
    await timeSegmentRepo.startSegment('mc-2');

    final running = await timeSegmentRepo.getRunningSegment('mc-2');
    expect(running, isNotNull);

    await useCase('mc-2');

    final stillRunning = await timeSegmentRepo.getRunningSegment('mc-2');
    expect(stillRunning, isNull);

    final segments = await timeSegmentRepo.getSegments('mc-2');
    expect(segments, hasLength(1));
    expect(segments.first.endTime, isNotNull);
  });

  test('works even when no segment is running', () async {
    await todoRepo.createTodo(makeTodo(id: 'mc-3'));

    final oldStatus = await useCase('mc-3');
    expect(oldStatus, TodoStatus.pending);
  });
}
