import 'package:sreerajp_todo/core/utils/date_utils.dart';
import 'package:sreerajp_todo/core/utils/unicode_utils.dart';
import 'package:sreerajp_todo/data/models/recall_confidence.dart';
import 'package:sreerajp_todo/data/models/spaced_repetition_item_entity.dart';
import 'package:sreerajp_todo/data/models/todo_status.dart';
import 'package:sreerajp_todo/domain/repositories/spaced_repetition_repository.dart';
import 'package:sreerajp_todo/domain/repositories/time_segment_repository.dart';
import 'package:sreerajp_todo/domain/repositories/todo_repository.dart';
import 'package:uuid/uuid.dart';

class CompleteSrsTodo {
  CompleteSrsTodo(
    this._todoRepository,
    this._timeSegmentRepository,
    this._srsRepository,
  );

  final TodoRepository _todoRepository;
  final TimeSegmentRepository _timeSegmentRepository;
  final SpacedRepetitionRepository _srsRepository;

  static const _uuid = Uuid();

  /// Completes an SRS-tagged or SRS-linked todo and recalculates next review date.
  Future<TodoStatus> call(String todoId, RecallConfidence confidence) async {
    final todo = await _todoRepository.getTodoById(todoId);
    if (todo == null) {
      throw StateError('Todo not found: $todoId');
    }

    final oldStatus = todo.status;

    final running = await _timeSegmentRepository.getRunningSegment(todoId);
    if (running != null) {
      await _timeSegmentRepository.stopSegment(todoId);
    }

    await _todoRepository.updateStatus(todoId, TodoStatus.completed);

    // Find or create SRS item
    SpacedRepetitionItemEntity? srsItem;
    if (todo.spacedRepetitionItemId != null) {
      srsItem = await _srsRepository.getItemById(todo.spacedRepetitionItemId!);
    }

    srsItem ??= await _srsRepository.getItemByTitle(todo.title);

    final today = DateTime.now();
    final todayStr = dateTimeToIso(today);
    final nowIso = today.toUtc().toIso8601String();

    if (srsItem == null) {
      // Create new SRS item if it was triggered by hashtag in title
      final cleanTitle = nfcNormalize(
        todo.title.replaceAll('#mastery', '').replaceAll('#spaced-repetition', '').trim(),
      );

      srsItem = SpacedRepetitionItemEntity(
        id: _uuid.v4(),
        title: cleanTitle.isNotEmpty ? cleanTitle : nfcNormalize(todo.title),
        description: todo.description,
        level: 1,
        easeFactor: 2.5,
        intervalDays: 1,
        nextReviewDate: todayStr,
        lastReviewedAt: nowIso,
        active: true,
        createdAt: nowIso,
        updatedAt: nowIso,
      );
      await _srsRepository.insertItem(srsItem);
    }

    // Calculate new interval and level
    int newLevel = srsItem.level;
    int newInterval = srsItem.intervalDays;

    switch (confidence) {
      case RecallConfidence.hard:
        newLevel = 1;
        newInterval = 1;
        break;
      case RecallConfidence.revision:
        // Maintain level, interval fixed to 3 days for revision
        newInterval = 3;
        break;
      case RecallConfidence.easy:
        newLevel = srsItem.level + 1;
        newInterval = 7 * newLevel;
        break;
    }

    final nextReviewDateTime = DateTime(today.year, today.month, today.day).add(
      Duration(days: newInterval),
    );
    final nextReviewDateStr = dateTimeToIso(nextReviewDateTime);

    final updatedSrsItem = srsItem.copyWith(
      level: newLevel,
      intervalDays: newInterval,
      nextReviewDate: nextReviewDateStr,
      lastReviewedAt: nowIso,
      updatedAt: nowIso,
    );

    await _srsRepository.updateItem(updatedSrsItem);

    // If todo wasn't linked to spacedRepetitionItemId, link it now
    if (todo.spacedRepetitionItemId == null) {
      final updatedTodo = todo.copyWith(
        spacedRepetitionItemId: updatedSrsItem.id,
      );
      await _todoRepository.updateTodo(updatedTodo);
    }

    return oldStatus;
  }
}
