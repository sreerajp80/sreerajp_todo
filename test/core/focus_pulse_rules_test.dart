import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_todo/core/utils/focus_pulse_rules.dart';

void main() {
  group('FocusPulseMode', () {
    test('off does nothing', () {
      expect(FocusPulseMode.off.isOn, isFalse);
      expect(FocusPulseMode.off.hasSound, isFalse);
      expect(FocusPulseMode.off.hasVibration, isFalse);
    });

    test('vibration and sound each do only their own thing', () {
      expect(FocusPulseMode.vibration.hasVibration, isTrue);
      expect(FocusPulseMode.vibration.hasSound, isFalse);
      expect(FocusPulseMode.sound.hasSound, isTrue);
      expect(FocusPulseMode.sound.hasVibration, isFalse);
    });

    test('both does everything', () {
      expect(FocusPulseMode.both.isOn, isTrue);
      expect(FocusPulseMode.both.hasSound, isTrue);
      expect(FocusPulseMode.both.hasVibration, isTrue);
    });
  });

  group('nextFocusPulseAfter', () {
    final start = DateTime(2026, 8, 19, 10);

    test('gives the first pulse one gap after the start', () {
      final next = nextFocusPulseAfter(
        start,
        start,
        const Duration(minutes: 30),
      );
      expect(next, DateTime(2026, 8, 19, 10, 30));
    });

    test('skips the gaps that already went by', () {
      final now = DateTime(2026, 8, 19, 11, 5);
      expect(
        nextFocusPulseAfter(start, now, const Duration(minutes: 30)),
        DateTime(2026, 8, 19, 11, 30),
      );
    });

    test('a pulse due at this exact moment counts as given', () {
      final now = DateTime(2026, 8, 19, 10, 30);
      expect(
        nextFocusPulseAfter(start, now, const Duration(minutes: 30)),
        DateTime(2026, 8, 19, 11),
      );
    });

    test('handles a clock that is behind the start time', () {
      final now = DateTime(2026, 8, 19, 9, 50);
      expect(
        nextFocusPulseAfter(start, now, const Duration(minutes: 30)),
        DateTime(2026, 8, 19, 10, 30),
      );
    });

    test('returns null for a gap that cannot be used', () {
      expect(nextFocusPulseAfter(start, start, Duration.zero), isNull);
      expect(
        nextFocusPulseAfter(start, start, const Duration(minutes: -5)),
        isNull,
      );
    });
  });
}
