import 'package:sreerajp_todo/core/errors/exceptions.dart';
import 'package:sreerajp_todo/core/utils/date_utils.dart';
import 'package:sreerajp_todo/core/utils/unicode_utils.dart';
import 'package:sreerajp_todo/data/models/todo_entity.dart';
import 'package:sreerajp_todo/data/models/todo_status.dart';
import 'package:sreerajp_todo/domain/repositories/time_segment_repository.dart';
import 'package:sreerajp_todo/domain/repositories/todo_repository.dart';
import 'package:uuid/uuid.dart';

class PortTodoResult {
  const PortTodoResult({required this.oldStatus, required this.copiedTodoId});

  final TodoStatus oldStatus;
  final String copiedTodoId;
}

class PortTodo {
  PortTodo(this._todoRepository, this._timeSegmentRepository);

  final TodoRepository _todoRepository;
  final TimeSegmentRepository _timeSegmentRepository;

  static const _uuid = Uuid();

  /// Ports a todo to [targetDate].
  ///
  /// 1. Validates target date is tomorrow or later.
  /// 2. Checks title uniqueness on target date.
  /// 3. Creates a copy on target date with fresh UUID.
  /// 4. Marks source as ported.
  /// 5. Stops any running timer on the source.
  Future<PortTodoResult> call(String todoId, String targetDate) async {
    if (!isFutureDate(targetDate)) {
      throw const DayLockedException(
        'Port target date must be tomorrow or later.',
      );
    }

    final todo = await _todoRepository.getTodoById(todoId);
    if (todo == null) {
      throw const TodoNotFoundException();
    }

    final normalizedTitle = nfcNormalize(todo.title);
    if (await _todoRepository.titleExistsOnDate(normalizedTitle, targetDate)) {
      throw const DuplicateTitleException();
    }

    final running = await _timeSegmentRepository.getRunningSegment(todoId);
    if (running != null) {
      await _timeSegmentRepository.stopSegment(todoId);
    }

    final oldStatus = todo.status;
    final now = DateTime.now().toUtc().toIso8601String();

    final existingTodos = await _todoRepository.getTodosByDate(targetDate);
    final maxSortOrder = existingTodos.isEmpty
        ? 0
        : existingTodos
                  .map((t) => t.sortOrder)
                  .reduce((a, b) => a > b ? a : b) +
              1;

    final copiedTodoId = _uuid.v4();
    final copy = TodoEntity(
      id: copiedTodoId,
      date: targetDate,
      title: todo.title,
      description: todo.description,
      status: TodoStatus.pending,
      sourceDate: todo.date,
      recurrenceRuleId: null,
      sortOrder: maxSortOrder,
      createdAt: now,
      updatedAt: now,
    );

    await _todoRepository.createTodo(copy);

    await _todoRepository.updateStatus(
      todoId,
      TodoStatus.ported,
      portedTo: targetDate,
    );

    return PortTodoResult(oldStatus: oldStatus, copiedTodoId: copiedTodoId);
  }
}
