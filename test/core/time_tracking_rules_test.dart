import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_todo/core/utils/time_tracking_rules.dart';

void main() {
  group('roundSecondsForDisplay', () {
    test('returns the exact seconds when rounding is off', () {
      expect(roundSecondsForDisplay(97, DurationRounding.off), 97);
    });

    test('clamps a zero or negative input to zero', () {
      expect(roundSecondsForDisplay(0, DurationRounding.nearest5Minutes), 0);
      expect(roundSecondsForDisplay(-40, DurationRounding.nearestMinute), 0);
    });

    test('rounds to the nearest minute, half away from zero', () {
      expect(roundSecondsForDisplay(29, DurationRounding.nearestMinute), 0);
      expect(roundSecondsForDisplay(30, DurationRounding.nearestMinute), 60);
      expect(roundSecondsForDisplay(89, DurationRounding.nearestMinute), 60);
      expect(roundSecondsForDisplay(90, DurationRounding.nearestMinute), 120);
    });

    test('rounds to the nearest 5 minutes', () {
      expect(roundSecondsForDisplay(149, DurationRounding.nearest5Minutes), 0);
      expect(
        roundSecondsForDisplay(150, DurationRounding.nearest5Minutes),
        300,
      );
      expect(
        roundSecondsForDisplay(460, DurationRounding.nearest5Minutes),
        600,
      );
    });

    test('rounds to the nearest 15 minutes', () {
      expect(roundSecondsForDisplay(449, DurationRounding.nearest15Minutes), 0);
      expect(
        roundSecondsForDisplay(450, DurationRounding.nearest15Minutes),
        900,
      );
      expect(
        roundSecondsForDisplay(3600, DurationRounding.nearest15Minutes),
        3600,
      );
    });
  });

  group('isSegmentTooShort', () {
    test('keeps everything when the limit is off', () {
      expect(isSegmentTooShort(1, MinimumSegmentLength.off), isFalse);
    });

    test('discards below the limit and keeps exactly at the limit', () {
      expect(isSegmentTooShort(9, MinimumSegmentLength.tenSeconds), isTrue);
      expect(isSegmentTooShort(10, MinimumSegmentLength.tenSeconds), isFalse);
      expect(isSegmentTooShort(11, MinimumSegmentLength.tenSeconds), isFalse);
    });

    test('honours the five minute limit', () {
      expect(isSegmentTooShort(299, MinimumSegmentLength.fiveMinutes), isTrue);
      expect(isSegmentTooShort(300, MinimumSegmentLength.fiveMinutes), isFalse);
    });
  });

  group('nextAutoStopInstant', () {
    final from = DateTime(2026, 8, 18, 14, 30);

    test('returns null when auto-stop is off', () {
      expect(nextAutoStopInstant(from, AutoStopMode.off), isNull);
    });

    test('midnight is the start of the next day', () {
      expect(
        nextAutoStopInstant(from, AutoStopMode.midnight),
        DateTime(2026, 8, 19),
      );
    });

    test('a custom time later today is used as is', () {
      expect(
        nextAutoStopInstant(
          from,
          AutoStopMode.customTime,
          customHour: 18,
          customMinute: 45,
        ),
        DateTime(2026, 8, 18, 18, 45),
      );
    });

    test('a custom time already past today rolls to tomorrow', () {
      expect(
        nextAutoStopInstant(
          from,
          AutoStopMode.customTime,
          customHour: 9,
          customMinute: 0,
        ),
        DateTime(2026, 8, 19, 9, 0),
      );
    });

    test('a custom time exactly now rolls to tomorrow', () {
      expect(
        nextAutoStopInstant(
          from,
          AutoStopMode.customTime,
          customHour: 14,
          customMinute: 30,
        ),
        DateTime(2026, 8, 19, 14, 30),
      );
    });
  });

  group('orphanCloseTime', () {
    final segmentStart = DateTime(2026, 8, 17, 22, 0);
    final now = DateTime(2026, 8, 18, 9, 0);

    test('returns null when auto-stop is off, keeping old behaviour', () {
      expect(orphanCloseTime(segmentStart, now, AutoStopMode.off), isNull);
    });

    test('closes an overnight orphan at midnight', () {
      expect(
        orphanCloseTime(segmentStart, now, AutoStopMode.midnight),
        DateTime(2026, 8, 18),
      );
    });

    test('closes at the custom time that followed the start', () {
      expect(
        orphanCloseTime(
          segmentStart,
          now,
          AutoStopMode.customTime,
          customHour: 6,
          customMinute: 30,
        ),
        DateTime(2026, 8, 18, 6, 30),
      );
    });

    test('never writes an end time in the future', () {
      // The cut-off has not happened yet, so there is nothing honest to write.
      expect(
        orphanCloseTime(
          DateTime(2026, 8, 18, 8, 0),
          now,
          AutoStopMode.customTime,
          customHour: 23,
          customMinute: 30,
        ),
        isNull,
      );
    });
  });
}
