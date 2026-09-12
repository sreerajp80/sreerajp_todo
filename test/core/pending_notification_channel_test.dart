import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_todo/core/platform/pending_notification_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PendingNotificationChannel', () {
    test('safe no-op when not supported', () async {
      final channel = PendingNotificationChannel(isSupported: false);

      await channel.showReminder(title: 'Test', body: 'Body', count: 2);
      await channel.cancel();
      await channel.scheduleAlerts(
        enabled: true,
        dayStartAlertEnabled: true,
        dayStartHour: 9,
        dayStartMinute: 0,
        intervalMinutes: 120,
        count: 3,
      );
      await channel.cancelScheduledAlerts();
      final hasPerm = await channel.hasPermission();
      final reqPerm = await channel.requestPermission();

      expect(hasPerm, isTrue);
      expect(reqPerm, isTrue);
    });

    test(
      'calls scheduleAlerts and cancelScheduledAlerts via method channel',
      () async {
        final calls = <MethodCall>[];
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
              const MethodChannel(PendingNotificationChannel.channelName),
              (call) async {
                calls.add(call);
                switch (call.method) {
                  case 'show':
                  case 'cancel':
                  case 'scheduleAlerts':
                  case 'cancelScheduledAlerts':
                  case 'hasPermission':
                  case 'requestPermission':
                    return true;
                  default:
                    return null;
                }
              },
            );

        final channel = PendingNotificationChannel(isSupported: true);

        await channel.scheduleAlerts(
          enabled: true,
          dayStartAlertEnabled: true,
          dayStartHour: 8,
          dayStartMinute: 30,
          intervalMinutes: 60,
          count: 5,
        );

        expect(calls.length, 1);
        expect(calls.first.method, 'scheduleAlerts');
        expect(calls.first.arguments['enabled'], isTrue);
        expect(calls.first.arguments['dayStartEnabled'], isTrue);
        expect(calls.first.arguments['dayStartHour'], 8);
        expect(calls.first.arguments['dayStartMinute'], 30);
        expect(calls.first.arguments['intervalMinutes'], 60);
        expect(calls.first.arguments['count'], 5);

        await channel.cancelScheduledAlerts();
        expect(calls.length, 2);
        expect(calls[1].method, 'cancelScheduledAlerts');
      },
    );
  });
}
