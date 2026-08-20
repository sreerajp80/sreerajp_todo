/// Pure Dart rules for the "Date & time" settings group.
///
/// Holds the choice lists and the small bits of logic behind them. No Flutter
/// import here, so `core/` stays framework free.
library;

/// Which day a week starts on in the calendar.
enum WeekStartDay {
  /// Follow whatever the device locale says.
  system,
  sunday,
  monday,
  saturday;

  /// The matching `DateTime` weekday number, or null for [system].
  ///
  /// `DateTime.monday` is 1 and `DateTime.sunday` is 7.
  int? get weekdayNumber => switch (this) {
    WeekStartDay.system => null,
    WeekStartDay.sunday => DateTime.sunday,
    WeekStartDay.monday => DateTime.monday,
    WeekStartDay.saturday => DateTime.saturday,
  };
}

/// Whether times show as `14:30` or `2:30 PM`.
enum ClockFormat {
  /// Follow whatever the device locale says.
  system,
  twelveHour,
  twentyFourHour;

  /// The `intl` skeleton for an hour-and-minute time, or null for [system].
  String? get timePattern => switch (this) {
    ClockFormat.system => null,
    ClockFormat.twelveHour => 'h:mm a',
    ClockFormat.twentyFourHour => 'HH:mm',
  };

  /// The same, with seconds.
  String? get timeWithSecondsPattern => switch (this) {
    ClockFormat.system => null,
    ClockFormat.twelveHour => 'h:mm:ss a',
    ClockFormat.twentyFourHour => 'HH:mm:ss',
  };
}

/// How a whole date reads on screen.
enum AppDateFormat {
  /// The locale's own medium form, for example `Wed, Aug 19, 2026`.
  system,

  /// The locale's own short form, for example `8/19/2026`.
  systemShort,

  /// `19/08/2026`.
  dayMonthYear,

  /// `08/19/2026`.
  monthDayYear,

  /// `19 Aug 2026`.
  dayMonthNameYear,

  /// `2026-08-19`.
  iso;

  /// The fixed `intl` pattern, or null when the locale decides.
  String? get pattern => switch (this) {
    AppDateFormat.system => null,
    AppDateFormat.systemShort => null,
    AppDateFormat.dayMonthYear => 'dd/MM/yyyy',
    AppDateFormat.monthDayYear => 'MM/dd/yyyy',
    AppDateFormat.dayMonthNameYear => 'd MMM yyyy',
    AppDateFormat.iso => 'yyyy-MM-dd',
  };
}

/// The hour a new day begins, for people who work past midnight.
///
/// Zero is plain midnight. Four means anything before 4 AM still counts as the
/// day before.
const int kMinDayStartHour = 0;

/// The latest day start the settings page offers. Kept below noon so a "day"
/// can never swallow more than half of the next one.
const int kMaxDayStartHour = 11;

/// Forces [hour] into the range the app allows.
int clampDayStartHour(int hour) {
  if (hour < kMinDayStartHour) return kMinDayStartHour;
  if (hour > kMaxDayStartHour) return kMaxDayStartHour;
  return hour;
}

/// The default working days: Monday to Friday.
const Set<int> kDefaultWorkingDays = <int>{
  DateTime.monday,
  DateTime.tuesday,
  DateTime.wednesday,
  DateTime.thursday,
  DateTime.friday,
};

/// Every weekday number, in the order a week is usually listed.
const List<int> kAllWeekdays = <int>[
  DateTime.monday,
  DateTime.tuesday,
  DateTime.wednesday,
  DateTime.thursday,
  DateTime.friday,
  DateTime.saturday,
  DateTime.sunday,
];

/// Reads a stored working-day set back from the string list kept in
/// preferences. Falls back to [kDefaultWorkingDays] when the stored value is
/// missing or unreadable, which can only happen after a downgrade or a
/// hand-edited file.
Set<int> parseWorkingDays(List<String>? stored) {
  if (stored == null) return kDefaultWorkingDays;
  final parsed = <int>{};
  for (final entry in stored) {
    final day = int.tryParse(entry);
    if (day != null && day >= DateTime.monday && day <= DateTime.sunday) {
      parsed.add(day);
    }
  }
  return parsed;
}

/// Turns a working-day set into the string list preferences can hold.
List<String> encodeWorkingDays(Set<int> days) {
  final sorted = days.toList()..sort();
  return [for (final day in sorted) '$day'];
}

/// Whether [date] falls on one of the chosen working days.
bool isWorkingDay(DateTime date, Set<int> workingDays) {
  return workingDays.contains(date.weekday);
}

/// Counts the working days in the inclusive range [from] to [to].
///
/// Statistics use this so a weekly average is not dragged down by days the
/// user never meant to work.
int countWorkingDays(DateTime from, DateTime to, Set<int> workingDays) {
  if (workingDays.isEmpty) return 0;
  if (to.isBefore(from)) return 0;

  var cursor = DateTime(from.year, from.month, from.day);
  final last = DateTime(to.year, to.month, to.day);
  var count = 0;
  while (!cursor.isAfter(last)) {
    if (workingDays.contains(cursor.weekday)) count++;
    cursor = cursor.add(const Duration(days: 1));
  }
  return count;
}
