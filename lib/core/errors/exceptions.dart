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

class DuplicateTitleException implements Exception {
  const DuplicateTitleException([
    this.message = 'A task with this title already exists for this date.',
  ]);
  final String message;

  @override
  String toString() => 'DuplicateTitleException: $message';
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

class BackupVersionTooNewException implements Exception {
  const BackupVersionTooNewException([
    this.message = 'This backup was created by a newer version of the app.',
  ]);
  final String message;

  @override
  String toString() => 'BackupVersionTooNewException: $message';
}

class BackupCorruptedException implements Exception {
  const BackupCorruptedException([
    this.message = 'The backup file is corrupted.',
  ]);
  final String message;

  @override
  String toString() => 'BackupCorruptedException: $message';
}
