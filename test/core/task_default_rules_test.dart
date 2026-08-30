import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_todo/core/utils/task_default_rules.dart';

void main() {
  group('DefaultTargetTime', () {
    test('none carries no target at all', () {
      expect(DefaultTargetTime.none.minutes, 0);
      expect(DefaultTargetTime.none.seconds, isNull);
    });

    test('every other option is its minutes in seconds', () {
      expect(DefaultTargetTime.fifteenMinutes.seconds, 900);
      expect(DefaultTargetTime.thirtyMinutes.seconds, 1800);
      expect(DefaultTargetTime.oneHour.seconds, 3600);
      expect(DefaultTargetTime.twoHours.seconds, 7200);
    });
  });

  group('splitTargetSeconds', () {
    test('null and zero both read as no target', () {
      expect(splitTargetSeconds(null), (hours: 0, minutes: 0));
      expect(splitTargetSeconds(0), (hours: 0, minutes: 0));
    });

    test('a negative value cannot make a negative box', () {
      expect(splitTargetSeconds(-60), (hours: 0, minutes: 0));
    });

    test('splits into whole hours and leftover minutes', () {
      expect(splitTargetSeconds(5400), (hours: 1, minutes: 30));
      expect(splitTargetSeconds(2700), (hours: 0, minutes: 45));
      expect(splitTargetSeconds(7200), (hours: 2, minutes: 0));
    });

    test('seconds below a minute are dropped', () {
      expect(splitTargetSeconds(59), (hours: 0, minutes: 0));
      expect(splitTargetSeconds(3659), (hours: 1, minutes: 0));
    });
  });

  group('joinTargetSeconds', () {
    test('both boxes at zero means no target', () {
      expect(joinTargetSeconds(hours: 0, minutes: 0), isNull);
    });

    test('adds the two boxes together', () {
      expect(joinTargetSeconds(hours: 1, minutes: 30), 5400);
      expect(joinTargetSeconds(hours: 0, minutes: 45), 2700);
    });

    test('minutes past 59 are allowed and simply add up', () {
      expect(joinTargetSeconds(hours: 0, minutes: 90), 5400);
    });

    test('round trips through the splitter', () {
      final split = splitTargetSeconds(5400);
      expect(
        joinTargetSeconds(hours: split.hours, minutes: split.minutes),
        5400,
      );
    });
  });

  group('shouldAskCarryOver', () {
    const today = '2026-08-19';

    test('never asks while the setting is off', () {
      expect(
        shouldAskCarryOver(enabled: false, lastAskedIso: null, todayIso: today),
        isFalse,
      );
    });

    test('asks when it has never been shown', () {
      expect(
        shouldAskCarryOver(enabled: true, lastAskedIso: null, todayIso: today),
        isTrue,
      );
      expect(
        shouldAskCarryOver(enabled: true, lastAskedIso: '', todayIso: today),
        isTrue,
      );
    });

    test('does not ask twice on the same day', () {
      expect(
        shouldAskCarryOver(enabled: true, lastAskedIso: today, todayIso: today),
        isFalse,
      );
    });

    test('asks again on the next day', () {
      expect(
        shouldAskCarryOver(
          enabled: true,
          lastAskedIso: '2026-08-18',
          todayIso: today,
        ),
        isTrue,
      );
    });

    test('a clock set forward cannot lock the sheet out for good', () {
      expect(
        shouldAskCarryOver(
          enabled: true,
          lastAskedIso: '2027-01-01',
          todayIso: today,
        ),
        isTrue,
      );
    });
  });

  group('CarryOverLookBack', () {
    test('names how many days back are searched', () {
      expect(CarryOverLookBack.previousDay.days, 1);
      expect(CarryOverLookBack.threeDays.days, 3);
      expect(CarryOverLookBack.lastSevenDays.days, 7);
      expect(CarryOverLookBack.fourteenDays.days, 14);
      expect(CarryOverLookBack.thirtyDays.days, 30);
      expect(CarryOverLookBack.fortyFiveDays.days, 45);
    });

    test('sanitizeCarryOverLookBackDays clamps between 1 and 45', () {
      expect(sanitizeCarryOverLookBackDays(null), 7);
      expect(sanitizeCarryOverLookBackDays(0), 1);
      expect(sanitizeCarryOverLookBackDays(-5), 1);
      expect(sanitizeCarryOverLookBackDays(10), 10);
      expect(sanitizeCarryOverLookBackDays(45), 45);
      expect(sanitizeCarryOverLookBackDays(100), 45);
    });
  });

  group('SuggestionCount', () {
    test('carries the SQL limit it stands for', () {
      expect(SuggestionCount.five.limit, 5);
      expect(SuggestionCount.ten.limit, 10);
      expect(SuggestionCount.twenty.limit, 20);
      expect(SuggestionCount.fifty.limit, 50);
    });
  });
}
