import 'package:sreerajp_todo/core/constants/app_constants.dart';
import 'package:sreerajp_todo/core/errors/exceptions.dart';
import 'package:sreerajp_todo/core/utils/date_utils.dart';
import 'package:sreerajp_todo/core/utils/unicode_utils.dart';
import 'package:sreerajp_todo/data/dao/time_segment_dao.dart';
import 'package:sreerajp_todo/data/dao/todo_dao.dart';
import 'package:sreerajp_todo/data/dao/todo_history_dao.dart';
import 'package:sreerajp_todo/data/models/todo_entity.dart';
import 'package:sreerajp_todo/data/models/todo_history_entity.dart';
import 'package:sreerajp_todo/data/models/todo_search_result.dart';
import 'package:sreerajp_todo/data/models/todo_status.dart';
import 'package:sreerajp_todo/domain/repositories/todo_repository.dart';
import 'package:uuid/uuid.dart';

class TodoRepositoryImpl implements TodoRepository {
  TodoRepositoryImpl(this._todoDao, {this.todoHistoryDao, this.timeSegmentDao});

  final TodoDao _todoDao;
  final TodoHistoryDao? todoHistoryDao;
  final TimeSegmentDao? timeSegmentDao;
  static const _uuid = Uuid();

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

    await logHistoryEvent(
      todoId: normalized.id,
      eventType: TodoHistoryEventType.created,
      description: 'Task created for ${normalized.date}',
      eventTime: normalized.createdAt,
    );
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

    await logHistoryEvent(
      todoId: normalized.id,
      eventType: TodoHistoryEventType.edited,
      description: 'Task details updated',
    );
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

    await logHistoryEvent(
      todoId: id,
      eventType: TodoHistoryEventType.statusChanged,
      description: 'Status changed to ${status.name}',
      metadata: '{"status":"${status.name}"}',
    );
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

    await logHistoryEvent(
      todoId: todoId,
      eventType: TodoHistoryEventType.subtaskToggled,
      description: isCompleted ? 'Sub-task completed' : 'Sub-task reopened',
      metadata: '{"subtask_id":"$subTaskId","is_completed":$isCompleted}',
    );
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

  @override
  Future<void> logHistoryEvent({
    required String todoId,
    required TodoHistoryEventType eventType,
    required String description,
    String? metadata,
    String? eventTime,
  }) async {
    final historyDao = todoHistoryDao;
    if (historyDao == null) return;
    final nowIso = DateTime.now().toUtc().toIso8601String();
    final event = TodoHistoryEntity(
      id: _uuid.v4(),
      todoId: todoId,
      eventType: eventType,
      eventTime: eventTime ?? nowIso,
      description: description,
      metadata: metadata,
      createdAt: nowIso,
    );
    await historyDao.insert(event);
  }

  @override
  Future<List<TodoHistoryEntity>> getHistoryForTodo(String todoId) async {
    final historyDao = todoHistoryDao;
    final recorded = historyDao != null
        ? await historyDao.findByTodoId(todoId)
        : <TodoHistoryEntity>[];

    final todo = await _todoDao.findById(todoId);
    if (todo == null) return recorded;

    final hasCreated = recorded.any(
      (e) => e.eventType == TodoHistoryEventType.created,
    );
    final events = [...recorded];

    if (!hasCreated) {
      final originalDate = todo.sourceDate ?? todo.date;
      events.add(
        TodoHistoryEntity(
          id: 'synth-created-$todoId',
          todoId: todoId,
          eventType: TodoHistoryEventType.created,
          eventTime: todo.createdAt,
          description: 'Task created for $originalDate',
          createdAt: todo.createdAt,
        ),
      );
    }

    final segmentDao = timeSegmentDao;
    if (segmentDao != null) {
      final segments = await segmentDao.findByTodoId(todoId);
      final segmentIdsRecorded = recorded
          .where(
            (e) => e.metadata != null && e.metadata!.contains('segment_id'),
          )
          .map((e) => e.metadata!)
          .toSet();

      for (final segment in segments) {
        if (!segmentIdsRecorded.any((m) => m.contains(segment.id))) {
          if (segment.endTime != null && segment.durationSeconds != null) {
            events.add(
              TodoHistoryEntity(
                id: 'synth-segment-${segment.id}',
                todoId: todoId,
                eventType: segment.manual
                    ? TodoHistoryEventType.manualSegmentAdded
                    : TodoHistoryEventType.timerStopped,
                eventTime: segment.endTime!,
                description: segment.manual
                    ? 'Manual time recorded (${segment.durationSeconds}s)'
                    : 'Timer session completed (${segment.durationSeconds}s)',
                metadata:
                    '{"segment_id":"${segment.id}","duration_seconds":${segment.durationSeconds}}',
                createdAt: segment.createdAt,
              ),
            );
          }
        }
      }
    }

    events.sort((a, b) => a.eventTime.compareTo(b.eventTime));
    return events;
  }

  @override
  Future<void> moveTodo(String todoId, String targetDate) async {
    final todo = await _todoDao.findById(todoId);
    if (todo == null) throw const TodoNotFoundException();

    final normalizedTitle = nfcNormalize(todo.title);
    if (await _todoDao.existsTitleOnDate(
      normalizedTitle,
      targetDate,
      excludeId: todo.id,
    )) {
      throw const DuplicateTitleException();
    }

    final maxSort = await _todoDao.maxSortOrder(targetDate);
    final newSortOrder = maxSort < 0 ? 0 : maxSort + 1;
    final fromDate = todo.date;

    final updated = todo.copyWith(
      date: targetDate,
      sortOrder: newSortOrder,
      status: todo.status == TodoStatus.ported
          ? TodoStatus.pending
          : todo.status,
      portedTo: null,
      sourceDate: todo.sourceDate ?? fromDate,
      updatedAt: DateTime.now().toUtc().toIso8601String(),
    );

    await _todoDao.update(updated);

    await logHistoryEvent(
      todoId: todoId,
      eventType: TodoHistoryEventType.moved,
      description: 'Moved from $fromDate to $targetDate',
      metadata: '{"from_date":"$fromDate","to_date":"$targetDate"}',
    );
  }
}
