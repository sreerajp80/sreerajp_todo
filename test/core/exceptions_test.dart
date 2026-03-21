import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_todo/core/errors/exceptions.dart';

void main() {
  group('DayLockedException', () {
    test('has default message', () {
      const e = DayLockedException();
      expect(e.message, contains('past dates'));
      expect(e.toString(), contains('DayLockedException'));
    });

    test('accepts custom message', () {
      const e = DayLockedException('custom');
      expect(e.message, 'custom');
    });
  });

  group('CompletedLockException', () {
    test('has default message', () {
      const e = CompletedLockException();
      expect(e.message, contains('completed'));
    });
  });

  group('DuplicateTitleException', () {
    test('has default message', () {
      const e = DuplicateTitleException();
      expect(e.message, contains('title'));
    });
  });

  group('SegmentAlreadyRunningException', () {
    test('has default message', () {
      const e = SegmentAlreadyRunningException();
      expect(e.message, contains('already running'));
    });
  });

  group('TodoNotFoundException', () {
    test('has default message', () {
      const e = TodoNotFoundException();
      expect(e.message, contains('not found'));
    });
  });

  group('BackupVersionTooNewException', () {
    test('has default message', () {
      const e = BackupVersionTooNewException();
      expect(e.message, contains('newer version'));
    });
  });

  group('BackupCorruptedException', () {
    test('has default message', () {
      const e = BackupCorruptedException();
      expect(e.message, contains('corrupted'));
    });
  });
}
