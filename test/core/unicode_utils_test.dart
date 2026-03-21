import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_todo/core/utils/unicode_utils.dart';

void main() {
  group('nfcNormalize', () {
    test('normalises NFC-decomposed to composed', () {
      // é as e + combining acute accent (NFD) → é as single code point (NFC)
      const decomposed = '\u0065\u0301'; // e + ◌́
      const composed = '\u00E9'; // é
      expect(nfcNormalize(decomposed), composed);
    });

    test('already NFC string is unchanged', () {
      const s = 'Hello World';
      expect(nfcNormalize(s), s);
    });

    test('handles empty string', () {
      expect(nfcNormalize(''), '');
    });

    test('handles emoji', () {
      const emoji = '👍🏽';
      expect(nfcNormalize(emoji), isNotEmpty);
    });

    test('handles CJK characters', () {
      const cjk = '漢字テスト';
      expect(nfcNormalize(cjk), cjk);
    });

    test('handles Devanagari', () {
      const devanagari = 'हिन्दी';
      expect(nfcNormalize(devanagari), isNotEmpty);
    });

    test(
      'NFC equivalence: decomposed and composed compare equal after normalisation',
      () {
        const a = '\u00F1'; // ñ (NFC)
        const b = '\u006E\u0303'; // n + ◌̃ (NFD)
        expect(nfcNormalize(a), nfcNormalize(b));
      },
    );

    test('composes Hangul Jamo', () {
      const decomposed = '\u1112\u1161\u11AB'; // ㅎ + ㅏ + ㄴ
      const composed = '\uD55C'; // 한
      expect(nfcNormalize(decomposed), composed);
    });
  });

  group('detectTextDirection', () {
    test('detects LTR for Latin text', () {
      expect(detectTextDirection('Hello'), TextDirection.ltr);
    });

    test('detects RTL for Arabic text', () {
      expect(detectTextDirection('مرحبا'), TextDirection.rtl);
    });

    test('detects RTL for Hebrew text', () {
      expect(detectTextDirection('שלום'), TextDirection.rtl);
    });

    test('returns null for empty string', () {
      expect(detectTextDirection(''), isNull);
    });

    test('returns null for digits only', () {
      expect(detectTextDirection('12345'), isNull);
    });

    test('detects LTR for CJK', () {
      expect(detectTextDirection('漢字'), TextDirection.ltr);
    });

    test('detects LTR for Devanagari', () {
      expect(detectTextDirection('हिन्दी'), TextDirection.ltr);
    });

    test('uses first strong character for mixed text', () {
      expect(detectTextDirection('123Hello'), TextDirection.ltr);
      expect(detectTextDirection('123مرحبا'), TextDirection.rtl);
    });
  });
}
