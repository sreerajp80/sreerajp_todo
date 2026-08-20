/// Pure Dart rules behind the Task defaults settings.
///
/// No Flutter imports, so every rule here can be unit tested on its own.
library;

/// The status a brand new task starts in.
///
/// Only two of the five `TodoStatus` values make sense for a task that does not
/// exist yet, so this is a small enum of its own rather than the full status
/// list. Picking [working] pre-selects the status but never starts a timer.
enum NewTaskStatus { pending, working }

/// The target time pre-filled on a new task.
///
/// A fixed list of common lengths, because this is a default and not the real
/// picker — the create/edit form still lets any target be typed.
enum DefaultTargetTime {
  none(0),
  fifteenMinutes(15),
  thirtyMinutes(30),
  fortyFiveMinutes(45),
  oneHour(60),
  ninetyMinutes(90),
  twoHours(120);

  const DefaultTargetTime(this.minutes);

  /// How long this option is, in minutes. Zero means "no target".
  final int minutes;

  /// The value written to `todos.target_seconds`, or null for "no target".
  int? get seconds => minutes == 0 ? null : minutes * 60;
}

/// How many title suggestions the autocomplete field may show.
enum SuggestionCount {
  five(5),
  ten(10),
  twenty(20),
  fifty(50);

  const SuggestionCount(this.limit);

  /// The SQL `LIMIT` applied to the prefix query.
  final int limit;
}

/// How far back the carry-over sheet looks for unfinished tasks.
enum CarryOverLookBack {
  /// Only the day before today.
  previousDay(1),

  /// Today minus one through today minus seven.
  lastSevenDays(7);

  const CarryOverLookBack(this.days);

  /// How many days before today are searched.
  final int days;
}

/// Whether the carry-over sheet should be offered on [todayIso].
///
/// [lastAskedIso] is the day the sheet was last shown, as `yyyy-MM-dd`, or null
/// if it has never been shown. The sheet appears at most once per day, so this
/// is simply "have we already asked today".
///
/// A stored date in the future — which can only come from a clock change — is
/// treated as "not asked today", so a wrong clock can never lock the sheet out
/// for good.
bool shouldAskCarryOver({
  required bool enabled,
  required String? lastAskedIso,
  required String todayIso,
}) {
  if (!enabled) return false;
  if (lastAskedIso == null || lastAskedIso.isEmpty) return true;
  return lastAskedIso != todayIso;
}

/// Splits [totalSeconds] into whole hours and the leftover whole minutes.
///
/// Used by the target time picker, which shows two number fields rather than a
/// clock. Seconds below a minute are dropped, because a target is never set
/// that finely.
({int hours, int minutes}) splitTargetSeconds(int? totalSeconds) {
  if (totalSeconds == null || totalSeconds <= 0) {
    return (hours: 0, minutes: 0);
  }
  final totalMinutes = totalSeconds ~/ 60;
  return (hours: totalMinutes ~/ 60, minutes: totalMinutes % 60);
}

/// Builds a `target_seconds` value from a picker's hours and minutes.
///
/// Returns null when both are zero, which is how "no target" is stored.
int? joinTargetSeconds({required int hours, required int minutes}) {
  final total = (hours * 60 + minutes) * 60;
  return total <= 0 ? null : total;
}
