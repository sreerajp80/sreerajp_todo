import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sreerajp_todo/data/models/todo_entity.dart';

const String kPendingAlertsEnabledKey = 'pending_alerts_enabled';
const String kPendingAlertsDayStartKey = 'pending_alerts_day_start_enabled';
const String kPendingAlertsDayStartHourKey = 'pending_alerts_day_start_hour';
const String kPendingAlertsDayStartMinuteKey =
    'pending_alerts_day_start_minute';
const String kPendingAlertsIntervalMinutesKey =
    'pending_alerts_interval_minutes';
const String kPendingAlertsHapticKey = 'pending_alerts_haptic';
const String kPendingAlertsLastDayKey = 'pending_alerts_last_day';
const String kPendingAlertsLastIntervalEpochKey =
    'pending_alerts_last_interval_epoch';

const int kDefaultPendingDayStartHour = 9;
const int kDefaultPendingDayStartMinute = 0;
const int kDefaultPendingIntervalMinutes = 120; // 2 hours

/// Represents the active pending tasks for today and any previous unfinished tasks.
@immutable
class PendingAlertPayload {
  const PendingAlertPayload({
    this.todayTodos = const [],
    this.previousTodos = const [],
  });

  final List<TodoEntity> todayTodos;
  final List<TodoEntity> previousTodos;

  int get totalCount => todayTodos.length + previousTodos.length;
  bool get isEmpty => todayTodos.isEmpty && previousTodos.isEmpty;
  bool get isNotEmpty => !isEmpty;
}

@immutable
class PendingAlertSettings {
  const PendingAlertSettings({
    this.enabled = true,
    this.dayStartAlertEnabled = true,
    this.dayStartHour = kDefaultPendingDayStartHour,
    this.dayStartMinute = kDefaultPendingDayStartMinute,
    this.intervalMinutes = kDefaultPendingIntervalMinutes,
    this.haptic = true,
    this.lastDayAlertDate,
    this.lastIntervalAlertEpoch,
  });

  /// Master switch for pending task alerts.
  final bool enabled;

  /// Whether to alert at the start of the day about pending tasks.
  final bool dayStartAlertEnabled;

  /// Hour (0-23) when the morning / day-start alert becomes eligible.
  final int dayStartHour;

  /// Minute (0-59) when the morning / day-start alert becomes eligible.
  final int dayStartMinute;

  /// Reminder interval in minutes (0 = Off, 30, 60, 120, 180, 240).
  final int intervalMinutes;

  /// Whether to provide gentle haptic pulse when alert appears.
  final bool haptic;

  /// Last date (`yyyy-MM-dd`) when the day-start alert was displayed/dismissed.
  final String? lastDayAlertDate;

  /// Timestamp in milliseconds of the last interval alert or snooze.
  final int? lastIntervalAlertEpoch;

  /// Determines if the day-start alert should trigger for [today] at [now].
  bool shouldTriggerDayStartAlert(String today, DateTime now) {
    if (!enabled || !dayStartAlertEnabled) return false;
    if (lastDayAlertDate == today) return false;
    if (now.hour < dayStartHour) return false;
    if (now.hour == dayStartHour && now.minute < dayStartMinute) return false;
    return true;
  }

  /// Determines if the interval alert should trigger at [now].
  bool shouldTriggerIntervalAlert(DateTime now) {
    if (!enabled || intervalMinutes <= 0) return false;
    if (lastIntervalAlertEpoch == null) return false;
    final elapsedMs = now.millisecondsSinceEpoch - lastIntervalAlertEpoch!;
    final targetMs = intervalMinutes * 60 * 1000;
    return elapsedMs >= targetMs;
  }

  PendingAlertSettings copyWith({
    bool? enabled,
    bool? dayStartAlertEnabled,
    int? dayStartHour,
    int? dayStartMinute,
    int? intervalMinutes,
    bool? haptic,
    String? lastDayAlertDate,
    int? lastIntervalAlertEpoch,
  }) {
    return PendingAlertSettings(
      enabled: enabled ?? this.enabled,
      dayStartAlertEnabled: dayStartAlertEnabled ?? this.dayStartAlertEnabled,
      dayStartHour: dayStartHour ?? this.dayStartHour,
      dayStartMinute: dayStartMinute ?? this.dayStartMinute,
      intervalMinutes: intervalMinutes ?? this.intervalMinutes,
      haptic: haptic ?? this.haptic,
      lastDayAlertDate: lastDayAlertDate ?? this.lastDayAlertDate,
      lastIntervalAlertEpoch:
          lastIntervalAlertEpoch ?? this.lastIntervalAlertEpoch,
    );
  }
}

