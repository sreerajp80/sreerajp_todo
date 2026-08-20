import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_todo/core/errors/exceptions.dart';
import 'package:sreerajp_todo/data/dao/time_segment_dao.dart';
import 'package:sreerajp_todo/data/dao/todo_dao.dart';
import 'package:sreerajp_todo/data/models/todo_entity.dart';
import 'package:sreerajp_todo/data/models/todo_status.dart';
import 'package:sreerajp_todo/data/repositories/time_segment_repository_impl.dart';
import 'package:sreerajp_todo/data/repositories/todo_repository_impl.dart';
import 'package:sreerajp_todo/domain/usecases/start_time_segment.dart';

import '../../helpers/test_database.dart';

String _todayIso() {
  final now = DateTime.now();
  return '${now.year.toString().padLeft(4, '0')}-'
      '${now.month.toString().padLeft(2, '0')}-'
      '${now.day.toString().padLeft(2, '0')}';
}

TodoEntity _makeTodo({required String id, required String title}) {
  final now = DateTime.now().toUtc().toIso8601String();
  return TodoEntity(
    id: id,
    date: _todayIso(),
    title: title,
    status: TodoStatus.pending,
    sortOrder: 0,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  late TodoDao todoDao;
  late TimeSegmentDao timeSegmentDao;
  late TodoRepositoryImpl todoRepo;
  late TimeSegmentRepositoryImpl timeSegmentRepo;

  /// Lets each test flip the setting without rebuilding the use case, which
  /// is how the real provider reads it too.
  late bool singleTimer;
  late StartTimeSegment useCase;

  setUpAll(initFfi);

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
    singleTimer = false;
    useCase = StartTimeSegment(
      todoRepo,
      timeSegmentRepo,
      singleTimer: () => singleTimer,
    );

    await todoRepo.createTodo(_makeTodo(id: 'one-a', title: 'Task A'));
    await todoRepo.createTodo(_makeTodo(id: 'one-b', title: 'Task B'));
  });

  test('with the setting off, two timers may run together', () async {
    await useCase('one-a');
    final stopped = await useCase('one-b');

    expect(stopped, isEmpty);
    expect(await timeSegmentRepo.getRunningSegment('one-a'), isNotNull);
    expect(await timeSegmentRepo.getRunningSegment('one-b'), isNotNull);
  });

  test('with the setting on, starting one stops the other', () async {
    await useCase('one-a');
    singleTimer = true;

    final stopped = await useCase('one-b');

    expect(stopped, ['one-a']);
    expect(await timeSegmentRepo.getRunningSegment('one-a'), isNull);
    expect(await timeSegmentRepo.getRunningSegment('one-b'), isNotNull);
  });

  test('the stopped timer keeps the time it had tracked', () async {
    await useCase('one-a');
    singleTimer = true;
    await useCase('one-b');

    final segments = await timeSegmentRepo.getSegments('one-a');
    expect(segments, hasLength(1));
    expect(segments.first.endTime, isNotNull);
    expect(segments.first.durationSeconds, isNotNull);
    expect(segments.first.durationSeconds, greaterThanOrEqualTo(0));
  });

  test('a refused start leaves the other timer alone', () async {
    // Nothing should be stopped for a start that was never going to succeed.
    await useCase('one-a');
    singleTimer = true;

    await expectLater(
      () => useCase('missing-todo'),
      throwsA(isA<TodoNotFoundException>()),
    );
    expect(await timeSegmentRepo.getRunningSegment('one-a'), isNotNull);
  });

  test('restarting the same todo does not stop itself', () async {
    singleTimer = true;
    await useCase('one-a');

    await expectLater(
      () => useCase('one-a'),
      throwsA(isA<SegmentAlreadyRunningException>()),
    );
    expect(await timeSegmentRepo.getRunningSegment('one-a'), isNotNull);
  });
}
