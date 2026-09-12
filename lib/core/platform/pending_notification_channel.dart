import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Dart side of the pending task reminders notification channel.
///
/// Android only. Uses the host's native NotificationManager to show local
/// reminder notifications without adding any external package.
class PendingNotificationChannel {
  PendingNotificationChannel({MethodChannel? channel, bool? isSupported})
    : _channel = channel ?? const MethodChannel(channelName),
      _isSupported = isSupported ?? _defaultIsSupported();

  static const String channelName = 'in.sreerajp.todo/pending_notification';

  final MethodChannel _channel;
  final bool _isSupported;

  static bool _defaultIsSupported() {
    if (kIsWeb) return false;
    return Platform.isAndroid;
  }

  /// Displays an Android status-bar notification for pending tasks.
  Future<void> showReminder({
    required String title,
    required String body,
    int count = 1,
  }) async {
    if (!_isSupported) return;
    try {
      await _channel.invokeMethod<void>('show', {
        'title': title,
        'body': body,
        'count': count,
      });
    } on PlatformException catch (e) {
      debugPrint('PendingNotificationChannel: show failed (${e.code})');
    } on MissingPluginException {
      debugPrint(
        'PendingNotificationChannel: host does not handle pending notifications',
      );
    }
  }

  /// Cancels any active pending task notification.
  Future<void> cancel() async {
    if (!_isSupported) return;
    try {
      await _channel.invokeMethod<void>('cancel');
    } on PlatformException catch (e) {
      debugPrint('PendingNotificationChannel: cancel failed (${e.code})');
    } on MissingPluginException {
      debugPrint(
        'PendingNotificationChannel: host does not handle pending notifications',
      );
    }
  }

  /// Schedules background alarms via Android AlarmManager so reminders
  /// trigger even when the application is killed or the device is asleep.
  Future<void> scheduleAlerts({
    required bool enabled,
    required bool dayStartAlertEnabled,
    required int dayStartHour,
    required int dayStartMinute,
    required int intervalMinutes,
    required int count,
  }) async {
    if (!_isSupported) return;
    try {
      await _channel.invokeMethod<void>('scheduleAlerts', {
        'enabled': enabled,
        'dayStartEnabled': dayStartAlertEnabled,
        'dayStartHour': dayStartHour,
        'dayStartMinute': dayStartMinute,
        'intervalMinutes': intervalMinutes,
        'count': count,
      });
    } on PlatformException catch (e) {
      debugPrint(
        'PendingNotificationChannel: scheduleAlerts failed (${e.code})',
      );
    } on MissingPluginException {
      debugPrint(
        'PendingNotificationChannel: host does not handle scheduleAlerts',
      );
    }
  }

  /// Cancels any pending background alarms.
  Future<void> cancelScheduledAlerts() async {
    if (!_isSupported) return;
    try {
      await _channel.invokeMethod<void>('cancelScheduledAlerts');
    } on PlatformException catch (e) {
      debugPrint(
        'PendingNotificationChannel: cancelScheduledAlerts failed (${e.code})',
      );
    } on MissingPluginException {
      debugPrint(
        'PendingNotificationChannel: host does not handle cancelScheduledAlerts',
      );
    }
  }

  /// Checks if POST_NOTIFICATIONS permission is granted (Android 13+).
  Future<bool> hasPermission() async {
    if (!_isSupported) return true;
    try {
      final granted = await _channel.invokeMethod<bool>('hasPermission');
      return granted ?? true;
    } catch (_) {
      return true;
    }
  }

  /// Prompts the system permission dialog for POST_NOTIFICATIONS (Android 13+).
  Future<bool> requestPermission() async {
    if (!_isSupported) return true;
    try {
      final granted = await _channel.invokeMethod<bool>('requestPermission');
      return granted ?? true;
    } catch (_) {
      return true;
    }
  }
}
