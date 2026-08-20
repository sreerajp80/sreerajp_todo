import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_todo/core/voice/voice_command_parser.dart';
import 'package:sreerajp_todo/core/voice/voice_parse_result.dart';

void main() {
  const parser = VoiceCommandParser();

  // A Wednesday, so the weekday tests have a fixed answer.
  final today = DateTime(2026, 8, 19);
  const todayIso = '2026-08-19';

  VoiceParseResult run(String text) => parser.parse(text, today: today);

  group('English — the whole sentence', () {
    test('date, time and duration all in one sentence', () {
      final result = run('Call the bank tomorrow at 10 am for 30 minutes');

      expect(result.title, 'Call the bank');
      expect(result.date, '2026-08-20');
      expect(result.hour, 10);
      expect(result.minute, 0);
      expect(result.targetSeconds, 30 * 60);
      expect(
        result.matched,
        containsAll(<VoiceField>[
          VoiceField.date,
          VoiceField.timeOfDay,
          VoiceField.target,
        ]),
      );
    });

    test('two duration parts are added together', () {
      final result = run('Study Dart next Monday for 1 hour 30 minutes');

      expect(result.title, 'Study Dart');
      expect(result.targetSeconds, 90 * 60);
      // Wednesday to the next Monday is five days.
      expect(result.date, '2026-08-24');
    });
  });

  group('English — dates', () {
    test('no date words means today', () {
      final result = run('Buy milk');

      expect(result.title, 'Buy milk');
      expect(result.date, todayIso);
      expect(result.isTitleOnly, isTrue);
    });

    test('tomorrow', () {
      expect(run('Pay rent tomorrow').date, '2026-08-20');
    });

    test('the day after tomorrow beats tomorrow', () {
      final result = run('Send report the day after tomorrow');

      expect(result.date, '2026-08-21');
      expect(result.title, 'Send report');
    });

    test('in three days', () {
      final result = run('Report in 3 days');

      expect(result.date, '2026-08-22');
      expect(result.title, 'Report');
    });

    test('in two weeks', () {
      expect(run('Review in 2 weeks').date, '2026-09-02');
    });

    test('a weekday always looks forward, never at today', () {
      // Today is a Wednesday, so "Wednesday" means the one a week away.
      expect(run('Team sync on Wednesday').date, '2026-08-26');
      expect(run('Gym on Friday').date, '2026-08-21');
    });

    test('next week', () {
      expect(run('Plan holiday next week').date, '2026-08-26');
    });
  });

  group('English — times of day', () {
    test('am and pm', () {
      expect(run('Meeting at 10 am').hour, 10);
      expect(run('Meeting at 10 pm').hour, 22);
      expect(run('Meeting at 12 am').hour, 0);
      expect(run('Meeting at 12 pm').hour, 12);
    });

    test('hours and minutes with a colon', () {
      final result = run('Meeting at 10:30 pm');

      expect(result.hour, 22);
      expect(result.minute, 30);
      expect(result.title, 'Meeting');
      expect(result.timeOfDayLabel, '22:30');
    });

    test('o clock', () {
      expect(run("Call home at 9 o'clock").hour, 9);
    });

    test('half past and quarter to', () {
      final half = run('Team sync at half past seven');
      expect(half.hour, 7);
      expect(half.minute, 30);
      expect(half.title, 'Team sync');

      final quarter = run('Leave at quarter to 8');
      expect(quarter.hour, 7);
      expect(quarter.minute, 45);
    });

    test('a part of the day decides morning or evening', () {
      final result = run('Walk in the morning at 7');

      expect(result.hour, 7);
      expect(result.title, 'Walk');
    });

    test('an hour with nothing to go on is kept exactly as said', () {
      // The parser never guesses. "at 5" stays 05:00, it is not turned into
      // 17:00 on a hunch.
      expect(run('Snack at 5').hour, 5);
    });

    test('a part of the day on its own stays in the title', () {
      final result = run('Morning walk');

      expect(result.hour, isNull);
      expect(result.title, 'Morning walk');
    });

    test('a bare number is not a time', () {
      final result = run('Read 20 pages');

      expect(result.hour, isNull);
      expect(result.title, 'Read 20 pages');
    });
  });

  group('English — durations', () {
    test('minutes in digits', () {
      expect(run('Gym for 45 mins').targetSeconds, 45 * 60);
      expect(run('Gym for 45 mins').title, 'Gym');
    });

    test('minutes in words, tens and units joined', () {
      expect(run('Practice for forty five minutes').targetSeconds, 45 * 60);
      expect(run('Practice for forty-five minutes').targetSeconds, 45 * 60);
    });

    test('half an hour', () {
      final result = run('Meditate for half an hour');

      expect(result.targetSeconds, 30 * 60);
      expect(result.title, 'Meditate');
    });
  });

  group('English — priority', () {
    test('a single word', () {
      final result = run('urgent: Pay rent tomorrow');

      expect(result.priority, VoicePriority.urgent);
      expect(result.title, 'Pay rent');
      expect(result.date, '2026-08-20');
    });

    test('a two word phrase', () {
      final result = run('Dentist appointment low priority');

      expect(result.priority, VoicePriority.low);
      expect(result.title, 'Dentist appointment');
    });
  });

  group('English — title clean-up', () {
    test('an opening phrase is dropped', () {
      final result = run('remind me to call amma at 6 pm');

      expect(result.title, 'call amma');
      expect(result.hour, 18);
    });

    test('small words are only trimmed at the ends', () {
      // "the" in the middle has to survive, or the title stops making sense.
      expect(run('Call the bank').title, 'Call the bank');
    });

    test(
      'a sentence with nothing but a date and a time keeps its own words',
      () {
        final result = run('tomorrow at 10 am');

        expect(result.title, 'tomorrow at 10 am');
        expect(result.date, '2026-08-20');
        expect(result.hour, 10);
      },
    );

    test('an empty sentence gives an empty title', () {
      final result = run('   ');

      expect(result.title, '');
      expect(result.date, todayIso);
    });
  });

  group('Day-Lock', () {
    test('the date is never before today', () {
      for (final text in <String>[
        'Buy milk',
        'Gym on Monday',
        'Report in 3 days',
        'Plan next week',
      ]) {
        expect(
          run(text).date.compareTo(todayIso) >= 0,
          isTrue,
          reason: 'parsing "$text" gave a day before today',
        );
      }
    });
  });
}
