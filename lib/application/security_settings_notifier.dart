// ignore_for_file: prefer_initializing_formals
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sreerajp_todo/core/platform/app_lock_channel.dart';
import 'package:sreerajp_todo/core/security/app_lock_service.dart';
import 'package:sreerajp_todo/core/utils/app_lock_rules.dart';

/// SharedPreferences key for how the app is locked.
const String kLockModeKey = 'security_lock_mode';

/// SharedPreferences key for how long the app may sit in the background.
const String kAutoLockDelayKey = 'security_auto_lock_delay';

/// SharedPreferences key for hiding the app in the recent-apps preview.
const String kSecureScreenKey = 'security_secure_screen';

/// SharedPreferences key for the PIN or password salt.
const String kLockSaltKey = 'security_lock_salt';

/// SharedPreferences key for the PIN or password hash.
const String kLockHashKey = 'security_lock_hash';

/// SharedPreferences key for the work factor the stored hash was made with.
const String kLockIterationsKey = 'security_lock_iterations';

/// Immutable snapshot of every security preference.
@immutable
class SecuritySettings {
  const SecuritySettings({
    this.lockMode = AppLockMode.off,
    this.autoLockDelay = AutoLockDelay.oneMinute,
    this.secureScreen = false,
    this.hasStoredSecret = false,
  });

  /// How the app is locked, if at all.
  final AppLockMode lockMode;

  /// How long the app may sit in the background before it locks again.
  final AutoLockDelay autoLockDelay;

  /// When true, the recent-apps preview and screenshots stay blank.
  final bool secureScreen;

  /// Whether a PIN or password is on record.
  ///
  /// The secret itself is never held in state. This flag only says whether one
  /// exists, so the settings page can offer "change" instead of "set up".
  final bool hasStoredSecret;

  /// Whether the app asks for anything at all before it opens.
  bool get isLockEnabled => lockMode != AppLockMode.off;

  /// Whether this lock needs a typed secret rather than the device screen.
  bool get needsTypedSecret =>
      lockMode == AppLockMode.pin || lockMode == AppLockMode.password;

  SecuritySettings copyWith({
    AppLockMode? lockMode,
    AutoLockDelay? autoLockDelay,
    bool? secureScreen,
    bool? hasStoredSecret,
  }) {
    return SecuritySettings(
      lockMode: lockMode ?? this.lockMode,
      autoLockDelay: autoLockDelay ?? this.autoLockDelay,
      secureScreen: secureScreen ?? this.secureScreen,
      hasStoredSecret: hasStoredSecret ?? this.hasStoredSecret,
    );
  }
}

/// Owns the security preferences and the stored PIN or password record.
///
/// The PIN itself is never kept here, never written to preferences and never
/// logged. Only a salt and a hash are stored, exactly as the backup passphrase
/// is handled.
class SecuritySettingsNotifier extends StateNotifier<SecuritySettings> {
  SecuritySettingsNotifier(
    this._prefs, {
    AppLockService lockService = const AppLockService(),
    AppLockChannel? lockChannel,
  }) : _lockService = lockService,
       _lockChannel = lockChannel ?? AppLockChannel(),
       super(_loadInitialState(_prefs)) {
    // The window flag does not survive a restart, so it is re-applied here.
    _applySecureFlag();
  }

  final SharedPreferences _prefs;
  final AppLockService _lockService;
  final AppLockChannel _lockChannel;

  static SecuritySettings _loadInitialState(SharedPreferences prefs) {
    const defaults = SecuritySettings();
    final mode = _readEnum(
      prefs.getInt(kLockModeKey),
      AppLockMode.values,
      defaults.lockMode,
    );
    final hasSecret =
        prefs.getString(kLockSaltKey) != null &&
        prefs.getString(kLockHashKey) != null;

    return SecuritySettings(
      // A typed lock with no stored secret would lock the app with nothing
      // able to open it. That can only happen after a half-finished write, so
      // it falls back to no lock at all.
      lockMode:
          (mode == AppLockMode.pin || mode == AppLockMode.password) &&
              !hasSecret
          ? AppLockMode.off
          : mode,
      autoLockDelay: _readEnum(
        prefs.getInt(kAutoLockDelayKey),
        AutoLockDelay.values,
        defaults.autoLockDelay,
      ),
      secureScreen: prefs.getBool(kSecureScreenKey) ?? defaults.secureScreen,
      hasStoredSecret: hasSecret,
    );
  }

