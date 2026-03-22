import 'package:flutter/foundation.dart';
import 'package:rrule/rrule.dart';
import 'package:sreerajp_todo/core/utils/date_utils.dart';
import 'package:sreerajp_todo/core/utils/unicode_utils.dart';
import 'package:sreerajp_todo/data/dao/recurrence_rule_dao.dart';
import 'package:sreerajp_todo/data/dao/todo_dao.dart';
import 'package:sreerajp_todo/data/models/todo_entity.dart';
import 'package:sreerajp_todo/data/models/todo_status.dart';
import 'package:uuid/uuid.dart';

class GenerateRecurringTasks {
  GenerateRecurringTasks(this._recurrenceRuleDao, this._todoDao);

  final RecurrenceRuleDao _recurrenceRuleDao;
  final TodoDao _todoDao;

  static const _uuid = Uuid();
  static const _lookAheadDays = 7;

  /// Generates recurring tasks for [today, today + 7 days].
  /// Returns the number of tasks created.
  Future<int> call() async {
    final rules = await _recurrenceRuleDao.findActive();
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

          final exists = await _todoDao.existsTitleOnDate(
            normalizedTitle,
            dateStr,
          );
          if (exists) continue;

          final maxOrder = await _todoDao.maxSortOrder(dateStr);
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
          await _todoDao.bulkInsert(todosToInsert);
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
