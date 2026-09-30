import 'package:flutter/services.dart';
import 'package:sreerajp_todo/core/errors/exceptions.dart';
import 'package:sreerajp_todo/domain/services/qr_decoder_service.dart';

/// QR decoding through the Android host, which uses the ZXing core library.
///
/// ZXing is plain Java maths with no network code and no Play Services.
class NativeQrDecoderService implements QrDecoderService {
  const NativeQrDecoderService({this.channel = _defaultChannel});

  static const MethodChannel _defaultChannel = MethodChannel(
    'in.sreerajp.todo/qr_decoder',
  );

  final MethodChannel channel;

  @override
  Future<String?> decodeFrame({
    required Uint8List bytes,
    required int width,
    required int height,
    required int rowStride,
  }) async {
    try {
      final text = await channel.invokeMethod<String>(
        'decodeFrame',
        <String, dynamic>{
          'bytes': bytes,
          'width': width,
          'height': height,
          'rowStride': rowStride,
        },
      );
      if (text == null || text.isEmpty) return null;
      return text;
    } on MissingPluginException catch (_) {
      // No native side here, for example on Windows.
      throw const QrScannerUnavailableException();
    }
  }
}
