import 'package:sreerajp_todo/data/models/todo_entity.dart';
import 'package:sreerajp_todo/data/models/todo_status.dart';

abstract class TodoRepository {
  Future<List<TodoEntity>> getTodosByDate(String date);
  Future<TodoEntity?> getTodoById(String id);
  Future<void> createTodo(TodoEntity todo);
  Future<void> updateTodo(TodoEntity todo, {bool bypassLock = false});
  Future<void> deleteTodo(String id, {bool bypassLock = false});
  Future<int> deleteAllByRecurrenceRuleId(String recurrenceRuleId);
  Future<void> updateStatus(
    String id,
    TodoStatus status, {
    String? portedTo,
    bool bypassLock = false,
  });
  Future<bool> titleExistsOnDate(
    String title,
    String date, {
    String? excludeId,
  });
  Future<List<String>> getAutocompleteSuggestions(String prefix);
  Future<List<TodoEntity>> searchByTitle(String query, {int limit = 50});
  Future<void> reorderTodos(List<TodoEntity> todos, {bool bypassLock = false});
  Future<int> maxSortOrder(String date);
  Future<void> bulkCreateTodos(List<TodoEntity> todos);
}
