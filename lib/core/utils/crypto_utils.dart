import 'dart:convert';
import 'dart:typed_data';

/// Pure Dart Cryptography utilities for PBKDF2 key derivation and AES validation.
class CryptoUtils {
  const CryptoUtils._();

  /// Default iteration count for PBKDF2-HMAC-SHA256 key derivation as per 3.11 specification.
  static const int pbkdf2Iterations = 300000;

  /// Header magic bytes identifying a SreerajP ToDo encrypted backup archive.
  static const String backupHeaderMagic = 'SREEAJS_BACKUP_AES_V1';

  /// Validates that a passphrase satisfies minimum security requirements (at least 8 characters).
  static void validatePassphrase(String passphrase) {
    if (passphrase.length < 8) {
      throw ArgumentError('Passphrase must be at least 8 characters long.');
    }
  }

  /// Formats backup file names following the specification pattern:
  /// `sreerajp_todo_backup_YYYYMMDD_HHMMSS.db.aes`
  static String formatBackupFileName(DateTime timestamp) {
    final year = timestamp.year.toString().padLeft(4, '0');
    final month = timestamp.month.toString().padLeft(2, '0');
    final day = timestamp.day.toString().padLeft(2, '0');
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    final second = timestamp.second.toString().padLeft(2, '0');

    return 'sreerajp_todo_backup_$year$month${day}_$hour$minute$second.db.aes';
  }

  /// Derives a 256-bit key from [passphrase] and [salt] using PBKDF2-HMAC-SHA256.
  static Uint8List deriveKey({
    required String passphrase,
    required Uint8List salt,
    int iterations = pbkdf2Iterations,
    int keyLength = 32,
  }) {
    final passwordBytes = utf8.encode(passphrase);
    return _pbkdf2HmacSha256(
      password: passwordBytes,
      salt: salt,
      iterations: iterations,
      keyLength: keyLength,
    );
  }

  static Uint8List _pbkdf2HmacSha256({
    required List<int> password,
    required Uint8List salt,
    required int iterations,
    required int keyLength,
  }) {
    final result = Uint8List(keyLength);
    int derivedBytes = 0;
    int blockIndex = 1;

    while (derivedBytes < keyLength) {
      final block = _pbkdf2F(password, salt, iterations, blockIndex);
      final copyLen = (keyLength - derivedBytes < 32)
          ? keyLength - derivedBytes
          : 32;
      result.setRange(
        derivedBytes,
        derivedBytes + copyLen,
        block.sublist(0, copyLen),
      );
      derivedBytes += copyLen;
      blockIndex++;
    }

    return result;
  }

  static Uint8List _pbkdf2F(
    List<int> password,
    Uint8List salt,
    int iterations,
    int blockIndex,
  ) {
    final saltWithBlock = Uint8List(salt.length + 4);
    saltWithBlock.setAll(0, salt);
    final bd = ByteData.view(saltWithBlock.buffer, salt.length, 4);
    bd.setUint32(0, blockIndex, Endian.big);

    Uint8List u = _hmacSha256(password, saltWithBlock);
    final result = Uint8List.fromList(u);

    for (int i = 1; i < iterations; i++) {
      u = _hmacSha256(password, u);
      for (int j = 0; j < result.length; j++) {
        result[j] ^= u[j];
      }
    }

    return result;
  }

  static Uint8List _hmacSha256(List<int> key, List<int> data) {
    final blockKey = Uint8List(64);
    if (key.length > 64) {
      final keyHash = _sha256(key);
      blockKey.setRange(0, keyHash.length, keyHash);
    } else {
      blockKey.setRange(0, key.length, key);
    }

    final oPad = Uint8List(64);
    final iPad = Uint8List(64);
    for (int i = 0; i < 64; i++) {
      oPad[i] = blockKey[i] ^ 0x5c;
      iPad[i] = blockKey[i] ^ 0x36;
    }

    final inner = _sha256([...iPad, ...data]);
    return Uint8List.fromList(_sha256([...oPad, ...inner]));
  }

