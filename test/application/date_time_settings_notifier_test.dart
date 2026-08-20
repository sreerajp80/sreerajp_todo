import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sreerajp_todo/application/date_time_settings_notifier.dart';
import 'package:sreerajp_todo/core/utils/date_format_rules.dart';
import 'package:sreerajp_todo/core/utils/date_utils.dart' as date_utils;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<SharedPreferences> freshPrefs([
    Map<String, Object> values = const {},
  ]) async {
    SharedPreferences.setMockInitialValues(values);
    return SharedPreferences.getInstance();
  }

  // The notifier pushes three values into the shared date helpers, so each
  // test puts them back afterwards.
  tearDown(() {
    date_utils.setDayStartHour(0);
    date_utils.setAppDateFormat(AppDateFormat.system);
    date_utils.setClockFormat(ClockFormat.system);
  });

  group('defaults', () {
    test('nothing saved keeps the behaviour the app already had', () async {
      final state = DateTimeSettingsNotifier(await freshPrefs()).state;

      expect(state.weekStart, WeekStartDay.system);
      expect(state.clockFormat, ClockFormat.system);
      expect(state.dateFormat, AppDateFormat.system);
      expect(state.dayStartHour, 0);
      expect(state.workingDays, kDefaultWorkingDays);
    });

    test('a bad saved enum index falls back instead of crashing', () async {
      final prefs = await freshPrefs({
        kWeekStartKey: 99,
        kClockFormatKey: -1,
        kDateFormatKey: 42,
      });
      final state = DateTimeSettingsNotifier(prefs).state;

      expect(state.weekStart, WeekStartDay.system);
      expect(state.clockFormat, ClockFormat.system);
      expect(state.dateFormat, AppDateFormat.system);
    });

    test('a saved day start outside the range is clamped on load', () async {
      final prefs = await freshPrefs({kDayStartHourKey: 20});
      expect(
        DateTimeSettingsNotifier(prefs).state.dayStartHour,
        kMaxDayStartHour,
      );
    });
  });

  group('saving', () {
    test('every choice is written to preferences', () async {
      final prefs = await freshPrefs();
      final notifier = DateTimeSettingsNotifier(prefs);

      await notifier.setWeekStart(WeekStartDay.monday);
      await notifier.setClockFormat(ClockFormat.twentyFourHour);
      await notifier.setDateFormat(AppDateFormat.iso);
      await notifier.setDayStartHour(4);

      expect(prefs.getInt(kWeekStartKey), WeekStartDay.monday.index);
      expect(prefs.getInt(kClockFormatKey), ClockFormat.twentyFourHour.index);
      expect(prefs.getInt(kDateFormatKey), AppDateFormat.iso.index);
      expect(prefs.getInt(kDayStartHourKey), 4);
    });

    test('a saved choice is read back on the next start', () async {
      final prefs = await freshPrefs();
      await DateTimeSettingsNotifier(prefs).setDateFormat(AppDateFormat.iso);

      final reloaded = DateTimeSettingsNotifier(prefs).state;
      expect(reloaded.dateFormat, AppDateFormat.iso);
    });
  });

  group('the shared date helpers', () {
    test('are set from the saved values when the notifier is built', () async {
      final prefs = await freshPrefs({
        kDayStartHourKey: 5,
        kDateFormatKey: AppDateFormat.iso.index,
        kClockFormatKey: ClockFormat.twentyFourHour.index,
      });
      DateTimeSettingsNotifier(prefs);

      expect(date_utils.dayStartHour, 5);
      expect(date_utils.appDateFormat, AppDateFormat.iso);
      expect(date_utils.clockFormat, ClockFormat.twentyFourHour);
    });

    test('follow a change made later', () async {
      final notifier = DateTimeSettingsNotifier(await freshPrefs());

      await notifier.setDayStartHour(3);
      expect(date_utils.dayStartHour, 3);

      await notifier.setDateFormat(AppDateFormat.dayMonthYear);
      expect(date_utils.appDateFormat, AppDateFormat.dayMonthYear);
    });

    test(
      'a day start outside the range is clamped before it is saved',
      () async {
        final prefs = await freshPrefs();
        final notifier = DateTimeSettingsNotifier(prefs);

        await notifier.setDayStartHour(50);

        expect(notifier.state.dayStartHour, kMaxDayStartHour);
        expect(date_utils.dayStartHour, kMaxDayStartHour);
      },
    );
  });

  group('working days', () {
    test('a day can be turned off and on again', () async {
      final prefs = await freshPrefs();
      final notifier = DateTimeSettingsNotifier(prefs);

      await notifier.toggleWorkingDay(DateTime.monday, false);
      expect(notifier.state.workingDays, isNot(contains(DateTime.monday)));

      await notifier.toggleWorkingDay(DateTime.saturday, true);
      expect(notifier.state.workingDays, contains(DateTime.saturday));

      expect(
        parseWorkingDays(prefs.getStringList(kWorkingDaysKey)),
        notifier.state.workingDays,
      );
    });

    test('a weekday number outside 1 to 7 is ignored', () async {
      final notifier = DateTimeSettingsNotifier(await freshPrefs());

      await notifier.toggleWorkingDay(0, true);
      await notifier.toggleWorkingDay(8, true);

      expect(notifier.state.workingDays, kDefaultWorkingDays);
    });

    test('reset puts Monday to Friday back', () async {
      final notifier = DateTimeSettingsNotifier(await freshPrefs());

      await notifier.toggleWorkingDay(DateTime.monday, false);
      await notifier.toggleWorkingDay(DateTime.sunday, true);
      await notifier.resetWorkingDays();

      expect(notifier.state.workingDays, kDefaultWorkingDays);
    });

    test('every day can be turned off', () async {
      final notifier = DateTimeSettingsNotifier(await freshPrefs());

      for (final day in kAllWeekdays) {
        await notifier.toggleWorkingDay(day, false);
      }

      expect(notifier.state.workingDays, isEmpty);
    });
  });
}
