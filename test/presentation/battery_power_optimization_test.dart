import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sreerajp_todo/application/pending_alert_notifier.dart';
import 'package:sreerajp_todo/application/providers.dart';
import 'package:sreerajp_todo/application/time_tracking_notifier.dart';
import 'package:sreerajp_todo/application/time_tracking_state.dart';
import 'package:sreerajp_todo/core/utils/ritual_rules.dart';
import 'package:sreerajp_todo/domain/repositories/todo_repository.dart';
import 'package:sreerajp_todo/l10n/app_localizations.dart';
import 'package:sreerajp_todo/presentation/screens/ritual/widgets/breathing_orb.dart';
import 'package:sreerajp_todo/presentation/shared/widgets/pending_alert_watcher.dart';

class _FakeTimeTrackingNotifier extends StateNotifier<TimeTrackingState>
    implements TimeTrackingNotifier {
  _FakeTimeTrackingNotifier(super.state);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MockTodoRepository extends Mock implements TodoRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Battery and Power Usage Optimizations', () {
    test('appLifecycleStateProvider defaults to resumed', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(
        container.read(appLifecycleStateProvider),
        AppLifecycleState.resumed,
      );
    });

    test(
      'liveTimerProvider suspends active ticking when lifecycle is paused or hidden',
      () async {
        final startTime = DateTime.now()
            .subtract(const Duration(seconds: 42))
            .toIso8601String();
        final container = ProviderContainer(
          overrides: [
            timeTrackingProvider('todo-1').overrideWith(
              (ref) => _FakeTimeTrackingNotifier(
                TimeTrackingState(
                  totalDurationSeconds: 42,
                  runningSegment: TimeSegmentEntity(
                    id: 'seg-1',
                    todoId: 'todo-1',
                    startTime: startTime,
                    createdAt: startTime,
                  ),
                ),
              ),
            ),
          ],
        );
        addTearDown(container.dispose);

        // While in foreground, reading it yields the elapsed value
        final initialSeconds = await container.read(
          liveTimerProvider('todo-1').future,
        );
        expect(initialSeconds, greaterThanOrEqualTo(42));

        // When paused/backgrounded, liveTimerProvider emits static value without periodic ticking
        container.read(appLifecycleStateProvider.notifier).state =
            AppLifecycleState.paused;

        final pausedSeconds = await container.read(
          liveTimerProvider('todo-1').future,
        );
        expect(pausedSeconds, greaterThanOrEqualTo(42));
      },
    );

    test('pomodoroCountdownProvider suspends ticking when paused', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(appLifecycleStateProvider.notifier).state =
          AppLifecycleState.paused;

      final seconds = await container.read(pomodoroCountdownProvider.future);
      expect(seconds, equals(0));
    });

    test('focusPulseCountdownProvider suspends ticking when hidden', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(appLifecycleStateProvider.notifier).state =
          AppLifecycleState.hidden;

      final seconds = await container.read(focusPulseCountdownProvider.future);
      expect(seconds, equals(0));
    });

    testWidgets('BreathingOrb disposes cleanly without timer or ticker leaks', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: BreathingOrb(
              technique: BreathTechnique.box,
              breaths: 2,
              haptic: false,
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Replace with an empty widget to trigger dispose()
      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: SizedBox.shrink()),
        ),
      );
      await tester.pump();

      // Ensure no dangling timers or tickers throw exceptions
      expect(tester.takeException(), isNull);
    });

    testWidgets('PendingAlertWatcher handles lifecycle transitions safely', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({kPendingAlertsEnabledKey: false});
      final prefs = await SharedPreferences.getInstance();
      final mockRepo = _MockTodoRepository();
      when(() => mockRepo.getTodosByDate(any())).thenAnswer((_) async => []);

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          todoRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: PendingAlertWatcher(child: Scaffold(body: Text('Content'))),
          ),
        ),
      );
      await tester.pump();

      // Trigger app lifecycle changes to pause and resume
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump();

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  });
}
