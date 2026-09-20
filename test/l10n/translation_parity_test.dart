import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const locales = ['ml', 'sa'];

  /// Strings allowed to match English: brand names, font names, symbols, technical identifiers, formulas.
  const sameAsEnglishAllowed = <String>{
    'appName', // Brand name: "SreerajP ToDo"
    'aboutAuthorName', // "Sreeraj P"
    'aboutAiModels', // "Anthropic Claude, Google Gemini"
    'csvFormat', // "CSV"
    'jsonFormat', // "JSON"
    'sqlcipherLabel', // "SQLCipher"
    'emptyValue', // Symbol: "--"
    'manualSegmentShort', // Single letter indicator: "M"
    'targetHoursRangeError', // Numeric range: "0–23"
    'targetMinutesRangeError', // Numeric range: "0–59"
    'fontManjari', // Font name: "Manjari"
    'fontAnekMalayalam', // Font name: "Anek Malayalam"
    'fontNotoSansMalayalam', // Font name: "Noto Sans Malayalam"
    'typographySampleLatin', // Latin pangram sample
    'typographySampleMalayalam', // Malayalam sample text
    'settingsLanguageEnglish', // English language name: "English"
    'voiceLanguageEnglish', // English language name: "English"
    'ocrLanguageEnglish', // English language name: "English"
  };

  group('ARB parity tests', () {
    test('every ARB file has the same keys as the template', () {
      final en = _keys('lib/l10n/app_en.arb');
      for (final locale in locales) {
        final other = _keys('lib/l10n/app_$locale.arb');
        expect(other.difference(en), isEmpty, reason: 'extra keys in $locale');
        expect(
          en.difference(other),
          isEmpty,
          reason: 'missing keys in $locale',
        );
      }
    });

    test('no translation is a copy of the English value', () {
      final enStrings = _strings('lib/l10n/app_en.arb');
      final problems = <String>[];
      for (final locale in locales) {
        final other = _strings('lib/l10n/app_$locale.arb');
        for (final entry in other.entries) {
          final key = entry.key;
          final value = entry.value;
          if (sameAsEnglishAllowed.contains(key)) continue;
          if (value == enStrings[key] && value.trim().isNotEmpty) {
            problems.add(
              'lib/l10n/app_$locale.arb: $key is untranslated (matches English)',
            );
          }
        }
      }
      expect(problems, isEmpty, reason: problems.join('\n'));
    });

    test(
      'aboutMadeWithLove keeps the {heart} marker in all three languages',
      () {
        for (final locale in ['en', ...locales]) {
          final strings = _strings('lib/l10n/app_$locale.arb');
          final text = strings['madeWithLove'] ?? strings['aboutMadeWithLove'];
          if (text != null) {
            expect(
              text.contains('{heart}'),
              isTrue,
              reason:
                  'app_$locale.arb madeWithLove is missing the {heart} marker',
            );
          }
        }
      },
    );
  });

  group('About JSON config parity tests', () {
    test('app_config.json has all three languages and valid detail labels', () {
      final file = File('assets/config/app_config.json');
      if (!file.existsSync()) return;

      final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      final enKeys = _keys('lib/l10n/app_en.arb');
      final problems = <String>[];

      void checkLanguages(String path, dynamic value) {
        if (value is Map<String, dynamic>) {
          for (final lang in ['en', 'ml', 'sa']) {
            final text = value[lang]?.toString().trim() ?? '';
            if (text.isEmpty) {
              problems.add('$path.$lang is missing or empty');
            }
          }
        }
      }

      checkLanguages('appName', json['appName']);
      checkLanguages('description', json['description']);

      final details = json['details'];
      if (details is Map<String, dynamic>) {
        for (final entry in details.entries) {
          final id = entry.key;
          checkLanguages('details.$id', entry.value);

          // Details key is lowerCamelCase; label in ARB is aboutDetail<Key>
          final labelKey =
              'aboutDetail${id[0].toUpperCase()}${id.substring(1)}';
          if (!enKeys.contains(labelKey)) {
            problems.add(
              'details.$id has no corresponding ARB key "$labelKey"',
            );
          }
        }
      }

      expect(problems, isEmpty, reason: problems.join('\n'));
    });
  });

  group('Content asset parity tests', () {
    test('content and help assets exist in all three languages', () {
      final assetsDir = Directory('assets');
      if (!assetsDir.existsSync()) return;

      final problems = <String>[];
      final enFiles = assetsDir
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => RegExp(r'_en\.[^.]+$').hasMatch(f.path));

      for (final enFile in enFiles) {
        for (final lang in locales) {
          final twinPath = enFile.path.replaceAllMapped(
            RegExp(r'_en(\.[^.]+)$'),
            (match) => '_$lang${match[1]}',
          );
          if (!File(twinPath).existsSync()) {
            problems.add(
              'Missing localized asset: $twinPath (matching ${enFile.path})',
            );
          }
        }
      }

      expect(problems, isEmpty, reason: problems.join('\n'));
    });
  });
}

Set<String> _keys(String path) =>
    (jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>).keys
        .where((k) => !k.startsWith('@'))
        .toSet();

Map<String, String> _strings(String path) {
  final raw = jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
  return {
    for (final e in raw.entries)
      if (!e.key.startsWith('@') && e.value is String) e.key: e.value as String,
  };
}
