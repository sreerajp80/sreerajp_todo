import 'dart:io';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sreerajp_todo/core/utils/win32_dpapi.dart';

class DatabaseKeyService {
  DatabaseKeyService({MethodChannel? methodChannel, this._win32dpapi})
    : _methodChannel =
          methodChannel ?? const MethodChannel('in.sreerajp.todo/database_key');

  final MethodChannel _methodChannel;
  final Win32Dpapi? _win32dpapi;
  String? _cachedKeyHex;

  /// The key handed out under test, made once per process.
  ///
  /// It is random rather than a fixed literal so no key-shaped constant ends up
  /// compiled into the shipped binary. Every instance in a run shares it, so a
  /// test that reopens a database with a fresh service still gets the same key.
  static final String _testKeyHex = _randomKeyHex();

  bool get _isTestEnvironment => Platform.environment['FLUTTER_TEST'] == 'true';

  Future<String> getOrCreateDatabaseKey() async {
    if (_cachedKeyHex != null) {
      return _cachedKeyHex!;
    }

    if (_isTestEnvironment) {
      _cachedKeyHex = _testKeyHex;
      return _cachedKeyHex!;
    }

    if (Platform.isAndroid) {
      try {
        final keyHex = await _methodChannel.invokeMethod<String>(
          'getOrCreateDatabaseKey',
        );
        if (keyHex != null && keyHex.length == 64) {
          _cachedKeyHex = keyHex;
          return _cachedKeyHex!;
        }
      } catch (e) {
        // Fallback to fallback secure key storage if channel fails
      }
    }

    if (Platform.isWindows) {
      final dpapi = _win32dpapi ?? Win32Dpapi();
      final docsDir = await getApplicationDocumentsDirectory();
      final keyFilePath = p.join(docsDir.path, 'sreerajp_todo_db.key');
      final keyFile = File(keyFilePath);

      if (await keyFile.exists()) {
        final protectedBytes = await keyFile.readAsBytes();
        final rawKeyBytes = dpapi.unprotect(protectedBytes);
        _cachedKeyHex = _bytesToHex(rawKeyBytes);
        return _cachedKeyHex!;
      } else {
        final rawKeyBytes = Uint8List(32);
        final random = Random.secure();
        for (var i = 0; i < 32; i++) {
          rawKeyBytes[i] = random.nextInt(256);
        }
        final protectedBytes = dpapi.protect(rawKeyBytes);
        await keyFile.writeAsBytes(protectedBytes, flush: true);
        _cachedKeyHex = _bytesToHex(rawKeyBytes);
        return _cachedKeyHex!;
      }
    }

    // Default fallback for linux / macos / development
    final docsDir = await getApplicationDocumentsDirectory();
    final fallbackFile = File(
      p.join(docsDir.path, 'sreerajp_todo_fallback.key'),
    );
    if (await fallbackFile.exists()) {
      _cachedKeyHex = (await fallbackFile.readAsString()).trim();
      return _cachedKeyHex!;
    } else {
      final rawKeyBytes = Uint8List(32);
      final random = Random.secure();
      for (var i = 0; i < 32; i++) {
        rawKeyBytes[i] = random.nextInt(256);
      }
      final keyHex = _bytesToHex(rawKeyBytes);
      await fallbackFile.writeAsString(keyHex, flush: true);
      _cachedKeyHex = keyHex;
      return _cachedKeyHex!;
    }
  }

  /// A fresh random 256-bit key, as 64 hex characters.
  ///
  /// Only generates the value. Nothing is stored until [storeDatabaseKey] is
  /// called, so a caller can rekey the database first and keep the old key
  /// usable until that has actually worked.
  String generateKeyHex() => _randomKeyHex();

  /// A fresh random 256-bit key as 64 hex characters.
  static String _randomKeyHex() {
    final rawKeyBytes = Uint8List(32);
    final random = Random.secure();
    for (var i = 0; i < 32; i++) {
      rawKeyBytes[i] = random.nextInt(256);
    }
    return rawKeyBytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  /// Replaces the stored database key with [keyHex].
  ///
  /// Returns false when the key could not be written, in which case the old
  /// key is still the stored one and the caller must put the database back.
  /// Never logs the key.
  Future<bool> storeDatabaseKey(String keyHex) async {
    if (keyHex.length != 64) return false;

    if (_isTestEnvironment) {
      _cachedKeyHex = keyHex;
      return true;
    }

    if (Platform.isAndroid) {
      try {
        final stored = await _methodChannel.invokeMethod<bool>(
          'storeDatabaseKey',
          {'keyHex': keyHex},
        );
        if (stored ?? false) {
          _cachedKeyHex = keyHex;
          return true;
        }
        return false;
      } catch (_) {
        return false;
      }
    }

    if (Platform.isWindows) {
      try {
        final dpapi = _win32dpapi ?? Win32Dpapi();
        final docsDir = await getApplicationDocumentsDirectory();
        final keyFile = File(p.join(docsDir.path, 'sreerajp_todo_db.key'));
        final protectedBytes = dpapi.protect(_hexToBytes(keyHex));
        await keyFile.writeAsBytes(protectedBytes, flush: true);
        _cachedKeyHex = keyHex;
        return true;
      } catch (_) {
        return false;
      }
    }

    try {
      final docsDir = await getApplicationDocumentsDirectory();
      final fallbackFile = File(
        p.join(docsDir.path, 'sreerajp_todo_fallback.key'),
      );
      await fallbackFile.writeAsString(keyHex, flush: true);
      _cachedKeyHex = keyHex;
      return true;
    } catch (_) {
      return false;
    }
  }

  String _bytesToHex(Uint8List bytes) {
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  Uint8List _hexToBytes(String hex) {
    final bytes = Uint8List(hex.length ~/ 2);
    for (var i = 0; i < bytes.length; i++) {
      bytes[i] = int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16);
    }
    return bytes;
  }
}
