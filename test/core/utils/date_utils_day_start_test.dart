import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_todo/core/utils/date_format_rules.dart';
import 'package:sreerajp_todo/core/utils/date_utils.dart';

void main() {
  // Every test leaves the shared settings back at their defaults, so one test
  // can never change the answer of the next.
  tearDown(() {
    setDayStartHour(0);
    setAppDateFormat(AppDateFormat.system);
    setClockFormat(ClockFormat.system);
  });

  group('setDayStartHour', () {
    test('starts at plain midnight', () {
      expect(dayStartHour, 0);
    });

    test('keeps a normal hour', () {
      setDayStartHour(4);
      expect(dayStartHour, 4);
    });

    test('clamps a value outside the allowed range', () {
      setDayStartHour(99);
      expect(dayStartHour, kMaxDayStartHour);

      setDayStartHour(-5);
      expect(dayStartHour, kMinDayStartHour);
    });
  });

  group('toAppDay', () {
    test('changes nothing while the day starts at midnight', () {
      final moment = DateTime(2026, 8, 20, 1, 30);
      expect(toAppDay(moment), moment);
    });

    test('1 AM still belongs to the day before when the day starts at 4', () {
      setDayStartHour(4);
      final oneInTheMorning = DateTime(2026, 8, 20, 1, 30);
      expect(dateTimeToIso(toAppDay(oneInTheMorning)), '2026-08-19');
    });

    test('the boundary hour itself belongs to the new day', () {
      setDayStartHour(4);
      final fourExactly = DateTime(2026, 8, 20, 4);
      expect(dateTimeToIso(toAppDay(fourExactly)), '2026-08-20');
    });

    test('one minute before the boundary is still the day before', () {
      setDayStartHour(4);
      final justBefore = DateTime(2026, 8, 20, 3, 59);
      expect(dateTimeToIso(toAppDay(justBefore)), '2026-08-19');
    });

    test('an afternoon is untouched by the shift', () {
      setDayStartHour(4);
      final afternoon = DateTime(2026, 8, 20, 15);
      expect(dateTimeToIso(toAppDay(afternoon)), '2026-08-20');
    });
  });

  group('formatDate', () {
    test('follows the chosen style', () {
      final date = DateTime(2026, 8, 19);

      setAppDateFormat(AppDateFormat.iso);
      expect(formatDate(date), '2026-08-19');

      setAppDateFormat(AppDateFormat.dayMonthYear);
      expect(formatDate(date), '19/08/2026');

      setAppDateFormat(AppDateFormat.monthDayYear);
      expect(formatDate(date), '08/19/2026');
    });

    test('reads the same from an ISO string', () {
      setAppDateFormat(AppDateFormat.iso);
      expect(formatDateFromIso('2026-08-19'), '2026-08-19');
    });
  });

  group('formatTime', () {
    test('follows the chosen clock', () {
      final moment = DateTime(2026, 8, 19, 14, 30, 15);

      setClockFormat(ClockFormat.twentyFourHour);
      expect(formatTime(moment), '14:30');
      expect(formatTime(moment, withSeconds: true), '14:30:15');

      setClockFormat(ClockFormat.twelveHour);
      expect(formatTime(moment), contains('2:30'));
    });
  });

  group('formatDateTime', () {
    test('joins the chosen date style and clock', () {
      setAppDateFormat(AppDateFormat.iso);
      setClockFormat(ClockFormat.twentyFourHour);
      expect(formatDateTime(DateTime(2026, 8, 19, 9, 5)), '2026-08-19 09:05');
    });
  });
}
