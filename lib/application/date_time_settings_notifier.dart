import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sreerajp_todo/core/utils/date_format_rules.dart';
import 'package:sreerajp_todo/core/utils/date_utils.dart' as date_utils;

/// SharedPreferences key for the first day of the week.
const String kWeekStartKey = 'datetime_week_start';

/// SharedPreferences key for the 12- or 24-hour clock choice.
const String kClockFormatKey = 'datetime_clock_format';

/// SharedPreferences key for how a date reads on screen.
const String kDateFormatKey = 'datetime_date_format';

/// SharedPreferences key for the hour a new day begins.
const String kDayStartHourKey = 'datetime_day_start_hour';

/// SharedPreferences key for the chosen working days.
const String kWorkingDaysKey = 'datetime_working_days';

/// Immutable snapshot of every date and time preference.
@immutable
class DateTimeSettings {
  const DateTimeSettings({
    this.weekStart = WeekStartDay.system,
    this.clockFormat = ClockFormat.system,
    this.dateFormat = AppDateFormat.system,
    this.dayStartHour = 0,
    this.workingDays = kDefaultWorkingDays,
  });

  /// The day the calendar starts each row on.
  final WeekStartDay weekStart;

  /// Whether times show as `14:30` or `2:30 PM`.
  final ClockFormat clockFormat;

  /// How a whole date reads on screen.
  final AppDateFormat dateFormat;

  /// The hour a new day begins. Zero is plain midnight.
  final int dayStartHour;

  /// The weekdays statistics should treat as working days.
  final Set<int> workingDays;

  DateTimeSettings copyWith({
    WeekStartDay? weekStart,
    ClockFormat? clockFormat,
    AppDateFormat? dateFormat,
    int? dayStartHour,
    Set<int>? workingDays,
  }) {
    return DateTimeSettings(
      weekStart: weekStart ?? this.weekStart,
      clockFormat: clockFormat ?? this.clockFormat,
      dateFormat: dateFormat ?? this.dateFormat,
      dayStartHour: dayStartHour ?? this.dayStartHour,
      workingDays: workingDays ?? this.workingDays,
    );
  }
}

/// Owns the date and time preferences and writes every change straight to
/// [SharedPreferences], so the choices survive a restart.
///
/// Also mirrors three of them into `date_utils.dart`. Those helpers are plain
/// top-level functions called from dozens of places that have no access to a
/// provider, so the settings are pushed to them instead of pulled.
class DateTimeSettingsNotifier extends StateNotifier<DateTimeSettings> {
  DateTimeSettingsNotifier(this._prefs) : super(_loadInitialState(_prefs)) {
    _applyToDateUtils();
  }

  final SharedPreferences _prefs;

  static DateTimeSettings _loadInitialState(SharedPreferences prefs) {
    const defaults = DateTimeSettings();
    return DateTimeSettings(
      weekStart: _readEnum(
        prefs.getInt(kWeekStartKey),
        WeekStartDay.values,
        defaults.weekStart,
      ),
      clockFormat: _readEnum(
        prefs.getInt(kClockFormatKey),
        ClockFormat.values,
        defaults.clockFormat,
      ),
      dateFormat: _readEnum(
        prefs.getInt(kDateFormatKey),
        AppDateFormat.values,
        defaults.dateFormat,
      ),
      dayStartHour: clampDayStartHour(
        prefs.getInt(kDayStartHourKey) ?? defaults.dayStartHour,
      ),
      workingDays: parseWorkingDays(prefs.getStringList(kWorkingDaysKey)),
    );
  }

  /// Reads a saved enum index, falling back when it is missing or out of
  /// range. A bad stored value can only come from a downgrade or a hand-edited
  /// file, and must never crash the app.
  static T _readEnum<T>(int? index, List<T> values, T fallback) {
    if (index == null || index < 0 || index >= values.length) return fallback;
    return values[index];
  }

  void _applyToDateUtils() {
    date_utils.setDayStartHour(state.dayStartHour);
    date_utils.setAppDateFormat(state.dateFormat);
    date_utils.setClockFormat(state.clockFormat);
  }

  /// Sets the day the calendar starts each row on.
  Future<void> setWeekStart(WeekStartDay value) async {
    if (value == state.weekStart) return;
    state = state.copyWith(weekStart: value);
    await _prefs.setInt(kWeekStartKey, value.index);
  }

  /// Sets the 12- or 24-hour clock choice.
  Future<void> setClockFormat(ClockFormat value) async {
    if (value == state.clockFormat) return;
    state = state.copyWith(clockFormat: value);
    date_utils.setClockFormat(value);
    await _prefs.setInt(kClockFormatKey, value.index);
  }

  /// Sets how a whole date reads on screen.
  Future<void> setDateFormat(AppDateFormat value) async {
    if (value == state.dateFormat) return;
    state = state.copyWith(dateFormat: value);
    date_utils.setAppDateFormat(value);
    await _prefs.setInt(kDateFormatKey, value.index);
  }

  /// Sets the hour a new day begins.
  ///
  /// This moves where the Day Lock boundary sits, so it takes effect for every
  /// date helper at once.
  Future<void> setDayStartHour(int value) async {
    final hour = clampDayStartHour(value);
    if (hour == state.dayStartHour) return;
    state = state.copyWith(dayStartHour: hour);
    date_utils.setDayStartHour(hour);
    await _prefs.setInt(kDayStartHourKey, hour);
  }

  /// Turns one weekday on or off as a working day.
  Future<void> toggleWorkingDay(int weekday, bool isWorking) async {
    if (weekday < DateTime.monday || weekday > DateTime.sunday) return;
    final updated = Set<int>.from(state.workingDays);
    if (isWorking) {
      updated.add(weekday);
    } else {
      updated.remove(weekday);
    }
    if (setEquals(updated, state.workingDays)) return;
    state = state.copyWith(workingDays: updated);
    await _prefs.setStringList(kWorkingDaysKey, encodeWorkingDays(updated));
  }

  /// Puts the working days back to Monday through Friday.
  Future<void> resetWorkingDays() async {
    if (setEquals(state.workingDays, kDefaultWorkingDays)) return;
    state = state.copyWith(workingDays: kDefaultWorkingDays);
    await _prefs.setStringList(
      kWorkingDaysKey,
      encodeWorkingDays(kDefaultWorkingDays),
    );
  }
}
