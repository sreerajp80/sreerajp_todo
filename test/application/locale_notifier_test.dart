import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sreerajp_todo/application/locale_notifier.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LocaleNotifier', () {
    test('initial state is null (system default) when no key is set', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final notifier = LocaleNotifier(prefs);

      expect(notifier.state, isNull);
    });

    test('initial state loads Locale("en") when preference is "en"', () async {
      SharedPreferences.setMockInitialValues({kLocalePreferenceKey: 'en'});
      final prefs = await SharedPreferences.getInstance();

      final notifier = LocaleNotifier(prefs);

      expect(notifier.state, const Locale('en'));
    });

    test('initial state loads Locale("ml") when preference is "ml"', () async {
      SharedPreferences.setMockInitialValues({kLocalePreferenceKey: 'ml'});
      final prefs = await SharedPreferences.getInstance();

      final notifier = LocaleNotifier(prefs);

      expect(notifier.state, const Locale('ml'));
    });

    test(
      'setLocale("en") updates state to English and persists preference',
      () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();

        final notifier = LocaleNotifier(prefs);
        await notifier.setLocale('en');

        expect(notifier.state, const Locale('en'));
        expect(prefs.getString(kLocalePreferenceKey), 'en');
      },
    );

    test(
      'setLocale("ml") updates state to Malayalam and persists preference',
      () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();

        final notifier = LocaleNotifier(prefs);
        await notifier.setLocale('ml');

        expect(notifier.state, const Locale('ml'));
        expect(prefs.getString(kLocalePreferenceKey), 'ml');
      },
    );

    test(
      'setLocale("system") resets state to null and persists "system"',
      () async {
        SharedPreferences.setMockInitialValues({kLocalePreferenceKey: 'en'});
        final prefs = await SharedPreferences.getInstance();

        final notifier = LocaleNotifier(prefs);
        expect(notifier.state, const Locale('en'));

        await notifier.setLocale('system');

        expect(notifier.state, isNull);
        expect(prefs.getString(kLocalePreferenceKey), 'system');
      },
    );
  });
}
