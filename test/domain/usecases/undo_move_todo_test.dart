import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_todo/core/errors/exceptions.dart';
import 'package:sreerajp_todo/core/utils/date_utils.dart';
import 'package:sreerajp_todo/data/dao/time_segment_dao.dart';
import 'package:sreerajp_todo/data/dao/todo_dao.dart';
import 'package:sreerajp_todo/data/dao/todo_history_dao.dart';
import 'package:sreerajp_todo/domain/entities/todo_entity.dart';
import 'package:sreerajp_todo/domain/entities/todo_status.dart';
import 'package:sreerajp_todo/data/repositories/time_segment_repository_impl.dart';
import 'package:sreerajp_todo/data/repositories/todo_repository_impl.dart';
import 'package:sreerajp_todo/domain/usecases/move_todo.dart';
import 'package:sreerajp_todo/domain/usecases/undo_move_todo.dart';

import '../../helpers/test_database.dart';

String _day(int offset) {
  final now = DateTime.now();
  return dateTimeToIso(DateTime(now.year, now.month, now.day + offset));
}

void main() {
  setUpAll(initFfi);

  late TodoDao todoDao;
  late TodoRepositoryImpl todoRepo;
  late TimeSegmentRepositoryImpl timeSegmentRepo;
  late MoveTodo moveTodo;
  late UndoMoveTodo undoMoveTodo;

  setUp(() async {
    final dbService = await createTestDatabaseService();
    todoDao = TodoDao(dbService);
    final timeSegmentDao = TimeSegmentDao(dbService);
    final historyDao = TodoHistoryDao(dbService);
    todoRepo = TodoRepositoryImpl(
      todoDao,
      todoHistoryDao: historyDao,
      timeSegmentDao: timeSegmentDao,
    );
    timeSegmentRepo = TimeSegmentRepositoryImpl(
      timeSegmentDao,
      todoDao,
      dbService,
      todoHistoryDao: historyDao,
    );
    moveTodo = MoveTodo(todoRepo, timeSegmentRepo);
    undoMoveTodo = UndoMoveTodo(todoRepo, timeSegmentRepo);
  });

  Future<void> insert({
    required String id,
    required String date,
    String? sourceDate,
  }) {
    final now = DateTime.now().toUtc().toIso8601String();
    return todoDao.insert(
      TodoEntity(
        id: id,
        date: date,
        sourceDate: sourceDate,
        title: 'Task $id',
        status: TodoStatus.pending,
        sortOrder: 0,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  Future<void> undo(MoveTodoResult result) => undoMoveTodo(
    todoId: result.todoId,
    originalDate: result.fromDate,
    originalSourceDate: result.previousSourceDate,
  );

  group('UndoMoveTodo', () {
    test(
      'undoing an explicit move of a multi-day task restores its days',
      () async {
        await insert(id: 'multi', date: _day(0), sourceDate: _day(-2));

        final result = await moveTodo('multi', _day(3), detach: true);
        await undo(result);

        final todo = await todoRepo.getTodoById('multi');
        expect(todo!.date, _day(0));
        expect(todo.sourceDate, _day(-2));
        for (final offset in [-2, -1, 0]) {
          final list = await todoRepo.getTodosByDate(_day(offset));
          expect(list.map((t) => t.id), contains('multi'), reason: '$offset');
        }
      },
    );

    test(
      'undoing a carry-over puts it back on the past day with no start date',
      () async {
        await insert(id: 'carried', date: _day(-1));

        final result = await moveTodo('carried', _day(0));
        expect((await todoRepo.getTodoById('carried'))!.sourceDate, _day(-1));

        await undo(result);

        final todo = await todoRepo.getTodoById('carried');
        expect(todo!.date, _day(-1));
        expect(todo.sourceDate, isNull);
        final todayList = await todoRepo.getTodosByDate(_day(0));
        expect(todayList.where((t) => t.id == 'carried'), isEmpty);
      },
    );

    test('stops a running timer before restoring', () async {
      await insert(id: 'timed', date: _day(0));
      final result = await moveTodo('timed', _day(0));
      await timeSegmentRepo.startSegment('timed');

      await undo(result);

      expect(await timeSegmentRepo.getRunningSegment('timed'), isNull);
    });

    test('throws when the todo is gone', () async {
      expect(
        () => undoMoveTodo(
          todoId: 'missing',
          originalDate: _day(0),
          originalSourceDate: null,
        ),
        throwsA(isA<TodoNotFoundException>()),
      );
    });
  });
}
