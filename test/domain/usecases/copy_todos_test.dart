import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_todo/data/dao/recurrence_rule_dao.dart';
import 'package:sreerajp_todo/data/dao/time_segment_dao.dart';
import 'package:sreerajp_todo/data/dao/todo_dao.dart';
import 'package:sreerajp_todo/data/models/recurrence_rule_entity.dart';
import 'package:sreerajp_todo/data/models/todo_entity.dart';
import 'package:sreerajp_todo/data/models/todo_status.dart';
import 'package:sreerajp_todo/data/repositories/time_segment_repository_impl.dart';
import 'package:sreerajp_todo/data/repositories/todo_repository_impl.dart';
import 'package:sreerajp_todo/domain/usecases/copy_todos.dart';

import '../../helpers/test_database.dart';

void main() {
  late TodoDao todoDao;
  late TimeSegmentDao timeSegmentDao;
  late RecurrenceRuleDao recurrenceRuleDao;
  late TodoRepositoryImpl todoRepo;
  late TimeSegmentRepositoryImpl timeSegmentRepo;
  late CopyTodos useCase;

  setUp(() async {
    final dbService = await createTestDatabaseService();
    todoDao = TodoDao(dbService);
    timeSegmentDao = TimeSegmentDao(dbService);
    recurrenceRuleDao = RecurrenceRuleDao(dbService);
    todoRepo = TodoRepositoryImpl(todoDao);
    timeSegmentRepo = TimeSegmentRepositoryImpl(
      timeSegmentDao,
      todoDao,
      dbService,
    );
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

  TodoEntity makeTodo({
    required String id,
    required String title,
    TodoStatus status = TodoStatus.pending,
    String? recurrenceRuleId,
  }) {
    final now = DateTime.now().toUtc().toIso8601String();
    return TodoEntity(
      id: id,
      date: todayIso(),
      title: title,
      status: status,
      recurrenceRuleId: recurrenceRuleId,
      sortOrder: 0,
      createdAt: now,
      updatedAt: now,
    );
  }

  test('copies 3 todos to target date with correct fields', () async {
    await todoRepo.createTodo(makeTodo(id: 'c-1', title: 'Task A'));
    await todoRepo.createTodo(makeTodo(id: 'c-2', title: 'Task B'));
    await todoRepo.createTodo(makeTodo(id: 'c-3', title: 'Task C'));

    final result = await useCase(['c-1', 'c-2', 'c-3'], tomorrowIso());

    expect(result.copied, hasLength(3));
    expect(result.skipped, isEmpty);

    final targetTodos = await todoRepo.getTodosByDate(tomorrowIso());
    expect(targetTodos, hasLength(3));
    for (final t in targetTodos) {
      expect(t.status, TodoStatus.pending);
      expect(t.sourceDate, todayIso());
      expect(t.date, tomorrowIso());
    }
  });

  test('skips 1 conflicting title, copies the other 2', () async {
    await todoRepo.createTodo(makeTodo(id: 'c-4', title: 'Task D'));
    await todoRepo.createTodo(makeTodo(id: 'c-5', title: 'Task E'));
    await todoRepo.createTodo(makeTodo(id: 'c-6', title: 'Task F'));

    final existingOnTarget = TodoEntity(
      id: 'existing-d',
      date: tomorrowIso(),
      title: 'Task D',
      sortOrder: 0,
      createdAt: DateTime.now().toUtc().toIso8601String(),
      updatedAt: DateTime.now().toUtc().toIso8601String(),
    );
    await todoRepo.createTodo(existingOnTarget);

    final result = await useCase(['c-4', 'c-5', 'c-6'], tomorrowIso());

    expect(result.copied, hasLength(2));
    expect(result.skipped, hasLength(1));
    expect(result.skipped.first.title, 'Task D');
  });

  test('copied todos have sourceDate set to source date', () async {
    await todoRepo.createTodo(makeTodo(id: 'c-7', title: 'Source Test'));

    final result = await useCase(['c-7'], tomorrowIso());

    expect(result.copied.first.sourceDate, todayIso());
  });

  test(
    'copied todos have status=pending regardless of source status',
    () async {
      await todoRepo.createTodo(
        makeTodo(
          id: 'c-8',
          title: 'Completed One',
          status: TodoStatus.completed,
        ),
      );
      await todoRepo.createTodo(
        makeTodo(id: 'c-9', title: 'Dropped One', status: TodoStatus.dropped),
      );

      final result = await useCase(['c-8', 'c-9'], tomorrowIso());

      expect(result.copied, hasLength(2));
      for (final t in result.copied) {
        expect(t.status, TodoStatus.pending);
      }
    },
  );

  test('time segments are NOT copied', () async {
    await todoRepo.createTodo(makeTodo(id: 'c-10', title: 'Timer Task'));
    await timeSegmentRepo.startSegment('c-10');
    await timeSegmentRepo.stopSegment('c-10');

    final result = await useCase(['c-10'], tomorrowIso());

    final copiedId = result.copied.first.id;
    final segments = await timeSegmentRepo.getSegments(copiedId);
    expect(segments, isEmpty);
  });

  test('recurrenceRuleId is NOT inherited', () async {
    final now = DateTime.now().toUtc().toIso8601String();
    await recurrenceRuleDao.insert(
      RecurrenceRuleEntity(
        id: 'some-rule-id',
        title: 'Test Rule',
        rrule: 'FREQ=DAILY;COUNT=5',
        startDate: todayIso(),
        createdAt: now,
        updatedAt: now,
      ),
    );
    await todoRepo.createTodo(
      makeTodo(
        id: 'c-11',
        title: 'Recurring Copy',
        recurrenceRuleId: 'some-rule-id',
      ),
    );

    final result = await useCase(['c-11'], tomorrowIso());

    expect(result.copied.first.recurrenceRuleId, isNull);
    final onTarget = await todoRepo.getTodosByDate(tomorrowIso());
    expect(onTarget.first.recurrenceRuleId, isNull);
  });

  test('copied todos have fresh IDs', () async {
    await todoRepo.createTodo(makeTodo(id: 'c-12', title: 'Fresh ID'));

    final result = await useCase(['c-12'], tomorrowIso());

    expect(result.copied.first.id, isNot('c-12'));
  });

  test('copied todos have incrementing sort order', () async {
    await todoRepo.createTodo(makeTodo(id: 'c-13', title: 'Order A'));
    await todoRepo.createTodo(makeTodo(id: 'c-14', title: 'Order B'));

    await useCase(['c-13', 'c-14'], tomorrowIso());

    final targetTodos = await todoRepo.getTodosByDate(tomorrowIso());
    expect(targetTodos[0].sortOrder, lessThan(targetTodos[1].sortOrder));
  });
}