/// Manages pending todo alert preferences stored in SharedPreferences.
class PendingAlertNotifier extends StateNotifier<PendingAlertSettings> {
  PendingAlertNotifier(this._prefs) : super(_loadInitialState(_prefs));

  final SharedPreferences _prefs;

  static PendingAlertSettings _loadInitialState(SharedPreferences prefs) {
    const defaults = PendingAlertSettings();
    return PendingAlertSettings(
      enabled: prefs.getBool(kPendingAlertsEnabledKey) ?? defaults.enabled,
      dayStartAlertEnabled:
          prefs.getBool(kPendingAlertsDayStartKey) ??
          defaults.dayStartAlertEnabled,
      dayStartHour:
          prefs.getInt(kPendingAlertsDayStartHourKey) ?? defaults.dayStartHour,
      dayStartMinute:
          prefs.getInt(kPendingAlertsDayStartMinuteKey) ??
          defaults.dayStartMinute,
      intervalMinutes:
          prefs.getInt(kPendingAlertsIntervalMinutesKey) ??
          defaults.intervalMinutes,
      haptic: prefs.getBool(kPendingAlertsHapticKey) ?? defaults.haptic,
      lastDayAlertDate: prefs.getString(kPendingAlertsLastDayKey),
      lastIntervalAlertEpoch: prefs.getInt(kPendingAlertsLastIntervalEpochKey),
    );
  }

  Future<void> setEnabled(bool value) async {
    if (value == state.enabled) return;
    state = state.copyWith(enabled: value);
    await _prefs.setBool(kPendingAlertsEnabledKey, value);
  }

  Future<void> setDayStartAlertEnabled(bool value) async {
    if (value == state.dayStartAlertEnabled) return;
    state = state.copyWith(dayStartAlertEnabled: value);
    await _prefs.setBool(kPendingAlertsDayStartKey, value);
  }

  Future<void> setDayStartTime(int hour, int minute) async {
    final clampedHour = hour.clamp(0, 23);
    final clampedMinute = minute.clamp(0, 59);
    state = state.copyWith(
      dayStartHour: clampedHour,
      dayStartMinute: clampedMinute,
    );
    await _prefs.setInt(kPendingAlertsDayStartHourKey, clampedHour);
    await _prefs.setInt(kPendingAlertsDayStartMinuteKey, clampedMinute);
  }

  Future<void> setIntervalMinutes(int minutes) async {
    if (minutes == state.intervalMinutes) return;
    state = state.copyWith(intervalMinutes: minutes);
    await _prefs.setInt(kPendingAlertsIntervalMinutesKey, minutes);
  }

  Future<void> setHaptic(bool value) async {
    if (value == state.haptic) return;
    state = state.copyWith(haptic: value);
    await _prefs.setBool(kPendingAlertsHapticKey, value);
  }

  Future<void> markDayAlertShown(String todayDate) async {
    state = state.copyWith(lastDayAlertDate: todayDate);
    await _prefs.setString(kPendingAlertsLastDayKey, todayDate);
  }

  Future<void> markIntervalAlertShown(int epochMs) async {
    state = state.copyWith(lastIntervalAlertEpoch: epochMs);
    await _prefs.setInt(kPendingAlertsLastIntervalEpochKey, epochMs);
  }

  Future<void> snoozeInterval(Duration duration) async {
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    // Set last interval epoch to offset snooze
    final intervalMs = state.intervalMinutes * 60 * 1000;
    final newEpoch = nowMs + duration.inMilliseconds - intervalMs;
    state = state.copyWith(lastIntervalAlertEpoch: newEpoch);
    await _prefs.setInt(kPendingAlertsLastIntervalEpochKey, newEpoch);
  }
}
