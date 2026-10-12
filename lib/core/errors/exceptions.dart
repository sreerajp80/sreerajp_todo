/// Base type for every error the app throws on purpose.
///
/// It is `sealed`, so a `switch` over it must handle every case. Add new
/// app errors to this file.
sealed class AppException implements Exception {
  const AppException();
}

class DayLockedException extends AppException {
  const DayLockedException([
    this.message = 'Cannot modify tasks from past dates.',
  ]);
  final String message;

  @override
  String toString() => 'DayLockedException: $message';
}

class CompletedLockException extends AppException {
  const CompletedLockException([
    this.message = 'Cannot add time segments to a completed or dropped task.',
  ]);
  final String message;

  @override
  String toString() => 'CompletedLockException: $message';
}

class FutureDayTimerException extends AppException {
  const FutureDayTimerException([
    this.message =
        'Cannot start a timer on a task that starts on a future day.',
  ]);
  final String message;

  @override
  String toString() => 'FutureDayTimerException: $message';
}

class DuplicateTitleException extends AppException {
  const DuplicateTitleException([
    this.message = 'A task with this title already exists for this date.',
  ]);
  final String message;

  @override
  String toString() => 'DuplicateTitleException: $message';
}

class MultiDayDuplicateTitleException extends AppException {
  const MultiDayDuplicateTitleException(
    this.conflictingDate, [
    this.message = 'A task with this title already exists on another date where this task was active.',
  ]);

  final String conflictingDate;
  final String message;

  @override
  String toString() =>
      'MultiDayDuplicateTitleException: $message (conflictingDate: $conflictingDate)';
}

class SegmentAlreadyRunningException extends AppException {
  const SegmentAlreadyRunningException([
    this.message = 'A time segment is already running for this task.',
  ]);
  final String message;

  @override
  String toString() => 'SegmentAlreadyRunningException: $message';
}

class TodoNotFoundException extends AppException {
  const TodoNotFoundException([this.message = 'Task not found.']);
  final String message;

  @override
  String toString() => 'TodoNotFoundException: $message';
}

class SegmentOverlapException extends AppException {
  const SegmentOverlapException([
    this.message = 'This segment overlaps with an existing one.',
  ]);
  final String message;

  @override
  String toString() => 'SegmentOverlapException: $message';
}

class BackupVersionTooNewException extends AppException {
  const BackupVersionTooNewException(
    this.backupVersion,
    this.appVersion, [
    this.message = 'This backup was created by a newer version of the app.',
  ]);

  final int backupVersion;
  final int appVersion;
  final String message;

  @override
  String toString() =>
      'BackupVersionTooNewException: $message (backupVersion: $backupVersion, appVersion: $appVersion)';
}

class BackupCorruptedException extends AppException {
  const BackupCorruptedException([
    this.details,
    this.message = 'The backup file is corrupted.',
  ]);

  final String? details;
  final String message;

  @override
  String toString() => details == null
      ? 'BackupCorruptedException: $message'
      : 'BackupCorruptedException: $message ($details)';
}

/// Thrown when Wi-Fi sync is asked to talk to an address outside the local
/// network. The app never sends data over the internet.
class NonLocalAddressException extends AppException {
  const NonLocalAddressException(
    this.address, [
    this.message = 'Wi-Fi sync works only with devices on the local network.',
  ]);

  final String address;
  final String message;

  @override
  String toString() => 'NonLocalAddressException: $message ($address)';
}

/// Thrown when on-device text reading (Tesseract OCR) is not available on
/// this platform, for example on Windows.
class OcrUnavailableException extends AppException {
  const OcrUnavailableException([
    this.message = 'Text reading is not available on this device.',
  ]);

  final String message;

  @override
  String toString() => 'OcrUnavailableException: $message';
}

/// Thrown when the native QR decoder is not available on this platform, for
/// example on Windows.
class QrScannerUnavailableException extends AppException {
  const QrScannerUnavailableException([
    this.message = 'QR scanning is not available on this device.',
  ]);

  final String message;

  @override
  String toString() => 'QrScannerUnavailableException: $message';
}

/// Thrown when input breaks a rule, for example a time segment whose start is
/// not before its end.
class ValidationException extends AppException {
  const ValidationException(this.message);

  final String message;

  @override
  String toString() => 'ValidationException: $message';
}
