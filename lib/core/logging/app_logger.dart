import 'dart:developer' as developer;

/// How serious a log message is (engineering standard §14.1).
enum LogLevel { trace, debug, info, warning, error, fatal }

/// Receives each log record. Tests replace it to capture output.
typedef LogSink =
    void Function(
      LogLevel level,
      String message, {
      Object? error,
      StackTrace? stackTrace,
    });

/// The app's only logger. Never use `print` or `debugPrint`.
///
/// Rules (engineering standard §14.3):
/// - Never log secrets, passphrases, keys or user content such as task titles.
/// - Log the operation name and the error type, not the raw error message.
/// - `trace` and `debug` are silent in release builds.
///
/// Output goes to the developer console only. Nothing is written to disk and
/// nothing leaves the device.
abstract final class AppLogger {
  static const String _name = 'sreerajp_todo';

  /// True in release (AOT product) builds.
  static const bool _isRelease = bool.fromEnvironment('dart.vm.product');

  static LogSink _sink = _developerSink;

  /// Whether `trace` and `debug` messages are written.
  static bool verboseEnabled = !_isRelease;

  /// Replaces the output. Used by tests.
  static void setSinkForTesting(LogSink sink) => _sink = sink;

  /// Restores the default output.
  static void resetForTesting() {
    _sink = _developerSink;
    verboseEnabled = !_isRelease;
  }

  static void trace(String message) {
    if (verboseEnabled) _sink(LogLevel.trace, message);
  }

  static void debug(String message) {
    if (verboseEnabled) _sink(LogLevel.debug, message);
  }

  static void info(String message) => _sink(LogLevel.info, message);

  static void warning(String message, {Object? error}) =>
      _sink(LogLevel.warning, message, error: error);

  static void error(String message, {Object? error, StackTrace? stackTrace}) =>
      _sink(LogLevel.error, message, error: error, stackTrace: stackTrace);

  static void fatal(String message, {Object? error, StackTrace? stackTrace}) =>
      _sink(LogLevel.fatal, message, error: error, stackTrace: stackTrace);

  static void _developerSink(
    LogLevel level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    developer.log(
      message,
      name: _name,
      level: _severity(level),
      // Only the error type is logged. Its message may hold user data.
      error: error?.runtimeType,
      stackTrace: stackTrace,
    );
  }

  /// Maps to the `package:logging` severity numbers that DevTools shows.
  static int _severity(LogLevel level) => switch (level) {
    LogLevel.trace => 300,
    LogLevel.debug => 500,
    LogLevel.info => 800,
    LogLevel.warning => 900,
    LogLevel.error => 1000,
    LogLevel.fatal => 1200,
  };
}
