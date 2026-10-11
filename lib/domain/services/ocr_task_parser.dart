import 'package:sreerajp_todo/core/utils/unicode_utils.dart' as unicode_utils;
import 'package:sreerajp_todo/domain/entities/ocr_task_result.dart';

/// Parses raw OCR recognized text into a task name (title) and description.
///
/// Specification:
/// - First non-empty line is the task name.
/// - Separator can be:
///   - Space (one or more blank / empty lines)
///   - Hash line (one or more '#' characters, e.g. '#', '##', '###')
///   - Dashed line (two or more dashes, underscores, or equals, e.g. '---', '___', '===')
/// - Everything after the separator is the task description.
/// - If no separator is present, line 1 is the task name and subsequent lines
///   form the description.
/// - Both title and description are Unicode NFC normalized.
class OcrTaskParser {
  OcrTaskParser._();

  static final _hashPattern = RegExp(r'^#+(\s*#+)*$');
  static final _dashedPattern = RegExp(r'^([-_=]\s*){2,}$');
  static final _markdownHeaderPattern = RegExp(r'^#+\s+');

  /// Parses [rawText] into an [OcrTaskResult].
  static OcrTaskResult parse(String rawText) {
    if (rawText.trim().isEmpty) {
      return const OcrTaskResult.empty();
    }

    final rawLines = rawText.split(RegExp(r'\r?\n'));

    // Find the first non-empty line (the task title)
    int firstNonEmptyIdx = -1;
    for (int i = 0; i < rawLines.length; i++) {
      if (rawLines[i].trim().isNotEmpty) {
        firstNonEmptyIdx = i;
        break;
      }
    }

    if (firstNonEmptyIdx == -1) {
      return const OcrTaskResult.empty();
    }

    // Extract title from the first line
    String title = rawLines[firstNonEmptyIdx].trim();
    // Clean leading markdown heading hashes (e.g. "# Task Title" -> "Task Title")
    if (_markdownHeaderPattern.hasMatch(title)) {
      title = title.replaceFirst(_markdownHeaderPattern, '').trim();
    }

    // Look for separator after the first line
    int separatorIdx = -1;
    OcrSeparatorType separatorType = OcrSeparatorType.none;

    for (int i = firstNonEmptyIdx + 1; i < rawLines.length; i++) {
      final line = rawLines[i].trim();

      if (line.isEmpty) {
        // Only treat as space separator if there is at least one non-empty line following it
        final hasFollowingContent = rawLines
            .skip(i + 1)
            .any((l) => l.trim().isNotEmpty);
        if (hasFollowingContent) {
          separatorIdx = i;
          separatorType = OcrSeparatorType.space;
          break;
        }
      } else if (_hashPattern.hasMatch(line)) {
        separatorIdx = i;
        separatorType = OcrSeparatorType.hash;
        break;
      } else if (_dashedPattern.hasMatch(line)) {
        separatorIdx = i;
        separatorType = OcrSeparatorType.dashed;
        break;
      }
    }

    String description = '';
    final hasSeparator = separatorIdx != -1;

    if (hasSeparator) {
      // Everything after the separator line is part of the description
      final descLines = <String>[];
      for (int i = separatorIdx + 1; i < rawLines.length; i++) {
        descLines.add(rawLines[i]);
      }
      description = descLines.join('\n').trim();
    } else {
      // No explicit separator line found.
      // If there are subsequent lines, join them as description.
      if (firstNonEmptyIdx + 1 < rawLines.length) {
        final descLines = <String>[];
        for (int i = firstNonEmptyIdx + 1; i < rawLines.length; i++) {
          descLines.add(rawLines[i]);
        }
        description = descLines.join('\n').trim();
      }
    }

    // Apply NFC normalization per project Hard Rule #2
    final normalizedTitle = unicode_utils.nfcNormalize(title);
    final normalizedDescription = unicode_utils.nfcNormalize(description);

    return OcrTaskResult(
      title: normalizedTitle,
      description: normalizedDescription,
      rawText: rawText,
      hasSeparator: hasSeparator,
      separatorType: separatorType,
    );
  }
}
