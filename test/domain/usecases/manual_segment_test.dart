import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_todo/core/errors/exceptions.dart';
import 'package:sreerajp_todo/data/dao/time_segment_dao.dart';
import 'package:sreerajp_todo/data/dao/todo_dao.dart';
import 'package:sreerajp_todo/data/models/time_segment_entity.dart';
import 'package:sreerajp_todo/data/models/todo_entity.dart';
import 'package:sreerajp_todo/data/models/todo_status.dart';
import 'package:sreerajp_todo/data/repositories/time_segment_repository_impl.dart';
import 'package:sreerajp_todo/data/repositories/todo_repository_impl.dart';

import '../../helpers/test_database.dart';

String _todayIso() {
  final now = DateTime.now();
  return '${now.year.toString().padLeft(4, '0')}-'
      '${now.month.toString().padLeft(2, '0')}-'
      '${now.day.toString().padLeft(2, '0')}';
}

String _yesterdayIso() {
  final y = DateTime.now().subtract(const Duration(days: 1));
  return '${y.year.toString().padLeft(4, '0')}-'
      '${y.month.toString().padLeft(2, '0')}-'
      '${y.day.toString().padLeft(2, '0')}';
}

void main() {
  late TodoDao todoDao;
  late TimeSegmentDao segmentDao;
  late TodoRepositoryImpl todoRepo;
  late TimeSegmentRepositoryImpl segmentRepo;

  setUpAll(initFfi);

  setUp(() async {
    final dbService = await createTestDatabaseService();
    todoDao = TodoDao(dbService);
    segmentDao = TimeSegmentDao(dbService);
    todoRepo = TodoRepositoryImpl(todoDao);
    segmentRepo = TimeSegmentRepositoryImpl(segmentDao, todoDao);
  });

  TodoEntity makeTodo({
    required String id,
    String? date,
    String? title,
    TodoStatus status = TodoStatus.pending,
  }) {
    final now = DateTime.now().toUtc().toIso8601String();
    return TodoEntity(
      id: id,
      date: date ?? _todayIso(),
      title: title ?? 'Task $id',
      status: status,
      sortOrder: 0,
      createdAt: now,
      updatedAt: now,
    );
  }

  TimeSegmentEntity makeManualSegment({
    required String id,
    required String todoId,
    required DateTime start,
    required DateTime end,
  }) {
    return TimeSegmentEntity(
      id: id,
      todoId: todoId,
      startTime: start.toIso8601String(),
      endTime: end.toIso8601String(),
      durationSeconds: end.difference(start).inSeconds,
      manual: true,
      createdAt: DateTime.now().toUtc().toIso8601String(),
    );
  }

  test('inserts manual segment with manual=true and computed duration',
      () async {
    await todoRepo.createTodo(makeTodo(id: 'ms-1'));

    final start = DateTime(2026, 3, 21, 9, 0);
    final end = DateTime(2026, 3, 21, 9, 45);
    final segment = makeManualSegment(
      id: 'man-1',
      todoId: 'ms-1',
      start: start,
      end: end,
    );

    await segmentRepo.insertManualSegment(segment);

    final segments = await segmentRepo.getSegments('ms-1');
    expect(segments, hasLength(1));
    expect(segments.first.manual, isTrue);
    expect(segments.first.durationSeconds, 2700);
  });

  test('rejects overlapping manual segment', () async {
    await todoRepo.createTodo(makeTodo(id: 'ms-2', title: 'Overlap test'));

    final start1 = DateTime(2026, 3, 21, 9, 0);
    final end1 = DateTime(2026, 3, 21, 10, 0);
    await segmentRepo.insertManualSegment(makeManualSegment(
      id: 'man-2a',
      todoId: 'ms-2',
      start: start1,
      end: end1,
    ));

    final start2 = DateTime(2026, 3, 21, 9, 30);
    final end2 = DateTime(2026, 3, 21, 10, 30);
    expect(
      () => segmentRepo.insertManualSegment(makeManualSegment(
        id: 'man-2b',
        todoId: 'ms-2',
        start: start2,
        end: end2,
      )),
      throwsA(isA<SegmentOverlapException>()),
    );
  });

  test('rejects manual segment on past-date todo', () async {
    final todo =
        makeTodo(id: 'ms-3', date: _yesterdayIso(), title: 'Past manual');
    await todoDao.insert(todo);

    final start = DateTime(2026, 3, 20, 9, 0);
    final end = DateTime(2026, 3, 20, 9, 30);

    expect(
      () => segmentRepo.insertManualSegment(makeManualSegment(
        id: 'man-3',
        todoId: 'ms-3',
        start: start,
        end: end,
      )),
      throwsA(isA<DayLockedException>()),
    );
  });

  test('rejects manual segment on completed todo', () async {
    await todoRepo.createTodo(makeTodo(id: 'ms-4', title: 'Completed manual'));
    await todoRepo.updateStatus('ms-4', TodoStatus.completed);

    final start = DateTime(2026, 3, 21, 9, 0);
    final end = DateTime(2026, 3, 21, 9, 30);

    expect(
      () => segmentRepo.insertManualSegment(makeManualSegment(
        id: 'man-4',
        todoId: 'ms-4',
        start: start,
        end: end,
      )),
      throwsA(isA<CompletedLockException>()),
    );
  });

  test('allows non-overlapping manual segments', () async {
    await todoRepo
        .createTodo(makeTodo(id: 'ms-5', title: 'No overlap'));

    final start1 = DateTime(2026, 3, 21, 9, 0);
    final end1 = DateTime(2026, 3, 21, 10, 0);
    await segmentRepo.insertManualSegment(makeManualSegment(
      id: 'man-5a',
      todoId: 'ms-5',
      start: start1,
      end: end1,
    ));

    final start2 = DateTime(2026, 3, 21, 10, 0);
    final end2 = DateTime(2026, 3, 21, 11, 0);
    await segmentRepo.insertManualSegment(makeManualSegment(
      id: 'man-5b',
      todoId: 'ms-5',
      start: start2,
      end: end2,
    ));

    final segments = await segmentRepo.getSegments('ms-5');
    expect(segments, hasLength(2));
  });
}