  /// Reads a saved enum index, falling back when it is missing or out of
  /// range. A bad stored value can only come from a downgrade or a hand-edited
  /// file, and must never crash the app.
  static T _readEnum<T>(int? index, List<T> values, T fallback) {
    if (index == null || index < 0 || index >= values.length) return fallback;
    return values[index];
  }

  void _applySecureFlag() {
    _lockChannel.setSecureFlag(state.secureScreen);
  }

  /// Whether the phone can show its own unlock screen.
  Future<bool> isDeviceCredentialAvailable() =>
      _lockChannel.isDeviceCredentialAvailable();

  /// The stored PIN or password record, or null when none is set.
  AppLockCredential? get storedCredential {
    final salt = _prefs.getString(kLockSaltKey);
    final hash = _prefs.getString(kLockHashKey);
    if (salt == null || hash == null) return null;
    return AppLockCredential(
      saltBase64: salt,
      hashBase64: hash,
      iterations:
          _prefs.getInt(kLockIterationsKey) ?? AppLockService.unlockIterations,
    );
  }

  /// Whether [secret] matches what is on record.
  ///
  /// Returns false when no record exists, so a missing record can never open a
  /// locked app.
  Future<bool> verifySecret(String secret) async {
    final stored = storedCredential;
    if (stored == null) return false;
    return _lockService.verify(secret, stored);
  }

  /// Saves a new PIN or password and turns that lock on.
  ///
  /// Rejects a secret with the wrong shape and returns the reason, so nothing
  /// is written until the value is usable.
  Future<SecretRejection?> setSecret(AppLockMode mode, String secret) async {
    final rejection = validateNewSecret(mode, secret);
    if (rejection != null) return rejection;

    final credential = await _lockService.createCredential(secret);
    // The record is written before the mode, so the app is never left in a
    // locked mode with nothing able to open it.
    await _prefs.setString(kLockSaltKey, credential.saltBase64);
    await _prefs.setString(kLockHashKey, credential.hashBase64);
    await _prefs.setInt(kLockIterationsKey, credential.iterations);
    await _prefs.setInt(kLockModeKey, mode.index);

    state = state.copyWith(lockMode: mode, hasStoredSecret: true);
    return null;
  }

  /// Switches to the phone unlock screen, which needs no secret of our own.
  Future<void> useDeviceCredential() async {
    await _prefs.setInt(kLockModeKey, AppLockMode.deviceCredential.index);
    state = state.copyWith(lockMode: AppLockMode.deviceCredential);
  }

  /// Turns the lock off and wipes the stored record.
  Future<void> disableLock() async {
    await _prefs.setInt(kLockModeKey, AppLockMode.off.index);
    await _prefs.remove(kLockSaltKey);
    await _prefs.remove(kLockHashKey);
    await _prefs.remove(kLockIterationsKey);
    state = state.copyWith(lockMode: AppLockMode.off, hasStoredSecret: false);
  }

  /// Sets how long the app may sit in the background before it locks again.
  Future<void> setAutoLockDelay(AutoLockDelay value) async {
    if (value == state.autoLockDelay) return;
    state = state.copyWith(autoLockDelay: value);
    await _prefs.setInt(kAutoLockDelayKey, value.index);
  }

  /// Hides or shows the app contents in the recent-apps preview.
  Future<void> setSecureScreen(bool value) async {
    if (value == state.secureScreen) return;
    state = state.copyWith(secureScreen: value);
    await _lockChannel.setSecureFlag(value);
    await _prefs.setBool(kSecureScreenKey, value);
  }
}
