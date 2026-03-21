import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:sreerajp_todo/core/utils/date_utils.dart';

void main() {
  group('todayAsIso', () {
    test('returns current date in YYYY-MM-DD format', () {
      final result = todayAsIso();
      expect(RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(result), isTrue);
      expect(result, DateFormat('yyyy-MM-dd').format(DateTime.now()));
    });
  });

  group('isToday', () {
    test('returns true for today', () {
      expect(isToday(todayAsIso()), isTrue);
    });

    test('returns false for yesterday', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      expect(isToday(DateFormat('yyyy-MM-dd').format(yesterday)), isFalse);
    });
  });

  group('isPastDate', () {
    test('returns true for yesterday', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final formatted = DateFormat('yyyy-MM-dd').format(yesterday);
      expect(isPastDate(formatted), isTrue);
    });

    test('returns false for today', () {
      expect(isPastDate(todayAsIso()), isFalse);
    });

    test('returns false for tomorrow', () {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final formatted = DateFormat('yyyy-MM-dd').format(tomorrow);
      expect(isPastDate(formatted), isFalse);
    });
  });

  group('isFutureDate', () {
    test('returns true for tomorrow', () {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final formatted = DateFormat('yyyy-MM-dd').format(tomorrow);
      expect(isFutureDate(formatted), isTrue);
    });

    test('returns false for today', () {
      expect(isFutureDate(todayAsIso()), isFalse);
    });
  });

  group('parseIsoDate', () {
    test('parses valid ISO date', () {
      final date = parseIsoDate('2026-03-21');
      expect(date.year, 2026);
      expect(date.month, 3);
      expect(date.day, 21);
    });

    test('throws on invalid format', () {
      expect(() => parseIsoDate('21-03-2026'), throwsFormatException);
    });
  });

  group('formatDate', () {
    test('returns localised display string', () {
      final date = DateTime(2026, 3, 21);
      final result = formatDate(date);
      expect(result, isNotEmpty);
      expect(result, contains('2026'));
    });
  });

  group('dateTimeToIso', () {
    test('formats DateTime as YYYY-MM-DD', () {
      final date = DateTime(2026, 1, 5);
      expect(dateTimeToIso(date), '2026-01-05');
    });
  });
}
