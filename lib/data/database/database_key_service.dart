import 'dart:io';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sreerajp_todo/core/utils/win32_dpapi.dart';

class DatabaseKeyService {
  DatabaseKeyService({
    MethodChannel? methodChannel,
    this._win32dpapi,
  })  : _methodChannel =
            methodChannel ??
            const MethodChannel('in.sreerajp.todo/database_key');

  final MethodChannel _methodChannel;
  final Win32Dpapi? _win32dpapi;
  String? _cachedKeyHex;

  bool get _isTestEnvironment =>
      Platform.environment['FLUTTER_TEST'] == 'true';

  Future<String> getOrCreateDatabaseKey() async {
    if (_cachedKeyHex != null) {
      return _cachedKeyHex!;
    }

    if (_isTestEnvironment) {
      _cachedKeyHex =
          '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';
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
    final fallbackFile = File(p.join(docsDir.path, 'sreerajp_todo_fallback.key'));
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

  String _bytesToHex(Uint8List bytes) {
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }
}
