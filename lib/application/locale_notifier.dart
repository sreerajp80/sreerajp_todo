import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences storage key for persistent language selection.
const String kLocalePreferenceKey = 'app_language_code';

/// Notifier that manages the active [Locale] override state.
///
/// A state of `null` indicates that the app should follow the system default language.
class LocaleNotifier extends StateNotifier<Locale?> {
  final SharedPreferences _prefs;

  LocaleNotifier(this._prefs) : super(_loadInitialLocale(_prefs));

  static Locale? _loadInitialLocale(SharedPreferences prefs) {
    final code = prefs.getString(kLocalePreferenceKey);
    if (code == 'en') return const Locale('en');
    if (code == 'ml') return const Locale('ml');
    return null; // System default
  }

  /// Updates the active locale and persists the selection to [SharedPreferences].
  ///
  /// Passing `'en'` sets English, `'ml'` sets Malayalam, and any other value
  /// (including `'system'`) resets to system default (`null`).
  Future<void> setLocale(String languageCode) async {
    if (languageCode == 'en') {
      state = const Locale('en');
      await _prefs.setString(kLocalePreferenceKey, 'en');
    } else if (languageCode == 'ml') {
      state = const Locale('ml');
      await _prefs.setString(kLocalePreferenceKey, 'ml');
    } else {
      state = null;
      await _prefs.setString(kLocalePreferenceKey, 'system');
    }
  }
}
