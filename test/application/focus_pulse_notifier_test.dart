import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_todo/application/focus_pulse_notifier.dart';
import 'package:sreerajp_todo/core/utils/focus_pulse_rules.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// Builds a notifier with a clock the test controls and a fake nudge, so no
  /// test has to wait half an hour or touch a platform channel.
  FocusPulseNotifier build({
    FocusPulseMode Function()? mode,
    Duration interval = const Duration(minutes: 30),
    bool Function()? suppressed,
    required DateTime Function() now,
    List<FocusPulseMode>? pulses,
  }) {
    return FocusPulseNotifier(
      mode: mode ?? () => FocusPulseMode.both,
      interval: () => interval,
      suppressed: suppressed,
      pulse: (m) async => pulses?.add(m),
      now: now,
    );
  }

  group('FocusPulseNotifier', () {
    test('starts with nothing scheduled', () {
      final notifier = build(now: () => DateTime(2026, 8, 19, 9));
      expect(notifier.state.isArmed, isFalse);
      expect(notifier.state.pulseCount, 0);
      notifier.dispose();
    });

    test('arms the first pulse one gap after the timer started', () {
      final clock = DateTime(2026, 8, 19, 9);
      final notifier = build(now: () => clock);

      notifier.syncWith(clock);

      expect(notifier.state.nextPulseAt, DateTime(2026, 8, 19, 9, 30));
      expect(notifier.state.secondsToNextPulse(clock), 30 * 60);
      notifier.dispose();
    });

    test('stays quiet when the mode is off', () {
      final clock = DateTime(2026, 8, 19, 9);
      final pulses = <FocusPulseMode>[];
      final notifier = build(
        mode: () => FocusPulseMode.off,
        now: () => clock,
        pulses: pulses,
      );

      notifier.syncWith(clock);

      expect(notifier.state.isArmed, isFalse);
      expect(pulses, isEmpty);
      notifier.dispose();
    });

    test('stays quiet while Pomodoro is making its own noise', () {
      final clock = DateTime(2026, 8, 19, 9);
      final notifier = build(now: () => clock, suppressed: () => true);

      notifier.syncWith(clock);

      expect(notifier.state.isArmed, isFalse);
      notifier.dispose();
    });

    test('fires when the gap really runs out', () async {
      final start = DateTime(2026, 8, 19, 9);
      var clock = start;
      final pulses = <FocusPulseMode>[];
      final notifier = build(
        interval: const Duration(milliseconds: 20),
        now: () => clock,
        pulses: pulses,
      );

      notifier.syncWith(start);
      clock = start.add(const Duration(milliseconds: 20));
      await Future<void>.delayed(const Duration(milliseconds: 60));

      expect(pulses, isNotEmpty);
      expect(pulses.first, FocusPulseMode.both);
      expect(notifier.state.pulseCount, greaterThanOrEqualTo(1));
      notifier.dispose();
    });

    test('a pulse that fell due while the app was away is dropped', () {
      var clock = DateTime(2026, 8, 19, 9);
      final start = clock;
      final pulses = <FocusPulseMode>[];
      final notifier = build(now: () => clock, pulses: pulses);

      notifier.syncWith(start);
      // The app went away and came back well after the first pulse was due.
      notifier.stop();
      clock = DateTime(2026, 8, 19, 9, 47);
      notifier.syncWith(start);

      // Nothing sounds for the moment that has already gone by, and the next
      // pulse is back on the grid.
      expect(pulses, isEmpty);
      expect(notifier.state.nextPulseAt, DateTime(2026, 8, 19, 10));
      notifier.dispose();
    });

    test('a repeat sync on the same timer keeps the pulses already given', () {
      var clock = DateTime(2026, 8, 19, 9);
      final start = clock;
      final notifier = build(now: () => clock);

      notifier.syncWith(start);
      clock = DateTime(2026, 8, 19, 9, 40);
      notifier.syncWith(start);

      expect(notifier.state.nextPulseAt, DateTime(2026, 8, 19, 10));
      notifier.dispose();
    });

    test('a new timer starts the count again', () {
      var clock = DateTime(2026, 8, 19, 9);
      final notifier = build(now: () => clock);

      notifier.syncWith(clock);
      clock = DateTime(2026, 8, 19, 11);
      notifier.syncWith(clock);

      expect(notifier.state.pulseCount, 0);
      expect(notifier.state.nextPulseAt, DateTime(2026, 8, 19, 11, 30));
      notifier.dispose();
    });

    test('a null sync clears the schedule', () {
      final clock = DateTime(2026, 8, 19, 9);
      final notifier = build(now: () => clock);

      notifier.syncWith(clock);
      notifier.syncWith(null);

      expect(notifier.state.isArmed, isFalse);
      expect(notifier.state.pulseCount, 0);
      notifier.dispose();
    });

    test('stop clears the schedule too', () {
      final clock = DateTime(2026, 8, 19, 9);
      final notifier = build(now: () => clock);

      notifier.syncWith(clock);
      notifier.stop();

      expect(notifier.state.isArmed, isFalse);
      notifier.dispose();
    });
  });
}
