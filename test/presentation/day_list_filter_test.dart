import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_todo/data/models/todo_entity.dart';
import 'package:sreerajp_todo/data/models/todo_status.dart';
import 'package:sreerajp_todo/presentation/screens/daily_list/day_list_filters.dart';

void main() {
  TodoEntity todo(String id, TodoStatus status) {
    const now = '2026-08-19T00:00:00.000Z';
    return TodoEntity(
      id: id,
      date: '2026-08-19',
      title: 'Task $id',
      status: status,
      createdAt: now,
      updatedAt: now,
    );
  }

  final all = [
    todo('a', TodoStatus.pending),
    todo('b', TodoStatus.completed),
    todo('c', TodoStatus.working),
    todo('d', TodoStatus.dropped),
    todo('e', TodoStatus.ported),
  ];

  List<String> idsOf(List<TodoEntity> todos) => todos.map((t) => t.id).toList();

  group('isFinishedStatus', () {
    test('completed, dropped and ported all count as finished', () {
      expect(isFinishedStatus(TodoStatus.completed), isTrue);
      expect(isFinishedStatus(TodoStatus.dropped), isTrue);
      expect(isFinishedStatus(TodoStatus.ported), isTrue);
    });

    test('pending and working are not finished', () {
      expect(isFinishedStatus(TodoStatus.pending), isFalse);
      expect(isFinishedStatus(TodoStatus.working), isFalse);
    });
  });

  group('filterVisibleTodos', () {
    test('shows everything when both switches are on', () {
      final result = filterVisibleTodos(
        all,
        showCompleted: true,
        showDropped: true,
      );
      expect(identical(result, all), isTrue);
    });

    test('hides completed tasks only', () {
      final result = filterVisibleTodos(
        all,
        showCompleted: false,
        showDropped: true,
      );
      expect(idsOf(result), ['a', 'c', 'd', 'e']);
    });

    test('hides dropped tasks only', () {
      final result = filterVisibleTodos(
        all,
        showCompleted: true,
        showDropped: false,
      );
      expect(idsOf(result), ['a', 'b', 'c', 'e']);
    });

    test('hides both, but never hides a ported task', () {
      final result = filterVisibleTodos(
        all,
        showCompleted: false,
        showDropped: false,
      );
      expect(idsOf(result), ['a', 'c', 'e']);
    });

    test('leaves the original list untouched', () {
      filterVisibleTodos(all, showCompleted: false, showDropped: false);
      expect(all, hasLength(5));
    });
  });

  group('sinkFinishedTodos', () {
    test('pushes finished tasks below the rest', () {
      expect(idsOf(sinkFinishedTodos(all)), ['a', 'c', 'b', 'd', 'e']);
    });

    test('keeps the order inside each group', () {
      final input = [
        todo('x', TodoStatus.completed),
        todo('y', TodoStatus.pending),
        todo('z', TodoStatus.dropped),
        todo('w', TodoStatus.working),
      ];
      expect(idsOf(sinkFinishedTodos(input)), ['y', 'w', 'x', 'z']);
    });

    test('a list with nothing finished comes back in the same order', () {
      final input = [
        todo('p', TodoStatus.pending),
        todo('q', TodoStatus.working),
      ];
      expect(idsOf(sinkFinishedTodos(input)), ['p', 'q']);
    });

    test('an empty list stays empty', () {
      expect(sinkFinishedTodos(const []), isEmpty);
    });
  });

  group('filter then sink together', () {
    test('hidden tasks never come back through sinking', () {
      final visible = filterVisibleTodos(
        all,
        showCompleted: false,
        showDropped: false,
      );
      expect(idsOf(sinkFinishedTodos(visible)), ['a', 'c', 'e']);
    });
  });
}
