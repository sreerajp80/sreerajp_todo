import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_todo/data/dao/time_segment_dao.dart';
import 'package:sreerajp_todo/data/dao/todo_dao.dart';
import 'package:sreerajp_todo/data/dao/todo_history_dao.dart';
import 'package:sreerajp_todo/data/models/time_segment_entity.dart';
import 'package:sreerajp_todo/data/models/todo_entity.dart';
import 'package:sreerajp_todo/data/models/todo_history_entity.dart';
import 'package:sreerajp_todo/data/models/todo_status.dart';
import 'package:sreerajp_todo/data/repositories/todo_repository_impl.dart';
import 'package:sreerajp_todo/domain/usecases/get_todo_history.dart';

import '../../helpers/test_database.dart';

void main() {
  setUpAll(initFfi);

  late TodoDao todoDao;
  late TimeSegmentDao timeSegmentDao;
  late TodoHistoryDao historyDao;
  late TodoRepositoryImpl todoRepo;
  late GetTodoHistory useCase;

  setUp(() async {
    final dbService = await createTestDatabaseService();
    todoDao = TodoDao(dbService);
    timeSegmentDao = TimeSegmentDao(dbService);
    historyDao = TodoHistoryDao(dbService);
    todoRepo = TodoRepositoryImpl(
      todoDao,
      todoHistoryDao: historyDao,
      timeSegmentDao: timeSegmentDao,
    );
    useCase = GetTodoHistory(todoRepo);
  });

  group('GetTodoHistory', () {
    test(
      'synthesizes created and past time segments when no explicit history exists',
      () async {
        final now = DateTime.now().toUtc().toIso8601String();
        final todo = TodoEntity(
          id: 'legacy-todo',
          date: '2026-08-25',
          title: 'Legacy task',
          status: TodoStatus.completed,
          sortOrder: 0,
          createdAt: '2026-08-25T08:00:00.000Z',
          updatedAt: now,
        );
        await todoDao.insert(todo);

        const seg1 = TimeSegmentEntity(
          id: 'seg-1',
          todoId: 'legacy-todo',
          startTime: '2026-08-25T09:00:00.000Z',
          endTime: '2026-08-25T09:25:00.000Z',
          durationSeconds: 1500,
          manual: false,
          createdAt: '2026-08-25T09:00:00.000Z',
        );
        await timeSegmentDao.insert(seg1);

        final history = await useCase('legacy-todo');
        expect(history.length, 2);
        expect(history[0].eventType, TodoHistoryEventType.created);
        expect(history[0].description, contains('2026-08-25'));
        expect(history[1].eventType, TodoHistoryEventType.timerStopped);
        expect(history[1].description, contains('1500s'));
      },
    );
  });
}
