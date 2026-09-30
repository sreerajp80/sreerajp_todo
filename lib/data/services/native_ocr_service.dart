import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:sreerajp_todo/core/errors/exceptions.dart';
import 'package:sreerajp_todo/domain/services/ocr_service.dart';

/// On-device OCR implementation backed by native Tesseract 5 (Tesseract4Android)
/// via MethodChannel, providing accurate Malayalam and English text recognition.
class NativeOcrService implements OcrService {
  const NativeOcrService({this.channel = _defaultChannel});

  static const MethodChannel _defaultChannel = MethodChannel(
    'in.sreerajp.todo/ocr',
  );

  final MethodChannel channel;

  @override
  Future<String> extractTextFromImage(
    String imagePath, {
    String language = 'eng+mal',
    int? requestId,
  }) async {
    try {
      final String? result = await channel.invokeMethod<String>(
        'extractText',
        <String, dynamic>{
          'imagePath': imagePath,
          'language': language,
          'requestId': requestId ?? 0,
        },
      );
      return result?.trim() ?? '';
    } on MissingPluginException catch (_) {
      // No native side here, for example on Windows. Tesseract is the only
      // OCR engine, so text reading is simply not available.
      throw const OcrUnavailableException();
    } catch (e) {
      debugPrint('NativeOcrService: recognition failed ($e)');
      rethrow;
    }
  }

  @override
  Future<void> cancelRequests(List<int> requestIds) async {
    if (requestIds.isEmpty) return;
    try {
      await channel.invokeMethod<void>('cancelOcr', <String, dynamic>{
        'requestIds': requestIds,
      });
    } on MissingPluginException catch (_) {
      // No native side in host tests; nothing is queued there either.
    } catch (e) {
      debugPrint('NativeOcrService: cancel failed ($e)');
    }
  }
}
