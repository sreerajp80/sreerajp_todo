import 'dart:ui';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// Lightweight representation of a recognized text line and its bounding box.
class OcrLineItem {
  const OcrLineItem({required this.text, required this.boundingBox});

  final String text;
  final Rect boundingBox;
}

/// Utility that sorts recognized OCR text geometrically from top-to-bottom
/// and left-to-right, preserving natural reading order and paragraph gaps.
class OcrTextSorter {
  OcrTextSorter._();

  /// Extracts and sorts all text lines from ML Kit [RecognizedText].
  static String sort(RecognizedText recognizedText) {
    if (recognizedText.blocks.isEmpty) {
      return recognizedText.text.trim();
    }

    final items = <OcrLineItem>[];
    for (final block in recognizedText.blocks) {
      for (final line in block.lines) {
        items.add(OcrLineItem(text: line.text, boundingBox: line.boundingBox));
      }
    }

    if (items.isEmpty) {
      return recognizedText.text.trim();
    }

    return sortLineItems(items);
  }

  /// Sorts a collection of [OcrLineItem]s geometrically.
  ///
  /// Lines sharing the same vertical band (within 50% line height) are
  /// treated as part of the same line row and sorted left-to-right.
  /// All other lines are sorted strictly top-to-bottom.
  ///
  /// If the vertical gap between consecutive lines exceeds standard line height,
  /// a blank line (`\n\n`) is preserved to signify a section / paragraph break.
  static String sortLineItems(List<OcrLineItem> items) {
    if (items.isEmpty) return '';

    // Copy to avoid mutating original list
    final sorted = List<OcrLineItem>.from(items);

    sorted.sort((a, b) {
      final aTop = a.boundingBox.top;
      final bTop = b.boundingBox.top;
      final aH = a.boundingBox.height;
      final bH = b.boundingBox.height;
      final avgH = (aH + bH) / 2;
      final threshold = avgH > 0 ? avgH * 0.5 : 10.0;

      if ((aTop - bTop).abs() <= threshold) {
        return a.boundingBox.left.compareTo(b.boundingBox.left);
      }
      return aTop.compareTo(bTop);
    });

    final buffer = StringBuffer();
    OcrLineItem? prevLine;

    for (final line in sorted) {
      final lineText = line.text.trim();
      if (lineText.isEmpty) continue;

      if (prevLine != null) {
        final prevBottom = prevLine.boundingBox.bottom;
        final currentTop = line.boundingBox.top;
        final prevHeight = prevLine.boundingBox.height;

        final verticalGap = currentTop - prevBottom;
        // If vertical gap is greater than ~1.1x line height, insert paragraph break
        if (prevHeight > 0 && verticalGap > prevHeight * 1.1) {
          buffer.write('\n\n');
        } else {
          buffer.write('\n');
        }
      }

      buffer.write(lineText);
      prevLine = line;
    }

    return buffer.toString().trim();
  }
}
