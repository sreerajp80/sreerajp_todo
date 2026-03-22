import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sreerajp_todo/core/constants/app_strings.dart';
import 'package:sreerajp_todo/core/utils/duration_utils.dart';
import 'package:sreerajp_todo/data/models/statistics_models.dart';

class PerItemLineChart extends StatelessWidget {
  const PerItemLineChart({
    super.key,
    required this.selectedTitle,
    required this.history,
  });

  final String? selectedTitle;
  final List<TitleTimePoint> history;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (selectedTitle == null || selectedTitle!.isEmpty) {
      return Card(
        child: SizedBox(
          height: 320,
          child: Center(
            child: Text(
              AppStrings.stats.selectTaskToViewHistory,
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    if (history.isEmpty) {
      return Card(
        child: SizedBox(
          height: 320,
          child: Center(
            child: Text(
              AppStrings.stats.noHistoryForTitle,
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final points = [
      for (var i = 0; i < history.length; i++)
        FlSpot(i.toDouble(), history[i].totalSeconds / 60),
    ];
    final maxY = points.map((point) => point.y).reduce((a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.stats.historyFor(selectedTitle!),
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: maxY + 1,
                  gridData: const FlGridData(drawVerticalLine: false),
                  borderData: FlBorderData(show: false),
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (spots) {
                        return spots
                            .map(
                              (spot) => LineTooltipItem(
                                '${DateFormat.MMMd().format(DateTime.parse(history[spot.x.toInt()].date))}\n${formatDuration(history[spot.x.toInt()].totalSeconds)}',
                                theme.textTheme.bodySmall!,
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
                      axisNameWidget: Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(AppStrings.stats.minutes),
                      ),
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 42,
                        getTitlesWidget: (value, meta) => SideTitleWidget(
                          meta: meta,
                          space: 8,
                          child: Text(value.toStringAsFixed(0)),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 36,
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
                              DateFormat.MMMd().format(
                                DateTime.parse(history[index].date),
                              ),
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
                      isCurved: false,
                      barWidth: 3,
                      color: theme.colorScheme.primary,
                      dotData: const FlDotData(show: true),
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
