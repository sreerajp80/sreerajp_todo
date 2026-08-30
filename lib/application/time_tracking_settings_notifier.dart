import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sreerajp_todo/core/utils/focus_pulse_rules.dart';
import 'package:sreerajp_todo/core/utils/time_tracking_rules.dart';

/// SharedPreferences key for the auto-stop mode.
const String kAutoStopModeKey = 'tracking_auto_stop_mode';

/// SharedPreferences key for the custom auto-stop hour (0-23).
const String kAutoStopHourKey = 'tracking_auto_stop_hour';

/// SharedPreferences key for the custom auto-stop minute (0-59).
const String kAutoStopMinuteKey = 'tracking_auto_stop_minute';

/// SharedPreferences key for "only one timer may run at a time".
const String kSingleTimerKey = 'tracking_single_timer';

/// SharedPreferences key for "pause a running timer when the app leaves the
/// foreground".
const String kAutoPauseOnBackgroundKey = 'tracking_auto_pause_background';

/// SharedPreferences key for the display rounding step.
const String kDurationRoundingKey = 'tracking_duration_rounding';

/// SharedPreferences key for the duration display format.
const String kDurationFormatKey = 'tracking_duration_format';

/// SharedPreferences key for the shortest live segment worth keeping.
const String kMinimumSegmentLengthKey = 'tracking_minimum_segment_length';

/// SharedPreferences key for "keep the screen awake while a timer runs".
const String kKeepScreenAwakeKey = 'tracking_keep_screen_awake';

/// SharedPreferences key for "show live ongoing notification while a timer runs".
const String kShowRunningNotificationKey = 'tracking_show_running_notification';

/// SharedPreferences key for the manual entry default duration.
const String kManualEntryDurationKey = 'tracking_manual_entry_duration';

/// SharedPreferences key for the Pomodoro on/off switch.
const String kPomodoroEnabledKey = 'tracking_pomodoro_enabled';

/// SharedPreferences key for the Pomodoro work block length, in minutes.
const String kPomodoroWorkMinutesKey = 'tracking_pomodoro_work_minutes';

/// SharedPreferences key for the Pomodoro short break length, in minutes.
const String kPomodoroShortBreakMinutesKey = 'tracking_pomodoro_short_break';

/// SharedPreferences key for the Pomodoro long break length, in minutes.
const String kPomodoroLongBreakMinutesKey = 'tracking_pomodoro_long_break';

/// SharedPreferences key for how many work blocks come before a long break.
const String kPomodoroBlocksBeforeLongBreakKey = 'tracking_pomodoro_blocks';

/// SharedPreferences key for "start the next Pomodoro block on its own".
const String kPomodoroAutoStartNextKey = 'tracking_pomodoro_auto_start';

/// SharedPreferences key for what a focus pulse does.
const String kFocusPulseModeKey = 'tracking_focus_pulse_mode';

/// SharedPreferences key for the gap between focus pulses, in minutes.
const String kFocusPulseIntervalKey = 'tracking_focus_pulse_interval';

/// SharedPreferences key for "hide the status bar in the Focus view".
const String kFocusImmersiveKey = 'tracking_focus_immersive';

/// The allowed range for every Pomodoro length, in minutes.
const int kPomodoroMinMinutes = 1;

/// The longest a Pomodoro block may be, in minutes.
const int kPomodoroMaxMinutes = 180;

/// The allowed range for work blocks before a long break.
const int kPomodoroMinBlocks = 2;

/// The most work blocks allowed before a long break.
const int kPomodoroMaxBlocks = 12;

/// Immutable snapshot of every time-tracking preference.
@immutable
class TimeTrackingSettings {
  const TimeTrackingSettings({
    this.autoStopMode = AutoStopMode.off,
    this.autoStopHour = 22,
    this.autoStopMinute = 0,
    this.singleTimer = false,
    this.autoPauseOnBackground = false,
    this.rounding = DurationRounding.off,
    this.format = DurationFormat.hhmmss,
    this.minimumSegmentLength = MinimumSegmentLength.off,
    this.keepScreenAwake = false,
    this.showRunningNotification = true,
    this.manualEntryDuration = ManualEntryDuration.oneHour,
    this.pomodoroEnabled = false,
    this.pomodoroWorkMinutes = 25,
    this.pomodoroShortBreakMinutes = 5,
    this.pomodoroLongBreakMinutes = 15,
    this.pomodoroBlocksBeforeLongBreak = 4,
    this.pomodoroAutoStartNext = false,
    this.focusPulseMode = FocusPulseMode.off,
    this.focusPulseIntervalMinutes = 30,
    this.focusImmersive = true,
  });

