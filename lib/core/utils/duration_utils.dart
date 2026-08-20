import 'package:sreerajp_todo/core/utils/time_tracking_rules.dart';

/// Formats [seconds] for display.
///
/// The defaults reproduce the original `HH:MM:SS` with no rounding, so every
/// existing call site keeps its old output. Screens that follow the user's
/// time-tracking settings pass [rounding] and [format].
///
/// [rounding] only ever changes what is shown. Stored segment seconds are
/// never rewritten.
String formatDuration(
  int seconds, {
  DurationRounding rounding = DurationRounding.off,
  DurationFormat format = DurationFormat.hhmmss,
}) {
  final value = roundSecondsForDisplay(seconds, rounding);

  switch (format) {
    case DurationFormat.hhmmss:
      final h = value ~/ 3600;
      final m = (value % 3600) ~/ 60;
      final s = value % 60;
      return '${_pad(h)}:${_pad(m)}:${_pad(s)}';
    case DurationFormat.hhmm:
      final h = value ~/ 3600;
      final m = (value % 3600) ~/ 60;
      return '${_pad(h)}:${_pad(m)}';
    case DurationFormat.decimalHours:
      final hours = value / 3600;
      return '${hours.toStringAsFixed(2)} h';
  }
}

String _pad(int value) => value.toString().padLeft(2, '0');

int durationInSeconds(DateTime start, DateTime end) =>
    end.difference(start).inSeconds;
