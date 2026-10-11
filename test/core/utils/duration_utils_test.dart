import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_todo/core/utils/duration_utils.dart';

void main() {
  group('formatDuration', () {
    test('formats zero seconds', () {
      expect(formatDuration(0), '00:00:00');
    });

    test('formats seconds only', () {
      expect(formatDuration(45), '00:00:45');
    });

    test('formats minutes and seconds', () {
      expect(formatDuration(125), '00:02:05');
    });

    test('formats hours, minutes, and seconds', () {
      expect(formatDuration(3661), '01:01:01');
    });

    test('formats large values', () {
      expect(formatDuration(86399), '23:59:59');
    });

    test('formats beyond 24 hours', () {
      expect(formatDuration(90000), '25:00:00');
    });
  });

  group('durationInSeconds', () {
    test('calculates difference in seconds', () {
      final start = DateTime(2026, 3, 21, 10, 0, 0);
      final end = DateTime(2026, 3, 21, 10, 5, 30);
      expect(durationInSeconds(start, end), 330);
    });

    test('returns zero for same time', () {
      final time = DateTime(2026, 3, 21, 10, 0, 0);
      expect(durationInSeconds(time, time), 0);
    });
  });
}
