import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Dart side of the running todo ongoing notification platform channel.
///
/// Android only. The host displays an ongoing status bar and notification drawer
/// notification with a live ticking chronometer for the currently active task timer.
/// A lightweight platform channel is used instead of external packages to maintain
/// the 100% offline inventory. Everywhere else this is a safe no-op.
class RunningNotificationChannel {
  RunningNotificationChannel({MethodChannel? channel, bool? isSupported})
    : _channel = channel ?? const MethodChannel(channelName),
      _isSupported = isSupported ?? _defaultIsSupported();

  /// The channel name, kept beside the existing screen-wake and speech channels.
  static const String channelName = 'in.sreerajp.todo/running_notification';

  final MethodChannel _channel;
  final bool _isSupported;

  static bool _defaultIsSupported() {
    if (kIsWeb) return false;
    return Platform.isAndroid;
  }

  /// Displays or updates the ongoing notification for the running todo.
  ///
  /// [title] is the task title displayed in the notification headline.
  /// [startTime] is when the timer started, used by Android's chronometer.
  Future<void> showRunningNotification({
    required String title,
    required DateTime startTime,
  }) async {
    if (!_isSupported) return;
    try {
      await _channel.invokeMethod<bool>('show', {
        'title': title,
        'startTimeMillis': startTime.millisecondsSinceEpoch,
      });
    } on PlatformException catch (e) {
      debugPrint('RunningNotificationChannel: show failed (${e.code})');
    } on MissingPluginException {
      debugPrint('RunningNotificationChannel: host does not handle show');
    }
  }

  /// Dismisses and cancels the ongoing notification.
  Future<void> hideRunningNotification() async {
    if (!_isSupported) return;
    try {
      await _channel.invokeMethod<bool>('hide');
    } on PlatformException catch (e) {
      debugPrint('RunningNotificationChannel: hide failed (${e.code})');
    } on MissingPluginException {
      debugPrint('RunningNotificationChannel: host does not handle hide');
    }
  }

  /// Checks if POST_NOTIFICATIONS permission is granted (API 33+).
  Future<bool> hasPermission() async {
    if (!_isSupported) return true;
    try {
      final granted = await _channel.invokeMethod<bool>('hasPermission');
      return granted ?? true;
    } on PlatformException catch (e) {
      debugPrint(
        'RunningNotificationChannel: hasPermission failed (${e.code})',
      );
      return true;
    } on MissingPluginException {
      return true;
    }
  }

  /// Requests notification permission on Android 13+.
  Future<bool> requestPermission() async {
    if (!_isSupported) return true;
    try {
      final granted = await _channel.invokeMethod<bool>('requestPermission');
      return granted ?? true;
    } on PlatformException catch (e) {
      debugPrint(
        'RunningNotificationChannel: requestPermission failed (${e.code})',
      );
      return true;
    } on MissingPluginException {
      return true;
    }
  }
}
