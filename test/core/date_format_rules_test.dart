import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_todo/core/utils/date_format_rules.dart';

void main() {
  group('WeekStartDay', () {
    test('system has no weekday of its own', () {
      expect(WeekStartDay.system.weekdayNumber, isNull);
    });

    test('the named days map to the DateTime numbers', () {
      expect(WeekStartDay.monday.weekdayNumber, DateTime.monday);
      expect(WeekStartDay.saturday.weekdayNumber, DateTime.saturday);
      expect(WeekStartDay.sunday.weekdayNumber, DateTime.sunday);
    });
  });

  group('ClockFormat', () {
    test('system leaves the pattern to the locale', () {
      expect(ClockFormat.system.timePattern, isNull);
      expect(ClockFormat.system.timeWithSecondsPattern, isNull);
    });

    test('the fixed choices carry their own pattern', () {
      expect(ClockFormat.twelveHour.timePattern, 'h:mm a');
      expect(ClockFormat.twentyFourHour.timePattern, 'HH:mm');
      expect(ClockFormat.twentyFourHour.timeWithSecondsPattern, 'HH:mm:ss');
    });
  });

  group('AppDateFormat', () {
    test('the two system styles leave the pattern to the locale', () {
      expect(AppDateFormat.system.pattern, isNull);
      expect(AppDateFormat.systemShort.pattern, isNull);
    });

    test('the fixed styles carry their own pattern', () {
      expect(AppDateFormat.dayMonthYear.pattern, 'dd/MM/yyyy');
      expect(AppDateFormat.iso.pattern, 'yyyy-MM-dd');
    });
  });

  group('clampDayStartHour', () {
    test('keeps a normal hour as it is', () {
      expect(clampDayStartHour(4), 4);
    });

    test('pulls a value below zero back to midnight', () {
      expect(clampDayStartHour(-3), kMinDayStartHour);
    });

    test('pulls a value past the limit back to the limit', () {
      expect(clampDayStartHour(23), kMaxDayStartHour);
    });

    test('the limit stays below noon, so a day cannot swallow the next', () {
      expect(kMaxDayStartHour, lessThan(12));
    });
  });

  group('parseWorkingDays', () {
    test('nothing saved gives Monday to Friday', () {
      expect(parseWorkingDays(null), kDefaultWorkingDays);
    });

    test('reads back what encodeWorkingDays wrote', () {
      const days = {DateTime.saturday, DateTime.sunday};
      expect(parseWorkingDays(encodeWorkingDays(days)), days);
    });

    test('drops entries that are not real weekdays', () {
      expect(parseWorkingDays(['1', '9', 'x', '0', '7']), {
        DateTime.monday,
        DateTime.sunday,
      });
    });

    test('an empty saved list stays empty rather than falling back', () {
      expect(parseWorkingDays(const <String>[]), isEmpty);
    });
  });

  group('encodeWorkingDays', () {
    test('writes the days in order', () {
      expect(encodeWorkingDays({DateTime.friday, DateTime.monday}), ['1', '5']);
    });
  });

  group('isWorkingDay', () {
    test('follows the chosen set', () {
      // 2026-08-19 is a Wednesday.
      final wednesday = DateTime(2026, 8, 19);
      expect(isWorkingDay(wednesday, kDefaultWorkingDays), isTrue);
      expect(isWorkingDay(wednesday, {DateTime.sunday}), isFalse);
    });
  });

  group('countWorkingDays', () {
    test('counts only the chosen days across a full week', () {
      final monday = DateTime(2026, 8, 17);
      final sunday = DateTime(2026, 8, 23);
      expect(countWorkingDays(monday, sunday, kDefaultWorkingDays), 5);
    });

    test('includes both ends of the range', () {
      final monday = DateTime(2026, 8, 17);
      expect(countWorkingDays(monday, monday, kDefaultWorkingDays), 1);
    });

    test('an empty set counts nothing', () {
      final monday = DateTime(2026, 8, 17);
      final sunday = DateTime(2026, 8, 23);
      expect(countWorkingDays(monday, sunday, const <int>{}), 0);
    });

    test('a backwards range counts nothing', () {
      expect(
        countWorkingDays(
          DateTime(2026, 8, 23),
          DateTime(2026, 8, 17),
          kDefaultWorkingDays,
        ),
        0,
      );
    });
  });
}
