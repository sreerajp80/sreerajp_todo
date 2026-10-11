import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_todo/core/logging/app_logger.dart';

void main() {
  final records = <(LogLevel, String, Object?, StackTrace?)>[];

  setUp(() {
    records.clear();
    AppLogger.setSinkForTesting((
      level,
      message, {
      Object? error,
      StackTrace? stackTrace,
    }) {
      records.add((level, message, error, stackTrace));
    });
  });

  tearDown(AppLogger.resetForTesting);

  test('writes each level with its message', () {
    AppLogger.verboseEnabled = true;
    AppLogger.trace('t');
    AppLogger.debug('d');
    AppLogger.info('i');
    AppLogger.warning('w');
    AppLogger.error('e');
    AppLogger.fatal('f');

    expect(records.map((r) => r.$1), LogLevel.values);
    expect(records.map((r) => r.$2), ['t', 'd', 'i', 'w', 'e', 'f']);
  });

  test('trace and debug are silent when verbose logging is off', () {
    AppLogger.verboseEnabled = false;
    AppLogger.trace('t');
    AppLogger.debug('d');
    AppLogger.info('i');

    expect(records.map((r) => r.$1), [LogLevel.info]);
  });

  test('error passes the error object and stack trace on', () {
    final error = StateError('boom');
    final stack = StackTrace.current;

    AppLogger.error('op failed', error: error, stackTrace: stack);

    expect(records.single.$3, same(error));
    expect(records.single.$4, same(stack));
  });

  test('the default output does not throw', () {
    AppLogger.resetForTesting();
    expect(
      () => AppLogger.error('op failed', error: Exception('x')),
      returnsNormally,
    );
  });
}
