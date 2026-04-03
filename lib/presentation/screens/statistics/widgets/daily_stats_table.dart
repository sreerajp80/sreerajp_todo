import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sreerajp_todo/core/constants/app_strings.dart';
import 'package:sreerajp_todo/core/utils/duration_utils.dart';
import 'package:sreerajp_todo/data/models/statistics_models.dart';
import 'package:sreerajp_todo/data/models/todo_status.dart';
import 'package:sreerajp_todo/presentation/shared/theme/app_theme.dart';
import 'package:sreerajp_todo/presentation/shared/widgets/app_section_card.dart';

class DailyStatsTable extends StatelessWidget {
  const DailyStatsTable({
    super.key,
    required this.stats,
    required this.currentPage,
    required this.totalPages,
    required this.onPrevious,
    required this.onNext,
    required this.onSelectDate,
  });

  final List<DayStats> stats;
  final int currentPage;
  final int totalPages;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final ValueChanged<String> onSelectDate;

  @override
  Widget build(BuildContext context) {
    if (stats.isEmpty) {
      return AppSectionCard(
        title: AppStrings.stats.total,
        child: SizedBox(
          height: 180,
          child: Center(child: Text(AppStrings.stats.noDailyStats)),
        ),
      );
    }

    final pageCount = totalPages == 0 ? 1 : totalPages;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 560;

        return AppSectionCard(
          title: AppStrings.stats.total,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (isCompact) ...[
                for (var i = 0; i < stats.length; i++) ...[
                  _CompactDailyStatTile(
                    stat: stats[i],
                    onTap: () => onSelectDate(stats[i].date),
                  ),
                  if (i != stats.length - 1) const SizedBox(height: 12),
                ],
              ] else
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 18,
                    horizontalMargin: 6,
                    headingRowHeight: 40,
                    dataRowMinHeight: 42,
                    dataRowMaxHeight: 46,
                    columns: [
                      DataColumn(label: Text(AppStrings.stats.date)),
                      DataColumn(label: Text(AppStrings.stats.total)),
                      const DataColumn(label: Text(AppStrings.statusPending)),
                      const DataColumn(label: Text(AppStrings.statusWorking)),
                      const DataColumn(label: Text(AppStrings.statusCompleted)),
                      const DataColumn(label: Text(AppStrings.statusDropped)),
                      const DataColumn(label: Text(AppStrings.statusPorted)),
                      const DataColumn(label: Text(AppStrings.totalTime)),
                    ],
                    rows: [
                      for (final stat in stats)
                        DataRow(
                          cells: [
                            DataCell(
                              Text(
                                DateFormat.yMMMd().format(
                                  DateTime.parse(stat.date),
                                ),
                              ),
                              onTap: () => onSelectDate(stat.date),
                            ),
                            DataCell(
                              Text('${stat.total}'),
                              onTap: () => onSelectDate(stat.date),
                            ),
                            DataCell(
                              Text('${stat.pending}'),
                              onTap: () => onSelectDate(stat.date),
                            ),
                            DataCell(
                              Text('${stat.working}'),
                              onTap: () => onSelectDate(stat.date),
                            ),
                            DataCell(
                              Text('${stat.completed}'),
                              onTap: () => onSelectDate(stat.date),
                            ),
                            DataCell(
                              Text('${stat.dropped}'),
                              onTap: () => onSelectDate(stat.date),
                            ),
                            DataCell(
                              Text('${stat.ported}'),
                              onTap: () => onSelectDate(stat.date),
                            ),
                            DataCell(
                              Text(formatDuration(stat.totalSeconds)),
                              onTap: () => onSelectDate(stat.date),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              _PaginationFooter(
                currentPage: currentPage,
                pageCount: pageCount,
                canGoBack: currentPage > 0,
                canGoForward: currentPage + 1 < totalPages,
                onPrevious: onPrevious,
                onNext: onNext,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CompactDailyStatTile extends StatelessWidget {
  const _CompactDailyStatTile({required this.stat, required this.onTap});

  final DayStats stat;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      DateFormat.yMMMd().format(DateTime.parse(stat.date)),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  _ValueBadge(
                    label: AppStrings.stats.total,
                    value: '${stat.total}',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _StatusPill(
                    label: AppStrings.statusPending,
                    value: '${stat.pending}',
                    status: TodoStatus.pending,
                  ),
                  _StatusPill(
                    label: AppStrings.statusWorking,
                    value: '${stat.working}',
                    status: TodoStatus.working,
                  ),
                  _StatusPill(
                    label: AppStrings.statusCompleted,
                    value: '${stat.completed}',
                    status: TodoStatus.completed,
                  ),
                  _StatusPill(
                    label: AppStrings.statusDropped,
                    value: '${stat.dropped}',
                    status: TodoStatus.dropped,
                  ),
                  _StatusPill(
                    label: AppStrings.statusPorted,
                    value: '${stat.ported}',
                    status: TodoStatus.ported,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '${AppStrings.totalTime}: ${formatDuration(stat.totalSeconds)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.label,
    required this.value,
    required this.status,
  });

  final String label;
  final String value;
  final TodoStatus status;

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.statusColor(Theme.of(context), status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$label $value',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ValueBadge extends StatelessWidget {
  const _ValueBadge({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$label $value',
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _PaginationFooter extends StatelessWidget {
  const _PaginationFooter({
    required this.currentPage,
    required this.pageCount,
    required this.canGoBack,
    required this.canGoForward,
    required this.onPrevious,
    required this.onNext,
  });

  final int currentPage;
  final int pageCount;
  final bool canGoBack;
  final bool canGoForward;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 340;

        return Row(
          children: [
            Expanded(
              child: compact
                  ? OutlinedButton(
                      onPressed: canGoBack ? onPrevious : null,
                      child: const Icon(Icons.arrow_back_rounded),
                    )
                  : OutlinedButton.icon(
                      onPressed: canGoBack ? onPrevious : null,
                      icon: const Icon(Icons.arrow_back_rounded),
                      label: const Text(AppStrings.previous),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(AppStrings.stats.pageOf(currentPage + 1, pageCount)),
            ),
            Expanded(
              child: compact
                  ? OutlinedButton(
                      onPressed: canGoForward ? onNext : null,
                      child: const Icon(Icons.arrow_forward_rounded),
                    )
                  : OutlinedButton.icon(
                      onPressed: canGoForward ? onNext : null,
                      icon: const Icon(Icons.arrow_forward_rounded),
                      label: const Text(AppStrings.next),
                    ),
            ),
          ],
        );
      },
    );
  }
}
