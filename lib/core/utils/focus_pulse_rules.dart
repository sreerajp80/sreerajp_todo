// Pure Dart rules for the focus pulse, the gentle nudge that fires while a
// timer runs so the user notices time passing.
//
// Like `time_tracking_rules.dart`, this file has no Flutter imports, so every
// rule can be unit tested without a widget binding.

/// What the app does when a focus pulse falls due.
enum FocusPulseMode {
  /// Nothing happens. This is the default.
  off,

  /// A short vibration only.
  vibration,

  /// A short system chime only.
  sound,

  /// Both a vibration and a chime.
  both;

  /// True when this mode makes the device vibrate.
  bool get hasVibration =>
      this == FocusPulseMode.vibration || this == FocusPulseMode.both;

  /// True when this mode plays a sound.
  bool get hasSound =>
      this == FocusPulseMode.sound || this == FocusPulseMode.both;

  /// True when a pulse should ever fire at all.
  bool get isOn => this != FocusPulseMode.off;
}

/// The shortest gap allowed between two pulses, in minutes.
const int kFocusPulseMinMinutes = 5;

/// The longest gap allowed between two pulses, in minutes.
const int kFocusPulseMaxMinutes = 120;

/// The step the settings page moves the gap by, in minutes.
const int kFocusPulseStepMinutes = 5;

/// The moment of the next pulse for a timer that started at [startedAt], seen
/// from [now], with a gap of [gap].
///
/// Pulses are counted from the start of the running segment, so "every 30
/// minutes" means 30 minutes of tracked work rather than 30 minutes of app
/// uptime. Because the answer is worked out from the clock every time, a spell
/// in the background can never make the schedule drift.
///
/// The gap is a [Duration] rather than a number of minutes so a test can use a
/// gap of a few milliseconds and still exercise the real scheduling path.
///
/// Returns null when [gap] is not a usable gap.
DateTime? nextFocusPulseAfter(DateTime startedAt, DateTime now, Duration gap) {
  if (gap <= Duration.zero) return null;

  final elapsed = now.difference(startedAt);
  if (elapsed.isNegative) return startedAt.add(gap);

  // How many whole gaps have gone by, then move on to the one after it. Using
  // `+ 1` on the whole count means a pulse due at this exact moment is treated
  // as already given, so the same pulse never fires twice.
  final gapsGone = elapsed.inMicroseconds ~/ gap.inMicroseconds;
  return startedAt.add(gap * (gapsGone + 1));
}
