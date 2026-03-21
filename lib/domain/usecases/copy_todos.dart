import 'package:sreerajp_todo/core/utils/unicode_utils.dart';
import 'package:sreerajp_todo/data/models/todo_entity.dart';
import 'package:sreerajp_todo/data/models/todo_status.dart';
import 'package:sreerajp_todo/domain/repositories/todo_repository.dart';
import 'package:uuid/uuid.dart';

class CopyTodosResult {
  const CopyTodosResult({required this.copied, required this.skipped});

  final List<TodoEntity> copied;
  final List<TodoEntity> skipped;
}

class CopyTodos {
  CopyTodos(this._todoRepository);

  final TodoRepository _todoRepository;

  static const _uuid = Uuid();

  /// Copies [todoIds] to [targetDate].
  ///
  /// Skips any todo whose title already exists on [targetDate].
  /// All inserts are performed via the repository (which handles
  /// NFC normalisation and day lock checks).
  Future<CopyTodosResult> call(
    List<String> todoIds,
    String targetDate,
  ) async {
    final copied = <TodoEntity>[];
    final skipped = <TodoEntity>[];

    final existingTodos = await _todoRepository.getTodosByDate(targetDate);
    var nextSortOrder = existingTodos.isEmpty
        ? 0
        : existingTodos
            .map((t) => t.sortOrder)
            .reduce((a, b) => a > b ? a : b) + 1;

    for (final todoId in todoIds) {
      final source = await _todoRepository.getTodoById(todoId);
      if (source == null) continue;

      final normalizedTitle = nfcNormalize(source.title);
      if (await _todoRepository.titleExistsOnDate(
        normalizedTitle,
        targetDate,
      )) {
        skipped.add(source);
        continue;
      }

      final now = DateTime.now().toUtc().toIso8601String();
      final copy = TodoEntity(
        id: _uuid.v4(),
        date: targetDate,
        title: source.title,
        description: source.description,
        status: TodoStatus.pending,
        sourceDate: source.date,
        recurrenceRuleId: null,
        sortOrder: nextSortOrder,
        createdAt: now,
        updatedAt: now,
      );

      await _todoRepository.createTodo(copy);
      copied.add(copy);
      nextSortOrder++;
    }

    return CopyTodosResult(copied: copied, skipped: skipped);
  }
}
