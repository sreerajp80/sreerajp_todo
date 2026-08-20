import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:sreerajp_todo/core/utils/win32_dpapi.dart';

/// Encrypts a short secret so it can be kept on disk.
///
/// Used for the backup passphrase, which has to be available without asking
/// when a scheduled backup runs. The plain text never reaches preferences: on
/// Android the Android Keystore does the encryption, on Windows it is DPAPI.
/// Both tie the result to this device and this app.
///
/// Every method fails quietly by returning null rather than throwing. A secret
/// that cannot be stored simply means the app asks for it instead, which is
/// always a working fallback.
class SecretStore {
  SecretStore({MethodChannel? methodChannel, this.win32dpapi})
    : _methodChannel =
          methodChannel ?? const MethodChannel('in.sreerajp.todo/database_key');

  final MethodChannel _methodChannel;

  /// Injected only by the Windows tests. Null means "make a real one".
  final Win32Dpapi? win32dpapi;

  bool get _isTestEnvironment => Platform.environment['FLUTTER_TEST'] == 'true';

  /// Whether this platform can keep a secret at all.
  ///
  /// The settings page reads this to decide whether to offer "remember my
  /// passphrase" instead of failing later.
  bool get isSupported =>
      _isTestEnvironment || Platform.isAndroid || Platform.isWindows;

  /// Encrypts [plainText] into an opaque string, or null when it cannot.
  Future<String?> encrypt(String plainText) async {
    if (plainText.isEmpty) return null;

    if (_isTestEnvironment) {
      // No platform key store under test. The value is still not readable at a
      // glance, and no real secret exists in a test run.
      return base64Encode(utf8.encode(plainText));
    }

    if (Platform.isAndroid) {
      try {
        return await _methodChannel.invokeMethod<String>('encryptSecret', {
          'plainText': plainText,
        });
      } on PlatformException {
        return null;
      } on MissingPluginException {
        return null;
      }
    }

    if (Platform.isWindows) {
      try {
        final dpapi = win32dpapi ?? Win32Dpapi();
        final protectedBytes = dpapi.protect(
          Uint8List.fromList(utf8.encode(plainText)),
        );
        return base64Encode(protectedBytes);
      } on Exception {
        return null;
      }
    }

    return null;
  }

  /// Reads back what [encrypt] wrote, or null when it cannot.
  Future<String?> decrypt(String storedValue) async {
    if (storedValue.isEmpty) return null;

    if (_isTestEnvironment) {
      try {
        return utf8.decode(base64Decode(storedValue));
      } on FormatException {
        return null;
      }
    }

    if (Platform.isAndroid) {
      try {
        return await _methodChannel.invokeMethod<String>('decryptSecret', {
          'cipherText': storedValue,
        });
      } on PlatformException {
        return null;
      } on MissingPluginException {
        return null;
      }
    }

    if (Platform.isWindows) {
      try {
        final dpapi = win32dpapi ?? Win32Dpapi();
        final rawBytes = dpapi.unprotect(base64Decode(storedValue));
        return utf8.decode(rawBytes);
      } on Exception {
        // Covers a corrupt stored value as well as a DPAPI failure: either way
        // the app just asks for the passphrase again.
        return null;
      }
    }

    return null;
  }
}
