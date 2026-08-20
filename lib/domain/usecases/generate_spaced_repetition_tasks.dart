import 'package:sreerajp_todo/core/utils/date_utils.dart';
import 'package:sreerajp_todo/core/utils/unicode_utils.dart';
import 'package:sreerajp_todo/data/models/todo_entity.dart';
import 'package:sreerajp_todo/data/models/todo_status.dart';
import 'package:sreerajp_todo/domain/repositories/spaced_repetition_repository.dart';
import 'package:sreerajp_todo/domain/repositories/todo_repository.dart';
import 'package:uuid/uuid.dart';

class GenerateSpacedRepetitionTasks {
  GenerateSpacedRepetitionTasks(this._srsRepository, this._todoRepository);

  final SpacedRepetitionRepository _srsRepository;
  final TodoRepository _todoRepository;

  static const _uuid = Uuid();

  /// Generates daily tasks for active SRS items due on or before today.
  /// Returns the number of tasks created.
  Future<int> call() async {
    final todayStr = dateTimeToIso(DateTime.now());
    final dueItems = await _srsRepository.getItemsDueOnOrBefore(todayStr);

    var totalGenerated = 0;
    for (final item in dueItems) {
      final targetDate = item.nextReviewDate.compareTo(todayStr) < 0
          ? todayStr
          : item.nextReviewDate;

      final normalizedTitle = nfcNormalize(item.title);
      final exists = await _todoRepository.titleExistsOnDate(
        normalizedTitle,
        targetDate,
      );
      if (exists) continue;

      final maxOrder = await _todoRepository.maxSortOrder(targetDate);
      final now = DateTime.now().toUtc().toIso8601String();

      final todo = TodoEntity(
        id: _uuid.v4(),
        date: targetDate,
        title: normalizedTitle,
        description: item.description != null
            ? nfcNormalize(item.description!)
            : null,
        status: TodoStatus.pending,
        spacedRepetitionItemId: item.id,
        sortOrder: maxOrder + 1,
        createdAt: now,
        updatedAt: now,
      );

      await _todoRepository.createTodo(todo);
      totalGenerated++;
    }

    return totalGenerated;
  }
}
