import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sreerajp_todo/application/providers.dart';
import 'package:sreerajp_todo/application/statistics_state.dart';
import 'package:sreerajp_todo/data/dao/statistics_query_service.dart';
import 'package:sreerajp_todo/data/models/statistics_models.dart';
import 'package:sreerajp_todo/presentation/screens/statistics/statistics_screen.dart';
import 'package:sreerajp_todo/presentation/screens/statistics/widgets/per_item_stats_table.dart';
import 'package:sreerajp_todo/presentation/shared/theme/app_theme.dart';

class MockStatisticsQueryService extends Mock
    implements StatisticsQueryService {}

void main() {
  late MockStatisticsQueryService service;

  setUp(() {
    service = MockStatisticsQueryService();

    when(
      () => service.getCountsPerDay(
        limit: any(named: 'limit'),
        offset: any(named: 'offset'),
        startDate: any(named: 'startDate'),
        endDate: any(named: 'endDate'),
      ),
    ).thenAnswer((invocation) async {
      final offset = invocation.namedArguments[#offset] as int? ?? 0;
      final startDate = invocation.namedArguments[#startDate] as String?;
      final endDate = invocation.namedArguments[#endDate] as String?;
      if (offset >= 20) {
        return const [
          DayStats(
            date: '2026-03-01',
            total: 1,
            completed: 1,
            dropped: 0,
            ported: 0,
            pending: 0,
            totalSeconds: 600,
          ),
        ];
      }
      if (startDate == null && endDate == null) {
        return const [
          DayStats(
            date: '2026-03-10',
            total: 8,
            completed: 5,
            dropped: 1,
            ported: 1,
            pending: 1,
            totalSeconds: 7200,
          ),
        ];
      }
      return const [
        DayStats(
          date: '2026-03-21',
          total: 3,
          completed: 2,
          dropped: 1,
          ported: 0,
          pending: 0,
          totalSeconds: 5400,
        ),
      ];
    });

    when(
      () => service.getDayCount(
        startDate: any(named: 'startDate'),
        endDate: any(named: 'endDate'),
      ),
    ).thenAnswer((_) async => 21);

    when(
      () => service.getSummaryStats(
        startDate: any(named: 'startDate'),
        endDate: any(named: 'endDate'),
      ),
    ).thenAnswer((invocation) async {
      final startDate = invocation.namedArguments[#startDate] as String?;
      final endDate = invocation.namedArguments[#endDate] as String?;
      if (startDate == null && endDate == null) {
        return const SummaryStats(
          totalTodos: 8,
          avgCompletedPerDay: 4,
          avgTimePerDaySeconds: 3600,
          totalProductiveTimeSeconds: 5400,
          totalDroppedTimeSeconds: 900,
        );
      }
      return const SummaryStats(
        totalTodos: 3,
        avgCompletedPerDay: 2,
        avgTimePerDaySeconds: 1800,
        totalProductiveTimeSeconds: 3600,
        totalDroppedTimeSeconds: 1800,
      );
    });

    when(
      () => service.getPerItemStats(
        limit: any(named: 'limit'),
        offset: any(named: 'offset'),
        titleQuery: any(named: 'titleQuery'),
      ),
    ).thenAnswer((invocation) async {
      final offset = invocation.namedArguments[#offset] as int? ?? 0;
      final titleQuery = invocation.namedArguments[#titleQuery] as String?;
      if (offset >= 20) {
        return const [
          TodoTimeStats(
            title: 'Deep Work',
            appearances: 1,
            completed: 1,
            totalSeconds: 2400,
          ),
        ];
      }
      if (titleQuery != null && titleQuery.isNotEmpty) {
        return const [
          TodoTimeStats(
            title: 'Read',
            appearances: 2,
            completed: 1,
            dropped: 1,
            totalSeconds: 3000,
          ),
        ];
      }
      return const [
        TodoTimeStats(
          title: 'Read',
          appearances: 2,
          completed: 1,
          dropped: 1,
          totalSeconds: 3000,
        ),
      ];
    });

    when(
      () => service.getPerItemCount(titleQuery: any(named: 'titleQuery')),
    ).thenAnswer((_) async => 21);

    when(() => service.getTimeSeriesForTitle(any())).thenAnswer((
      invocation,
    ) async {
      final title = invocation.positionalArguments.first as String;
      if (title == 'Deep Work') {
        return const [
          TitleTimePoint(
            title: 'Deep Work',
            date: '2026-03-20',
            totalSeconds: 2400,
          ),
        ];
      }
      return const [
        TitleTimePoint(title: 'Read', date: '2026-03-20', totalSeconds: 1200),
        TitleTimePoint(title: 'Read', date: '2026-03-21', totalSeconds: 1800),
      ];
    });
  });

  Future<void> pumpStatisticsScreen(
    WidgetTester tester, {
    ThemeMode themeMode = ThemeMode.light,
    Size size = const Size(800, 900),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [statisticsQueryServiceProvider.overrideWithValue(service)],
        child: MaterialApp(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeMode,
          home: const StatisticsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('renders the statistics screen in the light theme', (
    tester,
  ) async {
    await pumpStatisticsScreen(tester, themeMode: ThemeMode.light);

    expect(find.text('Statistics'), findsWidgets);
    expect(find.text('Daily Overview'), findsWidgets);
    expect(find.text('Per-Item Overview'), findsWidgets);
    expect(find.byType(TabBar), findsOneWidget);
  });

  testWidgets('renders the statistics screen in the dark theme', (
    tester,
  ) async {
    await pumpStatisticsScreen(tester, themeMode: ThemeMode.dark);

    expect(find.text('Statistics'), findsWidgets);
    expect(find.byType(StatisticsScreen), findsOneWidget);
  });

  testWidgets('mobile width renders the tab screen with bottom navigation', (
    tester,
  ) async {
    await pumpStatisticsScreen(tester, size: const Size(390, 844));

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);
  });

  testWidgets('desktop width renders the tab screen with navigation rail', (
    tester,
  ) async {
    await pumpStatisticsScreen(tester, size: const Size(1280, 900));

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('daily and per-item charts render without exceptions', (
    tester,
  ) async {
    await pumpStatisticsScreen(tester);

    expect(find.byType(BarChart), findsOneWidget);

    await tester.tap(find.text('Per-Item Overview'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Read').last);
    await tester.pumpAndSettle();

    expect(find.byType(LineChart), findsOneWidget);
  });
  testWidgets('tab switching and row selection update the per-item history', (
    tester,
  ) async {
    await pumpStatisticsScreen(tester);

    await tester.tap(find.text('Per-Item Overview'));
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Read'), findsWidgets);

    await tester.tap(find.text('Read').last);
    await tester.pumpAndSettle();

    expect(find.text('Time history: Read'), findsOneWidget);
  });

  testWidgets('date range selection updates the daily overview data', (
    tester,
  ) async {
    await pumpStatisticsScreen(tester);

    expect(find.text('3'), findsWidgets);

    await tester.tap(find.text('All time'));
    await tester.pumpAndSettle();

    expect(find.text('8'), findsWidgets);
    expect(find.text('Mar 10'), findsWidgets);
  });

  testWidgets('compact date range selector keeps labels readable', (
    tester,
  ) async {
    await pumpStatisticsScreen(tester, size: const Size(300, 844));

    expect(find.byType(SegmentedButton<DateRange>), findsNothing);
    expect(find.byType(ChoiceChip), findsNWidgets(4));
    expect(find.text('Last 7 days'), findsOneWidget);
    expect(find.text('Last 30 days'), findsOneWidget);
    expect(find.text('All time'), findsOneWidget);
    expect(find.text('Custom range'), findsOneWidget);

    final chipTops = [
      tester.getTopLeft(find.widgetWithText(ChoiceChip, 'Last 7 days')).dy,
      tester.getTopLeft(find.widgetWithText(ChoiceChip, 'Last 30 days')).dy,
      tester.getTopLeft(find.widgetWithText(ChoiceChip, 'All time')).dy,
      tester.getTopLeft(find.widgetWithText(ChoiceChip, 'Custom range')).dy,
    ];

    expect(chipTops.toSet().length, greaterThan(1));
  });
  testWidgets('custom range date buttons stay on one row at compact width', (
    tester,
  ) async {
    await pumpStatisticsScreen(tester, size: const Size(300, 844));

    await tester.tap(find.widgetWithText(ChoiceChip, 'Custom range'));
    await tester.pumpAndSettle();

    final compactYearLabel = DateFormat.y().format(DateTime.now());

    expect(find.text(compactYearLabel), findsNWidgets(2));

    final startTop = tester
        .getTopLeft(
          find.ancestor(
            of: find.byIcon(Icons.date_range_outlined),
            matching: find.byType(InkWell),
          ),
        )
        .dy;
    final endTop = tester
        .getTopLeft(
          find.ancestor(
            of: find.byIcon(Icons.event_outlined),
            matching: find.byType(InkWell),
          ),
        )
        .dy;

    expect(startTop, moreOrLessEquals(endTop));
  });

  testWidgets('pagination buttons advance pages', (tester) async {
    await pumpStatisticsScreen(tester);

    expect(find.text('Page 1 of 2'), findsOneWidget);

    await tester.ensureVisible(find.byType(OutlinedButton).last);
    await tester.tap(find.byType(OutlinedButton).last);
    await tester.pumpAndSettle();

    expect(find.text('Page 2 of 2'), findsOneWidget);
    expect(find.text('Mar 1'), findsWidgets);
  });

  testWidgets('search filter updates the per-item table without chart errors', (
    tester,
  ) async {
    await pumpStatisticsScreen(tester);

    await tester.tap(find.text('Per-Item Overview'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Read');
    await tester.pumpAndSettle();

    expect(find.text('Read'), findsWidgets);
    expect(find.byType(StatisticsScreen), findsOneWidget);
  });
  testWidgets('mobile per-item tab keeps task selection above the chart', (
    tester,
  ) async {
    await pumpStatisticsScreen(tester, size: const Size(390, 844));

    await tester.tap(find.text('Per-Item Overview'));
    await tester.pumpAndSettle();

    expect(find.text('Choose task'), findsWidgets);
    expect(find.byType(PerItemStatsTable), findsNothing);

    expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);

    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Read').last);
    await tester.pumpAndSettle();

    final chooserTop = tester.getTopLeft(find.byType(PerItemSelectorCard)).dy;
    final chartTop = tester.getTopLeft(find.text('Time history: Read')).dy;

    expect(find.text('Selected task'), findsNothing);
    expect(find.text('Completed 1'), findsOneWidget);
    expect(find.text('Dropped 1'), findsOneWidget);
    expect(chooserTop, lessThan(chartTop));
  });
}
