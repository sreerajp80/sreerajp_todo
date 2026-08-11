import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:sreerajp_todo/core/utils/crypto_utils.dart';

/// Pure Dart Authenticated Encryption Engine (AES-256-CTR + HMAC-SHA256)
/// with key derivation via PBKDF2-HMAC-SHA256 (300,000 iterations).
class P2pWifiSyncCrypto {
  const P2pWifiSyncCrypto._();

  /// Derives a 256-bit AES session key from a 6-digit PIN and [salt] using 300,000 iterations.
  static Uint8List deriveSessionKey({
    required String pin,
    required Uint8List salt,
  }) {
    return CryptoUtils.deriveKey(
      passphrase: pin,
      salt: salt,
      iterations: CryptoUtils.pbkdf2Iterations,
      keyLength: 32,
    );
  }

  /// Generates a cryptographically secure 16-byte random salt.
  static Uint8List generateSalt([int length = 16]) {
    final random = Random.secure();
    final salt = Uint8List(length);
    for (int i = 0; i < length; i++) {
      salt[i] = random.nextInt(256);
    }
    return salt;
  }

  /// Generates a random 6-digit numeric pairing PIN.
  static String generatePairingPin() {
    final random = Random.secure();
    final pin = random.nextInt(900000) + 100000;
    return pin.toString();
  }

  /// Encrypts [plainText] using derived 256-bit AES session key in CTR mode with HMAC-SHA256.
  static String encryptPayload({
    required String plainText,
    required Uint8List sessionKey,
    Uint8List? nonce,
  }) {
    final bytes = utf8.encode(plainText);
    final actualNonce = nonce ?? generateSalt(12);

    final cipherBytes = _aes256CtrProcess(
      data: Uint8List.fromList(bytes),
      key: sessionKey,
      nonce: actualNonce,
    );

    final macData = Uint8List(actualNonce.length + cipherBytes.length);
    macData.setAll(0, actualNonce);
    macData.setAll(actualNonce.length, cipherBytes);

    final mac = _hmacSha256(sessionKey, macData);

    final payloadMap = {
      'nonce': base64.encode(actualNonce),
      'cipher': base64.encode(cipherBytes),
      'mac': base64.encode(mac),
    };

    return jsonEncode(payloadMap);
  }

  /// Decrypts encrypted JSON payload package using derived 256-bit AES session key.
  static String decryptPayload({
    required String encryptedPackage,
    required Uint8List sessionKey,
  }) {
    final Map<String, dynamic> payloadMap;
    try {
      payloadMap = jsonDecode(encryptedPackage) as Map<String, dynamic>;
    } catch (_) {
      throw const FormatException('Invalid payload JSON structure.');
    }

    final nonceStr = payloadMap['nonce'] as String?;
    final cipherStr = payloadMap['cipher'] as String?;
    final macStr = payloadMap['mac'] as String?;

    if (nonceStr == null || cipherStr == null || macStr == null) {
      throw const FormatException('Missing required encryption fields.');
    }

    final nonce = base64.decode(nonceStr);
    final cipherBytes = base64.decode(cipherStr);
    final expectedMac = base64.decode(macStr);

    final macData = Uint8List(nonce.length + cipherBytes.length);
    macData.setAll(0, nonce);
    macData.setAll(nonce.length, cipherBytes);

    final computedMac = _hmacSha256(sessionKey, macData);

    if (!_constantTimeEquals(expectedMac, computedMac)) {
      throw const FormatException('Payload authentication failed: HMAC mismatch.');
    }

    final plainBytes = _aes256CtrProcess(
      data: cipherBytes,
      key: sessionKey,
      nonce: nonce,
    );

    return utf8.decode(plainBytes);
  }

