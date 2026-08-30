import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_todo/core/platform/running_notification_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RunningNotificationChannel', () {
    test('safe no-op when not supported', () async {
      final channel = RunningNotificationChannel(isSupported: false);

      await channel.showRunningNotification(
        title: 'Test Task',
        startTime: DateTime.now(),
      );
      await channel.hideRunningNotification();
      final hasPerm = await channel.hasPermission();
      final reqPerm = await channel.requestPermission();

      expect(hasPerm, isTrue);
      expect(reqPerm, isTrue);
    });

    test('calls show and hide on platform method channel', () async {
      final calls = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel(RunningNotificationChannel.channelName),
            (call) async {
              calls.add(call);
              switch (call.method) {
                case 'show':
                case 'hide':
                case 'hasPermission':
                case 'requestPermission':
                  return true;
                default:
                  return null;
              }
            },
          );

      final channel = RunningNotificationChannel(isSupported: true);
      final startTime = DateTime(2026, 8, 27, 10, 30);

      await channel.showRunningNotification(
        title: 'Running Task Title',
        startTime: startTime,
      );
      expect(calls.length, 1);
      expect(calls.first.method, 'show');
      expect(calls.first.arguments['title'], 'Running Task Title');
      expect(
        calls.first.arguments['startTimeMillis'],
        startTime.millisecondsSinceEpoch,
      );

      await channel.hideRunningNotification();
      expect(calls.length, 2);
      expect(calls[1].method, 'hide');

      final hasPerm = await channel.hasPermission();
      expect(hasPerm, isTrue);
      expect(calls.length, 3);
      expect(calls[2].method, 'hasPermission');

      final reqPerm = await channel.requestPermission();
      expect(reqPerm, isTrue);
      expect(calls.length, 4);
      expect(calls[3].method, 'requestPermission');
    });
  });
}
