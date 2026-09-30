class DayLockedException implements Exception {
  const DayLockedException([
    this.message = 'Cannot modify tasks from past dates.',
  ]);
  final String message;

  @override
  String toString() => 'DayLockedException: $message';
}

class CompletedLockException implements Exception {
  const CompletedLockException([
    this.message = 'Cannot add time segments to a completed or dropped task.',
  ]);
  final String message;

  @override
  String toString() => 'CompletedLockException: $message';
}

class FutureDayTimerException implements Exception {
  const FutureDayTimerException([
    this.message =
        'Cannot start a timer on a task that starts on a future day.',
  ]);
  final String message;

  @override
  String toString() => 'FutureDayTimerException: $message';
}

class DuplicateTitleException implements Exception {
  const DuplicateTitleException([
    this.message = 'A task with this title already exists for this date.',
  ]);
  final String message;

  @override
  String toString() => 'DuplicateTitleException: $message';
}

class MultiDayDuplicateTitleException implements Exception {
  const MultiDayDuplicateTitleException(
    this.conflictingDate, [
    this.message =
        'A task with this title already exists on another date where this task was active.',
  ]);

  final String conflictingDate;
  final String message;

  @override
  String toString() =>
      'MultiDayDuplicateTitleException: $message (conflictingDate: $conflictingDate)';
}

class SegmentAlreadyRunningException implements Exception {
  const SegmentAlreadyRunningException([
    this.message = 'A time segment is already running for this task.',
  ]);
  final String message;

  @override
  String toString() => 'SegmentAlreadyRunningException: $message';
}

class TodoNotFoundException implements Exception {
  const TodoNotFoundException([this.message = 'Task not found.']);
  final String message;

  @override
  String toString() => 'TodoNotFoundException: $message';
}

class SegmentOverlapException implements Exception {
  const SegmentOverlapException([
    this.message = 'This segment overlaps with an existing one.',
  ]);
  final String message;

  @override
  String toString() => 'SegmentOverlapException: $message';
}

class BackupVersionTooNewException implements Exception {
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

class BackupCorruptedException implements Exception {
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
class NonLocalAddressException implements Exception {
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
class OcrUnavailableException implements Exception {
  const OcrUnavailableException([
    this.message = 'Text reading is not available on this device.',
  ]);

  final String message;

  @override
  String toString() => 'OcrUnavailableException: $message';
}

/// Thrown when the native QR decoder is not available on this platform, for
/// example on Windows.
class QrScannerUnavailableException implements Exception {
  const QrScannerUnavailableException([
    this.message = 'QR scanning is not available on this device.',
  ]);

  final String message;

  @override
  String toString() => 'QrScannerUnavailableException: $message';
}