  /// When a running timer stops on its own.
  final AutoStopMode autoStopMode;

  /// Hour of the custom auto-stop time. Only read for
  /// [AutoStopMode.customTime].
  final int autoStopHour;

  /// Minute of the custom auto-stop time. Only read for
  /// [AutoStopMode.customTime].
  final int autoStopMinute;

  /// When true, starting a timer stops any timer running on another todo.
  final bool singleTimer;

  /// When true, leaving the app pauses a running timer.
  final bool autoPauseOnBackground;

  /// Rounding applied to shown durations. Never changes stored data.
  final DurationRounding rounding;

  /// How a duration is written out on screen.
  final DurationFormat format;

  /// The shortest live segment worth keeping.
  final MinimumSegmentLength minimumSegmentLength;

  /// When true, the screen stays on while a timer runs. Android only.
  final bool keepScreenAwake;

  /// When true, an ongoing notification with a live chronometer is shown. Android only.
  final bool showRunningNotification;

  /// The gap pre-filled in the manual time entry form.
  final ManualEntryDuration manualEntryDuration;

  /// When true, a running timer is treated as a Pomodoro work block.
  final bool pomodoroEnabled;

  /// Length of a Pomodoro work block, in minutes.
  final int pomodoroWorkMinutes;

  /// Length of a Pomodoro short break, in minutes.
  final int pomodoroShortBreakMinutes;

  /// Length of a Pomodoro long break, in minutes.
  final int pomodoroLongBreakMinutes;

  /// How many work blocks are finished before a long break is offered.
  final int pomodoroBlocksBeforeLongBreak;

  /// When true, the next block starts on its own instead of waiting for a tap.
  final bool pomodoroAutoStartNext;

  /// What a focus pulse does while a timer runs.
  final FocusPulseMode focusPulseMode;

  /// The gap between focus pulses, in minutes.
  final int focusPulseIntervalMinutes;

  /// When true, the Focus view hides the status and navigation bars.
  final bool focusImmersive;

  /// The custom auto-stop time as a [TimeOfDay], for the picker.
  TimeOfDay get autoStopTimeOfDay =>
      TimeOfDay(hour: autoStopHour, minute: autoStopMinute);

  /// The next moment a timer started at [from] should auto-stop, or null.
  DateTime? nextAutoStopAfter(DateTime from) => nextAutoStopInstant(
    from,
    autoStopMode,
    customHour: autoStopHour,
    customMinute: autoStopMinute,
  );

