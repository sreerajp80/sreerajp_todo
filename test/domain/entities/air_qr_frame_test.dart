import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_todo/domain/entities/air_qr_frame.dart';

void main() {
  group('AirQrFrame', () {
    test('systematic v1 frame serialization and parsing roundtrip', () {
      const frame = AirQrFrame(
        streamId: '883921',
        totalBlocks: 5,
        sequenceIndex: 2,
        isParity: false,
        degree: 1,
        indices: [2],
        checksum: 12345678,
        payloadBytes: [72, 101, 108, 108, 111],
      );

      final qrString = frame.toQrString();
      expect(qrString.startsWith('AIRQR|v1|883921|5|2|12345678|'), isTrue);

      final parsed = AirQrFrame.parse(qrString);
      expect(parsed, isNotNull);
      expect(parsed!.streamId, equals('883921'));
      expect(parsed.totalBlocks, equals(5));
      expect(parsed.sequenceIndex, equals(2));
      expect(parsed.isParity, isFalse);
      expect(parsed.checksum, equals(12345678));
      expect(parsed.payloadBytes, equals([72, 101, 108, 108, 111]));
    });

    test('fountain LT1 parity frame serialization and parsing roundtrip', () {
      const frame = AirQrFrame(
        streamId: '992104',
        totalBlocks: 10,
        sequenceIndex: -1,
        isParity: true,
        degree: 3,
        indices: [0, 3, 7],
        checksum: 87654321,
        payloadBytes: [1, 2, 3, 4],
      );

      final qrString = frame.toQrString();
      expect(qrString.startsWith('AIRQR|LT1|992104|10|3:0,3,7|87654321|'), isTrue);

      final parsed = AirQrFrame.parse(qrString);
      expect(parsed, isNotNull);
      expect(parsed!.streamId, equals('992104'));
      expect(parsed.totalBlocks, equals(10));
      expect(parsed.isParity, isTrue);
      expect(parsed.degree, equals(3));
      expect(parsed.indices, equals([0, 3, 7]));
      expect(parsed.checksum, equals(87654321));
    });

    test('returns null for invalid frame string format', () {
      expect(AirQrFrame.parse('INVALID_STRING'), isNull);
      expect(AirQrFrame.parse('AIRQR|v1|only_three_parts'), isNull);
    });
  });
}
