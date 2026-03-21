import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_todo/core/errors/exceptions.dart';
import 'package:sreerajp_todo/data/dao/recurrence_rule_dao.dart';
import 'package:sreerajp_todo/data/dao/time_segment_dao.dart';
import 'package:sreerajp_todo/data/dao/todo_dao.dart';
import 'package:sreerajp_todo/data/models/recurrence_rule_entity.dart';
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
  late RecurrenceRuleDao recurrenceRuleDao;
  late TodoRepositoryImpl todoRepo;
  late TimeSegmentRepositoryImpl timeSegmentRepo;
  late PortTodo useCase;

  setUp(() async {
    final dbService = await createTestDatabaseService();
    todoDao = TodoDao(dbService);
    timeSegmentDao = TimeSegmentDao(dbService);
    recurrenceRuleDao = RecurrenceRuleDao(dbService);
    todoRepo = TodoRepositoryImpl(todoDao);
    timeSegmentRepo = TimeSegmentRepositoryImpl(timeSegmentDao, todoDao);
    useCase = PortTodo(todoRepo, timeSegmentRepo);
  });

  TodoEntity makeTodo({
    required String id,
    required String title,
    TodoStatus status = TodoStatus.pending,
    String? recurrenceRuleId,
  }) {
    final now = DateTime.now().toUtc().toIso8601String();
    return TodoEntity(
      id: id,
      date: _todayIso(),
      title: title,
      status: status,
      recurrenceRuleId: recurrenceRuleId,
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

  test('source portedTo is set to target date', () async {
    await todoRepo.createTodo(makeTodo(id: 'pt-pto', title: 'Ported To Test'));

    await useCase('pt-pto', _tomorrowIso());

    final source = await todoRepo.getTodoById('pt-pto');
    expect(source?.portedTo, _tomorrowIso());
  });

  test('copy sourceDate is set to source date', () async {
    await todoRepo.createTodo(makeTodo(id: 'pt-src', title: 'Source Date'));

    final result = await useCase('pt-src', _tomorrowIso());

    final copy = await todoRepo.getTodoById(result.copiedTodoId);
    expect(copy?.sourceDate, _todayIso());
  });

  test('undo: copy deleted, source reverts to original status', () async {
    await todoRepo.createTodo(makeTodo(id: 'pt-undo', title: 'Undo Port'));

    final result = await useCase('pt-undo', _tomorrowIso());

    expect(
      (await todoRepo.getTodoById('pt-undo'))?.status,
      TodoStatus.ported,
    );
    expect(await todoRepo.getTodoById(result.copiedTodoId), isNotNull);

    await todoRepo.deleteTodo(result.copiedTodoId, bypassLock: true);
    await todoRepo.updateStatus('pt-undo', result.oldStatus, portedTo: null);

    final reverted = await todoRepo.getTodoById('pt-undo');
    expect(reverted?.status, TodoStatus.pending);
    expect(reverted?.portedTo, isNull);
    expect(await todoRepo.getTodoById(result.copiedTodoId), isNull);
  });

  test('stops running timer on source before porting', () async {
    await todoRepo.createTodo(makeTodo(id: 'pt-timer', title: 'Timer Port'));
    await timeSegmentRepo.startSegment('pt-timer');

    final running = await timeSegmentRepo.getRunningSegment('pt-timer');
    expect(running, isNotNull);

    await useCase('pt-timer', _tomorrowIso());

    final runningAfter = await timeSegmentRepo.getRunningSegment('pt-timer');
    expect(runningAfter, isNull);
  });

  test('throws DayLockedException if target date is today (not future)',
      () async {
    await todoRepo.createTodo(makeTodo(id: 'pt-today', title: 'Today Port'));

    expect(
      () => useCase('pt-today', _todayIso()),
      throwsA(isA<DayLockedException>()),
    );
  });

  test('throws DuplicateTitleException if title exists on target date',
      () async {
    await todoRepo.createTodo(makeTodo(id: 'pt-dup', title: 'Dup Port'));

    final existingOnTarget = TodoEntity(
      id: 'target-dup',
      date: _tomorrowIso(),
      title: 'Dup Port',
      sortOrder: 0,
      createdAt: DateTime.now().toUtc().toIso8601String(),
      updatedAt: DateTime.now().toUtc().toIso8601String(),
    );
    await todoRepo.createTodo(existingOnTarget);

    expect(
      () => useCase('pt-dup', _tomorrowIso()),
      throwsA(isA<DuplicateTitleException>()),
    );
  });

  test('throws TodoNotFoundException for nonexistent todo', () async {
    expect(
      () => useCase('nonexistent', _tomorrowIso()),
      throwsA(isA<TodoNotFoundException>()),
    );
  });

  test('recurrenceRuleId is NOT inherited', () async {
    final now = DateTime.now().toUtc().toIso8601String();
    await recurrenceRuleDao.insert(RecurrenceRuleEntity(
      id: 'rule-123',
      title: 'Test Rule',
      rrule: 'FREQ=DAILY;COUNT=5',
      startDate: _todayIso(),
      createdAt: now,
      updatedAt: now,
    ));
    await todoRepo.createTodo(makeTodo(
      id: 'pt-rule',
      title: 'Recurring Port',
      recurrenceRuleId: 'rule-123',
    ));

    final result = await useCase('pt-rule', _tomorrowIso());

    final copy = await todoRepo.getTodoById(result.copiedTodoId);
    expect(copy?.recurrenceRuleId, isNull);
  });

  test('copy has fresh UUID different from source', () async {
    await todoRepo.createTodo(makeTodo(id: 'pt-uuid', title: 'UUID Port'));

    final result = await useCase('pt-uuid', _tomorrowIso());

    expect(result.copiedTodoId, isNot('pt-uuid'));
  });
}
