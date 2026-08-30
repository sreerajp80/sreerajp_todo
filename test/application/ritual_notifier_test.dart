import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sreerajp_todo/application/ritual_notifier.dart';
import 'package:sreerajp_todo/core/utils/ritual_rules.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<SharedPreferences> freshPrefs([
    Map<String, Object> values = const {},
  ]) async {
    SharedPreferences.setMockInitialValues(values);
    return SharedPreferences.getInstance();
  }

  group('RitualNotifier defaults', () {
    test('nothing saved leaves the app exactly as it was', () async {
      final state = RitualNotifier(await freshPrefs()).state;

      // The whole feature is off on a fresh install. This is the test that
      // protects every existing user from ever meeting the ritual by accident.
      expect(state.enabled, isFalse);
      expect(state.openOnLaunch, isTrue);
      expect(state.technique, BreathTechnique.box);
      expect(state.breathCount, kRitualDefaultBreaths);
      expect(state.haptic, isFalse);
      expect(state.cardStep, isTrue);
      expect(state.settleStep, isTrue);
      expect(state.eveningClose, isFalse);
      expect(state.eveningHour, kRitualDefaultEveningHour);
      expect(state.lastRunDate, isNull);
    });

    test('a saved value out of range falls back instead of crashing', () async {
      final state = RitualNotifier(
        await freshPrefs({
          kRitualBreathTechniqueKey: 99,
          kRitualBreathCountKey: 500,
          kRitualEveningHourKey: 3,
        }),
      ).state;

      expect(state.technique, BreathTechnique.box);
      expect(state.breathCount, kRitualMaxBreaths);
      expect(state.eveningHour, kRitualMinEveningHour);
    });
  });

  group('RitualNotifier saving', () {
    test('every change survives a restart', () async {
      final prefs = await freshPrefs();
      final notifier = RitualNotifier(prefs);

      await notifier.setEnabled(true);
      await notifier.setTechnique(BreathTechnique.relaxing);
      await notifier.setBreathCount(4);
      await notifier.setHaptic(true);
      await notifier.setCardStep(false);
      await notifier.setEveningClose(true);
      await notifier.setEveningHour(21);

      final reloaded = RitualNotifier(prefs).state;
      expect(reloaded.enabled, isTrue);
      expect(reloaded.technique, BreathTechnique.relaxing);
      expect(reloaded.breathCount, 4);
      expect(reloaded.haptic, isTrue);
      expect(reloaded.cardStep, isFalse);
      expect(reloaded.eveningClose, isTrue);
      expect(reloaded.eveningHour, 21);
    });

    test('the breath count cannot be pushed outside its range', () async {
      final notifier = RitualNotifier(await freshPrefs());

      await notifier.setBreathCount(0);
      expect(notifier.state.breathCount, kRitualMinBreaths);

      await notifier.setBreathCount(99);
      expect(notifier.state.breathCount, kRitualMaxBreaths);
    });
  });

  group('the once-a-day gate', () {
    test('stays shut while Ritual mode is off', () async {
      final notifier = RitualNotifier(await freshPrefs());
      expect(notifier.state.shouldOpenOn('2026-08-27'), isFalse);
    });

    test('opens on a day it has not run yet', () async {
      final notifier = RitualNotifier(await freshPrefs());
      await notifier.setEnabled(true);

      expect(notifier.state.shouldOpenOn('2026-08-27'), isTrue);
    });

    test('does not open twice on the same day', () async {
      final notifier = RitualNotifier(await freshPrefs());
      await notifier.setEnabled(true);
      await notifier.markRun('2026-08-27');

      expect(notifier.state.shouldOpenOn('2026-08-27'), isFalse);
      // Tomorrow is a new day, so it opens again.
      expect(notifier.state.shouldOpenOn('2026-08-28'), isTrue);
    });

    test('stays shut when automatic opening is turned off', () async {
      final notifier = RitualNotifier(await freshPrefs());
      await notifier.setEnabled(true);
      await notifier.setOpenOnLaunch(false);

      expect(notifier.state.shouldOpenOn('2026-08-27'), isFalse);
    });
  });

  group('the evening close gate', () {
    Future<RitualNotifier> readyNotifier() async {
      final notifier = RitualNotifier(await freshPrefs());
      await notifier.setEnabled(true);
      await notifier.setEveningClose(true);
      await notifier.setEveningHour(20);
      return notifier;
    }

    test('says nothing before the chosen hour', () async {
      final notifier = await readyNotifier();
      final morning = DateTime(2026, 8, 27, 9);

      expect(
        notifier.state.shouldOfferEveningClose('2026-08-27', morning),
        isFalse,
      );
    });

    test('offers once the hour has come', () async {
      final notifier = await readyNotifier();
      final evening = DateTime(2026, 8, 27, 20, 5);

      expect(
        notifier.state.shouldOfferEveningClose('2026-08-27', evening),
        isTrue,
      );
    });

    test('offers only once a day', () async {
      final notifier = await readyNotifier();
      final evening = DateTime(2026, 8, 27, 21);
      await notifier.markEveningAsked('2026-08-27');

      expect(
        notifier.state.shouldOfferEveningClose('2026-08-27', evening),
        isFalse,
      );
    });

    test('stays quiet while the whole feature is off', () async {
      final notifier = RitualNotifier(await freshPrefs());
      await notifier.setEveningClose(true);

      expect(
        notifier.state.shouldOfferEveningClose(
          '2026-08-27',
          DateTime(2026, 8, 27, 22),
        ),
        isFalse,
      );
    });
  });
}
