import 'package:sreerajp_todo/core/constants/app_strings.dart';
import 'package:sreerajp_todo/core/errors/exceptions.dart';

String mapErrorToMessage(Object error) {
  return switch (error) {
    DayLockedException() => AppStrings.errors.dayLocked,
    CompletedLockException() => AppStrings.errors.completedLocked,
    DuplicateTitleException() => AppStrings.errors.duplicateTitle,
    SegmentAlreadyRunningException() => AppStrings.errors.segmentAlreadyRunning,
    SegmentOverlapException() => AppStrings.segmentOverlap,
    TodoNotFoundException() => AppStrings.errors.todoNotFound,
    BackupVersionTooNewException() => AppStrings.errors.backupVersionTooNew,
    BackupCorruptedException() => AppStrings.errors.backupCorrupted,
    _ => AppStrings.errors.generic,
  };
}
