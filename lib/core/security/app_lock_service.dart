import 'dart:convert';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';

import 'package:sreerajp_todo/core/utils/crypto_utils.dart';

/// A stored PIN or password, as salt and hash only.
///
/// The secret itself is never held here, never written to preferences and
/// never logged. Losing this record means the lock can only be cleared by
/// reinstalling, which is why the setup screen warns about it.
class AppLockCredential {
  const AppLockCredential({
    required this.saltBase64,
    required this.hashBase64,
    required this.iterations,
  });

  final String saltBase64;
  final String hashBase64;

  /// Kept alongside the hash so an older record still verifies after the work
  /// factor is raised in a later version.
  final int iterations;
}

/// Turns a PIN or password into a salted hash, and checks one against it.
///
/// The hashing runs on its own isolate. It is deliberately slow, and the
/// unlock screen must stay responsive while it happens.
class AppLockService {
  const AppLockService();

  /// The work factor for a new secret.
  ///
  /// Lower than the backup passphrase's count on purpose. The lock screen has
  /// to answer while somebody is standing there holding the phone, and the
  /// growing wait after wrong tries is what actually holds off guessing.
  static const int unlockIterations = 100000;

  /// The salt length in bytes.
  static const int saltLength = 16;

  /// Hashes [secret] with a fresh random salt.
  Future<AppLockCredential> createCredential(String secret) async {
    final random = Random.secure();
    final salt = Uint8List(saltLength);
    for (var i = 0; i < saltLength; i++) {
      salt[i] = random.nextInt(256);
    }

    final hash = await _derive(secret, salt, unlockIterations);
    return AppLockCredential(
      saltBase64: base64Encode(salt),
      hashBase64: base64Encode(hash),
      iterations: unlockIterations,
    );
  }

  /// Whether [secret] matches [stored].
  Future<bool> verify(String secret, AppLockCredential stored) async {
    final Uint8List salt;
    final Uint8List expected;
    try {
      salt = base64Decode(stored.saltBase64);
      expected = base64Decode(stored.hashBase64);
    } on FormatException {
      // A record that cannot be read can never match. Failing closed here is
      // safer than letting a corrupt record open the app.
      return false;
    }

    final actual = await _derive(secret, salt, stored.iterations);
    return _constantTimeEquals(actual, expected);
  }

  Future<Uint8List> _derive(String secret, Uint8List salt, int iterations) {
    return Isolate.run(
      () => CryptoUtils.deriveKey(
        passphrase: secret,
        salt: salt,
        iterations: iterations,
      ),
    );
  }

  /// Compares two hashes without stopping early on the first difference, so
  /// the time taken says nothing about how much of the hash was right.
  static bool _constantTimeEquals(Uint8List a, Uint8List b) {
    if (a.length != b.length) return false;
    var difference = 0;
    for (var i = 0; i < a.length; i++) {
      difference |= a[i] ^ b[i];
    }
    return difference == 0;
  }
}
