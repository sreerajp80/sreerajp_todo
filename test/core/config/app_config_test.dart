import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_todo/core/config/app_config.dart';

void main() {
  group('LocalizedText', () {
    test('plain string resolves identically for any language code', () {
      const text = LocalizedText.plain('Plain English');
      expect(text.resolve('en'), equals('Plain English'));
      expect(text.resolve('ml'), equals('Plain English'));
      expect(text.resolve('fr'), equals('Plain English'));
      expect(text.isEmpty, isFalse);
    });

    test('byLocale resolves according to languageCode and falls back', () {
      const text = LocalizedText.byLocale({'en': 'Hello', 'ml': 'നമസ്കാരം'});
      expect(text.resolve('en'), equals('Hello'));
      expect(text.resolve('ml'), equals('നമസ്കാരം'));
      expect(text.resolve('fr'), equals('Hello')); // falls back to en
    });

    test('fromJson handles string and map correctly', () {
      final textFromString = LocalizedText.fromJson('Test');
      expect(textFromString.resolve('en'), equals('Test'));

      final textFromMap = LocalizedText.fromJson(const {
        'en': 'English',
        'ml': 'മലയാളം',
      });
      expect(textFromMap.resolve('en'), equals('English'));
      expect(textFromMap.resolve('ml'), equals('മലയാളം'));

      final textFromNull = LocalizedText.fromJson(null, fallback: 'Default');
      expect(textFromNull.resolve('en'), equals('Default'));
    });
  });

  group('AppConfig', () {
    test('fallback returns expected default values', () {
      expect(AppConfig.fallback.appName.resolve('en'), equals('SreerajP ToDo'));
      expect(AppConfig.fallback.version, equals('2.1.0'));
      expect(AppConfig.fallback.build, equals('45'));
      expect(AppConfig.fallback.details, isNotEmpty);
      expect(
        AppConfig.fallback.description.resolve('en'),
        equals('Personal offline-first daily ToDo and time-tracker.'),
      );
    });

    test('fromJson parses valid json object properly', () {
      final json = {
        'appName': 'Test App',
        'description': {'en': 'English desc', 'ml': 'Malayalam desc'},
        'version': '2.0.0',
        'build': '42',
        'details': {
          'author': 'Tester',
          'license': {'en': 'MIT', 'ml': 'എം.ഐ.ടി'},
        },
      };

      final config = AppConfig.fromJson(json);

      expect(config.appName.resolve('en'), equals('Test App'));
      expect(config.description.resolve('en'), equals('English desc'));
      expect(config.description.resolve('ml'), equals('Malayalam desc'));
      expect(config.version, equals('2.0.0'));
      expect(config.build, equals('42'));
      expect(config.details['author']?.resolve('en'), equals('Tester'));
      expect(config.details['license']?.resolve('en'), equals('MIT'));
      expect(config.details['license']?.resolve('ml'), equals('എം.ഐ.ടി'));
    });

    test('fromJson parses trilingual appName properly', () {
      final json = {
        'appName': {
          'en': 'SreerajP ToDo',
          'ml': 'ശ്രീരാജ്പി ടുഡു',
          'sa': 'श्रीराज्-पी कार्यसूची',
        },
        'description': 'Desc',
        'version': '1.0.0',
        'build': '1',
      };
      final config = AppConfig.fromJson(json);
      expect(config.appName.resolve('en'), equals('SreerajP ToDo'));
      expect(config.appName.resolve('ml'), equals('ശ്രീരാജ്പി ടുഡു'));
      expect(config.appName.resolve('sa'), equals('श्रीराज्-पी कार्यसूची'));
    });

    test('fromJson falls back on missing or wrong type fields', () {
      final json = {'appName': 12345, 'details': 'not a map'};

      final config = AppConfig.fromJson(json);

      expect(
        config.appName.resolve('en'),
        equals(AppConfig.fallback.appName.resolve('en')),
      );
      expect(
        config.description.resolve('en'),
        equals(AppConfig.fallback.description.resolve('en')),
      );
      expect(config.version, equals(AppConfig.fallback.version));
      expect(config.build, equals(AppConfig.fallback.build));
      expect(config.details, isEmpty);
    });
  });

  group('app_config.json compliance tests', () {
    test(
      'app_config.json has complete en, ml, sa entries and no Hindi markers',
      () {
        final file = File('assets/config/app_config.json');
        expect(file.existsSync(), isTrue, reason: 'app_config.json must exist');

        final json =
            jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
        final problems = <String>[];

        void checkLanguages(String path, dynamic value) {
          if (value is! Map<String, dynamic>) {
            problems.add('$path must be a locale map');
            return;
          }
          for (final lang in ['en', 'ml', 'sa']) {
            final text = value[lang]?.toString().trim() ?? '';
            if (text.isEmpty) {
              problems.add('$path.$lang is missing or empty');
            }
          }
        }

        checkLanguages('appName', json['appName']);
        checkLanguages('description', json['description']);

        final details = json['details'] as Map<String, dynamic>;
        checkLanguages('details.author', details['author']);
        checkLanguages('details.license', details['license']);
        checkLanguages('details.aiUsed', details['aiUsed']);
        checkLanguages('details.ideUsed', details['ideUsed']);

        expect(problems, isEmpty, reason: problems.join('\n'));

        // Forbidden Hindi markers and nukta check from standard §8.5
        const forbiddenSubstringMarkers = [
          'करें',
          'करना',
          'करके',
          'रहा',
          'रही',
          'रहे',
          'गया',
          'गयी',
          'चाहिए',
          'नहीं',
          'लेकिन',
          'क्या',
          'कृपया',
          'सेटिंग्स',
          'ऐप',
        ];

        const forbiddenStandaloneMarkers = [
          'था',
          'थे',
          'थी',
          'हो',
          'है',
          'हैं',
          'हूं',
          'और',
        ];

        void checkSanskritText(String path, dynamic value) {
          if (value is Map<String, dynamic>) {
            final saText = value['sa']?.toString() ?? '';

            // Check nukta
            for (final rune in saText.runes) {
              if (rune == 0x093C || (rune >= 0x0958 && rune <= 0x095F)) {
                problems.add(
                  'Nukta character U+${rune.toRadixString(16).toUpperCase()} found in $path.sa: "$saText"',
                );
              }
            }

            // Check forbidden substrings
            for (final marker in forbiddenSubstringMarkers) {
              if (saText.contains(marker)) {
                problems.add(
                  'Forbidden Hindi marker "$marker" found in $path.sa: "$saText"',
                );
              }
            }

            // Check forbidden standalone words
            final words = saText.split(RegExp(r'[\s।,.\?!;:\-_/]+'));
            for (final marker in forbiddenStandaloneMarkers) {
              if (words.contains(marker)) {
                problems.add(
                  'Forbidden Hindi word "$marker" found in $path.sa: "$saText"',
                );
              }
            }
          }
        }

        checkSanskritText('appName', json['appName']);
        checkSanskritText('description', json['description']);
        for (final entry in details.entries) {
          checkSanskritText('details.${entry.key}', entry.value);
        }

        expect(problems, isEmpty, reason: problems.join('\n'));
      },
    );
  });
}
