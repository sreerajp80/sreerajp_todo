import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sreerajp_todo/application/appearance_notifier.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<SharedPreferences> freshPrefs([
    Map<String, Object> values = const {},
  ]) async {
    SharedPreferences.setMockInitialValues(values);
    return SharedPreferences.getInstance();
  }

  group('AppearanceNotifier', () {
    test('starts with the app defaults when nothing is saved', () async {
      final notifier = AppearanceNotifier(await freshPrefs());

      expect(notifier.state.themeMode, ThemeMode.system);
      expect(notifier.state.font, AppFont.system);
      expect(notifier.state.textScale, AppTextScale.normal);
      expect(notifier.state.lightAccent, isNull);
      expect(notifier.state.darkAccent, isNull);
    });

    test('saves the theme mode and reads it back', () async {
      final prefs = await freshPrefs();
      await AppearanceNotifier(prefs).setThemeMode(ThemeMode.dark);

      expect(prefs.getInt(kThemeModePreferenceKey), ThemeMode.dark.index);
      expect(AppearanceNotifier(prefs).state.themeMode, ThemeMode.dark);
    });

    test('saves the font and reads it back', () async {
      final prefs = await freshPrefs();
      await AppearanceNotifier(prefs).setFont(AppFont.manjari);

      expect(prefs.getInt(kAppFontPreferenceKey), AppFont.manjari.index);
      expect(AppearanceNotifier(prefs).state.font, AppFont.manjari);
      expect(AppFont.manjari.family, 'Manjari');
      expect(AppFont.system.family, isNull);
    });

    test('saves the text scale and reads it back', () async {
      final prefs = await freshPrefs();
      await AppearanceNotifier(prefs).setTextScale(AppTextScale.large);

      expect(prefs.getInt(kTextScalePreferenceKey), AppTextScale.large.index);
      expect(AppearanceNotifier(prefs).state.textScale, AppTextScale.large);
      expect(AppTextScale.large.scale, 1.15);
    });

    test('keeps a separate accent for light and dark mode', () async {
      final prefs = await freshPrefs();
      final notifier = AppearanceNotifier(prefs);

      await notifier.setAccentFor(Brightness.light, const Color(0xFF0D9488));
      await notifier.setAccentFor(Brightness.dark, const Color(0xFF7C8AFF));

      final reloaded = AppearanceNotifier(prefs).state;
      expect(reloaded.accentFor(Brightness.light), const Color(0xFF0D9488));
      expect(reloaded.accentFor(Brightness.dark), const Color(0xFF7C8AFF));
    });

    test('reset clears only the accent of that brightness', () async {
      final prefs = await freshPrefs();
      final notifier = AppearanceNotifier(prefs);
      await notifier.setAccentFor(Brightness.light, const Color(0xFF0D9488));
      await notifier.setAccentFor(Brightness.dark, const Color(0xFF7C8AFF));

      await notifier.resetAccentFor(Brightness.dark);

      expect(notifier.state.darkAccent, isNull);
      expect(notifier.state.lightAccent, const Color(0xFF0D9488));
      expect(prefs.getInt(kAccentDarkPreferenceKey), isNull);
      expect(prefs.getInt(kAccentLightPreferenceKey), isNotNull);
    });

    test('ignores an out of range saved value', () async {
      final prefs = await freshPrefs({
        kThemeModePreferenceKey: 99,
        kAppFontPreferenceKey: -1,
        kTextScalePreferenceKey: 42,
      });

      final state = AppearanceNotifier(prefs).state;
      expect(state.themeMode, ThemeMode.system);
      expect(state.font, AppFont.system);
      expect(state.textScale, AppTextScale.normal);
    });
  });
}
