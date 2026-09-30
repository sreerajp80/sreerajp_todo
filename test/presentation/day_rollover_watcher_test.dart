import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sreerajp_todo/l10n/app_localizations.dart';
import 'package:sreerajp_todo/presentation/shared/widgets/day_rollover_watcher.dart';

import '../helpers/test_l10n.dart';

void main() {
  group('dayRolloverTarget', () {
    test('same day stays put', () {
      expect(
        dayRolloverTarget(
          lastSeenDay: '2026-09-27',
          today: '2026-09-27',
          currentLocation: '/day/2026-09-30',
        ),
        isNull,
      );
    });

    test('new day on another day list goes to today', () {
      expect(
        dayRolloverTarget(
          lastSeenDay: '2026-09-27',
          today: '2026-09-28',
          currentLocation: '/day/2026-09-30',
        ),
        '/day/2026-09-28',
      );
    });

    test('new day already on today stays put', () {
      expect(
        dayRolloverTarget(
          lastSeenDay: '2026-09-27',
          today: '2026-09-28',
          currentLocation: '/day/2026-09-28',
        ),
        isNull,
      );
    });

    test('new day on another screen stays put', () {
      expect(
        dayRolloverTarget(
          lastSeenDay: '2026-09-27',
          today: '2026-09-28',
          currentLocation: '/settings',
        ),
        isNull,
      );
      expect(
        dayRolloverTarget(
          lastSeenDay: '2026-09-27',
          today: '2026-09-28',
          currentLocation: null,
        ),
        isNull,
      );
    });
  });

  group('DayRolloverWatcher', () {
    late String today;
    late DateTime now;
    late GoRouter router;

    setUp(() => now = DateTime(2026, 9, 27, 12));

    Future<void> pumpApp(WidgetTester tester, String start) async {
      router = GoRouter(
        initialLocation: start,
        routes: [
          GoRoute(
            path: '/day/:date',
            builder: (context, state) =>
                Scaffold(body: Text('day ${state.pathParameters['date']}')),
          ),
          GoRoute(
            path: '/edit',
            builder: (context, state) => const Scaffold(body: Text('edit')),
          ),
        ],
      );
      await tester.pumpWidget(
        MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
          builder: (context, child) => DayRolloverWatcher(
            router: router,
            today: () => today,
            now: () => now,
            child: child!,
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    Future<void> leaveAndReturn(WidgetTester tester, String newDay) async {
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      today = newDay;
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
    }

    testWidgets('returns to today when resumed on a new day', (tester) async {
      today = '2026-09-27';
      await pumpApp(tester, '/day/2026-09-30');

      await leaveAndReturn(tester, '2026-09-28');

      expect(find.text('day 2026-09-28'), findsOneWidget);
      expect(find.text(testL10n.newDayShowingToday), findsOneWidget);
    });

    testWidgets('stays on the chosen day when resumed on the same day', (
      tester,
    ) async {
      today = '2026-09-27';
      await pumpApp(tester, '/day/2026-09-30');

      await leaveAndReturn(tester, '2026-09-27');

      expect(find.text('day 2026-09-30'), findsOneWidget);
    });

    testWidgets('leaves a pushed screen alone on a new day', (tester) async {
      today = '2026-09-27';
      await pumpApp(tester, '/day/2026-09-30');
      router.push('/edit');
      await tester.pumpAndSettle();

      await leaveAndReturn(tester, '2026-09-28');

      expect(find.text('edit'), findsOneWidget);
    });

    testWidgets('moves to today at midnight while the app stays open', (
      tester,
    ) async {
      today = '2026-09-27';
      now = DateTime(2026, 9, 27, 23, 59);
      await pumpApp(tester, '/day/2026-09-27');

      // Still before midnight: nothing happens.
      await tester.pump(const Duration(seconds: 30));
      expect(find.text('day 2026-09-27'), findsOneWidget);

      today = '2026-09-28';
      await tester.pump(const Duration(seconds: 31));
      await tester.pumpAndSettle();

      expect(find.text('day 2026-09-28'), findsOneWidget);
      expect(find.text(testL10n.newDayShowingToday), findsOneWidget);
    });

    testWidgets('midnight check leaves a pushed screen alone', (tester) async {
      today = '2026-09-27';
      now = DateTime(2026, 9, 27, 23, 59);
      await pumpApp(tester, '/day/2026-09-27');
      router.push('/edit');
      await tester.pumpAndSettle();

      today = '2026-09-28';
      await tester.pump(const Duration(seconds: 61));
      await tester.pumpAndSettle();

      expect(find.text('edit'), findsOneWidget);
    });
  });
}
