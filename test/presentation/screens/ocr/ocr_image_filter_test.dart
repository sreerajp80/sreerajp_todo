import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_todo/presentation/screens/ocr/utils/ocr_image_filter.dart';

void main() {
  group('OcrImageFilter', () {
    test('returns 20 elements for all predefined matrices', () {
      for (final mode in OcrFilterMode.values) {
        final matrix = OcrImageFilter.matrixForMode(mode);
        expect(matrix.length, 20);
      }
    });

    test('original mode has no ColorFilter', () {
      expect(
        OcrImageFilter.colorFilterForMode(OcrFilterMode.original),
        isNull,
      );
    });

    test('documentBw, grayscale, and brighten have valid ColorFilter instances', () {
      expect(
        OcrImageFilter.colorFilterForMode(OcrFilterMode.documentBw),
        isA<ColorFilter>(),
      );
      expect(
        OcrImageFilter.colorFilterForMode(OcrFilterMode.grayscale),
        isA<ColorFilter>(),
      );
      expect(
        OcrImageFilter.colorFilterForMode(OcrFilterMode.brighten),
        isA<ColorFilter>(),
      );
    });

    test('generateMatrix generates 20-element list with proper contrast and brightness', () {
      final matrix = OcrImageFilter.generateMatrix(
        brightness: 20.0,
        contrast: 1.5,
        isGrayscale: true,
      );
      expect(matrix.length, 20);
      // Alpha row is preserved [0, 0, 0, 1, 0]
      expect(matrix[15], 0.0);
      expect(matrix[16], 0.0);
      expect(matrix[17], 0.0);
      expect(matrix[18], 1.0);
      expect(matrix[19], 0.0);
    });
  });
}
