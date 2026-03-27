import 'package:flutter/foundation.dart';
import 'package:rrule/rrule.dart';
import 'package:sreerajp_todo/core/utils/date_utils.dart';
import 'package:sreerajp_todo/core/utils/unicode_utils.dart';
import 'package:sreerajp_todo/data/models/todo_entity.dart';
import 'package:sreerajp_todo/data/models/todo_status.dart';
import 'package:sreerajp_todo/domain/repositories/recurrence_rule_repository.dart';
import 'package:sreerajp_todo/domain/repositories/todo_repository.dart';
import 'package:uuid/uuid.dart';

class GenerateRecurringTasks {
  GenerateRecurringTasks(this._recurrenceRuleRepository, this._todoRepository);

  final RecurrenceRuleRepository _recurrenceRuleRepository;
  final TodoRepository _todoRepository;

  static const _uuid = Uuid();
  static const _lookAheadDays = 7;

  /// Generates recurring tasks for [today, today + 7 days].
  /// Returns the number of tasks created.
  Future<int> call() async {
    final rules = await _recurrenceRuleRepository.findActive();
    var totalGenerated = 0;

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final windowEnd = todayDate.add(const Duration(days: _lookAheadDays));

    for (final rule in rules) {
      final ruleEndDate = rule.endDate != null
          ? parseIsoDate(rule.endDate!)
          : null;

      if (ruleEndDate != null && ruleEndDate.isBefore(todayDate)) {
        continue;
      }

      try {
        final rrule = RecurrenceRule.fromString('RRULE:${rule.rrule}');
        final ruleStart = parseIsoDate(rule.startDate);

        final startUtc = ruleStart.copyWith(isUtc: true);
        final windowStartUtc = todayDate.copyWith(isUtc: true);
        final windowEndUtc = windowEnd.copyWith(isUtc: true);

        // getInstances returns dates in chronological order.
        // Use skipWhile/takeWhile to avoid consuming an infinite iterable.
        final instances = rrule
            .getInstances(start: startUtc)
            .skipWhile((d) => d.isBefore(windowStartUtc))
            .takeWhile((d) => !d.isAfter(windowEndUtc));

        final normalizedTitle = nfcNormalize(rule.title);
        final normalizedDescription = rule.description != null
            ? nfcNormalize(rule.description!)
            : null;

        final todosToInsert = <TodoEntity>[];

        for (final instance in instances) {
          final localDate = instance.copyWith(isUtc: false);
          final dateStr = dateTimeToIso(localDate);

          if (ruleEndDate != null && localDate.isAfter(ruleEndDate)) {
            continue;
          }

          final exists = await _todoRepository.titleExistsOnDate(
            normalizedTitle,
            dateStr,
          );
          if (exists) continue;

          final maxOrder = await _todoRepository.maxSortOrder(dateStr);
          final now = DateTime.now().toUtc().toIso8601String();
          todosToInsert.add(
            TodoEntity(
              id: _uuid.v4(),
              date: dateStr,
              title: normalizedTitle,
              description: normalizedDescription,
              status: TodoStatus.pending,
              recurrenceRuleId: rule.id,
              sortOrder: maxOrder + 1,
              createdAt: now,
              updatedAt: now,
            ),
          );
        }

        if (todosToInsert.isNotEmpty) {
          await _todoRepository.bulkCreateTodos(todosToInsert);
          totalGenerated += todosToInsert.length;
        }
      } on FormatException catch (e) {
        debugPrint('Skipping rule ${rule.id}: invalid RRULE: $e');
      }
    }

    debugPrint('GenerateRecurringTasks: created $totalGenerated tasks');
    return totalGenerated;
  }
}
