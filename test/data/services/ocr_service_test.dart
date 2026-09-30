import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_todo/core/errors/exceptions.dart';
import 'package:sreerajp_todo/data/services/native_ocr_service.dart';
import 'package:sreerajp_todo/domain/services/ocr_service.dart';

class _FakeOcrService implements OcrService {
  _FakeOcrService({this.textToReturn = '', this.shouldThrow = false});

  final String textToReturn;
  final bool shouldThrow;
  String? lastProcessedPath;
  String? lastLanguage;
  final List<int> cancelledRequestIds = <int>[];

  @override
  Future<String> extractTextFromImage(
    String imagePath, {
    String language = 'eng+mal',
    int? requestId,
  }) async {
    lastProcessedPath = imagePath;
    lastLanguage = language;
    if (shouldThrow) {
      throw Exception('OCR extraction failed');
    }
    return textToReturn;
  }

  @override
  Future<void> cancelRequests(List<int> requestIds) async {
    cancelledRequestIds.addAll(requestIds);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('OcrService', () {
    test('extracts text from image correctly', () async {
      final service = _FakeOcrService(textToReturn: 'Recognized task text');
      final result = await service.extractTextFromImage('/tmp/test_image.jpg');

      expect(result, 'Recognized task text');
      expect(service.lastProcessedPath, '/tmp/test_image.jpg');
    });

    test('returns empty string when no text found', () async {
      final service = _FakeOcrService();
      final result = await service.extractTextFromImage('/tmp/blank_image.jpg');

      expect(result, isEmpty);
    });

    test('throws when extraction fails', () async {
      final service = _FakeOcrService(shouldThrow: true);

      expect(
        () => service.extractTextFromImage('/tmp/corrupted.jpg'),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('NativeOcrService', () {
    const ocrChannel = MethodChannel('in.sreerajp.todo/ocr');
    MethodCall? lastCall;

    setUp(() {
      lastCall = null;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(ocrChannel, (call) async {
            lastCall = call;
            if (call.method == 'extractText') {
              final lang = call.arguments['language'] as String?;
              if (lang == 'mal') {
                return 'മാതൃവാണി';
              }
              return 'English text and മലയാളം';
            }
            return null;
          });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(ocrChannel, null);
    });

    test(
      'invokes native extractText with default bilingual language',
      () async {
        const service = NativeOcrService();
        final result = await service.extractTextFromImage(
          '/tmp/test_image.jpg',
        );

        expect(result, 'English text and മലയാളം');
        expect(lastCall?.method, 'extractText');
        expect(lastCall?.arguments['imagePath'], '/tmp/test_image.jpg');
        expect(lastCall?.arguments['language'], 'eng+mal');
      },
    );

    test('passes the request id so the call can be cancelled later', () async {
      const service = NativeOcrService();
      await service.extractTextFromImage('/tmp/test_image.jpg', requestId: 7);

      expect(lastCall?.arguments['requestId'], 7);
    });

    test('asks the platform to drop cancelled recognition requests', () async {
      const service = NativeOcrService();
      await service.cancelRequests(<int>[3, 4]);

      expect(lastCall?.method, 'cancelOcr');
      expect(lastCall?.arguments['requestIds'], <int>[3, 4]);
    });

    test('sends nothing when there is nothing to cancel', () async {
      const service = NativeOcrService();
      await service.cancelRequests(<int>[]);

      expect(lastCall, isNull);
    });

    test('invokes native extractText with specific language', () async {
      const service = NativeOcrService();
      final result = await service.extractTextFromImage(
        '/tmp/malayalam.jpg',
        language: 'mal',
      );

      expect(result, 'മാതൃവാണി');
      expect(lastCall?.arguments['language'], 'mal');
    });

    test(
      'throws OcrUnavailableException when native plugin is missing',
      () async {
        const service = NativeOcrService(
          channel: MethodChannel('non_existent_channel'),
        );

        await expectLater(
          service.extractTextFromImage('/tmp/photo.jpg', language: 'eng'),
          throwsA(isA<OcrUnavailableException>()),
        );
      },
    );
  });
}
