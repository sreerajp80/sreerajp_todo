import 'package:sreerajp_todo/core/errors/exceptions.dart';
import 'package:sreerajp_todo/l10n/app_localizations.dart';

/// Turns any caught error into a short, localized message for the user.
///
/// It never returns raw exception text (engineering standard §11.2). The
/// `switch` over the sealed [AppException] is exhaustive, so a new app error
/// type does not compile until it gets a message here.
String mapErrorToMessage(AppLocalizations l10n, Object error) {
  if (error is! AppException) return l10n.errorGeneric;
  return switch (error) {
    DayLockedException() => l10n.errorDayLocked,
    CompletedLockException() => l10n.errorCompletedLocked,
    FutureDayTimerException() => l10n.errorTimerFutureTask,
    DuplicateTitleException() => l10n.errorDuplicateTitle,
    final MultiDayDuplicateTitleException e => l10n.multiDayDuplicateTitleAlert(
      e.conflictingDate,
    ),
    SegmentAlreadyRunningException() => l10n.errorSegmentAlreadyRunning,
    SegmentOverlapException() => l10n.segmentOverlap,
    TodoNotFoundException() => l10n.errorTodoNotFound,
    BackupVersionTooNewException() => l10n.errorBackupVersionTooNew,
    BackupCorruptedException() => l10n.errorBackupCorrupted,
    NonLocalAddressException() => l10n.errorNotLocalNetwork,
    OcrUnavailableException() => l10n.ocrUnavailableMessage,
    QrScannerUnavailableException() => l10n.airQrScanUnavailable,
    ValidationException() => l10n.errorInvalidInput,
  };
}
