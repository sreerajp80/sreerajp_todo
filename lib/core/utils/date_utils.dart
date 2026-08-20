import 'package:intl/intl.dart';
import 'package:sreerajp_todo/core/utils/date_format_rules.dart';

final _isoFormat = DateFormat('yyyy-MM-dd');

/// The hour a new day begins. Zero is plain midnight.
///
/// Held here rather than passed around because every date helper below needs
/// it and there are dozens of call sites. `main.dart` sets it once at startup
/// and `DateTimeSettingsNotifier` updates it whenever the user changes it.
int _dayStartHour = 0;

/// How dates read on screen.
AppDateFormat _dateFormat = AppDateFormat.system;

/// How times read on screen.
ClockFormat _clockFormat = ClockFormat.system;

/// Sets the hour a new day begins. Values outside the allowed range are
/// clamped, so a bad saved value can never shift the day by a wild amount.
void setDayStartHour(int hour) {
  _dayStartHour = clampDayStartHour(hour);
}

/// The hour a new day currently begins.
int get dayStartHour => _dayStartHour;

/// Sets the date style used by [formatDate] and [formatDateFromIso].
void setAppDateFormat(AppDateFormat format) {
  _dateFormat = format;
}

/// The date style in use.
AppDateFormat get appDateFormat => _dateFormat;

/// Sets the clock style used by [formatTime] and [formatDateTime].
void setClockFormat(ClockFormat format) {
  _clockFormat = format;
}

/// The clock style in use.
ClockFormat get clockFormat => _clockFormat;

/// "Now" shifted back by the day-start hour.
///
/// With a day start of 4 AM, 1 AM on the 20th reads as the 19th, so a person
/// working past midnight keeps writing to the day they think they are in and
/// the Day Lock rule does not close it early.
DateTime nowInAppDay() {
  if (_dayStartHour == 0) return DateTime.now();
  return DateTime.now().subtract(Duration(hours: _dayStartHour));
}

/// The same shift applied to any [moment], for callers that already hold a
/// timestamp.
DateTime toAppDay(DateTime moment) {
  if (_dayStartHour == 0) return moment;
  return moment.subtract(Duration(hours: _dayStartHour));
}

String todayAsIso() => _isoFormat.format(nowInAppDay());

bool isToday(String date) => date == todayAsIso();

bool isPastDate(String date) => date.compareTo(todayAsIso()) < 0;

bool isFutureDate(String date) => date.compareTo(todayAsIso()) > 0;

/// The date formatter for the chosen style. Built per call because the style
/// can change while the app is running.
DateFormat _dateFormatter() => switch (_dateFormat) {
  AppDateFormat.system => DateFormat.yMMMEd(),
  AppDateFormat.systemShort => DateFormat.yMd(),
  _ => DateFormat(_dateFormat.pattern),
};

/// A shorter date, used where space is tight such as chart labels.
DateFormat _shortDateFormatter() => switch (_dateFormat) {
  AppDateFormat.system => DateFormat.MMMd(),
  AppDateFormat.systemShort => DateFormat.Md(),
  AppDateFormat.iso => DateFormat('MM-dd'),
  AppDateFormat.dayMonthYear => DateFormat('dd/MM'),
  AppDateFormat.monthDayYear => DateFormat('MM/dd'),
  AppDateFormat.dayMonthNameYear => DateFormat('d MMM'),
};

/// The time formatter for the chosen clock style.
DateFormat _timeFormatter({bool withSeconds = false}) {
  final pattern = withSeconds
      ? _clockFormat.timeWithSecondsPattern
      : _clockFormat.timePattern;
  if (pattern == null) {
    return withSeconds ? DateFormat.Hms() : DateFormat.jm();
  }
  return DateFormat(pattern);
}

String formatDate(DateTime d) => _dateFormatter().format(d);

/// A date without the year, for labels that repeat inside one chart.
String formatShortDate(DateTime d) => _shortDateFormatter().format(d);

/// A clock time on its own, following the chosen 12- or 24-hour style.
String formatTime(DateTime d, {bool withSeconds = false}) =>
    _timeFormatter(withSeconds: withSeconds).format(d);

/// A date and a time together.
String formatDateTime(DateTime d, {bool withSeconds = false}) =>
    '${formatDate(d)} ${formatTime(d, withSeconds: withSeconds)}';

String dateTimeToIso(DateTime d) => _isoFormat.format(d);

DateTime parseIsoDate(String date) => _isoFormat.parseStrict(date);

String formatDateFromIso(String isoDate) =>
    _dateFormatter().format(parseIsoDate(isoDate));

/// A short date read straight from an ISO string.
String formatShortDateFromIso(String isoDate) =>
    _shortDateFormatter().format(parseIsoDate(isoDate));
