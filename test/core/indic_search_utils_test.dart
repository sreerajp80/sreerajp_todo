import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_todo/core/utils/indic_search_utils.dart';

void main() {
  // Written out as escapes so the intent stays readable and the test file
  // cannot be silently "fixed" by an editor normalising the characters.
  const String virama = '്';
  const String zwj = '‍';
  const String zwnj = '‌';

  // "മലയാളം" needs no joiners; these words do.
  const String naSequence = 'ന$virama$zwj'; // ന + virama + ZWJ
  const String naAtomic = 'ൻ'; // ൻ
  const String raSequence = 'ര$virama$zwj'; // ര + virama + ZWJ
  const String raAtomic = 'ർ'; // ർ

  group('foldForSearch - Chillu unification', () {
    test('consonant + virama + ZWJ folds to the atomic Chillu letter', () {
      expect(foldForSearch(naSequence), foldForSearch(naAtomic));
      expect(foldForSearch(raSequence), foldForSearch(raAtomic));
    });

    test('folds every supported Chillu consonant', () {
      for (final MapEntry<String, String> entry in kChilluByConsonant.entries) {
        final String sequence = '${entry.key}$kMalayalamVirama$kZwj';
        expect(
          foldForSearch(sequence),
          foldForSearch(entry.value),
          reason: 'Chillu for ${entry.key} did not unify',
        );
      }
    });

    test('the two spellings of a whole word match', () {
      const String sequenceWord = 'അവ$naSequence';
      const String atomicWord = 'അവ$naAtomic';
      expect(foldedEquals(sequenceWord, atomicWord), isTrue);
    });

    test('a bare virama is left alone', () {
      const String word = 'ക്ക'; // ക്ക
      expect(foldForSearch(word), word);
    });
  });

  group('foldForSearch - joiners', () {
    test('drops a stray ZWJ', () {
      expect(foldForSearch('abc${zwj}def'), 'abcdef');
    });

    test('drops a stray ZWNJ', () {
      expect(foldForSearch('abc${zwnj}def'), 'abcdef');
    });
  });

  group('foldForSearch - Latin accents and case', () {
    test('strips Latin accents', () {
      expect(foldForSearch('café'), 'cafe');
      expect(foldedEquals('résumé', 'resume'), isTrue);
    });

    test('lower-cases', () {
      expect(foldForSearch('Buy MILK'), 'buy milk');
    });

    test('collapses runs of whitespace and trims', () {
      expect(foldForSearch('  buy   fresh \n milk '), 'buy fresh milk');
    });

    test('keeps Malayalam vowel signs, which change the word', () {
      const String withSign = 'കാ'; // കാ
      const String withoutSign = 'ക'; // ക
      expect(foldForSearch(withSign), isNot(foldForSearch(withoutSign)));
    });

    test('empty input folds to an empty string', () {
      expect(foldForSearch(''), '');
      expect(foldForSearch('   '), '');
    });
  });

  group('buildFtsMatchQuery', () {
    test('returns empty for blank input', () {
      expect(buildFtsMatchQuery(''), '');
      expect(buildFtsMatchQuery('   '), '');
    });

    test('builds AND-joined prefix terms from folded words', () {
      expect(buildFtsMatchQuery('Buy Milk'), '"buy"* AND "milk"*');
    });

    test('folds the query the same way as stored text', () {
      expect(buildFtsMatchQuery(naSequence), buildFtsMatchQuery(naAtomic));
    });

    test('treats a fully quoted input as one phrase', () {
      expect(buildFtsMatchQuery('"buy fresh milk"'), '"buy fresh milk"');
    });

    test('strips FTS5 syntax characters instead of passing them through', () {
      final String query = buildFtsMatchQuery('buy* (milk)');
      expect(query.contains('('), isFalse);
      expect(query, '"buy"* AND "milk"*');
    });

    test('returns empty when only syntax characters are given', () {
      expect(buildFtsMatchQuery('***'), '');
    });
  });
}
