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

String _dayIso(int offset) {
  final d = DateTime.now().add(Duration(days: offset));
  return '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}

String _yesterdayIso() {
  final y = DateTime.now().subtract(const Duration(days: 1));
  return '${y.year.toString().padLeft(4, '0')}-'
      '${y.month.toString().padLeft(2, '0')}-'
      '${y.day.toString().padLeft(2, '0')}';
}

TodoEntity _makeTodo({
  required String id,
  String? date,
  String? title,
  String? sourceDate,
  TodoStatus status = TodoStatus.pending,
}) {
  final now = DateTime.now().toUtc().toIso8601String();
  return TodoEntity(
    id: id,
    date: date ?? _todayIso(),
    title: title ?? 'Task $id',
    status: status,
    sourceDate: sourceDate,
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
    useCase = StartTimeSegment(todoRepo, timeSegmentRepo);
  });

  test('starts segment on pending today todo', () async {
    await todoRepo.createTodo(_makeTodo(id: 'st-1'));

    await useCase('st-1');

    final running = await timeSegmentRepo.getRunningSegment('st-1');
    final updated = await todoRepo.getTodoById('st-1');
    expect(running, isNotNull);
    expect(running!.endTime, isNull);
    expect(running.todoId, 'st-1');
    expect(updated?.status, TodoStatus.working);
  });

  test('throws DayLockedException for past-date todo', () async {
    final todo = _makeTodo(id: 'st-2', date: _yesterdayIso());
    await todoDao.insert(todo);

    expect(() => useCase('st-2'), throwsA(isA<DayLockedException>()));
  });

  test('throws CompletedLockException for completed todo', () async {
    await todoRepo.createTodo(_makeTodo(id: 'st-3'));
    await todoRepo.updateStatus('st-3', TodoStatus.completed);

    expect(() => useCase('st-3'), throwsA(isA<CompletedLockException>()));
  });

  test('throws CompletedLockException for dropped todo', () async {
    await todoRepo.createTodo(_makeTodo(id: 'st-4', title: 'Dropped task'));
    await todoRepo.updateStatus('st-4', TodoStatus.dropped);

    expect(() => useCase('st-4'), throwsA(isA<CompletedLockException>()));
  });

  test(
    'throws SegmentAlreadyRunningException when one already running',
    () async {
      await todoRepo.createTodo(_makeTodo(id: 'st-5', title: 'Running'));

      await useCase('st-5');

      expect(
        () => useCase('st-5'),
        throwsA(isA<SegmentAlreadyRunningException>()),
      );
    },
  );

  test('throws TodoNotFoundException for nonexistent todo', () async {
    expect(() => useCase('nonexistent'), throwsA(isA<TodoNotFoundException>()));
  });

  test('throws FutureDayTimerException for a future-date todo', () async {
    await todoRepo.createTodo(_makeTodo(id: 'st-future', date: _dayIso(2)));

    await expectLater(
      () => useCase('st-future'),
      throwsA(isA<FutureDayTimerException>()),
    );
    expect(await timeSegmentRepo.getRunningSegment('st-future'), isNull);
  });

  test('repository refuses a timer on a future-date todo', () async {
    await todoRepo.createTodo(
      _makeTodo(id: 'st-future-repo', date: _dayIso(1)),
    );

    await expectLater(
      () => timeSegmentRepo.startSegment('st-future-repo'),
      throwsA(isA<FutureDayTimerException>()),
    );
  });

  test('allows a timer on a multi-day todo that started today', () async {
    await todoRepo.createTodo(
      _makeTodo(id: 'st-multi', date: _dayIso(2), sourceDate: _todayIso()),
    );

    await useCase('st-multi');

    expect(await timeSegmentRepo.getRunningSegment('st-multi'), isNotNull);
  });
}
