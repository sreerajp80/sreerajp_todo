import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sreerajp_todo/core/utils/date_utils.dart';
import 'package:sreerajp_todo/core/extensions/localization_extensions.dart';
import 'package:sreerajp_todo/core/utils/duration_utils.dart';
import 'package:sreerajp_todo/data/models/statistics_models.dart';
import 'package:sreerajp_todo/data/models/todo_status.dart';
import 'package:sreerajp_todo/presentation/shared/theme/app_theme.dart';
import 'package:sreerajp_todo/presentation/shared/widgets/app_section_card.dart';
import 'package:sreerajp_todo/presentation/shared/utils/tracked_duration_format.dart';

class PerItemLineChart extends StatelessWidget {
  const PerItemLineChart({
    super.key,
    required this.selectedTitle,
    required this.history,
    this.selectedStat,
  });

  final String? selectedTitle;
  final List<TitleTimePoint> history;
  final TodoTimeStats? selectedStat;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (selectedTitle == null || selectedTitle!.isEmpty) {
      return AppSectionCard(
        title: context.l10n.statsPerItemOverview,
        child: SizedBox(
          height: 320,
          child: Center(
            child: Text(
              context.l10n.statsSelectTaskToViewHistory,
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    if (history.isEmpty) {
      return AppSectionCard(
        title: context.l10n.statsHistoryFor(selectedTitle!),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (selectedStat != null) ...[
              _ChartLegend(stat: selectedStat!),
              const SizedBox(height: 16),
            ],
            SizedBox(
              height: 320,
              child: Center(
                child: Text(
                  context.l10n.statsNoHistoryForTitle,
                  style: theme.textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final points = [
      for (var i = 0; i < history.length; i++)
        FlSpot(i.toDouble(), history[i].totalSeconds / 60),
    ];
    final maxY = points.map((point) => point.y).reduce((a, b) => a > b ? a : b);
    final yAxisInterval = _resolveYAxisInterval(maxY);
    final chartMaxY = _resolveChartMaxY(maxY, yAxisInterval);

    return AppSectionCard(
      title: context.l10n.statsHistoryFor(selectedTitle!),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (selectedStat != null) ...[
            _ChartLegend(stat: selectedStat!),
            const SizedBox(height: 16),
          ],
          SizedBox(
            height: 320,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: chartMaxY,
                gridData: FlGridData(
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: theme.colorScheme.outlineVariant,
                    strokeWidth: 1,
                    dashArray: const [6, 4],
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (spots) {
                      return spots
                          .map(
                            (spot) => LineTooltipItem(
                              '${formatDateFromIso(history[spot.x.toInt()].date)}\n${context.trackedDuration(history[spot.x.toInt()].totalSeconds)}',
                              theme.textTheme.bodySmall!.copyWith(
                                color: theme.colorScheme.onInverseSurface,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                          .toList();
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(),
                  rightTitles: const AxisTitles(),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 72,
                      interval: yAxisInterval,
                      getTitlesWidget: (value, meta) => SideTitleWidget(
                        meta: meta,
                        space: 8,
                        child: Text(
                          formatDuration((value * 60).round()),
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 42,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= history.length) {
                          return const SizedBox.shrink();
                        }
                        final skipEvery = history.length > 10 ? 2 : 1;
                        if (index % skipEvery != 0) {
                          return const SizedBox.shrink();
                        }
                        return SideTitleWidget(
                          meta: meta,
                          space: 8,
                          child: Text(
                            formatShortDateFromIso(history[index].date),
                            style: theme.textTheme.bodySmall,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: points,
                    isCurved: true,
                    curveSmoothness: 0.2,
                    barWidth: 3.5,
                    color: theme.colorScheme.primary,
                    belowBarData: BarAreaData(
                      show: true,
                      color: theme.colorScheme.primary.withValues(alpha: 0.12),
                    ),
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) =>
                          FlDotCirclePainter(
                            radius: 4,
                            color: theme.colorScheme.primary,
                            strokeWidth: 2,
                            strokeColor: theme.colorScheme.surface,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _resolveYAxisInterval(double maxMinutes) {
    if (maxMinutes <= 1) {
      return 0.25;
    }
    if (maxMinutes <= 5) {
      return 1;
    }
    if (maxMinutes <= 15) {
      return 5;
    }
    if (maxMinutes <= 60) {
      return 15;
    }
    if (maxMinutes <= 180) {
      return 30;
    }
    return 60;
  }

  double _resolveChartMaxY(double maxMinutes, double interval) {
    final paddedMax = math.max(interval, maxMinutes + (interval * 0.5));
    return (paddedMax / interval).ceil() * interval;
  }
}

class _ChartLegend extends StatelessWidget {
  const _ChartLegend({required this.stat});

  final TodoTimeStats stat;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _LegendBadge(
              label: context.l10n.statsAppearances,
              value: '${stat.appearances}',
              backgroundColor: theme.colorScheme.primaryContainer,
              foregroundColor: theme.colorScheme.onPrimaryContainer,
            ),
            _StatusLegendBadge(
              label: context.l10n.statusPending,
              value: '${stat.pending}',
              status: TodoStatus.pending,
            ),
            _StatusLegendBadge(
              label: context.l10n.statusWorking,
              value: '${stat.working}',
              status: TodoStatus.working,
            ),
            _StatusLegendBadge(
              label: context.l10n.statusCompleted,
              value: '${stat.completed}',
              status: TodoStatus.completed,
            ),
            _StatusLegendBadge(
              label: context.l10n.statusDropped,
              value: '${stat.dropped}',
              status: TodoStatus.dropped,
            ),
            _StatusLegendBadge(
              label: context.l10n.statusPorted,
              value: '${stat.ported}',
              status: TodoStatus.ported,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          '${context.l10n.totalTime}: ${context.trackedDuration(stat.totalSeconds)}',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _StatusLegendBadge extends StatelessWidget {
  const _StatusLegendBadge({
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

    return _LegendBadge(
      label: label,
      value: value,
      backgroundColor: color.withValues(alpha: 0.12),
      foregroundColor: color,
    );
  }
}

class _LegendBadge extends StatelessWidget {
  const _LegendBadge({
    required this.label,
    required this.value,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final String label;
  final String value;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$label $value',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: foregroundColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
