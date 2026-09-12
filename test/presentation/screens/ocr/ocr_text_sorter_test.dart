import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_todo/core/utils/ocr_task_parser.dart';
import 'package:sreerajp_todo/presentation/screens/ocr/utils/ocr_text_sorter.dart';

void main() {
  group('OcrTextSorter', () {
    test('sorts lines out of order back to top-to-bottom natural order', () {
      // Simulating ML Kit detecting the bottom sentence first and top title second
      final items = [
        const OcrLineItem(
          text: 'An android app that tells about your battery',
          boundingBox: Rect.fromLTWH(20, 200, 300, 30),
        ),
        const OcrLineItem(
          text: 'Battery Soul',
          boundingBox: Rect.fromLTWH(20, 50, 150, 30),
        ),
      ];

      final sortedText = OcrTextSorter.sortLineItems(items);

      expect(
        sortedText,
        'Battery Soul\n\nAn android app that tells about your battery',
      );

      // Verify that OcrTaskParser correctly identifies title and description
      final taskResult = OcrTaskParser.parse(sortedText);
      expect(taskResult.title, 'Battery Soul');
      expect(
        taskResult.description,
        'An android app that tells about your battery',
      );
    });

    test('sorts same-row text left-to-right', () {
      final items = [
        const OcrLineItem(
          text: 'Right Column',
          boundingBox: Rect.fromLTWH(200, 50, 100, 25),
        ),
        const OcrLineItem(
          text: 'Left Column',
          boundingBox: Rect.fromLTWH(30, 52, 100, 25),
        ),
      ];

      final sortedText = OcrTextSorter.sortLineItems(items);
      expect(sortedText, 'Left Column\nRight Column');
    });

    test('keeps consecutive lines without large gap as single newline', () {
      final items = [
        const OcrLineItem(
          text: 'First line',
          boundingBox: Rect.fromLTWH(20, 50, 100, 20),
        ),
        const OcrLineItem(
          text: 'Second line directly under',
          boundingBox: Rect.fromLTWH(20, 75, 200, 20),
        ),
      ];

      final sortedText = OcrTextSorter.sortLineItems(items);
      expect(sortedText, 'First line\nSecond line directly under');
    });

    test('handles empty list gracefully', () {
      expect(OcrTextSorter.sortLineItems([]), '');
    });
  });
}
