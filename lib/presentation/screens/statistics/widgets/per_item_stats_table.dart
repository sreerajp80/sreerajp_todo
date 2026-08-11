import 'package:flutter/material.dart';
import 'package:sreerajp_todo/core/extensions/localization_extensions.dart';
import 'package:sreerajp_todo/core/utils/duration_utils.dart';
import 'package:sreerajp_todo/data/models/statistics_models.dart';
import 'package:sreerajp_todo/data/models/todo_status.dart';
import 'package:sreerajp_todo/presentation/shared/theme/app_theme.dart';
import 'package:sreerajp_todo/presentation/shared/widgets/app_section_card.dart';

class PerItemSelectorCard extends StatelessWidget {
  const PerItemSelectorCard({
    super.key,
    required this.stats,
    required this.selectedTitle,
    required this.currentPage,
    required this.totalPages,
    required this.onPrevious,
    required this.onNext,
    required this.onSelectTitle,
  });

  final List<TodoTimeStats> stats;
  final String? selectedTitle;
  final int currentPage;
  final int totalPages;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final ValueChanged<String> onSelectTitle;

  @override
  Widget build(BuildContext context) {
    if (stats.isEmpty) {
      return AppSectionCard(
        title: context.l10n.statsChooseTask,
        child: SizedBox(
          height: 180,
          child: Center(child: Text(context.l10n.statsNoPerItemStats)),
        ),
      );
    }

    final pageCount = totalPages == 0 ? 1 : totalPages;
    TodoTimeStats? selectedStat;
    for (final stat in stats) {
      if (stat.title == selectedTitle) {
        selectedStat = stat;
        break;
      }
    }

    return AppSectionCard(
      title: context.l10n.statsChooseTask,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownButtonFormField<String>(
            initialValue: selectedStat?.title,
            isExpanded: true,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
            ),
            hint: Text(selectedTitle ?? context.l10n.statsChooseTask),
            items: [
              for (final stat in stats)
                DropdownMenuItem<String>(
                  value: stat.title,
                  child: Text(stat.title, overflow: TextOverflow.ellipsis),
                ),
            ],
            onChanged: (value) {
              if (value != null) {
                onSelectTitle(value);
              }
            },
          ),
          const SizedBox(height: 12),
          Text(
            selectedStat == null
                ? context.l10n.statsSelectTaskToViewHistory
                : '${context.l10n.totalTime}: ${formatDuration(selectedStat.totalSeconds)} / ${context.l10n.statsAppearances}: ${selectedStat.appearances}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
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
  }
}

class PerItemStatsTable extends StatelessWidget {
  const PerItemStatsTable({
    super.key,
    required this.stats,
    required this.currentPage,
    required this.totalPages,
    required this.onPrevious,
    required this.onNext,
    required this.onSelectTitle,
  });

  final List<TodoTimeStats> stats;
  final int currentPage;
  final int totalPages;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final ValueChanged<String> onSelectTitle;

  @override
  Widget build(BuildContext context) {
    if (stats.isEmpty) {
      return AppSectionCard(
        title: context.l10n.statsPerItemOverview,
        child: SizedBox(
          height: 180,
          child: Center(child: Text(context.l10n.statsNoPerItemStats)),
        ),
      );
    }

    final pageCount = totalPages == 0 ? 1 : totalPages;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 560;

        return AppSectionCard(
          title: context.l10n.statsPerItemOverview,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (isCompact) ...[
                for (var i = 0; i < stats.length; i++) ...[
                  _CompactPerItemTile(
                    stat: stats[i],
                    onTap: () => onSelectTitle(stats[i].title),
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
                      DataColumn(label: Text(context.l10n.statsTitle)),
                      DataColumn(label: Text(context.l10n.statsAppearances)),
                      DataColumn(label: Text(context.l10n.statusPending)),
                      DataColumn(label: Text(context.l10n.statusWorking)),
                      DataColumn(label: Text(context.l10n.statusCompleted)),
                      DataColumn(label: Text(context.l10n.statusDropped)),
                      DataColumn(label: Text(context.l10n.statusPorted)),
                      DataColumn(label: Text(context.l10n.totalTime)),
                    ],
                    rows: [
                      for (final stat in stats)
                        DataRow(
                          cells: [
                            DataCell(
                              Text(stat.title),
                              onTap: () => onSelectTitle(stat.title),
                            ),
                            DataCell(
                              Text('${stat.appearances}'),
                              onTap: () => onSelectTitle(stat.title),
                            ),
                            DataCell(
                              Text('${stat.pending}'),
                              onTap: () => onSelectTitle(stat.title),
                            ),
                            DataCell(
                              Text('${stat.working}'),
                              onTap: () => onSelectTitle(stat.title),
                            ),
                            DataCell(
                              Text('${stat.completed}'),
                              onTap: () => onSelectTitle(stat.title),
                            ),
                            DataCell(
                              Text('${stat.dropped}'),
                              onTap: () => onSelectTitle(stat.title),
                            ),
                            DataCell(
                              Text('${stat.ported}'),
                              onTap: () => onSelectTitle(stat.title),
                            ),
                            DataCell(
                              Text(formatDuration(stat.totalSeconds)),
                              onTap: () => onSelectTitle(stat.title),
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

class _CompactPerItemTile extends StatelessWidget {
  const _CompactPerItemTile({required this.stat, required this.onTap});

  final TodoTimeStats stat;
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
              Text(
                stat.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              _ValueBadge(
                label: context.l10n.statsAppearances,
                value: '${stat.appearances}',
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _StatusPill(
                    label: context.l10n.statusPending,
                    value: '${stat.pending}',
                    status: TodoStatus.pending,
                  ),
                  _StatusPill(
                    label: context.l10n.statusWorking,
                    value: '${stat.working}',
                    status: TodoStatus.working,
                  ),
                  _StatusPill(
                    label: context.l10n.statusCompleted,
                    value: '${stat.completed}',
                    status: TodoStatus.completed,
                  ),
                  _StatusPill(
                    label: context.l10n.statusDropped,
                    value: '${stat.dropped}',
                    status: TodoStatus.dropped,
                  ),
                  _StatusPill(
                    label: context.l10n.statusPorted,
                    value: '${stat.ported}',
                    status: TodoStatus.ported,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '${context.l10n.totalTime}: ${formatDuration(stat.totalSeconds)}',
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
                      label: Text(context.l10n.previous),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(context.l10n.statsPageOf(currentPage + 1, pageCount)),
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
                      label: Text(context.l10n.next),
                    ),
            ),
          ],
        );
      },
    );
  }
}