  static bool _constantTimeEquals(Uint8List a, Uint8List b) {
    if (a.length != b.length) return false;
    int result = 0;
    for (int i = 0; i < a.length; i++) {
      result |= a[i] ^ b[i];
    }
    return result == 0;
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
      0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1,
      0x923f82a4, 0xab1c5ed5, 0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3,
      0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174, 0xe49b69c1, 0xefbe4786,
      0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
      0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147,
      0x06ca6351, 0x14292967, 0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13,
      0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85, 0xa2bfe8a1, 0xa81a664b,
      0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
      0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a,
      0x5b9cca4f, 0x682e6ff3, 0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208,
      0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2
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
        final s0 = _rotr32(w[i - 15], 7) ^ _rotr32(w[i - 15], 18) ^ (w[i - 15] >>> 3);
        final s1 = _rotr32(w[i - 2], 17) ^ _rotr32(w[i - 2], 19) ^ (w[i - 2] >>> 10);
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

  static Uint8List _aes256CtrProcess({
    required Uint8List data,
    required Uint8List key,
    required Uint8List nonce,
  }) {
    final expandedKey = _expandKey256(key);
    final result = Uint8List(data.length);
    final counterBlock = Uint8List(16);

    counterBlock.setRange(0, min(12, nonce.length), nonce);

    int blockIndex = 0;
    final numBlocks = (data.length + 15) ~/ 16;

    for (int b = 0; b < numBlocks; b++) {
      final bd = ByteData.view(counterBlock.buffer);
      bd.setUint32(12, blockIndex, Endian.big);

      final keyStream = _aes256EncryptBlock(counterBlock, expandedKey);

      final start = b * 16;
      final end = min(start + 16, data.length);
      for (int i = start; i < end; i++) {
        result[i] = data[i] ^ keyStream[i - start];
      }

      blockIndex++;
    }

    return result;
  }

  // --- Standard AES-256 Cipher Constants & Functions ---
  static const List<int> _sBox = <int>[
    0x63, 0x7c, 0x77, 0x7b, 0xf2, 0x6b, 0x6f, 0xc5, 0x30, 0x01, 0x67, 0x2b, 0xfe, 0xd7, 0xab, 0x76,
    0xca, 0x82, 0xc9, 0x7d, 0xfa, 0x59, 0x47, 0xf0, 0xad, 0xd4, 0xa2, 0xaf, 0x9c, 0xa4, 0x72, 0xc0,
    0xb7, 0xfd, 0x93, 0x26, 0x36, 0x3f, 0xf7, 0xcc, 0x34, 0xa5, 0xe5, 0xf1, 0x71, 0xd8, 0x31, 0x15,
    0x04, 0xc7, 0x23, 0xc3, 0x18, 0x96, 0x05, 0x9a, 0x07, 0x12, 0x80, 0xe2, 0xeb, 0x27, 0xb2, 0x75,
    0x09, 0x83, 0x2c, 0x1a, 0x1b, 0x6e, 0x5a, 0xa0, 0x52, 0x3b, 0xd6, 0xb3, 0x29, 0xe3, 0x2f, 0x84,
    0x53, 0xd1, 0x00, 0xed, 0x20, 0xfc, 0xb1, 0x5b, 0x6a, 0xcb, 0xbe, 0x39, 0x4a, 0x4c, 0x58, 0xcf,
    0xd0, 0xef, 0xaa, 0xfb, 0x43, 0x4d, 0x33, 0x85, 0x45, 0xf9, 0x02, 0x7f, 0x50, 0x3c, 0x9f, 0xa8,
    0x51, 0xa3, 0x40, 0x8f, 0x92, 0x9d, 0x38, 0xf5, 0xbc, 0xb6, 0xda, 0x21, 0x10, 0xff, 0xf3, 0xd2,
    0xcd, 0x0c, 0x13, 0xec, 0x5f, 0x97, 0x44, 0x17, 0xc4, 0xa7, 0x7e, 0x3d, 0x64, 0x5d, 0x19, 0x73,
    0x60, 0x81, 0x4f, 0xdc, 0x22, 0x2a, 0x90, 0x88, 0x46, 0xee, 0xb8, 0x14, 0xde, 0x5e, 0x0b, 0xdb,
    0xe0, 0x32, 0x3a, 0x0a, 0x49, 0x06, 0x24, 0x5c, 0xc2, 0xd3, 0xac, 0x62, 0x91, 0x95, 0xe4, 0x79,
    0xe7, 0xc8, 0x37, 0x6d, 0x8d, 0xd5, 0x4e, 0xa9, 0x6c, 0x56, 0xf4, 0xea, 0x65, 0x7a, 0xae, 0x08,
    0xba, 0x78, 0x25, 0x2e, 0x1c, 0xa6, 0xb4, 0xc6, 0xe8, 0xdd, 0x74, 0x1f, 0x4b, 0xbd, 0x8b, 0x8a,
    0x70, 0x3e, 0xb5, 0x66, 0x48, 0x03, 0xf6, 0x0e, 0x61, 0x35, 0x57, 0xb9, 0x86, 0xc1, 0x1d, 0x9e,
    0xe1, 0xf8, 0x98, 0x11, 0x69, 0xd9, 0x8e, 0x94, 0x9b, 0x1e, 0x87, 0xe9, 0xce, 0x55, 0x28, 0xdf,
    0x8c, 0xa1, 0x89, 0x0d, 0xbf, 0xe6, 0x42, 0x68, 0x41, 0x99, 0x2d, 0x0f, 0xb0, 0x54, 0xbb, 0x16
  ];

  static const List<int> _rCon = <int>[
    0x00, 0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80, 0x1b, 0x36
  ];

  static Uint32List _expandKey256(Uint8List key) {
    final w = Uint32List(60);
    final keyBd = ByteData.view(key.buffer);

    for (int i = 0; i < 8; i++) {
      w[i] = keyBd.getUint32(i * 4, Endian.big);
    }

    for (int i = 8; i < 60; i++) {
      var temp = w[i - 1];
      if (i % 8 == 0) {
        temp = _subWord(_rotWord(temp)) ^ (_rCon[i ~/ 8] << 24);
      } else if (i % 8 == 4) {
        temp = _subWord(temp);
      }
      w[i] = w[i - 8] ^ temp;
    }

    return w;
  }

  static int _rotWord(int w) {
    return ((w << 8) | (w >>> 24)) & 0xFFFFFFFF;
  }

  static int _subWord(int w) {
    return (_sBox[(w >>> 24) & 0xFF] << 24) |
        (_sBox[(w >>> 16) & 0xFF] << 16) |
        (_sBox[(w >>> 8) & 0xFF] << 8) |
        _sBox[w & 0xFF];
  }

  static Uint8List _aes256EncryptBlock(Uint8List input, Uint32List w) {
    final state = Uint8List.fromList(input);

    _addRoundKey(state, w, 0);

    for (int round = 1; round < 14; round++) {
      _subBytes(state);
      _shiftRows(state);
      _mixColumns(state);
      _addRoundKey(state, w, round);
    }

    _subBytes(state);
    _shiftRows(state);
    _addRoundKey(state, w, 14);

    return state;
  }

  static void _addRoundKey(Uint8List state, Uint32List w, int round) {
    for (int c = 0; c < 4; c++) {
      final rk = w[round * 4 + c];
      state[c * 4 + 0] ^= (rk >>> 24) & 0xFF;
      state[c * 4 + 1] ^= (rk >>> 16) & 0xFF;
      state[c * 4 + 2] ^= (rk >>> 8) & 0xFF;
      state[c * 4 + 3] ^= rk & 0xFF;
    }
  }

  static void _subBytes(Uint8List state) {
    for (int i = 0; i < 16; i++) {
      state[i] = _sBox[state[i]];
    }
  }

  static void _shiftRows(Uint8List state) {
    int temp = state[1];
    state[1] = state[5];
    state[5] = state[9];
    state[9] = state[13];
    state[13] = temp;

    temp = state[2];
    state[2] = state[10];
    state[10] = temp;
    temp = state[6];
    state[6] = state[14];
    state[14] = temp;

    temp = state[15];
    state[15] = state[11];
    state[11] = state[7];
    state[7] = state[3];
    state[3] = temp;
  }

  static void _mixColumns(Uint8List state) {
    for (int c = 0; c < 4; c++) {
      final col = state.sublist(c * 4, c * 4 + 4);
      state[c * 4 + 0] = _gMul(0x02, col[0]) ^ _gMul(0x03, col[1]) ^ col[2] ^ col[3];
      state[c * 4 + 1] = col[0] ^ _gMul(0x02, col[1]) ^ _gMul(0x03, col[2]) ^ col[3];
      state[c * 4 + 2] = col[0] ^ col[1] ^ _gMul(0x02, col[2]) ^ _gMul(0x03, col[3]);
      state[c * 4 + 3] = _gMul(0x03, col[0]) ^ col[1] ^ col[2] ^ _gMul(0x02, col[3]);
    }
  }

  static int _gMul(int a, int b) {
    int p = 0;
    for (int counter = 0; counter < 8; counter++) {
      if ((b & 1) != 0) {
        p ^= a;
      }
      final hiBitSet = (a & 0x80) != 0;
      a = (a << 1) & 0xFF;
      if (hiBitSet) {
        a ^= 0x1b;
      }
      b >>= 1;
    }
    return p;
  }
}
