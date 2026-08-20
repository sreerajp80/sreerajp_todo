import 'package:sreerajp_todo/core/utils/app_lock_rules.dart';
import 'package:sreerajp_todo/l10n/app_localizations.dart';

/// Shared labels for the security settings values, so the settings pages and
/// the lock screen name the same things the same way.

/// The translated name of [mode].
String appLockModeName(AppLocalizations l10n, AppLockMode mode) {
  return switch (mode) {
    AppLockMode.off => l10n.appLockOff,
    AppLockMode.pin => l10n.appLockPin,
    AppLockMode.password => l10n.appLockPassword,
    AppLockMode.deviceCredential => l10n.appLockDeviceCredential,
  };
}

/// The translated name of [delay].
String autoLockDelayName(AppLocalizations l10n, AutoLockDelay delay) {
  return switch (delay) {
    AutoLockDelay.immediately => l10n.autoLockImmediately,
    AutoLockDelay.thirtySeconds => l10n.autoLock30Seconds,
    AutoLockDelay.oneMinute => l10n.autoLock1Minute,
    AutoLockDelay.fiveMinutes => l10n.autoLock5Minutes,
    AutoLockDelay.fifteenMinutes => l10n.autoLock15Minutes,
    AutoLockDelay.never => l10n.autoLockNever,
  };
}

/// The message to show for a rejected PIN or password.
String secretRejectionMessage(
  AppLocalizations l10n,
  AppLockMode mode,
  SecretRejection rejection,
) {
  return switch (rejection) {
    SecretRejection.empty => l10n.appLockErrorEmpty,
    SecretRejection.notDigits => l10n.appLockErrorNotDigits,
    SecretRejection.tooLong => l10n.appLockErrorPinTooLong,
    SecretRejection.mismatch => l10n.appLockErrorMismatch,
    SecretRejection.tooShort =>
      mode == AppLockMode.pin
          ? l10n.appLockErrorPinTooShort
          : l10n.appLockErrorPasswordTooShort,
  };
}
