import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Dart side of the keep-the-screen-on platform channel.
///
/// Android only. The host sets or clears `FLAG_KEEP_SCREEN_ON` on the window.
/// A small channel is used instead of a package so the audited dependency list
/// stays unchanged. Everywhere else this is a safe no-op.
class ScreenWakeChannel {
  ScreenWakeChannel({MethodChannel? channel, bool? isSupported})
    : _channel = channel ?? const MethodChannel(channelName),
      _isSupported = isSupported ?? _defaultIsSupported();

  /// The channel name, kept beside the existing database-key channel.
  static const String channelName = 'in.sreerajp.todo/screen_wake';

  final MethodChannel _channel;
  final bool _isSupported;

  static bool _defaultIsSupported() {
    if (kIsWeb) return false;
    return Platform.isAndroid;
  }

  /// Asks the host to keep the screen on, or lets it sleep again.
  ///
  /// Never throws. A screen that dims is a small annoyance, so a channel
  /// failure is swallowed rather than allowed to break the timer.
  Future<void> setKeepAwake(bool enabled) async {
    if (!_isSupported) return;
    try {
      await _channel.invokeMethod<void>('setKeepAwake', {'enabled': enabled});
    } on PlatformException catch (e) {
      debugPrint('ScreenWakeChannel: keep-awake request failed (${e.code})');
    } on MissingPluginException {
      debugPrint('ScreenWakeChannel: host does not handle keep-awake');
    }
  }
}