  TimeTrackingSettings copyWith({
    AutoStopMode? autoStopMode,
    int? autoStopHour,
    int? autoStopMinute,
    bool? singleTimer,
    bool? autoPauseOnBackground,
    DurationRounding? rounding,
    DurationFormat? format,
    MinimumSegmentLength? minimumSegmentLength,
    bool? keepScreenAwake,
    bool? showRunningNotification,
    ManualEntryDuration? manualEntryDuration,
    bool? pomodoroEnabled,
    int? pomodoroWorkMinutes,
    int? pomodoroShortBreakMinutes,
    int? pomodoroLongBreakMinutes,
    int? pomodoroBlocksBeforeLongBreak,
    bool? pomodoroAutoStartNext,
    FocusPulseMode? focusPulseMode,
    int? focusPulseIntervalMinutes,
    bool? focusImmersive,
  }) {
    return TimeTrackingSettings(
      autoStopMode: autoStopMode ?? this.autoStopMode,
      autoStopHour: autoStopHour ?? this.autoStopHour,
      autoStopMinute: autoStopMinute ?? this.autoStopMinute,
      singleTimer: singleTimer ?? this.singleTimer,
      autoPauseOnBackground:
          autoPauseOnBackground ?? this.autoPauseOnBackground,
      rounding: rounding ?? this.rounding,
      format: format ?? this.format,
      minimumSegmentLength: minimumSegmentLength ?? this.minimumSegmentLength,
      keepScreenAwake: keepScreenAwake ?? this.keepScreenAwake,
      showRunningNotification:
          showRunningNotification ?? this.showRunningNotification,
      manualEntryDuration: manualEntryDuration ?? this.manualEntryDuration,
      pomodoroEnabled: pomodoroEnabled ?? this.pomodoroEnabled,
      pomodoroWorkMinutes: pomodoroWorkMinutes ?? this.pomodoroWorkMinutes,
      pomodoroShortBreakMinutes:
          pomodoroShortBreakMinutes ?? this.pomodoroShortBreakMinutes,
      pomodoroLongBreakMinutes:
          pomodoroLongBreakMinutes ?? this.pomodoroLongBreakMinutes,
      pomodoroBlocksBeforeLongBreak:
          pomodoroBlocksBeforeLongBreak ?? this.pomodoroBlocksBeforeLongBreak,
      pomodoroAutoStartNext:
          pomodoroAutoStartNext ?? this.pomodoroAutoStartNext,
      focusPulseMode: focusPulseMode ?? this.focusPulseMode,
      focusPulseIntervalMinutes:
          focusPulseIntervalMinutes ?? this.focusPulseIntervalMinutes,
      focusImmersive: focusImmersive ?? this.focusImmersive,
    );
  }
}

/// Owns the time-tracking preferences and writes every change straight to
/// [SharedPreferences], so the choices survive a restart.
///
/// Mirrors the shape of `AppearanceNotifier` on purpose, so both settings
/// groups read the same way.
class TimeTrackingSettingsNotifier extends StateNotifier<TimeTrackingSettings> {
  TimeTrackingSettingsNotifier(this._prefs) : super(_loadInitialState(_prefs));

  final SharedPreferences _prefs;

  static TimeTrackingSettings _loadInitialState(SharedPreferences prefs) {
    const defaults = TimeTrackingSettings();
    return TimeTrackingSettings(
      autoStopMode: _readEnum(
        prefs.getInt(kAutoStopModeKey),
        AutoStopMode.values,
        defaults.autoStopMode,
      ),
      autoStopHour: _readInt(
        prefs.getInt(kAutoStopHourKey),
        0,
        23,
        defaults.autoStopHour,
      ),
      autoStopMinute: _readInt(
        prefs.getInt(kAutoStopMinuteKey),
        0,
        59,
        defaults.autoStopMinute,
      ),
      singleTimer: prefs.getBool(kSingleTimerKey) ?? defaults.singleTimer,
      autoPauseOnBackground:
          prefs.getBool(kAutoPauseOnBackgroundKey) ??
          defaults.autoPauseOnBackground,
      rounding: _readEnum(
        prefs.getInt(kDurationRoundingKey),
        DurationRounding.values,
        defaults.rounding,
      ),
      format: _readEnum(
        prefs.getInt(kDurationFormatKey),
        DurationFormat.values,
        defaults.format,
      ),
      minimumSegmentLength: _readEnum(
        prefs.getInt(kMinimumSegmentLengthKey),
        MinimumSegmentLength.values,
        defaults.minimumSegmentLength,
      ),
      keepScreenAwake:
          prefs.getBool(kKeepScreenAwakeKey) ?? defaults.keepScreenAwake,
      showRunningNotification:
          prefs.getBool(kShowRunningNotificationKey) ??
          defaults.showRunningNotification,
      manualEntryDuration: _readEnum(
        prefs.getInt(kManualEntryDurationKey),
        ManualEntryDuration.values,
        defaults.manualEntryDuration,
      ),
      pomodoroEnabled:
          prefs.getBool(kPomodoroEnabledKey) ?? defaults.pomodoroEnabled,
      pomodoroWorkMinutes: _readInt(
        prefs.getInt(kPomodoroWorkMinutesKey),
        kPomodoroMinMinutes,
        kPomodoroMaxMinutes,
        defaults.pomodoroWorkMinutes,
      ),
      pomodoroShortBreakMinutes: _readInt(
        prefs.getInt(kPomodoroShortBreakMinutesKey),
        kPomodoroMinMinutes,
        kPomodoroMaxMinutes,
        defaults.pomodoroShortBreakMinutes,
      ),
      pomodoroLongBreakMinutes: _readInt(
        prefs.getInt(kPomodoroLongBreakMinutesKey),
        kPomodoroMinMinutes,
        kPomodoroMaxMinutes,
        defaults.pomodoroLongBreakMinutes,
      ),
      pomodoroBlocksBeforeLongBreak: _readInt(
        prefs.getInt(kPomodoroBlocksBeforeLongBreakKey),
        kPomodoroMinBlocks,
        kPomodoroMaxBlocks,
        defaults.pomodoroBlocksBeforeLongBreak,
      ),
      pomodoroAutoStartNext:
          prefs.getBool(kPomodoroAutoStartNextKey) ??
          defaults.pomodoroAutoStartNext,
      focusPulseMode: _readEnum(
        prefs.getInt(kFocusPulseModeKey),
        FocusPulseMode.values,
        defaults.focusPulseMode,
      ),
      focusPulseIntervalMinutes: _readInt(
        prefs.getInt(kFocusPulseIntervalKey),
        kFocusPulseMinMinutes,
        kFocusPulseMaxMinutes,
        defaults.focusPulseIntervalMinutes,
      ),
      focusImmersive:
          prefs.getBool(kFocusImmersiveKey) ?? defaults.focusImmersive,
    );
  }

