import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_todo/data/dao/time_segment_dao.dart';
import 'package:sreerajp_todo/data/dao/todo_dao.dart';
import 'package:sreerajp_todo/data/models/todo_entity.dart';
import 'package:sreerajp_todo/data/models/todo_status.dart';
import 'package:sreerajp_todo/data/repositories/time_segment_repository_impl.dart';
import 'package:sreerajp_todo/data/repositories/todo_repository_impl.dart';
import 'package:sreerajp_todo/domain/usecases/mark_todo_dropped.dart';

import '../../helpers/test_database.dart';

void main() {
  late TodoDao todoDao;
  late TimeSegmentDao timeSegmentDao;
  late TodoRepositoryImpl todoRepo;
  late TimeSegmentRepositoryImpl timeSegmentRepo;
  late MarkTodoDropped useCase;

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
    useCase = MarkTodoDropped(todoRepo, timeSegmentRepo);
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

  test('sets status to dropped and returns old status', () async {
    await todoRepo.createTodo(makeTodo(id: 'md-1'));

    final oldStatus = await useCase('md-1');
    expect(oldStatus, TodoStatus.pending);

    final updated = await todoRepo.getTodoById('md-1');
    expect(updated?.status, TodoStatus.dropped);
  });

  test('closes running time segment before dropping', () async {
    await todoRepo.createTodo(makeTodo(id: 'md-2'));
    await timeSegmentRepo.startSegment('md-2');

    await useCase('md-2');

    final stillRunning = await timeSegmentRepo.getRunningSegment('md-2');
    expect(stillRunning, isNull);

    final segments = await timeSegmentRepo.getSegments('md-2');
    expect(segments, hasLength(1));
    expect(segments.first.endTime, isNotNull);
  });
}
