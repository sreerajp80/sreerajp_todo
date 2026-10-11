import 'package:sreerajp_todo/core/constants/app_constants.dart';
import 'package:sreerajp_todo/domain/entities/todo_entity.dart';
import 'package:sreerajp_todo/domain/entities/todo_history_entity.dart';
import 'package:sreerajp_todo/domain/entities/todo_search_result.dart';
import 'package:sreerajp_todo/domain/entities/todo_status.dart';

abstract class TodoRepository {
  Future<List<TodoEntity>> getTodosByDate(String date);
  Future<TodoEntity?> getTodoById(String id);
  Future<void> createTodo(TodoEntity todo);
  Future<void> updateTodo(TodoEntity todo, {bool bypassLock = false});
  Future<void> deleteTodo(String id, {bool bypassLock = false});
  Future<int> deleteAllByRecurrenceRuleId(String recurrenceRuleId);
  Future<int> deleteByRecurrenceRuleIdFromDate(
    String recurrenceRuleId,
    String fromDate,
  );
  Future<List<TodoEntity>> getTodosByRecurrenceRuleId(String recurrenceRuleId);
  Future<List<TodoEntity>> getTodosByRecurrenceRuleIdFromDate(
    String recurrenceRuleId,
    String fromDate,
  );
  Future<List<TodoEntity>> getTodosByMasteryDeckId(String deckId);
  Future<bool> existsRuleInstanceOnDate(String recurrenceRuleId, String date);
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
  Future<String?> findConflictingDateForTitle(
    String title,
    String fromDate,
    String toDate, {
    String? excludeId,
  });
  Future<void> deleteTodoFromDate(
    String id,
    String date, {
    bool bypassLock = false,
  });
  Future<List<String>> getAutocompleteSuggestions(
    String prefix, {
    int limit = kAutocompleteLimit,
  });
  Future<List<TodoEntity>> searchByTitle(String query, {int limit = 50});
  Future<List<TodoSearchResult>> searchWithMatchedNotes(
    String query, {
    int limit = 50,
  });
  Future<void> reorderTodos(List<TodoEntity> todos, {bool bypassLock = false});
  Future<int> maxSortOrder(String date);
  Future<void> bulkCreateTodos(List<TodoEntity> todos);
  Future<void> toggleSubTask(
    String todoId,
    String subTaskId,
    bool isCompleted, {
    bool bypassLock = false,
  });
  Future<List<TodoEntity>> getPendingPrerequisites(String todoId);
  Future<bool> isTodoBlocked(String todoId);

  /// Moves a todo to [targetDate].
  ///
  /// When [detach] is false (carry-over), the todo keeps its original start
  /// date, so it still shows on the days it was active before. When [detach]
  /// is true (an explicit move), the todo belongs only to [targetDate].
  Future<void> moveTodo(
    String todoId,
    String targetDate, {
    bool detach = false,
  });

  /// Puts a moved todo back on [originalDate] with [originalSourceDate].
  ///
  /// Used only to undo a move, so it may write a past date. It still checks
  /// title uniqueness on [originalDate].
  Future<void> restoreMove(
    String todoId, {
    required String originalDate,
    required String? originalSourceDate,
  });
  Future<List<TodoHistoryEntity>> getHistoryForTodo(String todoId);
  Future<void> logHistoryEvent({
    required String todoId,
    required TodoHistoryEventType eventType,
    required String description,
    String? metadata,
    String? eventTime,
  });
}
