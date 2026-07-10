import 'package:sreerajp_todo/core/errors/exceptions.dart';
import 'package:sreerajp_todo/l10n/app_localizations.dart';

String mapErrorToMessage(AppLocalizations l10n, Object error) {
  return switch (error) {
    DayLockedException() => l10n.errorDayLocked,
    CompletedLockException() => l10n.errorCompletedLocked,
    DuplicateTitleException() => l10n.errorDuplicateTitle,
    SegmentAlreadyRunningException() => l10n.errorSegmentAlreadyRunning,
    SegmentOverlapException() => l10n.segmentOverlap,
    TodoNotFoundException() => l10n.errorTodoNotFound,
    BackupVersionTooNewException() => l10n.errorBackupVersionTooNew,
    BackupCorruptedException() => l10n.errorBackupCorrupted,
    _ => l10n.errorGeneric,
  };
}
