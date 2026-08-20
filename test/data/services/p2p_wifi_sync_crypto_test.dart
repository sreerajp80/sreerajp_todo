import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_todo/data/services/p2p_wifi_sync_crypto.dart';

void main() {
  group('P2pWifiSyncCrypto Unit Tests', () {
    test('generatePairingPin returns a 6-digit numeric string', () {
      final pin = P2pWifiSyncCrypto.generatePairingPin();
      expect(pin.length, equals(6));
      expect(int.tryParse(pin), isNotNull);
    });

    test('generateSalt produces requested byte length', () {
      final salt = P2pWifiSyncCrypto.generateSalt(16);
      expect(salt.length, equals(16));
    });

    test('deriveSessionKey produces 32-byte key from PIN and salt', () {
      final salt = Uint8List.fromList(List.generate(16, (i) => i));
      final key = P2pWifiSyncCrypto.deriveSessionKey(pin: '123456', salt: salt);
      expect(key.length, equals(32));

      final key2 = P2pWifiSyncCrypto.deriveSessionKey(
        pin: '123456',
        salt: salt,
      );
      expect(key, equals(key2));
    });

    test('encryptPayload and decryptPayload roundtrip successfully', () {
      final salt = P2pWifiSyncCrypto.generateSalt(16);
      final key = P2pWifiSyncCrypto.deriveSessionKey(pin: '654321', salt: salt);
      const plainText = '{"title":"Test P2P Wi-Fi Sync","status":"pending"}';

      final encrypted = P2pWifiSyncCrypto.encryptPayload(
        plainText: plainText,
        sessionKey: key,
      );
      expect(encrypted, isNotEmpty);
      expect(encrypted.contains('nonce'), isTrue);
      expect(encrypted.contains('cipher'), isTrue);
      expect(encrypted.contains('mac'), isTrue);

      final decrypted = P2pWifiSyncCrypto.decryptPayload(
        encryptedPackage: encrypted,
        sessionKey: key,
      );
      expect(decrypted, equals(plainText));
    });

    test('decryptPayload throws FormatException when payload is tampered', () {
      final salt = P2pWifiSyncCrypto.generateSalt(16);
      final key = P2pWifiSyncCrypto.deriveSessionKey(pin: '999888', salt: salt);
      const plainText = 'Secret task payload';

      final encrypted = P2pWifiSyncCrypto.encryptPayload(
        plainText: plainText,
        sessionKey: key,
      );

      // Tamper cipher text
      final tampered = encrypted.replaceAll('a', 'b');

      expect(
        () => P2pWifiSyncCrypto.decryptPayload(
          encryptedPackage: tampered,
          sessionKey: key,
        ),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
