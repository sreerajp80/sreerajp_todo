import 'package:intl/intl.dart';
import 'package:sreerajp_todo/core/utils/date_format_rules.dart';
import 'package:sreerajp_todo/core/utils/date_utils.dart' as date_utils;
import 'package:sreerajp_todo/l10n/app_localizations.dart';
import 'package:table_calendar/table_calendar.dart';

/// Shared labels for the date and time settings values.
///
/// The settings pages and the calendar all name the same things, so the naming
/// lives in one place instead of being repeated.

/// A Monday that is only used to turn weekday numbers into names.
final DateTime _knownMonday = DateTime(2024, 1, 1);

/// The weekday name for [weekday], where 1 is Monday and 7 is Sunday.
///
/// Read from `intl` rather than the `.arb` files, so it always matches the
/// month and day names the rest of the app already prints.
String weekdayName(int weekday) {
  final date = _knownMonday.add(Duration(days: weekday - DateTime.monday));
  return DateFormat.EEEE().format(date);
}

/// The short weekday name, for tight rows.
String shortWeekdayName(int weekday) {
  final date = _knownMonday.add(Duration(days: weekday - DateTime.monday));
  return DateFormat.E().format(date);
}

/// The translated name of [value].
String weekStartName(AppLocalizations l10n, WeekStartDay value) {
  final weekday = value.weekdayNumber;
  if (weekday == null) return l10n.weekStartSystem;
  return weekdayName(weekday);
}

/// The translated name of [value], with a live sample of what it looks like.
String clockFormatName(AppLocalizations l10n, ClockFormat value) {
  return switch (value) {
    ClockFormat.system => l10n.clockFormatSystem,
    ClockFormat.twelveHour => l10n.clockFormat12,
    ClockFormat.twentyFourHour => l10n.clockFormat24,
  };
}

/// A sample time in [value], for example `2:30 PM`.
String clockFormatSample(ClockFormat value) {
  final sample = DateTime(2026, 8, 19, 14, 30);
  final pattern = value.timePattern;
  if (pattern == null) return DateFormat.jm().format(sample);
  return DateFormat(pattern).format(sample);
}

/// The translated name of [value].
String dateFormatName(AppLocalizations l10n, AppDateFormat value) {
  return switch (value) {
    AppDateFormat.system => l10n.dateFormatSystem,
    AppDateFormat.systemShort => l10n.dateFormatSystemShort,
    AppDateFormat.dayMonthYear => l10n.dateFormatDayMonthYear,
    AppDateFormat.monthDayYear => l10n.dateFormatMonthDayYear,
    AppDateFormat.dayMonthNameYear => l10n.dateFormatDayMonthNameYear,
    AppDateFormat.iso => l10n.dateFormatIso,
  };
}

/// Today written in [value], so the choice list shows the real result rather
/// than an abstract pattern.
String dateFormatSample(AppDateFormat value) {
  final today = DateTime.now();
  return switch (value) {
    AppDateFormat.system => DateFormat.yMMMEd().format(today),
    AppDateFormat.systemShort => DateFormat.yMd().format(today),
    _ => DateFormat(value.pattern).format(today),
  };
}

/// The label for a day-start hour, for example `4:00 AM`.
String dayStartHourLabel(AppLocalizations l10n, int hour) {
  if (hour == 0) return l10n.dayStartMidnight;
  return date_utils.formatTime(DateTime(2026, 8, 19, hour));
}

/// The `table_calendar` starting day for [value].
///
/// [WeekStartDay.system] has no direct match, so it falls back to Sunday,
/// which is what the calendar already used before this setting existed.
StartingDayOfWeek startingDayOfWeekFor(WeekStartDay value) {
  return switch (value) {
    WeekStartDay.system => StartingDayOfWeek.sunday,
    WeekStartDay.sunday => StartingDayOfWeek.sunday,
    WeekStartDay.monday => StartingDayOfWeek.monday,
    WeekStartDay.saturday => StartingDayOfWeek.saturday,
  };
}