  static T _readEnum<T>(int? index, List<T> values, T fallback) {
    if (index == null || index < 0 || index >= values.length) return fallback;
    return values[index];
  }

  /// Reads a saved whole number, falling back when it is missing or outside
  /// [min] to [max]. A bad stored value can only come from a downgrade or a
  /// hand-edited file, and must never crash the app.
  static int _readInt(int? value, int min, int max, int fallback) {
    if (value == null || value < min || value > max) return fallback;
    return value;
  }

  /// Sets when a running timer stops on its own.
  Future<void> setAutoStopMode(AutoStopMode mode) async {
    if (mode == state.autoStopMode) return;
    state = state.copyWith(autoStopMode: mode);
    await _prefs.setInt(kAutoStopModeKey, mode.index);
  }

  /// Sets the custom auto-stop time and saves it.
  Future<void> setAutoStopTime(TimeOfDay time) async {
    state = state.copyWith(
      autoStopHour: time.hour,
      autoStopMinute: time.minute,
    );
    await _prefs.setInt(kAutoStopHourKey, time.hour);
    await _prefs.setInt(kAutoStopMinuteKey, time.minute);
  }

  /// Turns "only one timer at a time" on or off.
  Future<void> setSingleTimer(bool value) async {
    if (value == state.singleTimer) return;
    state = state.copyWith(singleTimer: value);
    await _prefs.setBool(kSingleTimerKey, value);
  }

  /// Turns "pause when the app goes to the background" on or off.
  Future<void> setAutoPauseOnBackground(bool value) async {
    if (value == state.autoPauseOnBackground) return;
    state = state.copyWith(autoPauseOnBackground: value);
    await _prefs.setBool(kAutoPauseOnBackgroundKey, value);
  }

  /// Sets the display rounding step.
  Future<void> setRounding(DurationRounding rounding) async {
    if (rounding == state.rounding) return;
    state = state.copyWith(rounding: rounding);
    await _prefs.setInt(kDurationRoundingKey, rounding.index);
  }

  /// Sets how a duration is written out.
  Future<void> setFormat(DurationFormat format) async {
    if (format == state.format) return;
    state = state.copyWith(format: format);
    await _prefs.setInt(kDurationFormatKey, format.index);
  }

  /// Sets the shortest live segment worth keeping.
  Future<void> setMinimumSegmentLength(MinimumSegmentLength limit) async {
    if (limit == state.minimumSegmentLength) return;
    state = state.copyWith(minimumSegmentLength: limit);
    await _prefs.setInt(kMinimumSegmentLengthKey, limit.index);
  }

  /// Turns "keep the screen awake while a timer runs" on or off.
  Future<void> setKeepScreenAwake(bool value) async {
    if (value == state.keepScreenAwake) return;
    state = state.copyWith(keepScreenAwake: value);
    await _prefs.setBool(kKeepScreenAwakeKey, value);
  }

