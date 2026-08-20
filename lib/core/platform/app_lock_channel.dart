import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Dart side of the app-lock platform channel.
///
/// Android only. It does two things the framework cannot: it sets
/// `FLAG_SECURE` so the recent-apps preview stays blank, and it shows the
/// phone's own unlock screen, which uses fingerprint or face where the user
/// set that up. A small channel is used instead of a package so the audited
/// dependency list stays unchanged. Everywhere else these are safe no-ops.
class AppLockChannel {
  AppLockChannel({MethodChannel? channel, bool? isSupported})
    : _channel = channel ?? const MethodChannel(channelName),
      _isSupported = isSupported ?? _defaultIsSupported();

  /// The channel name, kept beside the existing database-key channel.
  static const String channelName = 'in.sreerajp.todo/app_lock';

  final MethodChannel _channel;
  final bool _isSupported;

  static bool _defaultIsSupported() {
    if (kIsWeb) return false;
    return Platform.isAndroid;
  }

  /// Whether this platform can do any of it.
  bool get isSupported => _isSupported;

  /// Hides the app contents from the recent-apps preview and from
  /// screenshots, or shows them again.
  ///
  /// Never throws. Failing here is a privacy setting that did not take, not a
  /// reason to stop the app, and the caller has nothing useful to do about it.
  Future<void> setSecureFlag(bool enabled) async {
    if (!_isSupported) return;
    try {
      await _channel.invokeMethod<void>('setSecureFlag', {'enabled': enabled});
    } on PlatformException catch (e) {
      debugPrint('AppLockChannel: secure flag request failed (${e.code})');
    } on MissingPluginException {
      debugPrint('AppLockChannel: host does not handle the secure flag');
    }
  }

  /// Whether the phone has a screen lock set up at all.
  ///
  /// Without one there is nothing to confirm against, so the settings page
  /// hides that choice rather than offering a lock that cannot open.
  Future<bool> isDeviceCredentialAvailable() async {
    if (!_isSupported) return false;
    try {
      final available = await _channel.invokeMethod<bool>(
        'isDeviceCredentialAvailable',
      );
      return available ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  /// Shows the phone unlock screen and waits for the answer.
  ///
  /// Returns true only on a real success. Anything else, including the user
  /// backing out and any channel failure, returns false, so a problem here can
  /// never open a locked app.
  Future<bool> authenticate({
    required String title,
    required String description,
  }) async {
    if (!_isSupported) return false;
    try {
      final unlocked = await _channel.invokeMethod<bool>(
        'authenticateWithDeviceCredential',
        {'title': title, 'description': description},
      );
      return unlocked ?? false;
    } on PlatformException catch (e) {
      debugPrint('AppLockChannel: unlock request failed (${e.code})');
      return false;
    } on MissingPluginException {
      debugPrint('AppLockChannel: host does not handle unlock');
      return false;
    }
  }
}
