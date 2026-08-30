import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sreerajp_todo/application/pending_alert_notifier.dart';
import 'package:sreerajp_todo/data/models/todo_entity.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<SharedPreferences> freshPrefs([
    Map<String, Object> values = const {},
  ]) async {
    SharedPreferences.setMockInitialValues(values);
    return SharedPreferences.getInstance();
  }

  group('PendingAlertPayload', () {
    test('calculates counts correctly for today and previous todos', () {
      const payloadEmpty = PendingAlertPayload();
      expect(payloadEmpty.isEmpty, isTrue);
      expect(payloadEmpty.totalCount, 0);

      const payloadWithItems = PendingAlertPayload(
        todayTodos: [
          TodoEntity(
            id: '1',
            date: '2026-08-28',
            title: 'Task 1',
            createdAt: '2026-08-28T09:00:00Z',
            updatedAt: '2026-08-28T09:00:00Z',
          ),
        ],
        previousTodos: [
          TodoEntity(
            id: '2',
            date: '2026-08-27',
            title: 'Task 2',
            createdAt: '2026-08-27T09:00:00Z',
            updatedAt: '2026-08-27T09:00:00Z',
          ),
        ],
      );

      expect(payloadWithItems.isEmpty, isFalse);
      expect(payloadWithItems.isNotEmpty, isTrue);
      expect(payloadWithItems.totalCount, 2);
    });
  });

  group('PendingAlertNotifier defaults', () {
    test('default settings are active with sensible defaults', () async {
      final state = PendingAlertNotifier(await freshPrefs()).state;

      expect(state.enabled, isTrue);
      expect(state.dayStartAlertEnabled, isTrue);
      expect(state.dayStartHour, kDefaultPendingDayStartHour);
      expect(state.dayStartMinute, kDefaultPendingDayStartMinute);
      expect(state.intervalMinutes, kDefaultPendingIntervalMinutes);
      expect(state.haptic, isTrue);
      expect(state.lastDayAlertDate, isNull);
      expect(state.lastIntervalAlertEpoch, isNull);
    });

    test('saved preferences are loaded correctly on startup', () async {
      final state = PendingAlertNotifier(
        await freshPrefs({
          kPendingAlertsEnabledKey: false,
          kPendingAlertsDayStartKey: false,
          kPendingAlertsDayStartHourKey: 8,
          kPendingAlertsDayStartMinuteKey: 30,
          kPendingAlertsIntervalMinutesKey: 60,
          kPendingAlertsHapticKey: false,
          kPendingAlertsLastDayKey: '2026-08-27',
        }),
      ).state;

      expect(state.enabled, isFalse);
      expect(state.dayStartAlertEnabled, isFalse);
      expect(state.dayStartHour, 8);
      expect(state.dayStartMinute, 30);
      expect(state.intervalMinutes, 60);
      expect(state.haptic, isFalse);
      expect(state.lastDayAlertDate, '2026-08-27');
    });
  });

  group('PendingAlertNotifier mutations', () {
    test('updating settings persists to SharedPreferences', () async {
      final prefs = await freshPrefs();
      final notifier = PendingAlertNotifier(prefs);

      await notifier.setEnabled(false);
      await notifier.setDayStartAlertEnabled(true);
      await notifier.setDayStartTime(10, 15);
      await notifier.setIntervalMinutes(180);
      await notifier.setHaptic(false);
      await notifier.markDayAlertShown('2026-08-27');

      final reloaded = PendingAlertNotifier(prefs).state;
      expect(reloaded.enabled, isFalse);
      expect(reloaded.dayStartAlertEnabled, isTrue);
      expect(reloaded.dayStartHour, 10);
      expect(reloaded.dayStartMinute, 15);
      expect(reloaded.intervalMinutes, 180);
      expect(reloaded.haptic, isFalse);
      expect(reloaded.lastDayAlertDate, '2026-08-27');
    });
  });

  group('Day start alert trigger logic', () {
    test(
      'triggers when day start time is reached and not already shown today',
      () async {
        final notifier = PendingAlertNotifier(await freshPrefs());
        await notifier.setDayStartTime(9, 0);

        final beforeTime = DateTime(2026, 8, 27, 8, 59);
        final atTime = DateTime(2026, 8, 27, 9, 0);
        final afterTime = DateTime(2026, 8, 27, 10, 30);

        expect(
          notifier.state.shouldTriggerDayStartAlert('2026-08-27', beforeTime),
          isFalse,
        );
        expect(
          notifier.state.shouldTriggerDayStartAlert('2026-08-27', atTime),
          isTrue,
        );
        expect(
          notifier.state.shouldTriggerDayStartAlert('2026-08-27', afterTime),
          isTrue,
        );

        // After marked as shown today
        await notifier.markDayAlertShown('2026-08-27');
        expect(
          notifier.state.shouldTriggerDayStartAlert('2026-08-27', afterTime),
          isFalse,
        );
        // Next day it should trigger again
        expect(
          notifier.state.shouldTriggerDayStartAlert('2026-08-28', afterTime),
          isTrue,
        );
      },
    );

    test('stays quiet when master enabled or day start is false', () async {
      final notifier = PendingAlertNotifier(await freshPrefs());
      await notifier.setEnabled(false);

      final now = DateTime(2026, 8, 27, 10, 0);
      expect(
        notifier.state.shouldTriggerDayStartAlert('2026-08-27', now),
        isFalse,
      );
    });
  });

  group('Interval alert trigger logic', () {
    test('triggers after configured interval minutes elapsed', () async {
      final notifier = PendingAlertNotifier(await freshPrefs());
      await notifier.setIntervalMinutes(60); // 1 hour

      final baseTime = DateTime(2026, 8, 27, 10, 0);
      await notifier.markIntervalAlertShown(baseTime.millisecondsSinceEpoch);

      final before30m = DateTime(2026, 8, 27, 10, 30);
      final after60m = DateTime(2026, 8, 27, 11, 0);
      final after90m = DateTime(2026, 8, 27, 11, 30);

      expect(notifier.state.shouldTriggerIntervalAlert(before30m), isFalse);
      expect(notifier.state.shouldTriggerIntervalAlert(after60m), isTrue);
      expect(notifier.state.shouldTriggerIntervalAlert(after90m), isTrue);
    });

    test('stays quiet when interval is 0 (off)', () async {
      final notifier = PendingAlertNotifier(await freshPrefs());
      await notifier.setIntervalMinutes(0);
      await notifier.markIntervalAlertShown(
        DateTime(2026, 8, 27, 10, 0).millisecondsSinceEpoch,
      );

      final later = DateTime(2026, 8, 27, 14, 0);
      expect(notifier.state.shouldTriggerIntervalAlert(later), isFalse);
    });
  });
}
