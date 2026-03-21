import 'package:flutter/material.dart';
import 'package:rrule/rrule.dart';
import 'package:sreerajp_todo/core/constants/app_strings.dart';
import 'package:sreerajp_todo/core/utils/date_utils.dart';

class RrulePreview extends StatelessWidget {
  const RrulePreview({
    super.key,
    required this.rruleString,
    required this.startDate,
    this.endDate,
  });

  final String rruleString;
  final String startDate;
  final String? endDate;

  List<DateTime> _computeOccurrences() {
    if (rruleString.isEmpty) return [];
    try {
      final rrule = RecurrenceRule.fromString('RRULE:$rruleString');
      final start = parseIsoDate(startDate);
      final end = endDate != null ? parseIsoDate(endDate!) : null;

      final instances = rrule
          .getInstances(start: start.copyWith(isUtc: true))
          .where((d) => end == null || !d.isAfter(end.copyWith(isUtc: true)))
          .take(5)
          .map((d) => d.copyWith(isUtc: false))
          .toList();
      return instances;
    } on Object {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final occurrences = _computeOccurrences();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.nextOccurrences,
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            if (occurrences.isEmpty)
              Text(
                AppStrings.noUpcomingOccurrences,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              )
            else
              ...occurrences.map(
                (date) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Icon(
                        Icons.event,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        formatDate(date),
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
