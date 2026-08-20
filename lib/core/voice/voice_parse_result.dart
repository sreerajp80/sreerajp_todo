/// What a spoken or typed sentence was understood to mean.
///
/// Pure Dart on purpose: this file lives in `core/` and must not import
/// Flutter, `sqflite`, or anything from `data/`. The priority is mirrored as
/// [VoicePriority] rather than reusing `TodoPriority` so the layer rule holds;
/// the two enums share their value names, so mapping is a name lookup.
library;

/// How important the sentence said the task is.
///
/// The names match `TodoPriority` exactly, so the presentation layer can map
/// one to the other by name without a switch that can drift.
enum VoicePriority { low, normal, high, urgent }

/// The pieces a sentence can carry, used to show the user what was picked up.
enum VoiceField { date, timeOfDay, target, priority }

/// The result of running [VoiceCommandParser] over one sentence.
class VoiceParseResult {
  const VoiceParseResult({
    required this.rawText,
    required this.title,
    required this.date,
    this.hour,
    this.minute = 0,
    this.targetSeconds,
    this.priority,
    this.dateWasClamped = false,
    this.matched = const <VoiceField>{},
  });

  /// The sentence as it was given, after NFC normalisation.
  final String rawText;

  /// The task title left over once every understood part was taken out.
  ///
  /// Never empty for a sentence that had words in it. If every word was
  /// understood as a date or a time, the whole sentence is kept as the title
  /// rather than handing back a blank task. An empty sentence gives an empty
  /// title, which the caller treats as "nothing to create".
  final String title;

  /// The day the task belongs to, as `yyyy-MM-dd`.
  ///
  /// Always today or later. A sentence that names a past day is moved forward
  /// to today, because Day-Lock makes past days read-only.
  final String date;

  /// The hour of day, 0 to 23, or null when no time was said.
  ///
  /// The task table has no time-of-day column, so this is only ever shown to
  /// the user and written into the description as a short note.
  final int? hour;

  /// The minute of the hour, 0 to 59. Meaningless while [hour] is null.
  final int minute;

  /// The tracking target in seconds, or null when no duration was said.
  final int? targetSeconds;

  /// The priority the sentence asked for, or null when it said nothing.
  final VoicePriority? priority;

  /// True when a named day had already passed and was moved to today.
  final bool dateWasClamped;

  /// Which parts of the sentence were understood.
  final Set<VoiceField> matched;

  /// True when a time of day was said.
  bool get hasTimeOfDay => hour != null;

  /// The time of day as `HH:mm`, or null when no time was said.
  String? get timeOfDayLabel {
    final h = hour;
    if (h == null) return null;
    return '${_two(h)}:${_two(minute)}';
  }

  /// True when nothing beyond a title was understood.
  bool get isTitleOnly => matched.isEmpty;

  static String _two(int value) => value.toString().padLeft(2, '0');
}
