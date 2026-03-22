import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sreerajp_todo/core/constants/app_strings.dart';
import 'package:sreerajp_todo/data/models/statistics_models.dart';
import 'package:sreerajp_todo/data/models/todo_status.dart';
import 'package:sreerajp_todo/presentation/shared/theme/app_theme.dart';

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
      return Card(
        child: SizedBox(
          height: 320,
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

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Semantics(
          container: true,
          label: AppStrings.stats.dailyOverview,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  _LegendItem(
                    color: completedColor,
                    label: AppStrings.statusCompleted,
                  ),
                  _LegendItem(
                    color: droppedColor,
                    label: AppStrings.statusDropped,
                  ),
                  _LegendItem(
                    color: portedColor,
                    label: AppStrings.statusPorted,
                  ),
                  _LegendItem(
                    color: pendingColor,
                    label: AppStrings.statusPending,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final width = math
                        .max(constraints.maxWidth, stats.length * 88)
                        .toDouble();

                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: width,
                        child: BarChart(
                          BarChartData(
                            maxY: maxValue + 1,
                            alignment: BarChartAlignment.spaceAround,
                            barTouchData: BarTouchData(enabled: true),
                            gridData: const FlGridData(drawVerticalLine: false),
                            borderData: FlBorderData(show: false),
                            titlesData: FlTitlesData(
                              topTitles: const AxisTitles(),
                              rightTitles: const AxisTitles(),
                              leftTitles: const AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 36,
                                  interval: 1,
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 36,
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
                                      width: 12,
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(4),
                                      ),
                                    ),
                                    BarChartRodData(
                                      toY: stats[i].dropped.toDouble(),
                                      color: droppedColor,
                                      width: 12,
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(4),
                                      ),
                                    ),
                                    BarChartRodData(
                                      toY: stats[i].ported.toDouble(),
                                      color: portedColor,
                                      width: 12,
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(4),
                                      ),
                                    ),
                                    BarChartRodData(
                                      toY: stats[i].pending.toDouble(),
                                      color: pendingColor,
                                      width: 12,
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(4),
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
        ),
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(label),
      ],
    );
  }
}
