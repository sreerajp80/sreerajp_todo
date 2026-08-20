import 'package:sreerajp_todo/core/constants/app_constants.dart';
import 'package:sreerajp_todo/core/errors/exceptions.dart';
import 'package:sreerajp_todo/core/utils/date_utils.dart';
import 'package:sreerajp_todo/core/utils/unicode_utils.dart';
import 'package:sreerajp_todo/data/dao/todo_dao.dart';
import 'package:sreerajp_todo/data/models/todo_entity.dart';
import 'package:sreerajp_todo/data/models/todo_search_result.dart';
import 'package:sreerajp_todo/data/models/todo_status.dart';
import 'package:sreerajp_todo/domain/repositories/todo_repository.dart';

class TodoRepositoryImpl implements TodoRepository {
  TodoRepositoryImpl(this._todoDao);

  final TodoDao _todoDao;

  void _checkDayLock(String date, {bool bypassLock = false}) {
    if (!bypassLock && isPastDate(date)) {
      throw const DayLockedException();
    }
  }

  TodoEntity _normalize(TodoEntity todo) {
    return todo.copyWith(
      title: nfcNormalize(todo.title),
      description: todo.description != null
          ? nfcNormalize(todo.description!)
          : null,
      subTasks: todo.subTasks
          .map((st) => st.copyWith(title: nfcNormalize(st.title)))
          .toList(),
    );
  }

  @override
  Future<List<TodoEntity>> getTodosByDate(String date) {
    return _todoDao.findByDate(date);
  }

  @override
  Future<TodoEntity?> getTodoById(String id) {
    return _todoDao.findById(id);
  }

  @override
  Future<void> createTodo(TodoEntity todo) async {
    _checkDayLock(todo.date);
    final normalized = _normalize(todo);

    if (await _todoDao.existsTitleOnDate(normalized.title, normalized.date)) {
      throw const DuplicateTitleException();
    }

    await _todoDao.insert(normalized);
  }

  @override
  Future<void> updateTodo(TodoEntity todo, {bool bypassLock = false}) async {
    _checkDayLock(todo.date, bypassLock: bypassLock);
    final normalized = _normalize(todo);

    if (await _todoDao.existsTitleOnDate(
      normalized.title,
      normalized.date,
      excludeId: normalized.id,
    )) {
      throw const DuplicateTitleException();
    }

    await _todoDao.update(normalized);
  }

  @override
  Future<void> deleteTodo(String id, {bool bypassLock = false}) async {
    final todo = await _todoDao.findById(id);
    if (todo == null) throw const TodoNotFoundException();
    _checkDayLock(todo.date, bypassLock: bypassLock);
    await _todoDao.delete(id);
  }

  @override
  Future<int> deleteAllByRecurrenceRuleId(String recurrenceRuleId) {
    return _todoDao.deleteByRecurrenceRuleId(recurrenceRuleId);
  }

  @override
  Future<int> deleteByRecurrenceRuleIdFromDate(
    String recurrenceRuleId,
    String fromDate,
  ) {
    return _todoDao.deleteByRecurrenceRuleIdFromDate(
      recurrenceRuleId,
      fromDate,
    );
  }

  @override
  Future<void> updateStatus(
    String id,
    TodoStatus status, {
    String? portedTo,
    bool bypassLock = false,
  }) async {
    final todo = await _todoDao.findById(id);
    if (todo == null) throw const TodoNotFoundException();
    _checkDayLock(todo.date, bypassLock: bypassLock);

    final updated = todo.copyWith(
      status: status,
      portedTo: status == TodoStatus.ported ? portedTo : null,
    );

    await _todoDao.update(updated);
  }

  @override
  Future<bool> titleExistsOnDate(
    String title,
    String date, {
    String? excludeId,
  }) {
    return _todoDao.existsTitleOnDate(
      nfcNormalize(title),
      date,
      excludeId: excludeId,
    );
  }

  @override
  Future<List<String>> getAutocompleteSuggestions(
    String prefix, {
    int limit = kAutocompleteLimit,
  }) {
    return _todoDao.getAllDistinctTitles(nfcNormalize(prefix), limit: limit);
  }

  @override
  Future<List<TodoEntity>> searchByTitle(String query, {int limit = 50}) {
    return _todoDao.searchByTitle(query, limit: limit);
  }

  @override
  Future<List<TodoSearchResult>> searchWithMatchedNotes(
    String query, {
    int limit = 50,
  }) {
    return _todoDao.searchWithMatchedNotes(query, limit: limit);
  }

  @override
  Future<void> reorderTodos(
    List<TodoEntity> todos, {
    bool bypassLock = false,
  }) async {
    if (todos.isNotEmpty) {
      _checkDayLock(todos.first.date, bypassLock: bypassLock);
    }
    await _todoDao.updateSortOrders(todos);
  }

  @override
  Future<int> maxSortOrder(String date) => _todoDao.maxSortOrder(date);

  @override
  Future<void> bulkCreateTodos(List<TodoEntity> todos) async {
    final normalized = todos.map(_normalize).toList();
    await _todoDao.bulkInsert(normalized);
  }

  @override
  Future<void> toggleSubTask(
    String todoId,
    String subTaskId,
    bool isCompleted, {
    bool bypassLock = false,
  }) async {
    final todo = await _todoDao.findById(todoId);
    if (todo == null) throw const TodoNotFoundException();
    _checkDayLock(todo.date, bypassLock: bypassLock);
    final now = DateTime.now().toUtc().toIso8601String();
    await _todoDao.subTaskDao.toggleSubTask(subTaskId, isCompleted, now);
  }

  @override
  Future<List<TodoEntity>> getPendingPrerequisites(String todoId) async {
    return _todoDao.taskDependencyDao.getPendingPrerequisites(todoId);
  }

  @override
  Future<bool> isTodoBlocked(String todoId) async {
    final pending = await _todoDao.taskDependencyDao.getPendingPrerequisites(
      todoId,
    );
    return pending.isNotEmpty;
  }
}
