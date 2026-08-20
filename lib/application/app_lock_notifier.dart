// ignore_for_file: prefer_initializing_formals
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sreerajp_todo/application/security_settings_notifier.dart';
import 'package:sreerajp_todo/core/platform/app_lock_channel.dart';
import 'package:sreerajp_todo/core/utils/app_lock_rules.dart';

/// SharedPreferences key for how many wrong tries have piled up.
const String kFailedAttemptsKey = 'security_failed_attempts';

/// SharedPreferences key for the moment the next try is allowed.
const String kRetryAfterKey = 'security_retry_after';

/// Whether the app is locked right now, and how long a wrong try has to wait.
@immutable
class AppLockState {
  const AppLockState({
    this.isLocked = false,
    this.failedAttempts = 0,
    this.retryAfter,
  });

  /// True while the lock screen is covering the app.
  final bool isLocked;

  /// How many wrong tries have piled up since the last success.
  final int failedAttempts;

  /// The moment the next try is allowed, or null when one is allowed now.
  final DateTime? retryAfter;

  /// How long is left of the wait, or zero when a try is allowed now.
  Duration remainingWait(DateTime now) {
    final until = retryAfter;
    if (until == null || !until.isAfter(now)) return Duration.zero;
    return until.difference(now);
  }

  AppLockState copyWith({
    bool? isLocked,
    int? failedAttempts,
    DateTime? retryAfter,
    bool clearRetryAfter = false,
  }) {
    return AppLockState(
      isLocked: isLocked ?? this.isLocked,
      failedAttempts: failedAttempts ?? this.failedAttempts,
      retryAfter: clearRetryAfter ? null : (retryAfter ?? this.retryAfter),
    );
  }
}

/// Owns whether the app is locked right now.
///
/// The settings live in [SecuritySettingsNotifier]; this holds only the live
/// state. Wrong tries are counted in preferences rather than memory, so
/// killing and reopening the app does not clear the wait.
class AppLockNotifier extends StateNotifier<AppLockState> {
  AppLockNotifier({
    required SecuritySettingsNotifier settings,
    required SharedPreferences prefs,
    AppLockChannel? lockChannel,
    DateTime Function() now = DateTime.now,
  }) : _settings = settings,
       _prefs = prefs,
       _lockChannel = lockChannel ?? AppLockChannel(),
       _now = now,
       super(const AppLockState()) {
    _restore();
  }

  final SecuritySettingsNotifier _settings;
  final SharedPreferences _prefs;
  final AppLockChannel _lockChannel;
  final DateTime Function() _now;

  /// When the app last went into the background, used to decide whether the
  /// auto-lock delay has run out.
  DateTime? _leftAt;

  void _restore() {
    final storedRetry = _prefs.getString(kRetryAfterKey);
    state = AppLockState(
      // A cold start always locks when a lock is set. This is the one case the
      // auto-lock delay never covers.
      isLocked: _settings.state.isLockEnabled,
      failedAttempts: _prefs.getInt(kFailedAttemptsKey) ?? 0,
      retryAfter: storedRetry == null ? null : DateTime.tryParse(storedRetry),
    );
  }

  /// Locks the app now, whatever the delay says.
  void lock() {
    if (!_settings.state.isLockEnabled) return;
    if (state.isLocked) return;
    state = state.copyWith(isLocked: true);
  }

  /// Called when the app goes into the background.
  void onPaused() {
    _leftAt = _now();
  }

  /// Called when the app comes back, and locks it when it was away too long.
  void onResumed() {
    final leftAt = _leftAt;
    _leftAt = null;
    if (!_settings.state.isLockEnabled || state.isLocked) return;
    if (leftAt == null) return;

    if (shouldRelock(
      _settings.state.autoLockDelay,
      _now().difference(leftAt),
    )) {
      state = state.copyWith(isLocked: true);
    }
  }

  /// Tries [secret] against the stored PIN or password.
  ///
  /// Returns false while a wait is still running, without even checking the
  /// secret, so the wait cannot be skipped by trying faster.
  Future<bool> unlockWithSecret(String secret) async {
    if (state.remainingWait(_now()) > Duration.zero) return false;

    final matched = await _settings.verifySecret(secret);
    if (matched) {
      await _onSuccess();
      return true;
    }
    await _onFailure();
    return false;
  }

  /// Shows the phone unlock screen and opens the app when it succeeds.
  Future<bool> unlockWithDeviceCredential({
    required String title,
    required String description,
  }) async {
    if (state.remainingWait(_now()) > Duration.zero) return false;

    final unlocked = await _lockChannel.authenticate(
      title: title,
      description: description,
    );
    if (unlocked) {
      await _onSuccess();
      return true;
    }
    // Backing out of the phone unlock screen is not a guess, so it does not
    // count towards the wait.
    return false;
  }

  Future<void> _onSuccess() async {
    state = const AppLockState();
    await _prefs.remove(kFailedAttemptsKey);
    await _prefs.remove(kRetryAfterKey);
  }

  Future<void> _onFailure() async {
    final attempts = state.failedAttempts + 1;
    final delay = unlockDelayFor(attempts);
    final retryAfter = delay == Duration.zero ? null : _now().add(delay);

    state = AppLockState(
      isLocked: true,
      failedAttempts: attempts,
      retryAfter: retryAfter,
    );

    await _prefs.setInt(kFailedAttemptsKey, attempts);
    if (retryAfter == null) {
      await _prefs.remove(kRetryAfterKey);
    } else {
      await _prefs.setString(kRetryAfterKey, retryAfter.toIso8601String());
    }
  }

  /// Opens the app without asking. Used only when the lock is turned off from
  /// the settings page while the app is already open.
  void releaseBecauseLockDisabled() {
    if (_settings.state.isLockEnabled) return;
    state = const AppLockState();
  }
}
