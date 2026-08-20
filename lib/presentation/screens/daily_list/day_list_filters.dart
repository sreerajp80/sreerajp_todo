import 'package:sreerajp_todo/data/models/todo_entity.dart';
import 'package:sreerajp_todo/data/models/todo_status.dart';

/// The show/hide and sink-to-bottom rules for the day list.
///
/// Pulled out of the screen so they can be tested on their own, without
/// building a widget tree.

/// True when [status] is one a finished task can be in.
///
/// `ported` counts as finished: the task has moved to another day, so as far
/// as this day is concerned it is done with.
bool isFinishedStatus(TodoStatus status) =>
    status == TodoStatus.completed ||
    status == TodoStatus.dropped ||
    status == TodoStatus.ported;

/// Drops the finished tasks the user has chosen to hide.
///
/// The stored status is used, not the effective one, so a pending task that
/// happens to have tracked time is never mistaken for a finished one.
List<TodoEntity> filterVisibleTodos(
  List<TodoEntity> todos, {
  required bool showCompleted,
  required bool showDropped,
}) {
  if (showCompleted && showDropped) return todos;

  return todos.where((todo) {
    if (!showCompleted && todo.status == TodoStatus.completed) return false;
    if (!showDropped && todo.status == TodoStatus.dropped) return false;
    return true;
  }).toList();
}

/// Pushes finished tasks below the rest, keeping each group in the order the
/// chosen sort produced.
List<TodoEntity> sinkFinishedTodos(List<TodoEntity> todos) {
  return [
    ...todos.where((todo) => !isFinishedStatus(todo.status)),
    ...todos.where((todo) => isFinishedStatus(todo.status)),
  ];
}
