import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_todo/data/models/statistics_models.dart';
import 'package:sreerajp_todo/presentation/screens/statistics/widgets/per_item_line_chart.dart';
import 'package:sreerajp_todo/presentation/shared/theme/app_theme.dart';

void main() {
  testWidgets('formats short per-item history axis labels as durations', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: PerItemLineChart(
            selectedTitle: 'Test 12',
            selectedStat: TodoTimeStats(
              title: 'Test 12',
              appearances: 1,
              totalSeconds: 30,
            ),
            history: [
              TitleTimePoint(
                title: 'Test 12',
                date: '2026-03-24',
                totalSeconds: 30,
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Time history: Test 12'), findsOneWidget);
    expect(find.text('Appearances 1'), findsOneWidget);
    expect(find.text('Completed 0'), findsOneWidget);
    expect(find.text('Dropped 0'), findsOneWidget);
    expect(find.text('Ported 0'), findsOneWidget);
    expect(find.text('Total time: 00:00:30'), findsOneWidget);
    expect(find.text('00:00:00'), findsOneWidget);
    expect(find.text('00:00:15'), findsOneWidget);
    expect(find.text('00:00:30'), findsOneWidget);
    expect(find.text('Mar 24'), findsOneWidget);
  });
}
