import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sreerajp_todo/core/constants/app_strings.dart';
import 'package:sreerajp_todo/core/utils/duration_utils.dart';
import 'package:sreerajp_todo/data/models/statistics_models.dart';

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
      return Card(
        child: SizedBox(
          height: 220,
          child: Center(child: Text(AppStrings.stats.noDailyStats)),
        ),
      );
    }

    final pageCount = totalPages == 0 ? 1 : totalPages;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: [
                    DataColumn(label: Text(AppStrings.stats.date)),
                    DataColumn(label: Text(AppStrings.stats.total)),
                    const DataColumn(label: Text(AppStrings.statusCompleted)),
                    const DataColumn(label: Text(AppStrings.statusDropped)),
                    const DataColumn(label: Text(AppStrings.statusPorted)),
                    const DataColumn(label: Text(AppStrings.statusPending)),
                    const DataColumn(label: Text(AppStrings.totalTime)),
                  ],
                  rows: [
                    for (var i = 0; i < stats.length; i++)
                      DataRow.byIndex(
                        index: i,
                        onSelectChanged: (_) => onSelectDate(stats[i].date),
                        cells: [
                          DataCell(
                            Text(
                              DateFormat.MMMd().format(
                                DateTime.parse(stats[i].date),
                              ),
                            ),
                          ),
                          DataCell(Text('${stats[i].total}')),
                          DataCell(Text('${stats[i].completed}')),
                          DataCell(Text('${stats[i].dropped}')),
                          DataCell(Text('${stats[i].ported}')),
                          DataCell(Text('${stats[i].pending}')),
                          DataCell(Text(formatDuration(stats[i].totalSeconds))),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(AppStrings.stats.pageOf(currentPage + 1, pageCount)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: currentPage == 0 ? null : onPrevious,
                    child: const Text(AppStrings.previous),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: currentPage + 1 >= totalPages ? null : onNext,
                    child: const Text(AppStrings.next),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
