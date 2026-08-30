import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sreerajp_todo/application/providers.dart';
import 'package:sreerajp_todo/application/ritual_notifier.dart';
import 'package:sreerajp_todo/core/constants/app_routes.dart';
import 'package:sreerajp_todo/core/utils/date_utils.dart';
import 'package:sreerajp_todo/core/utils/ritual_rules.dart';
import 'package:sreerajp_todo/data/services/ritual_service.dart';
import 'package:sreerajp_todo/l10n/app_localizations.dart';
import 'package:sreerajp_todo/presentation/screens/ritual/ritual_deck_screen.dart';
import 'package:sreerajp_todo/presentation/screens/ritual/ritual_screen.dart';

import '../helpers/test_l10n.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// Builds the ritual with the day list stubbed out, so "Skip" and "Begin"
  /// can be checked by where they land rather than by what they draw.
  Future<SharedPreferences> pumpRitual(
    WidgetTester tester, {
    Map<String, Object> prefValues = const {},
  }) async {
    SharedPreferences.setMockInitialValues({
      kRitualEnabledKey: true,
      // One breath of the shortest rhythm keeps the test quick, and the step
      // can be left before it finishes anyway.
      kRitualBreathCountKey: 1,
      kRitualBreathTechniqueKey: 2,
      ...prefValues,
    });
    final prefs = await SharedPreferences.getInstance();

    final router = GoRouter(
      initialLocation: AppRoutes.ritual,
      routes: [
        GoRoute(
          path: AppRoutes.ritual,
          builder: (context, state) => const RitualScreen(),
        ),
        GoRoute(
          path: AppRoutes.ritualDeck,
          builder: (context, state) => const RitualDeckScreen(),
        ),
        GoRoute(
          path: AppRoutes.dailyList,
          builder: (context, state) =>
              const Scaffold(body: Text('day list here')),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pump();
    return prefs;
  }

  group('the ritual flow', () {
    testWidgets('opens on the breathing step', (tester) async {
      await pumpRitual(tester);

      expect(find.text(testL10n.ritualTitle), findsOneWidget);
      expect(find.text(testL10n.ritualStepBreathe), findsOneWidget);
      expect(find.text(testL10n.ritualBreathIn), findsOneWidget);
    });

    testWidgets('skipping leaves for the day list', (tester) async {
      await pumpRitual(tester);

      // The app-bar button, not the one under the breathing circle: both
      // carry the same words, and only this one leaves the ritual outright.
      await tester.tap(find.widgetWithText(TextButton, testL10n.ritualSkip));
      await tester.pumpAndSettle();

      expect(find.text('day list here'), findsOneWidget);
    });

    testWidgets('skipping still marks the day, so it does not open again', (
      tester,
    ) async {
      final prefs = await pumpRitual(tester);

      // The app-bar button, not the one under the breathing circle: both
      // carry the same words, and only this one leaves the ritual outright.
      await tester.tap(find.widgetWithText(TextButton, testL10n.ritualSkip));
      await tester.pumpAndSettle();

      expect(prefs.getString(kRitualLastRunKey), todayAsIso());
      expect(RitualNotifier(prefs).state.shouldOpenOn(todayAsIso()), isFalse);
    });

    testWidgets('the breathing step can be left before it finishes', (
      tester,
    ) async {
      await pumpRitual(tester);

      // The button under the circle carries the ritual forward from the very
      // first second: no step is allowed to hold someone there.
      await tester.tap(find.widgetWithText(FilledButton, testL10n.ritualSkip));
      await tester.pumpAndSettle();

      expect(find.text(testL10n.ritualRateQuestion), findsOneWidget);
    });

    testWidgets('shows only the steps that are switched on', (tester) async {
      await pumpRitual(
        tester,
        prefValues: {kRitualCardStepKey: false, kRitualSettleStepKey: false},
      );

      expect(find.text(testL10n.ritualStepBreathe), findsOneWidget);
      expect(find.text(testL10n.ritualStepBegin), findsOneWidget);
      expect(find.text(testL10n.ritualStepReflect), findsNothing);
      expect(find.text(testL10n.ritualStepSettle), findsNothing);

      await tester.tap(find.widgetWithText(FilledButton, testL10n.ritualSkip));
      await tester.pumpAndSettle();
      expect(find.text(testL10n.ritualBeginTitle), findsOneWidget);
    });
  });

  group('the card step', () {
    Future<void> reachCardStep(WidgetTester tester) async {
      await pumpRitual(tester, prefValues: {kRitualSettleStepKey: false});
      await tester.tap(find.widgetWithText(FilledButton, testL10n.ritualSkip));
      await tester.pumpAndSettle();
    }

    testWidgets('shows a card with its three recall choices', (tester) async {
      await reachCardStep(tester);

      // A fresh install always starts at the first card of the deck.
      expect(find.text(testL10n.ritualCardSd01Title), findsOneWidget);
      expect(find.text(testL10n.ritualCardSd01Prompt), findsOneWidget);
      expect(find.text(testL10n.ritualRateHard), findsOneWidget);
      expect(find.text(testL10n.ritualRateRevision), findsOneWidget);
      expect(find.text(testL10n.ritualRateEasy), findsOneWidget);
    });

    testWidgets('"show another" moves along the deck', (tester) async {
      await reachCardStep(tester);

      await tester.tap(find.text(testL10n.ritualCardAnother));
      await tester.pumpAndSettle();

      expect(find.text(testL10n.ritualCardSd02Title), findsOneWidget);
      expect(find.text(testL10n.ritualCardSd01Title), findsNothing);
    });

    testWidgets('rating a card saves it and moves on', (tester) async {
      SharedPreferences.setMockInitialValues({});
      await reachCardStep(tester);

      await tester.tap(find.text(testL10n.ritualRateHard));
      await tester.pumpAndSettle();

      expect(find.text(testL10n.ritualBeginTitle), findsOneWidget);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('${kRitualCardReviewPrefix}sd_01'), isNotNull);
    });
  });

  group('the deck browser', () {
    testWidgets('lists every card and filters by theme', (tester) async {
      SharedPreferences.setMockInitialValues(const {});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: RitualDeckScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(testL10n.ritualCardSd01Title), findsOneWidget);
      // Every card starts unseen, so each one wears the "New" badge.
      expect(find.text(testL10n.ritualDeckUnseen), findsWidgets);

      // The first five cards are the Dharma group; picking Karma must drop
      // them from the list.
      await tester.tap(find.text(testL10n.ritualThemeKarma));
      await tester.pumpAndSettle();
      expect(find.text(testL10n.ritualCardSd01Title), findsNothing);
    });
  });

  group('breathing rhythms', () {
    test('a rhythm with no hold simply runs fewer phases', () {
      expect(BreathTechnique.calm.phases.map((phase) => phase.$1), [
        BreathPhase.inhale,
        BreathPhase.exhale,
      ]);
      expect(BreathTechnique.box.phases, hasLength(4));
      expect(BreathTechnique.relaxing.phases.map((phase) => phase.$1), [
        BreathPhase.inhale,
        BreathPhase.holdIn,
        BreathPhase.exhale,
      ]);
    });

    test('each rhythm adds up to the length it advertises', () {
      expect(BreathTechnique.box.cycleSeconds, 16);
      expect(BreathTechnique.relaxing.cycleSeconds, 19);
      expect(BreathTechnique.calm.cycleSeconds, 8);
    });
  });
}
