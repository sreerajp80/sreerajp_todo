import 'dart:typed_data';

/// Contract for reading a QR code from one camera frame.
///
/// Implementations must run 100% offline on the device.
abstract class QrDecoderService {
  /// Decodes the brightness ("Y") plane of one camera frame.
  ///
  /// [rowStride] is the number of bytes per row, which can be larger than
  /// [width] because of padding. Returns the QR text, or `null` when the
  /// frame holds no readable QR code.
  Future<String?> decodeFrame({
    required Uint8List bytes,
    required int width,
    required int height,
    required int rowStride,
  });
}
