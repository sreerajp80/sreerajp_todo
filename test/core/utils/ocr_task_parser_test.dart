import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_todo/core/utils/ocr_task_parser.dart';
import 'package:sreerajp_todo/domain/entities/ocr_task_result.dart';

void main() {
  group('OcrTaskParser', () {
    test('returns empty result for empty or whitespace text', () {
      expect(OcrTaskParser.parse('').isEmpty, isTrue);
      expect(OcrTaskParser.parse('   \n  \t  \n').isEmpty, isTrue);
    });

    test('parses single line as title with empty description', () {
      final result = OcrTaskParser.parse('Buy groceries');
      expect(result.title, 'Buy groceries');
      expect(result.description, '');
      expect(result.hasSeparator, isFalse);
      expect(result.separatorType, OcrSeparatorType.none);
    });

    test('parses two lines separated by space (empty line)', () {
      const input = '''
Buy groceries

Milk, bread, eggs, and apples.
Remember reusable bags.
''';
      final result = OcrTaskParser.parse(input);
      expect(result.title, 'Buy groceries');
      expect(
        result.description,
        'Milk, bread, eggs, and apples.\nRemember reusable bags.',
      );
      expect(result.hasSeparator, isTrue);
      expect(result.separatorType, OcrSeparatorType.space);
    });

    test('parses lines separated by hash line (# or ###)', () {
      const input = '''
Finish quarterly report
###
Include Q1 revenue charts.
Verify audit notes with team.
''';
      final result = OcrTaskParser.parse(input);
      expect(result.title, 'Finish quarterly report');
      expect(
        result.description,
        'Include Q1 revenue charts.\nVerify audit notes with team.',
      );
      expect(result.hasSeparator, isTrue);
      expect(result.separatorType, OcrSeparatorType.hash);
    });

    test('parses lines separated by dashed line (--- or ___ or ===)', () {
      const input = '''
Review pull requests
---
Check test coverage for AirQR and OCR.
Verify zero lint warnings.
''';
      final result = OcrTaskParser.parse(input);
      expect(result.title, 'Review pull requests');
      expect(
        result.description,
        'Check test coverage for AirQR and OCR.\nVerify zero lint warnings.',
      );
      expect(result.hasSeparator, isTrue);
      expect(result.separatorType, OcrSeparatorType.dashed);
    });

    test('handles dashed line with underscores or spaces', () {
      const input = '''
Doctor appointment
_ _ _
Bring previous medical reports.
''';
      final result = OcrTaskParser.parse(input);
      expect(result.title, 'Doctor appointment');
      expect(result.description, 'Bring previous medical reports.');
      expect(result.hasSeparator, isTrue);
      expect(result.separatorType, OcrSeparatorType.dashed);
    });

    test(
      'falls back to line 1 as title and subsequent lines as description when no separator',
      () {
        const input = '''
Fix roof leak
Inspect shingles near chimney
Apply sealant
''';
        final result = OcrTaskParser.parse(input);
        expect(result.title, 'Fix roof leak');
        expect(
          result.description,
          'Inspect shingles near chimney\nApply sealant',
        );
        expect(result.hasSeparator, isFalse);
        expect(result.separatorType, OcrSeparatorType.none);
      },
    );

    test('strips leading markdown header hashes from title', () {
      const input = '''
# Weekly Planning
---
Set goals for sprint 14.
''';
      final result = OcrTaskParser.parse(input);
      expect(result.title, 'Weekly Planning');
      expect(result.description, 'Set goals for sprint 14.');
    });

    test('preserves unicode NFC normalization and Malayalam script', () {
      const input = '''
പലചരക്ക് വാങ്ങുക
---
അരി, പഞ്ചസാര, തേയില
''';
      final result = OcrTaskParser.parse(input);
      expect(result.title, 'പലചരക്ക് വാങ്ങുക');
      expect(result.description, 'അരി, പഞ്ചസാര, തേയില');
      expect(result.hasSeparator, isTrue);
    });

    test('ignores leading empty lines before title', () {
      const input = '''


Important Meeting
#
Discuss project scope
''';
      final result = OcrTaskParser.parse(input);
      expect(result.title, 'Important Meeting');
      expect(result.description, 'Discuss project scope');
      expect(result.hasSeparator, isTrue);
      expect(result.separatorType, OcrSeparatorType.hash);
    });
  });
}
