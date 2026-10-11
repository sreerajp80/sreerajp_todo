import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_todo/core/errors/exceptions.dart';
import 'package:sreerajp_todo/presentation/shared/error_message_mapper.dart';

import '../../helpers/test_l10n.dart';

void main() {
  final l10n = testL10n;

  test('maps every app exception to its localized message', () {
    final cases = <Object, String>{
      const DayLockedException(): l10n.errorDayLocked,
      const CompletedLockException(): l10n.errorCompletedLocked,
      const FutureDayTimerException(): l10n.errorTimerFutureTask,
      const DuplicateTitleException(): l10n.errorDuplicateTitle,
      const MultiDayDuplicateTitleException('2026-10-05'): l10n
          .multiDayDuplicateTitleAlert('2026-10-05'),
      const SegmentAlreadyRunningException(): l10n.errorSegmentAlreadyRunning,
      const SegmentOverlapException(): l10n.segmentOverlap,
      const TodoNotFoundException(): l10n.errorTodoNotFound,
      const BackupVersionTooNewException(9, 1): l10n.errorBackupVersionTooNew,
      const BackupCorruptedException(): l10n.errorBackupCorrupted,
      const NonLocalAddressException('8.8.8.8'): l10n.errorNotLocalNetwork,
      const OcrUnavailableException(): l10n.ocrUnavailableMessage,
      const QrScannerUnavailableException(): l10n.airQrScanUnavailable,
      const ValidationException('bad'): l10n.errorInvalidInput,
    };

    for (final entry in cases.entries) {
      expect(mapErrorToMessage(l10n, entry.key), entry.value);
    }
  });

  test('other errors get the generic message, never their raw text', () {
    final message = mapErrorToMessage(l10n, Exception('secret task title'));

    expect(message, l10n.errorGeneric);
    expect(message, isNot(contains('secret task title')));
  });
}
