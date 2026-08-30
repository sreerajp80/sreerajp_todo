import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sreerajp_todo/application/time_tracking_settings_notifier.dart';
import 'package:sreerajp_todo/core/utils/focus_pulse_rules.dart';
import 'package:sreerajp_todo/core/utils/time_tracking_rules.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<SharedPreferences> freshPrefs([
    Map<String, Object> values = const {},
  ]) async {
    SharedPreferences.setMockInitialValues(values);
    return SharedPreferences.getInstance();
  }

  group('TimeTrackingSettingsNotifier defaults', () {
    test('nothing saved means today behaviour is unchanged', () async {
      final state = TimeTrackingSettingsNotifier(await freshPrefs()).state;

      expect(state.autoStopMode, AutoStopMode.off);
      expect(state.singleTimer, isFalse);
      expect(state.autoPauseOnBackground, isFalse);
      expect(state.rounding, DurationRounding.off);
      expect(state.format, DurationFormat.hhmmss);
      expect(state.minimumSegmentLength, MinimumSegmentLength.off);
      expect(state.keepScreenAwake, isFalse);
      expect(state.showRunningNotification, isTrue);
      expect(state.manualEntryDuration, ManualEntryDuration.oneHour);
      expect(state.pomodoroEnabled, isFalse);
      expect(state.pomodoroWorkMinutes, 25);
      expect(state.pomodoroShortBreakMinutes, 5);
      expect(state.pomodoroLongBreakMinutes, 15);
      expect(state.pomodoroBlocksBeforeLongBreak, 4);
      expect(state.pomodoroAutoStartNext, isFalse);
      expect(state.focusPulseMode, FocusPulseMode.off);
      expect(state.focusPulseIntervalMinutes, 30);
      expect(state.focusImmersive, isTrue);
    });
  });

  group('TimeTrackingSettingsNotifier saving', () {
    test('saves the auto-stop mode and reads it back', () async {
      final prefs = await freshPrefs();
      await TimeTrackingSettingsNotifier(
        prefs,
      ).setAutoStopMode(AutoStopMode.midnight);

      expect(prefs.getInt(kAutoStopModeKey), AutoStopMode.midnight.index);
      expect(
        TimeTrackingSettingsNotifier(prefs).state.autoStopMode,
        AutoStopMode.midnight,
      );
    });

    test('saves the custom auto-stop time', () async {
      final prefs = await freshPrefs();
      await TimeTrackingSettingsNotifier(
        prefs,
      ).setAutoStopTime(const TimeOfDay(hour: 21, minute: 45));

      final state = TimeTrackingSettingsNotifier(prefs).state;
      expect(state.autoStopHour, 21);
      expect(state.autoStopMinute, 45);
      expect(state.autoStopTimeOfDay.hour, 21);
    });

    test('saves each switch', () async {
      final prefs = await freshPrefs();
      final notifier = TimeTrackingSettingsNotifier(prefs);
      await notifier.setSingleTimer(true);
      await notifier.setAutoPauseOnBackground(true);
      await notifier.setKeepScreenAwake(true);
      await notifier.setShowRunningNotification(false);
      await notifier.setPomodoroEnabled(true);
      await notifier.setPomodoroAutoStartNext(true);

      final reloaded = TimeTrackingSettingsNotifier(prefs).state;
      expect(reloaded.singleTimer, isTrue);
      expect(reloaded.autoPauseOnBackground, isTrue);
      expect(reloaded.keepScreenAwake, isTrue);
      expect(reloaded.showRunningNotification, isFalse);
      expect(reloaded.pomodoroEnabled, isTrue);
      expect(reloaded.pomodoroAutoStartNext, isTrue);
    });

    test('saves rounding, format, minimum length and manual default', () async {
      final prefs = await freshPrefs();
      final notifier = TimeTrackingSettingsNotifier(prefs);
      await notifier.setRounding(DurationRounding.nearest15Minutes);
      await notifier.setFormat(DurationFormat.decimalHours);
      await notifier.setMinimumSegmentLength(MinimumSegmentLength.oneMinute);
      await notifier.setManualEntryDuration(ManualEntryDuration.twoHours);

      final reloaded = TimeTrackingSettingsNotifier(prefs).state;
      expect(reloaded.rounding, DurationRounding.nearest15Minutes);
      expect(reloaded.format, DurationFormat.decimalHours);
      expect(reloaded.minimumSegmentLength, MinimumSegmentLength.oneMinute);
      expect(reloaded.manualEntryDuration, ManualEntryDuration.twoHours);
    });
  });

  group('TimeTrackingSettingsNotifier guards', () {
    test('clamps a Pomodoro length to the allowed range', () async {
      final prefs = await freshPrefs();
      final notifier = TimeTrackingSettingsNotifier(prefs);

      await notifier.setPomodoroWorkMinutes(0);
      expect(notifier.state.pomodoroWorkMinutes, kPomodoroMinMinutes);

      await notifier.setPomodoroWorkMinutes(9999);
      expect(notifier.state.pomodoroWorkMinutes, kPomodoroMaxMinutes);
    });

    test('clamps the blocks before a long break', () async {
      final prefs = await freshPrefs();
      final notifier = TimeTrackingSettingsNotifier(prefs);

      await notifier.setPomodoroBlocksBeforeLongBreak(1);
      expect(notifier.state.pomodoroBlocksBeforeLongBreak, kPomodoroMinBlocks);

      await notifier.setPomodoroBlocksBeforeLongBreak(99);
      expect(notifier.state.pomodoroBlocksBeforeLongBreak, kPomodoroMaxBlocks);
    });

    test('saves the focus pulse mode and reads it back', () async {
      final prefs = await freshPrefs();
      await TimeTrackingSettingsNotifier(
        prefs,
      ).setFocusPulseMode(FocusPulseMode.both);

      expect(prefs.getInt(kFocusPulseModeKey), FocusPulseMode.both.index);
      expect(
        TimeTrackingSettingsNotifier(prefs).state.focusPulseMode,
        FocusPulseMode.both,
      );
    });

    test('saves the focus pulse gap and reads it back', () async {
      final prefs = await freshPrefs();
      await TimeTrackingSettingsNotifier(
        prefs,
      ).setFocusPulseIntervalMinutes(15);

      expect(prefs.getInt(kFocusPulseIntervalKey), 15);
      expect(
        TimeTrackingSettingsNotifier(prefs).state.focusPulseIntervalMinutes,
        15,
      );
    });

    test('clamps the focus pulse gap to the allowed range', () async {
      final notifier = TimeTrackingSettingsNotifier(await freshPrefs());

      await notifier.setFocusPulseIntervalMinutes(1);
      expect(notifier.state.focusPulseIntervalMinutes, kFocusPulseMinMinutes);

      await notifier.setFocusPulseIntervalMinutes(999);
      expect(notifier.state.focusPulseIntervalMinutes, kFocusPulseMaxMinutes);
    });

    test('saves the immersive focus view switch', () async {
      final prefs = await freshPrefs();
      await TimeTrackingSettingsNotifier(prefs).setFocusImmersive(false);

      expect(prefs.getBool(kFocusImmersiveKey), isFalse);
      expect(TimeTrackingSettingsNotifier(prefs).state.focusImmersive, isFalse);
    });

    test('falls back when a stored value is out of range', () async {
      // Only reachable from a downgrade or a hand-edited file, but it must
      // never crash or leave the engine with a length it cannot run.
      final prefs = await freshPrefs({
        kAutoStopHourKey: 99,
        kPomodoroWorkMinutesKey: -5,
        kAutoStopModeKey: 42,
        kFocusPulseIntervalKey: 3,
      });
      final state = TimeTrackingSettingsNotifier(prefs).state;

      expect(state.autoStopHour, 22);
      expect(state.pomodoroWorkMinutes, 25);
      expect(state.autoStopMode, AutoStopMode.off);
      expect(state.focusPulseIntervalMinutes, 30);
    });
  });
}
