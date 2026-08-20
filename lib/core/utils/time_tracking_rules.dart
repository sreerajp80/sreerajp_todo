// Pure Dart rules that drive the time-tracking settings.
//
// This file has no Flutter imports on purpose, so every rule can be unit
// tested without a widget binding. The enums live here rather than in the
// notifier so that `domain/` and `core/` can use them without depending on
// `application/`.

/// When a running timer should be closed on its own.
enum AutoStopMode {
  /// Never stop on its own. This is today's behaviour and the default.
  off,

  /// Stop at midnight, the end of the todo's own day.
  midnight,

  /// Stop at the hour and minute the user picked.
  customTime,
}

/// How a duration is rounded before it is shown in a report.
///
/// Rounding is display only. Stored segment seconds are never changed.
enum DurationRounding {
  /// Show the exact seconds. Default.
  off,

  /// Round to the nearest whole minute.
  nearestMinute,

  /// Round to the nearest 5 minutes.
  nearest5Minutes,

  /// Round to the nearest 15 minutes.
  nearest15Minutes;

  /// The rounding step in seconds, or null when rounding is off.
  int? get stepSeconds => switch (this) {
    DurationRounding.off => null,
    DurationRounding.nearestMinute => 60,
    DurationRounding.nearest5Minutes => 300,
    DurationRounding.nearest15Minutes => 900,
  };
}

/// How a duration is written out on screen.
enum DurationFormat {
  /// `01:23:45`. Default.
  hhmmss,

  /// `01:23`, seconds dropped.
  hhmm,

  /// `1.40 h`, decimal hours.
  decimalHours,
}

/// The shortest live segment that is worth keeping.
enum MinimumSegmentLength {
  /// Keep every segment, however short. Default.
  off,

  /// Discard anything under 10 seconds.
  tenSeconds,

  /// Discard anything under 30 seconds.
  thirtySeconds,

  /// Discard anything under 1 minute.
  oneMinute,

  /// Discard anything under 5 minutes.
  fiveMinutes;

  /// The limit in seconds. Zero means "keep everything".
  int get seconds => switch (this) {
    MinimumSegmentLength.off => 0,
    MinimumSegmentLength.tenSeconds => 10,
    MinimumSegmentLength.thirtySeconds => 30,
    MinimumSegmentLength.oneMinute => 60,
    MinimumSegmentLength.fiveMinutes => 300,
  };
}

/// The end time pre-filled in the manual time entry form.
enum ManualEntryDuration {
  /// 15 minutes.
  fifteenMinutes,

  /// 30 minutes.
  thirtyMinutes,

  /// 1 hour. Default.
  oneHour,

  /// 2 hours.
  twoHours;

  /// The gap in minutes between the picked start time and the filled end time.
  int get minutes => switch (this) {
    ManualEntryDuration.fifteenMinutes => 15,
    ManualEntryDuration.thirtyMinutes => 30,
    ManualEntryDuration.oneHour => 60,
    ManualEntryDuration.twoHours => 120,
  };
}

/// Rounds [seconds] for display using [rounding].
///
/// Rounds half away from zero, so 90 seconds at nearest-minute becomes 120.
/// A negative input is clamped to zero, because a negative tracked time is
/// always a bug rather than something to show.
int roundSecondsForDisplay(int seconds, DurationRounding rounding) {
  if (seconds <= 0) return 0;
  final step = rounding.stepSeconds;
  if (step == null) return seconds;
  return ((seconds + step ~/ 2) ~/ step) * step;
}

/// True when a live segment of [seconds] is too short to keep under [limit].
///
/// Only ever asked about timers the user started and then stopped or paused.
/// Manual entries, imports and restored backups never go through this.
bool isSegmentTooShort(int seconds, MinimumSegmentLength limit) {
  final min = limit.seconds;
  if (min <= 0) return false;
  return seconds < min;
}

/// The next moment at or after [from] when a running timer should auto-stop,
/// or null when auto-stop is off.
///
/// [customHour] and [customMinute] are only read when [mode] is
/// [AutoStopMode.customTime]. When the custom time has already passed today,
/// the next one is tomorrow.
DateTime? nextAutoStopInstant(
  DateTime from,
  AutoStopMode mode, {
  int customHour = 0,
  int customMinute = 0,
}) {
  switch (mode) {
    case AutoStopMode.off:
      return null;
    case AutoStopMode.midnight:
      return DateTime(from.year, from.month, from.day + 1);
    case AutoStopMode.customTime:
      final todayAt = DateTime(
        from.year,
        from.month,
        from.day,
        customHour,
        customMinute,
      );
      if (todayAt.isAfter(from)) return todayAt;
      return DateTime(
        from.year,
        from.month,
        from.day + 1,
        customHour,
        customMinute,
      );
  }
}

/// The time an orphaned segment that started at [segmentStart] should be
/// closed at, or null when it should keep today's zero-length behaviour.
///
/// An orphan is an open segment left on a past day. With auto-stop on we can
/// say honestly when the timer should have stopped, so the real worked time is
/// kept instead of being thrown away.
///
/// [now] guards against writing an end time in the future, which would happen
/// if the device clock moved backwards.
DateTime? orphanCloseTime(
  DateTime segmentStart,
  DateTime now,
  AutoStopMode mode, {
  int customHour = 0,
  int customMinute = 0,
}) {
  final cutoff = nextAutoStopInstant(
    segmentStart,
    mode,
    customHour: customHour,
    customMinute: customMinute,
  );
  if (cutoff == null) return null;
  if (cutoff.isAfter(now)) return null;
  return cutoff;
}
