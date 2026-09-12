import 'package:flutter/foundation.dart';

/// The type of separator detected between the task name and description.
enum OcrSeparatorType { none, space, hash, dashed }

/// Represents the parsed result of an OCR text recognition operation.
@immutable
class OcrTaskResult {
  final String title;
  final String description;
  final String rawText;
  final bool hasSeparator;
  final OcrSeparatorType separatorType;

  const OcrTaskResult({
    required this.title,
    required this.description,
    required this.rawText,
    this.hasSeparator = false,
    this.separatorType = OcrSeparatorType.none,
  });

  const OcrTaskResult.empty()
    : title = '',
      description = '',
      rawText = '',
      hasSeparator = false,
      separatorType = OcrSeparatorType.none;

  bool get isEmpty => title.trim().isEmpty && description.trim().isEmpty;
  bool get isNotEmpty => !isEmpty;

  OcrTaskResult copyWith({
    String? title,
    String? description,
    String? rawText,
    bool? hasSeparator,
    OcrSeparatorType? separatorType,
  }) {
    return OcrTaskResult(
      title: title ?? this.title,
      description: description ?? this.description,
      rawText: rawText ?? this.rawText,
      hasSeparator: hasSeparator ?? this.hasSeparator,
      separatorType: separatorType ?? this.separatorType,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OcrTaskResult &&
          runtimeType == other.runtimeType &&
          title == other.title &&
          description == other.description &&
          rawText == other.rawText &&
          hasSeparator == other.hasSeparator &&
          separatorType == other.separatorType;

  @override
  int get hashCode =>
      title.hashCode ^
      description.hashCode ^
      rawText.hashCode ^
      hasSeparator.hashCode ^
      separatorType.hashCode;

  @override
  String toString() =>
      'OcrTaskResult(title: "$title", description: "$description", hasSeparator: $hasSeparator, separatorType: $separatorType)';
}
