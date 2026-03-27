import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sreerajp_todo/core/constants/app_strings.dart';
import 'package:sreerajp_todo/data/models/statistics_models.dart';
import 'package:sreerajp_todo/data/models/todo_status.dart';
import 'package:sreerajp_todo/presentation/shared/theme/app_theme.dart';
import 'package:sreerajp_todo/presentation/shared/widgets/app_section_card.dart';

class DailyBarChart extends StatelessWidget {
  const DailyBarChart({super.key, required this.stats});

  final List<DayStats> stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final completedColor = AppTheme.statusColor(theme, TodoStatus.completed);
    final droppedColor = AppTheme.statusColor(theme, TodoStatus.dropped);
    final portedColor = AppTheme.statusColor(theme, TodoStatus.ported);
    final pendingColor = AppTheme.statusColor(theme, TodoStatus.pending);

    if (stats.isEmpty) {
      return AppSectionCard(
        title: AppStrings.stats.dailyOverview,
        child: SizedBox(
          height: 260,
          child: Center(
            child: Text(
              AppStrings.stats.noDailyStats,
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final maxValue = stats
        .map(
          (item) => [
            item.completed,
            item.dropped,
            item.ported,
            item.pending,
          ].reduce(math.max),
        )
        .reduce(math.max)
        .toDouble();
    final maxY = math.max(1.5, maxValue + 0.4);

    return AppSectionCard(
      title: AppStrings.stats.dailyOverview,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              _LegendItem(
                color: completedColor,
                label: AppStrings.statusCompleted,
              ),
              _LegendItem(color: droppedColor, label: AppStrings.statusDropped),
              _LegendItem(color: portedColor, label: AppStrings.statusPorted),
              _LegendItem(color: pendingColor, label: AppStrings.statusPending),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 280,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = math
                    .max(constraints.maxWidth, stats.length * 82)
                    .toDouble();

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: width,
                    child: BarChart(
                      BarChartData(
                        maxY: maxY,
                        alignment: BarChartAlignment.spaceAround,
                        barTouchData: BarTouchData(
                          enabled: true,
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              final item = stats[group.x.toInt()];
                              final labels = [
                                AppStrings.statusCompleted,
                                AppStrings.statusDropped,
                                AppStrings.statusPorted,
                                AppStrings.statusPending,
                              ];
                              return BarTooltipItem(
                                '${DateFormat.yMMMd().format(DateTime.parse(item.date))}\n${labels[rodIndex]}: ${rod.toY.toStringAsFixed(0)}',
                                theme.textTheme.bodySmall!.copyWith(
                                  color: theme.colorScheme.onInverseSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                              );
                            },
                          ),
                        ),
                        gridData: FlGridData(
                          drawVerticalLine: false,
                          horizontalInterval: maxValue <= 2 ? 0.5 : 1,
                          getDrawingHorizontalLine: (value) => FlLine(
                            color: theme.colorScheme.outlineVariant,
                            strokeWidth: 1,
                            dashArray: const [6, 4],
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        titlesData: FlTitlesData(
                          topTitles: const AxisTitles(),
                          rightTitles: const AxisTitles(),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 36,
                              interval: maxValue <= 2 ? 0.5 : 1,
                              getTitlesWidget: (value, meta) => SideTitleWidget(
                                meta: meta,
                                space: 10,
                                child: Text(
                                  value == value.roundToDouble()
                                      ? value.toInt().toString()
                                      : value.toStringAsFixed(1),
                                  style: theme.textTheme.bodySmall,
                                ),
                              ),
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index < 0 || index >= stats.length) {
                                  return const SizedBox.shrink();
                                }
                                final skipEvery = stats.length > 10 ? 2 : 1;
                                if (index % skipEvery != 0) {
                                  return const SizedBox.shrink();
                                }
                                final label = DateFormat.MMMd().format(
                                  DateTime.parse(stats[index].date),
                                );
                                return SideTitleWidget(
                                  meta: meta,
                                  space: 8,
                                  child: Text(
                                    label,
                                    style: theme.textTheme.bodySmall,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        barGroups: [
                          for (var i = 0; i < stats.length; i++)
                            BarChartGroupData(
                              x: i,
                              barsSpace: 4,
                              barRods: [
                                BarChartRodData(
                                  toY: stats[i].completed.toDouble(),
                                  color: completedColor,
                                  width: 10,
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(5),
                                  ),
                                ),
                                BarChartRodData(
                                  toY: stats[i].dropped.toDouble(),
                                  color: droppedColor,
                                  width: 10,
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(5),
                                  ),
                                ),
                                BarChartRodData(
                                  toY: stats[i].ported.toDouble(),
                                  color: portedColor,
                                  width: 10,
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(5),
                                  ),
                                ),
                                BarChartRodData(
                                  toY: stats[i].pending.toDouble(),
                                  color: pendingColor,
                                  width: 10,
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(5),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
