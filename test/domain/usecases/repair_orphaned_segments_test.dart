import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_todo/data/dao/time_segment_dao.dart';
import 'package:sreerajp_todo/data/dao/todo_dao.dart';
import 'package:sreerajp_todo/data/models/time_segment_entity.dart';
import 'package:sreerajp_todo/data/models/todo_entity.dart';
import 'package:sreerajp_todo/data/repositories/time_segment_repository_impl.dart';
import 'package:sreerajp_todo/domain/usecases/repair_orphaned_segments.dart';

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

String _twoDaysAgoIso() {
  final d = DateTime.now().subtract(const Duration(days: 2));
  return '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}

void main() {
  late TodoDao todoDao;
  late TimeSegmentDao segmentDao;
  late TimeSegmentRepositoryImpl segmentRepo;
  late RepairOrphanedSegments useCase;

  setUpAll(initFfi);

  setUp(() async {
    final dbService = await createTestDatabaseService();
    todoDao = TodoDao(dbService);
    segmentDao = TimeSegmentDao(dbService);
    segmentRepo = TimeSegmentRepositoryImpl(segmentDao, todoDao, dbService);
    useCase = RepairOrphanedSegments(segmentRepo);
  });

  TodoEntity makeTodo({required String id, required String date}) {
    final now = DateTime.now().toUtc().toIso8601String();
    return TodoEntity(
      id: id,
      date: date,
      title: 'Task $id',
      sortOrder: 0,
      createdAt: now,
      updatedAt: now,
    );
  }

  TimeSegmentEntity makeSegment({
    required String id,
    required String todoId,
    required DateTime startTime,
  }) {
    return TimeSegmentEntity(
      id: id,
      todoId: todoId,
      startTime: startTime.toIso8601String(),
      createdAt: DateTime.now().toUtc().toIso8601String(),
    );
  }

  test(
    'closes orphaned segments on past-date todos with zero duration and interrupted=true',
    () async {
      await todoDao.insert(makeTodo(id: 'past-todo', date: _yesterdayIso()));
      final startTime = DateTime(2026, 3, 20, 14, 0);
      await segmentDao.insert(
        makeSegment(id: 'orphan-1', todoId: 'past-todo', startTime: startTime),
      );

      await useCase();

      final segments = await segmentDao.findByTodoId('past-todo');
      expect(segments, hasLength(1));
      final repaired = segments.first;
      expect(repaired.endTime, isNotNull);
      expect(repaired.endTime, repaired.startTime);
      expect(repaired.durationSeconds, 0);
      expect(repaired.interrupted, isTrue);
    },
  );

  test('does not repair today\'s running segments', () async {
    await todoDao.insert(makeTodo(id: 'today-todo', date: _todayIso()));
    await segmentDao.insert(
      makeSegment(
        id: 'today-seg',
        todoId: 'today-todo',
        startTime: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    );

    await useCase();

    final running = await segmentDao.findRunningSegment('today-todo');
    expect(running, isNotNull);
    expect(running!.endTime, isNull);
  });

  test('repairs multiple orphans across different past-date todos', () async {
    await todoDao.insert(makeTodo(id: 'past-1', date: _yesterdayIso()));
    await todoDao.insert(makeTodo(id: 'past-2', date: _twoDaysAgoIso()));

    await segmentDao.insert(
      makeSegment(
        id: 'orphan-a',
        todoId: 'past-1',
        startTime: DateTime(2026, 3, 20, 10, 0),
      ),
    );
    await segmentDao.insert(
      makeSegment(
        id: 'orphan-b',
        todoId: 'past-2',
        startTime: DateTime(2026, 3, 19, 8, 0),
      ),
    );

    await useCase();

    final segsA = await segmentDao.findByTodoId('past-1');
    expect(segsA.first.interrupted, isTrue);
    expect(segsA.first.durationSeconds, 0);

    final segsB = await segmentDao.findByTodoId('past-2');
    expect(segsB.first.interrupted, isTrue);
    expect(segsB.first.durationSeconds, 0);
  });

  test('does nothing when there are no orphans', () async {
    await useCase();
  });
}
