import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_todo/data/services/air_qr_service.dart';
import 'package:sreerajp_todo/domain/entities/air_qr_progress.dart';

void main() {
  group('AirQrService', () {
    late AirQrService service;

    setUp(() {
      service = AirQrService();
    });

    test('computes valid CRC32 checksums', () {
      final bytes = [72, 101, 108, 108, 111]; // "Hello"
      final crc = AirQrService.computeCrc32(bytes);
      expect(crc, isA<int>());
      expect(crc, isNot(equals(0)));
    });

    test('encodes and decodes small payload seamlessly', () {
      const payload = 'SREERAJP_TODO|v1|{"type":"tasks","date":"2026-08-10","todos":[{"id":"1","title":"Test AirQR"}]}';
      final frames = AirQrService.encodePayload(payload, blockSize: 50);
      expect(frames.isNotEmpty, isTrue);

      AirQrProgress progress = const AirQrProgress(status: AirQrStatus.idle);
      for (final frame in frames) {
        progress = service.processFrameString(frame.toQrString(), progress);
        if (progress.status == AirQrStatus.completed) break;
      }

      expect(progress.status, equals(AirQrStatus.completed));
      expect(progress.reassembledContent, equals(payload));
    });

    test('recovers lost systematic blocks using LT Fountain parity frames', () {
      const payload = 'Fountain LT parity recovery test payload with enough text length to produce multiple block chunks for stream solving verification.';
      final frames = AirQrService.encodePayload(payload, blockSize: 30, extraParityRatioPercent: 100);

      // Filter systematic frames and parity frames
      final systematic = frames.where((f) => !f.isParity).toList();
      final parity = frames.where((f) => f.isParity).toList();

      expect(systematic.length, greaterThan(1));
      expect(parity.isNotEmpty, isTrue);

      // Drop 1 systematic frame (simulating camera packet drop)
      final incompleteFrames = [...systematic.sublist(1), ...parity];

      AirQrProgress progress = const AirQrProgress(status: AirQrStatus.idle);
      for (final frame in incompleteFrames) {
        progress = service.processFrameString(frame.toQrString(), progress);
        if (progress.status == AirQrStatus.completed) break;
      }

      expect(progress.status, equals(AirQrStatus.completed));
      expect(progress.reassembledContent, equals(payload));
    });

    test('resets session correctly', () {
      service.processFrameString(
        'AIRQR|v1|stream123|5|0|100|cGF5bG9hZA==',
        const AirQrProgress(),
      );
      service.reset();
      expect(service.processFrameString('INVALID', const AirQrProgress()).status, equals(AirQrStatus.idle));
    });
  });
}