  static List<int> _sha256(List<int> data) {
    const k = <int>[
      0x428a2f98,
      0x71374491,
      0xb5c0fbcf,
      0xe9b5dba5,
      0x3956c25b,
      0x59f111f1,
      0x923f82a4,
      0xab1c5ed5,
      0xd807aa98,
      0x12835b01,
      0x243185be,
      0x550c7dc3,
      0x72be5d74,
      0x80deb1fe,
      0x9bdc06a7,
      0xc19bf174,
      0xe49b69c1,
      0xefbe4786,
      0x0fc19dc6,
      0x240ca1cc,
      0x2de92c6f,
      0x4a7484aa,
      0x5cb0a9dc,
      0x76f988da,
      0x983e5152,
      0xa831c66d,
      0xb00327c8,
      0xbf597fc7,
      0xc6e00bf3,
      0xd5a79147,
      0x06ca6351,
      0x14292967,
      0x27b70a85,
      0x2e1b2138,
      0x4d2c6dfc,
      0x53380d13,
      0x650a7354,
      0x766a0abb,
      0x81c2c92e,
      0x92722c85,
      0xa2bfe8a1,
      0xa81a664b,
      0xc24b8b70,
      0xc76c51a3,
      0xd192e819,
      0xd6990624,
      0xf40e3585,
      0x106aa070,
      0x19a4c116,
      0x1e376c08,
      0x2748774c,
      0x34b0bcb5,
      0x391c0cb3,
      0x4ed8aa4a,
      0x5b9cca4f,
      0x682e6ff3,
      0x748f82ee,
      0x78a5636f,
      0x84c87814,
      0x8cc70208,
      0x90befffa,
      0xa4506ceb,
      0xbef9a3f7,
      0xc67178f2,
    ];

    var h0 = 0x6a09e667;
    var h1 = 0xbb67ae85;
    var h2 = 0x3c6ef372;
    var h3 = 0xa54ff53a;
    var h4 = 0x510e527f;
    var h5 = 0x9b05688c;
    var h6 = 0x1f83d9ab;
    var h7 = 0x5be0cd19;

    final bitLength = data.length * 8;
    final paddedLength = ((data.length + 9 + 63) ~/ 64) * 64;
    final padded = Uint8List(paddedLength);
    padded.setRange(0, data.length, data);
    padded[data.length] = 0x80;

    final bd = ByteData.view(padded.buffer, paddedLength - 8, 8);
    bd.setUint64(0, bitLength, Endian.big);

    final w = Int32List(64);

    for (int chunk = 0; chunk < paddedLength; chunk += 64) {
      final chunkBd = ByteData.view(padded.buffer, chunk, 64);
      for (int i = 0; i < 16; i++) {
        w[i] = chunkBd.getUint32(i * 4, Endian.big);
      }

      for (int i = 16; i < 64; i++) {
        final s0 =
            _rotr32(w[i - 15], 7) ^ _rotr32(w[i - 15], 18) ^ (w[i - 15] >>> 3);
        final s1 =
            _rotr32(w[i - 2], 17) ^ _rotr32(w[i - 2], 19) ^ (w[i - 2] >>> 10);
        w[i] = (w[i - 16] + s0 + w[i - 7] + s1) & 0xFFFFFFFF;
      }

      var a = h0;
      var b = h1;
      var c = h2;
      var d = h3;
      var e = h4;
      var f = h5;
      var g = h6;
      var h = h7;

      for (int i = 0; i < 64; i++) {
        final s1 = _rotr32(e, 6) ^ _rotr32(e, 11) ^ _rotr32(e, 25);
        final ch = (e & f) ^ ((~e) & g);
        final temp1 = (h + s1 + ch + k[i] + w[i]) & 0xFFFFFFFF;
        final s0 = _rotr32(a, 2) ^ _rotr32(a, 13) ^ _rotr32(a, 22);
        final maj = (a & b) ^ (a & c) ^ (b & c);
        final temp2 = (s0 + maj) & 0xFFFFFFFF;

        h = g;
        g = f;
        f = e;
        e = (d + temp1) & 0xFFFFFFFF;
        d = c;
        c = b;
        b = a;
        a = (temp1 + temp2) & 0xFFFFFFFF;
      }

      h0 = (h0 + a) & 0xFFFFFFFF;
      h1 = (h1 + b) & 0xFFFFFFFF;
      h2 = (h2 + c) & 0xFFFFFFFF;
      h3 = (h3 + d) & 0xFFFFFFFF;
      h4 = (h4 + e) & 0xFFFFFFFF;
      h5 = (h5 + f) & 0xFFFFFFFF;
      h6 = (h6 + g) & 0xFFFFFFFF;
      h7 = (h7 + h) & 0xFFFFFFFF;
    }

    final outBd = ByteData(32);
    outBd.setUint32(0, h0, Endian.big);
    outBd.setUint32(4, h1, Endian.big);
    outBd.setUint32(8, h2, Endian.big);
    outBd.setUint32(12, h3, Endian.big);
    outBd.setUint32(16, h4, Endian.big);
    outBd.setUint32(20, h5, Endian.big);
    outBd.setUint32(24, h6, Endian.big);
    outBd.setUint32(28, h7, Endian.big);

    return outBd.buffer.asUint8List();
  }

  static int _rotr32(int x, int n) {
    return ((x >>> n) | (x << (32 - n))) & 0xFFFFFFFF;
  }
}
