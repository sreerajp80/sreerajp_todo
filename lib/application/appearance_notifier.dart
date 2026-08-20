import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences key for the saved light/dark/system theme mode.
const String kThemeModePreferenceKey = 'appearance_theme_mode';

/// SharedPreferences key for the saved app font family choice.
const String kAppFontPreferenceKey = 'appearance_font';

/// SharedPreferences key for the saved app-wide text size choice.
const String kTextScalePreferenceKey = 'appearance_text_scale';

/// SharedPreferences key for the accent colour override used in light mode.
const String kAccentLightPreferenceKey = 'appearance_accent_light';

/// SharedPreferences key for the accent colour override used in dark mode.
const String kAccentDarkPreferenceKey = 'appearance_accent_dark';

/// App-wide UI font the user can pick in Settings -> Appearance -> Typography.
///
/// Every bundled choice renders both Latin (English) and Malayalam text.
enum AppFont {
  /// The platform default font. [family] is null so Flutter picks it.
  system,

  /// Manjari - elegant, highly readable Malayalam with a clean Latin.
  manjari,

  /// Anek Malayalam - modern, neutral sans covering both scripts.
  anekMalayalam,

  /// Noto Sans Malayalam - plain, maximally legible workhorse.
  notoSansMalayalam;

  /// The pubspec font-family name, or null to use the platform default.
  String? get family => switch (this) {
    AppFont.system => null,
    AppFont.manjari => 'Manjari',
    AppFont.anekMalayalam => 'Anek Malayalam',
    AppFont.notoSansMalayalam => 'Noto Sans Malayalam',
  };
}

/// App-wide text size the user can pick in Settings -> Appearance -> Typography.
///
/// Each choice is a multiplier applied on top of the system text scale.
enum AppTextScale {
  /// 0.85x - a little smaller than default.
  small,

  /// 1.0x - the app default, leaves text unchanged.
  normal,

  /// 1.15x - a little larger than default.
  large,

  /// 1.30x - noticeably larger, for easier reading.
  larger;

  /// The multiplier applied to every text size in the app.
  double get scale => switch (this) {
    AppTextScale.small => 0.85,
    AppTextScale.normal => 1.0,
    AppTextScale.large => 1.15,
    AppTextScale.larger => 1.30,
  };
}

/// Immutable snapshot of every appearance preference.
@immutable
class AppearanceState {
  const AppearanceState({
    this.themeMode = ThemeMode.system,
    this.font = AppFont.system,
    this.textScale = AppTextScale.normal,
    this.lightAccent,
    this.darkAccent,
  });

  /// Light, dark, or follow the system setting.
  final ThemeMode themeMode;

  /// The chosen app font family.
  final AppFont font;

  /// The chosen app-wide text size.
  final AppTextScale textScale;

  /// Accent override for light mode. Null means "use the app default".
  final Color? lightAccent;

  /// Accent override for dark mode. Null means "use the app default".
  final Color? darkAccent;

  /// The accent override for [brightness], or null when still on the default.
  Color? accentFor(Brightness brightness) =>
      brightness == Brightness.dark ? darkAccent : lightAccent;

  AppearanceState copyWith({
    ThemeMode? themeMode,
    AppFont? font,
    AppTextScale? textScale,
    Color? lightAccent,
    Color? darkAccent,
    bool clearLightAccent = false,
    bool clearDarkAccent = false,
  }) {
    return AppearanceState(
      themeMode: themeMode ?? this.themeMode,
      font: font ?? this.font,
      textScale: textScale ?? this.textScale,
      lightAccent: clearLightAccent ? null : (lightAccent ?? this.lightAccent),
      darkAccent: clearDarkAccent ? null : (darkAccent ?? this.darkAccent),
    );
  }
}

/// Notifier that owns the appearance preferences and persists every change to
/// [SharedPreferences], so the choices survive an app restart.
class AppearanceNotifier extends StateNotifier<AppearanceState> {
  AppearanceNotifier(this._prefs) : super(_loadInitialState(_prefs));

  final SharedPreferences _prefs;

  static AppearanceState _loadInitialState(SharedPreferences prefs) {
    final lightArgb = prefs.getInt(kAccentLightPreferenceKey);
    final darkArgb = prefs.getInt(kAccentDarkPreferenceKey);
    return AppearanceState(
      themeMode: _readEnum(
        prefs.getInt(kThemeModePreferenceKey),
        ThemeMode.values,
        ThemeMode.system,
      ),
      font: _readEnum(
        prefs.getInt(kAppFontPreferenceKey),
        AppFont.values,
        AppFont.system,
      ),
      textScale: _readEnum(
        prefs.getInt(kTextScalePreferenceKey),
        AppTextScale.values,
        AppTextScale.normal,
      ),
      lightAccent: lightArgb == null ? null : Color(lightArgb),
      darkAccent: darkArgb == null ? null : Color(darkArgb),
    );
  }

  static T _readEnum<T>(int? index, List<T> values, T fallback) {
    if (index == null || index < 0 || index >= values.length) return fallback;
    return values[index];
  }

  /// Sets light / dark / system mode and saves it.
  Future<void> setThemeMode(ThemeMode mode) async {
    if (mode == state.themeMode) return;
    state = state.copyWith(themeMode: mode);
    await _prefs.setInt(kThemeModePreferenceKey, mode.index);
  }

  /// Sets the app font family and saves it.
  Future<void> setFont(AppFont font) async {
    if (font == state.font) return;
    state = state.copyWith(font: font);
    await _prefs.setInt(kAppFontPreferenceKey, font.index);
  }

  /// Sets the app-wide text size and saves it.
  Future<void> setTextScale(AppTextScale scale) async {
    if (scale == state.textScale) return;
    state = state.copyWith(textScale: scale);
    await _prefs.setInt(kTextScalePreferenceKey, scale.index);
  }

  /// Sets the accent colour used for [brightness] and saves it.
  Future<void> setAccentFor(Brightness brightness, Color color) async {
    if (brightness == Brightness.dark) {
      state = state.copyWith(darkAccent: color);
      await _prefs.setInt(kAccentDarkPreferenceKey, color.toARGB32());
    } else {
      state = state.copyWith(lightAccent: color);
      await _prefs.setInt(kAccentLightPreferenceKey, color.toARGB32());
    }
  }

  /// Clears the accent override for [brightness], back to the app default.
  Future<void> resetAccentFor(Brightness brightness) async {
    if (brightness == Brightness.dark) {
      state = state.copyWith(clearDarkAccent: true);
      await _prefs.remove(kAccentDarkPreferenceKey);
    } else {
      state = state.copyWith(clearLightAccent: true);
      await _prefs.remove(kAccentLightPreferenceKey);
    }
  }
}