  /// Turns "show live notification while a timer runs" on or off.
  Future<void> setShowRunningNotification(bool value) async {
    if (value == state.showRunningNotification) return;
    state = state.copyWith(showRunningNotification: value);
    await _prefs.setBool(kShowRunningNotificationKey, value);
  }

  /// Sets the gap pre-filled in the manual time entry form.
  Future<void> setManualEntryDuration(ManualEntryDuration duration) async {
    if (duration == state.manualEntryDuration) return;
    state = state.copyWith(manualEntryDuration: duration);
    await _prefs.setInt(kManualEntryDurationKey, duration.index);
  }

  /// Turns Pomodoro blocks on or off.
  Future<void> setPomodoroEnabled(bool value) async {
    if (value == state.pomodoroEnabled) return;
    state = state.copyWith(pomodoroEnabled: value);
    await _prefs.setBool(kPomodoroEnabledKey, value);
  }

  /// Sets the work block length in minutes, clamped to the allowed range.
  Future<void> setPomodoroWorkMinutes(int minutes) async {
    final clamped = minutes.clamp(kPomodoroMinMinutes, kPomodoroMaxMinutes);
    if (clamped == state.pomodoroWorkMinutes) return;
    state = state.copyWith(pomodoroWorkMinutes: clamped);
    await _prefs.setInt(kPomodoroWorkMinutesKey, clamped);
  }

  /// Sets the short break length in minutes, clamped to the allowed range.
  Future<void> setPomodoroShortBreakMinutes(int minutes) async {
    final clamped = minutes.clamp(kPomodoroMinMinutes, kPomodoroMaxMinutes);
    if (clamped == state.pomodoroShortBreakMinutes) return;
    state = state.copyWith(pomodoroShortBreakMinutes: clamped);
    await _prefs.setInt(kPomodoroShortBreakMinutesKey, clamped);
  }

  /// Sets the long break length in minutes, clamped to the allowed range.
  Future<void> setPomodoroLongBreakMinutes(int minutes) async {
    final clamped = minutes.clamp(kPomodoroMinMinutes, kPomodoroMaxMinutes);
    if (clamped == state.pomodoroLongBreakMinutes) return;
    state = state.copyWith(pomodoroLongBreakMinutes: clamped);
    await _prefs.setInt(kPomodoroLongBreakMinutesKey, clamped);
  }

  /// Sets how many work blocks come before a long break.
  Future<void> setPomodoroBlocksBeforeLongBreak(int blocks) async {
    final clamped = blocks.clamp(kPomodoroMinBlocks, kPomodoroMaxBlocks);
    if (clamped == state.pomodoroBlocksBeforeLongBreak) return;
    state = state.copyWith(pomodoroBlocksBeforeLongBreak: clamped);
    await _prefs.setInt(kPomodoroBlocksBeforeLongBreakKey, clamped);
  }

  /// Turns "start the next block on its own" on or off.
  Future<void> setPomodoroAutoStartNext(bool value) async {
    if (value == state.pomodoroAutoStartNext) return;
    state = state.copyWith(pomodoroAutoStartNext: value);
    await _prefs.setBool(kPomodoroAutoStartNextKey, value);
  }

  /// Sets what a focus pulse does while a timer runs.
  Future<void> setFocusPulseMode(FocusPulseMode mode) async {
    if (mode == state.focusPulseMode) return;
    state = state.copyWith(focusPulseMode: mode);
    await _prefs.setInt(kFocusPulseModeKey, mode.index);
  }

  /// Sets the gap between focus pulses, clamped to the allowed range.
  Future<void> setFocusPulseIntervalMinutes(int minutes) async {
    final clamped = minutes.clamp(kFocusPulseMinMinutes, kFocusPulseMaxMinutes);
    if (clamped == state.focusPulseIntervalMinutes) return;
    state = state.copyWith(focusPulseIntervalMinutes: clamped);
    await _prefs.setInt(kFocusPulseIntervalKey, clamped);
  }

  /// Turns the immersive Focus view on or off.
  Future<void> setFocusImmersive(bool value) async {
    if (value == state.focusImmersive) return;
    state = state.copyWith(focusImmersive: value);
    await _prefs.setBool(kFocusImmersiveKey, value);
  }
}
