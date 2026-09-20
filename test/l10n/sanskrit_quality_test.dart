import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:unorm_dart/unorm_dart.dart' as unorm;

void main() {
  group('Sanskrit ARB Quality and Parity (§8.5)', () {
    late Map<String, dynamic> enArb;
    late Map<String, dynamic> saArb;
    late List<String> enKeys;
    late List<String> saKeys;

    setUpAll(() {
      final enFile = File('lib/l10n/app_en.arb');
      final saFile = File('lib/l10n/app_sa.arb');

      expect(enFile.existsSync(), isTrue);
      expect(saFile.existsSync(), isTrue);

      enArb = jsonDecode(enFile.readAsStringSync()) as Map<String, dynamic>;
      saArb = jsonDecode(saFile.readAsStringSync()) as Map<String, dynamic>;

      enKeys = enArb.keys.where((k) => !k.startsWith('@')).toList();
      saKeys = saArb.keys.where((k) => !k.startsWith('@')).toList();
    });

    test('app_sa.arb declares @@locale as sa', () {
      expect(saArb['@@locale'], 'sa');
    });

    test('100% key parity with app_en.arb', () {
      final missingInSa = enKeys.where((k) => !saArb.containsKey(k)).toList();
      final extraInSa = saKeys.where((k) => !enArb.containsKey(k)).toList();

      expect(
        missingInSa,
        isEmpty,
        reason: 'Keys missing in app_sa.arb: ${missingInSa.join(", ")}',
      );
      expect(
        extraInSa,
        isEmpty,
        reason: 'Extra keys in app_sa.arb: ${extraInSa.join(", ")}',
      );
    });

    test('no empty translations in app_sa.arb', () {
      final emptyKeys = <String>[];
      for (final key in saKeys) {
        final val = saArb[key]?.toString().trim() ?? '';
        if (val.isEmpty) {
          emptyKeys.add(key);
        }
      }
      expect(emptyKeys, isEmpty, reason: 'Empty keys: ${emptyKeys.join(", ")}');
    });

    test('all placeholders from app_en.arb are present in app_sa.arb', () {
      final placeholderErrors = <String>[];

      for (final key in enKeys) {
        final meta = enArb['@$key'] as Map<String, dynamic>?;
        if (meta != null && meta.containsKey('placeholders')) {
          final placeholders =
              (meta['placeholders'] as Map<String, dynamic>).keys;
          final saText = saArb[key]?.toString() ?? '';

          for (final ph in placeholders) {
            final pattern = RegExp('\\{$ph\\b');
            if (!pattern.hasMatch(saText)) {
              placeholderErrors.add(
                'Key $key is missing placeholder {$ph}: "$saText"',
              );
            }
          }
        }
      }

      expect(placeholderErrors, isEmpty, reason: placeholderErrors.join('\n'));
    });

    test('all Sanskrit strings are NFC normalized', () {
      final nonNfc = <String>[];

      for (final key in saKeys) {
        final text = saArb[key]?.toString() ?? '';
        final nfc = unorm.nfc(text);
        if (text != nfc) {
          nonNfc.add(key);
        }
      }

      expect(
        nonNfc,
        isEmpty,
        reason: 'Non-NFC normalized keys: ${nonNfc.join(", ")}',
      );
    });

    test('zero Hindi markers and zero nuktas (§8.5.1)', () {
      final problems = <String>[];

      // Forbidden substrings: Hindi verb forms, auxiliaries, loans, nuktas
      final substringRegex = RegExp(
        r'करें|करना|करके|रहा|रही|रहे|गया|गयी|चाहिए|नहीं|लेकिन|क्या|कृपया|सेटिंग्स|ऐप|[\u093C\u0958-\u095F]',
      );

      // Standalone forbidden words
      const forbiddenWords = {'था', 'थे', 'थी', 'हो', 'है', 'हैं', 'हूं', 'और'};

      for (final key in saKeys) {
        // Skip card 14 Ramcharitmanas Avadhi quote if needed
        if (key == 'ritualCardSd14Quote') continue;

        final text = saArb[key]?.toString() ?? '';

        final subMatch = substringRegex.firstMatch(text);
        if (subMatch != null) {
          problems.add(
            'Forbidden substring "${subMatch.group(0)}" found in $key: "$text"',
          );
        }

        final tokens = text
            .split(RegExp(r'''[\s"'()\[\]{}<>।,.?!;:/|`#*~-]+'''))
            .where((t) => t.isNotEmpty)
            .toSet();

        final badTokens = tokens.intersection(forbiddenWords);
        if (badTokens.isNotEmpty) {
          problems.add(
            'Forbidden standalone word(s) $badTokens found in $key: "$text"',
          );
        }
      }

      expect(problems, isEmpty, reason: problems.join('\n'));
    });
  });
}
