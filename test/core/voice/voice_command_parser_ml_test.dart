import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_todo/core/utils/unicode_utils.dart' as unicode_utils;
import 'package:sreerajp_todo/core/voice/voice_command_parser.dart';
import 'package:sreerajp_todo/core/voice/voice_parse_result.dart';

void main() {
  const parser = VoiceCommandParser();

  // A Wednesday, so the weekday tests have a fixed answer.
  final today = DateTime(2026, 8, 19);
  const todayIso = '2026-08-19';

  VoiceParseResult run(String text) => parser.parse(text, today: today);

  group('Malayalam — the whole sentence', () {
    test('next Monday, forty five minutes, study', () {
      // അടുത്ത തിങ്കളാഴ്ച 45 മിനിറ്റ് പഠനം
      final result = run('അടുത്ത തിങ്കളാഴ്ച 45 മിനിറ്റ് പഠനം');

      expect(result.title, 'പഠനം');
      expect(result.date, '2026-08-24');
      expect(result.targetSeconds, 45 * 60);
    });
  });

  group('Malayalam — times of day', () {
    test('a half past form carries its case ending', () {
      // ഏഴരയ്ക്ക് = "at half past seven", written as one word.
      final result = run('ഏഴരയ്ക്ക് നടക്കാൻ പോകണം');

      expect(result.hour, 7);
      expect(result.minute, 30);
      expect(result.title, 'നടക്കാൻ പോകണം');
      expect(result.timeOfDayLabel, '07:30');
    });

    test('a number followed by the o clock marker', () {
      // പത്തു മണിക്ക് = "at ten o'clock".
      final result = run('പത്തു മണിക്ക് ഡോക്ടറെ കാണണം');

      expect(result.hour, 10);
      expect(result.minute, 0);
      expect(result.title, 'ഡോക്ടറെ കാണണം');
    });

    test('digits with the o clock marker', () {
      final result = run('8 മണിക്ക് യോഗം');

      expect(result.hour, 8);
      expect(result.title, 'യോഗം');
    });

    test('a part of the day decides morning or evening', () {
      // രാവിലെ = morning, വൈകുന്നേരം = evening.
      expect(run('രാവിലെ 8 മണിക്ക് വ്യായാമം').hour, 8);
      expect(run('വൈകുന്നേരം 6 മണിക്ക് നടത്തം').hour, 18);
    });

    test('every half past form from one to twelve', () {
      const forms = <String, int>{
        'ഒന്നര': 1,
        'രണ്ടര': 2,
        'മൂന്നര': 3,
        'നാലര': 4,
        'അഞ്ചര': 5,
        'ആറര': 6,
        'ഏഴര': 7,
        'എട്ടര': 8,
        'ഒമ്പതര': 9,
        'പത്തര': 10,
        'പതിനൊന്നര': 11,
        'പന്ത്രണ്ടര': 12,
      };
      forms.forEach((word, hour) {
        final result = run('$word യോഗം');
        expect(result.hour, hour, reason: '$word should be $hour:30');
        expect(result.minute, 30, reason: '$word should be $hour:30');
      });
    });
  });

  group('Malayalam — durations', () {
    test('minutes', () {
      final result = run('45 മിനിറ്റ് പഠനം');

      expect(result.targetSeconds, 45 * 60);
      expect(result.title, 'പഠനം');
    });

    test('hours, and the hour unit is not read as an o clock marker', () {
      // രണ്ട് മണിക്കൂർ is "two hours long", not "at two o'clock". The words
      // മണിക്കൂർ and മണിക്ക് start the same way, so this is the trap the
      // duration pass runs first to avoid.
      final result = run('രണ്ട് മണിക്കൂർ വായന');

      expect(result.targetSeconds, 2 * 3600);
      expect(result.hour, isNull);
      expect(result.title, 'വായന');
    });

    test('a spelled out one with the hour unit', () {
      expect(run('ഒരു മണിക്കൂർ വ്യായാമം').targetSeconds, 3600);
    });

    test('the number and the unit glued into one word', () {
      expect(run('30മിനിറ്റ് ധ്യാനം').targetSeconds, 30 * 60);
    });
  });

  group('Malayalam — dates', () {
    test('today, tomorrow and the day after', () {
      expect(run('ഇന്ന് പലചരക്ക് വാങ്ങണം').date, todayIso);
      expect(run('നാളെ പലചരക്ക് വാങ്ങണം').date, '2026-08-20');
      expect(run('മറ്റന്നാൾ യാത്ര').date, '2026-08-21');
    });

    test('tomorrow leaves the rest of the sentence as the title', () {
      expect(run('നാളെ പലചരക്ക് വാങ്ങണം').title, 'പലചരക്ക് വാങ്ങണം');
    });

    test('every weekday, in both its short and its long form', () {
      const expected = <String, String>{
        'തിങ്കളാഴ്ച': '2026-08-24',
        'ചൊവ്വാഴ്ച': '2026-08-25',
        'ബുധനാഴ്ച': '2026-08-26',
        'വ്യാഴാഴ്ച': '2026-08-20',
        'വെള്ളിയാഴ്ച': '2026-08-21',
        'ശനിയാഴ്ച': '2026-08-22',
        'ഞായറാഴ്ച': '2026-08-23',
      };
      expected.forEach((word, date) {
        expect(run('$word യോഗം').date, date, reason: word);
      });

      // The short names must land on the same days.
      expect(run('തിങ്കൾ യോഗം').date, '2026-08-24');
      expect(run('വെള്ളി യോഗം').date, '2026-08-21');
    });

    test('next week', () {
      expect(run('അടുത്ത ആഴ്ച യാത്ര').date, '2026-08-26');
    });

    test('a count of days', () {
      expect(run('മൂന്ന് ദിവസം കഴിഞ്ഞ് വിളിക്കണം').date, '2026-08-22');
    });
  });

  group('Malayalam — priority', () {
    test('an urgent word', () {
      final result = run('അടിയന്തിരം ബാങ്കിൽ പോകണം');

      expect(result.priority, VoicePriority.urgent);
      expect(result.title, 'ബാങ്കിൽ പോകണം');
    });
  });

  group('Both languages at once', () {
    test('an English verb with a Malayalam object and date', () {
      final result = run('Call അമ്മ നാളെ for 20 minutes');

      expect(result.title, 'Call അമ്മ');
      expect(result.date, '2026-08-20');
      expect(result.targetSeconds, 20 * 60);
    });
  });

  group('Unicode', () {
    test('a decomposed spelling reads the same as a composed one', () {
      // ചൊവ്വ written with the two-part vowel sign (െ + ാ) instead of the
      // single ൊ. NFC normalisation has to fold them together before matching,
      // or a recogniser that emits the decomposed form would be ignored.
      const decomposed = 'ചൊവ്വാഴ്ച';
      const composed = 'ചൊവ്വാഴ്ച';

      expect(
        decomposed == composed,
        isFalse,
        reason: 'the two spellings must really differ before folding',
      );
      expect(unicode_utils.nfcNormalize(decomposed), composed);
      expect(run('$decomposed യോഗം').date, '2026-08-25');
      expect(run('$composed യോഗം').date, '2026-08-25');
    });

    test('the title comes back NFC normalised', () {
      final result = run('നാളെ ചൊറ്റ');

      expect(result.title, unicode_utils.nfcNormalize(result.title));
    });
  });

  group('Day-Lock', () {
    test('the date is never before today', () {
      for (final text in <String>[
        'പലചരക്ക് വാങ്ങണം',
        'തിങ്കളാഴ്ച യോഗം',
        'അടുത്ത ആഴ്ച യാത്ര',
        'മൂന്ന് ദിവസം കഴിഞ്ഞ് വിളിക്കണം',
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
