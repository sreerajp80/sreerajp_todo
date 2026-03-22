import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_todo/core/utils/rrule_display_utils.dart';

void main() {
  group('describeRrule', () {
    test('FREQ=DAILY → Daily', () {
      expect(describeRrule('FREQ=DAILY'), 'Daily');
    });

    test('FREQ=DAILY;INTERVAL=3 → Every 3 days', () {
      expect(describeRrule('FREQ=DAILY;INTERVAL=3'), 'Every 3 days');
    });

    test('FREQ=WEEKLY;BYDAY=MO,TU,WE,TH,FR → Every weekday', () {
      expect(
        describeRrule('FREQ=WEEKLY;BYDAY=MO,TU,WE,TH,FR'),
        'Every weekday',
      );
    });

    test('FREQ=WEEKLY;BYDAY=MO,TH → Every Monday and Thursday', () {
      expect(
        describeRrule('FREQ=WEEKLY;BYDAY=MO,TH'),
        'Every Monday and Thursday',
      );
    });

    test('FREQ=WEEKLY;BYDAY=SA,SU → Every weekend', () {
      expect(describeRrule('FREQ=WEEKLY;BYDAY=SA,SU'), 'Every weekend');
    });

    test('FREQ=MONTHLY;BYDAY=1MO → Monthly on the 1st Monday', () {
      expect(
        describeRrule('FREQ=MONTHLY;BYDAY=1MO'),
        'Monthly on the 1st Monday',
      );
    });

    test('FREQ=MONTHLY;BYMONTHDAY=15 → Monthly on day 15', () {
      expect(describeRrule('FREQ=MONTHLY;BYMONTHDAY=15'), 'Monthly on day 15');
    });

    test('FREQ=YEARLY;BYMONTH=3;BYMONTHDAY=15 → Annually on March 15', () {
      expect(
        describeRrule('FREQ=YEARLY;BYMONTH=3;BYMONTHDAY=15'),
        'Annually on March 15',
      );
    });

    test('FREQ=WEEKLY → Weekly', () {
      expect(describeRrule('FREQ=WEEKLY'), 'Weekly');
    });

    test('FREQ=WEEKLY;INTERVAL=2 → Every 2 weeks', () {
      expect(describeRrule('FREQ=WEEKLY;INTERVAL=2'), 'Every 2 weeks');
    });

    test('FREQ=YEARLY → Annually', () {
      expect(describeRrule('FREQ=YEARLY'), 'Annually');
    });

    test('FREQ=MONTHLY;BYDAY=-1FR → Monthly on the last Friday', () {
      expect(
        describeRrule('FREQ=MONTHLY;BYDAY=-1FR'),
        'Monthly on the last Friday',
      );
    });

    test('empty string returns as-is', () {
      expect(describeRrule(''), '');
    });

    test('three-day weekly', () {
      expect(
        describeRrule('FREQ=WEEKLY;BYDAY=MO,WE,FR'),
        'Every Monday, Wednesday and Friday',
      );
    });
  });
}
