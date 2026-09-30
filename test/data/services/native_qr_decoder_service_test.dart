import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_todo/core/errors/exceptions.dart';
import 'package:sreerajp_todo/data/services/native_qr_decoder_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('in.sreerajp.todo/qr_decoder');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  MethodCall? lastCall;
  String? reply;

  setUp(() {
    lastCall = null;
    reply = null;
    messenger.setMockMethodCallHandler(channel, (call) async {
      lastCall = call;
      return reply;
    });
  });

  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  Future<String?> decode(NativeQrDecoderService service) => service.decodeFrame(
    bytes: Uint8List.fromList([1, 2, 3, 4, 5, 6]),
    width: 2,
    height: 2,
    rowStride: 3,
  );

  test('sends the frame and its size to the host', () async {
    reply = 'AIRQR|1|2|abc';
    final result = await decode(const NativeQrDecoderService());

    expect(result, 'AIRQR|1|2|abc');
    expect(lastCall?.method, 'decodeFrame');
    final args = lastCall!.arguments as Map;
    expect(args['bytes'], Uint8List.fromList([1, 2, 3, 4, 5, 6]));
    expect(args['width'], 2);
    expect(args['height'], 2);
    expect(args['rowStride'], 3);
  });

  test('returns null when the frame has no QR code', () async {
    expect(await decode(const NativeQrDecoderService()), isNull);
  });

  test('returns null for an empty answer', () async {
    reply = '';
    expect(await decode(const NativeQrDecoderService()), isNull);
  });

  test('throws QrScannerUnavailableException without a native side', () async {
    const service = NativeQrDecoderService(
      channel: MethodChannel('non_existent_qr_channel'),
    );
    await expectLater(
      decode(service),
      throwsA(isA<QrScannerUnavailableException>()),
    );
  });
}
