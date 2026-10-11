/// Pure Dart rules for the app lock.
///
/// Holds the choice lists, the shape checks for a PIN or password, and the
/// slow-down applied after wrong tries. No Flutter import here, so `core/`
/// stays framework free.
library;

/// How the app is locked, if at all.
enum AppLockMode {
  /// No lock. The app opens straight into the day list.
  off,

  /// A digits-only code.
  pin,

  /// A free-text password.
  password,

  /// The phone's own unlock screen, which uses fingerprint or face where the
  /// user set that up. Android only.
  deviceCredential,
}

/// How long the app may sit in the background before it locks again.
enum AutoLockDelay {
  immediately,
  thirtySeconds,
  oneMinute,
  fiveMinutes,
  fifteenMinutes,

  /// Never re-lock while the app is still running. It still locks on a cold
  /// start.
  never;

  /// The wait before the lock comes back, or null for [never].
  Duration? get duration => switch (this) {
    AutoLockDelay.immediately => Duration.zero,
    AutoLockDelay.thirtySeconds => const Duration(seconds: 30),
    AutoLockDelay.oneMinute => const Duration(minutes: 1),
    AutoLockDelay.fiveMinutes => const Duration(minutes: 5),
    AutoLockDelay.fifteenMinutes => const Duration(minutes: 15),
    AutoLockDelay.never => null,
  };
}

/// The shortest PIN the app accepts.
const int kMinPinLength = 4;

/// The longest PIN the app accepts.
const int kMaxPinLength = 8;

/// The shortest password the app accepts.
const int kMinPasswordLength = 6;

/// How many wrong tries are free before the wait starts growing.
const int kFreeUnlockAttempts = 4;

/// The longest the app will ever make someone wait.
const Duration kMaxUnlockDelay = Duration(minutes: 5);

/// Why a PIN or password was rejected while it was being set.
enum SecretRejection {
  /// The field was left empty.
  empty,

  /// A PIN held something other than digits.
  notDigits,

  /// Shorter than the minimum for its kind.
  tooShort,

  /// A PIN longer than the maximum.
  tooLong,

  /// The second field did not match the first.
  mismatch,
}

/// Checks the shape of a new [secret] for [mode].
///
/// Returns null when it is acceptable. This only checks the shape; it says
/// nothing about how good a choice the secret is.
SecretRejection? validateNewSecret(AppLockMode mode, String secret) {
  if (secret.isEmpty) return SecretRejection.empty;

  if (mode == AppLockMode.pin) {
    if (!RegExp(r'^\d+$').hasMatch(secret)) return SecretRejection.notDigits;
    if (secret.length < kMinPinLength) return SecretRejection.tooShort;
    if (secret.length > kMaxPinLength) return SecretRejection.tooLong;
    return null;
  }

  if (mode == AppLockMode.password) {
    if (secret.length < kMinPasswordLength) return SecretRejection.tooShort;
    return null;
  }

  // The device credential has no secret of its own to check.
  return null;
}

/// How long to make someone wait after [failedAttempts] wrong tries.
///
/// The first few tries are free, because typing a PIN wrong is normal. After
/// that the wait doubles each time, up to [kMaxUnlockDelay]. This is the only
/// thing standing between a stolen phone and a four-digit code, so it is not
/// optional.
Duration unlockDelayFor(int failedAttempts) {
  if (failedAttempts <= kFreeUnlockAttempts) return Duration.zero;

  final steps = failedAttempts - kFreeUnlockAttempts;
  // Doubling gets very large very fast, so the exponent is capped before it is
  // used rather than after, to keep the arithmetic small.
  final cappedSteps = steps > 10 ? 10 : steps;
  final seconds = 5 * (1 << (cappedSteps - 1));
  final delay = Duration(seconds: seconds);
  return delay > kMaxUnlockDelay ? kMaxUnlockDelay : delay;
}

/// Whether the app should lock again after being away for [awayFor].
bool shouldRelock(AutoLockDelay setting, Duration awayFor) {
  final limit = setting.duration;
  if (limit == null) return false;
  return awayFor >= limit;
}
