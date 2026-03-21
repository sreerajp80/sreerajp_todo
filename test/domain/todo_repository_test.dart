import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_todo/core/errors/exceptions.dart';
import 'package:sreerajp_todo/core/utils/unicode_utils.dart';
import 'package:sreerajp_todo/data/dao/todo_dao.dart';
import 'package:sreerajp_todo/data/models/todo_entity.dart';
import 'package:sreerajp_todo/data/models/todo_status.dart';
import 'package:sreerajp_todo/data/repositories/todo_repository_impl.dart';

import '../helpers/test_database.dart';

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

String _tomorrowIso() {
  final t = DateTime.now().add(const Duration(days: 1));
  return '${t.year.toString().padLeft(4, '0')}-'
      '${t.month.toString().padLeft(2, '0')}-'
      '${t.day.toString().padLeft(2, '0')}';
}

TodoEntity _makeTodo({
  String? id,
  String? date,
  String? title,
  TodoStatus status = TodoStatus.pending,
}) {
  final now = DateTime.now().toUtc().toIso8601String();
  return TodoEntity(
    id: id ?? 'test-id',
    date: date ?? _todayIso(),
    title: title ?? 'Test Task',
    status: status,
    sortOrder: 0,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  late TodoDao todoDao;
  late TodoRepositoryImpl repository;

  setUp(() async {
    final dbService = await createTestDatabaseService();
    todoDao = TodoDao(dbService);
    repository = TodoRepositoryImpl(todoDao);
  });

  group('Day Lock', () {
    test('mutating a past-date todo throws DayLockedException', () async {
      final todo = _makeTodo(date: _yesterdayIso());
      await todoDao.insert(todo);

      expect(
        () => repository.updateTodo(todo.copyWith(title: 'Updated')),
        throwsA(isA<DayLockedException>()),
      );
    });

    test('bypassLock allows mutation of past-date todo', () async {
      final todo = _makeTodo(id: 'bypass-test', date: _yesterdayIso());
      await todoDao.insert(todo);

      await repository.updateTodo(
        todo.copyWith(title: 'Updated'),
        bypassLock: true,
      );

      final updated = await repository.getTodoById('bypass-test');
      expect(updated?.title, 'Updated');
    });

    test('delete on past-date throws DayLockedException', () async {
      final todo = _makeTodo(id: 'del-lock', date: _yesterdayIso());
      await todoDao.insert(todo);

      expect(
        () => repository.deleteTodo('del-lock'),
        throwsA(isA<DayLockedException>()),
      );
    });
  });

  group('Status Transitions', () {
    test('pending → completed', () async {
      final todo = _makeTodo(id: 'status-1');
      await repository.createTodo(todo);

      await repository.updateStatus('status-1', TodoStatus.completed);
      final updated = await repository.getTodoById('status-1');
      expect(updated?.status, TodoStatus.completed);
    });

    test('pending → dropped', () async {
      final todo = _makeTodo(id: 'status-2', title: 'Status Drop');
      await repository.createTodo(todo);

      await repository.updateStatus('status-2', TodoStatus.dropped);
      final updated = await repository.getTodoById('status-2');
      expect(updated?.status, TodoStatus.dropped);
    });

    test('pending → ported sets portedTo', () async {
      final todo = _makeTodo(id: 'status-3', title: 'Status Port');
      await repository.createTodo(todo);

      await repository.updateStatus(
        'status-3',
        TodoStatus.ported,
        portedTo: _tomorrowIso(),
      );
      final updated = await repository.getTodoById('status-3');
      expect(updated?.status, TodoStatus.ported);
      expect(updated?.portedTo, _tomorrowIso());
    });
  });

  group('Title Uniqueness', () {
    test('duplicate title on same date throws DuplicateTitleException',
        () async {
      final todo1 = _makeTodo(id: 'dup-1', title: 'Same Title');
      await repository.createTodo(todo1);

      final todo2 = _makeTodo(id: 'dup-2', title: 'Same Title');
      expect(
        () => repository.createTodo(todo2),
        throwsA(isA<DuplicateTitleException>()),
      );
    });

    test('same title on different dates is allowed', () async {
      final todo1 =
          _makeTodo(id: 'diff-date-1', title: 'Cross Date Title');
      await repository.createTodo(todo1);

      final todo2 = _makeTodo(
        id: 'diff-date-2',
        date: _tomorrowIso(),
        title: 'Cross Date Title',
      );
      await repository.createTodo(todo2);

      final result = await repository.getTodoById('diff-date-2');
      expect(result, isNotNull);
    });
  });

  group('NFC Normalisation', () {
    test('composed and decomposed titles are treated as the same', () async {
      const nfcTitle = 'caf\u00E9';
      const nfdTitle = 'cafe\u0301';

      final todo1 = _makeTodo(id: 'nfc-1', title: nfcTitle);
      await repository.createTodo(todo1);

      final todo2 = _makeTodo(id: 'nfc-2', title: nfdTitle);
      expect(
        () => repository.createTodo(todo2),
        throwsA(isA<DuplicateTitleException>()),
      );
    });

    test('title is stored in NFC form', () async {
      const nfdTitle = 'cafe\u0301';
      final todo = _makeTodo(id: 'nfc-store', title: nfdTitle);
      await repository.createTodo(todo);

      final stored = await repository.getTodoById('nfc-store');
      expect(stored?.title, nfcNormalize(nfdTitle));
    });
  });

  group('Autocomplete and Search', () {
    test('autocomplete returns matching titles', () async {
      await repository.createTodo(
          _makeTodo(id: 'ac-1', title: 'Buy groceries'));
      await repository
          .createTodo(_makeTodo(id: 'ac-2', title: 'Buy milk'));
      await repository
          .createTodo(_makeTodo(id: 'ac-3', title: 'Read book'));

      final suggestions = await repository.getAutocompleteSuggestions('Buy');
      expect(suggestions, hasLength(2));
      expect(suggestions, contains('Buy groceries'));
      expect(suggestions, contains('Buy milk'));
    });

    test('search returns results across dates', () async {
      await repository.createTodo(
          _makeTodo(id: 's-1', title: 'Review code'));
      await repository.createTodo(
          _makeTodo(id: 's-2', date: _tomorrowIso(), title: 'Code review'));

      final results = await repository.searchByTitle('code');
      expect(results.length, greaterThanOrEqualTo(1));
    });
  });
}
