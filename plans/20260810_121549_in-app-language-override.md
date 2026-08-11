# In-App Language Override (English / Malayalam / System Default)

**Status:** completed

## Files to change

- `pubspec.yaml` [MODIFY]
- `AGENTS.md` [MODIFY]
- `docs/dependencies.md` [MODIFY]
- `lib/l10n/app_en.arb` [MODIFY]
- `lib/l10n/app_ml.arb` [MODIFY]
- `lib/application/locale_notifier.dart` [NEW]
- `lib/application/providers.dart` [MODIFY]
- `lib/main.dart` [MODIFY]
- `lib/app.dart` [MODIFY]
- `lib/presentation/screens/settings/settings_screen.dart` [MODIFY]
- `test/application/locale_notifier_test.dart` [NEW]

## What is wrong

Currently, the app locale strictly follows the device's system language via `flutter_localizations`. Multi-lingual users cannot manually choose their preferred app language interface (System Default, English, or Malayalam) independently of their device-wide system language settings.

## Proposed Plan

1. **Add `shared_preferences` dependency**:
   - Update `pubspec.yaml` to include `shared_preferences: ^2.3.2` under `dependencies`.
   - Update `AGENTS.md` and `docs/dependencies.md` to include `shared_preferences` in approved local-only dependencies.

2. **Add Localized Strings**:
   - Update `lib/l10n/app_en.arb` with keys: `settingsLanguage`, `settingsLanguageSystem`, `settingsLanguageEnglish`, `settingsLanguageMalayalam`.
   - Update `lib/l10n/app_ml.arb` with Malayalam translations.

3. **Create `LocaleNotifier` and Riverpod Providers**:
   - Create `lib/application/locale_notifier.dart` managing `Locale?` state (where `null` means System Default, `Locale('en')` means English, `Locale('ml')` means Malayalam) and persisting the selection via `SharedPreferences`.
   - Expose `sharedPreferencesProvider` and `localeProvider` in `lib/application/providers.dart`.

4. **Initialize SharedPreferences at App Startup**:
   - Update `lib/main.dart` to initialize `SharedPreferences.getInstance()` asynchronously before app launch and pass `sharedPreferencesProvider.overrideWithValue(prefs)` into `ProviderContainer`.

5. **Dynamic App Locale Binding & UI**:
   - Update `lib/app.dart` to watch `localeProvider` and pass `locale: ref.watch(localeProvider)` into `MaterialApp.router`.
   - Update `lib/presentation/screens/settings/settings_screen.dart` to include an explicit Language selection section card using `SegmentedButton<String>` with System Default, English, and Malayalam options.

6. **Testing & Verification**:
   - Create unit test suite in `test/application/locale_notifier_test.dart` verifying initial state loading, setting locales ('en', 'ml', 'system'), and `SharedPreferences` persistence.
   - Run `flutter analyze` and `flutter test` to ensure zero static analysis errors and 100% test pass rate.

## After approval

Write a change log in `change_log/20260810_121549_in-app-language-override.md` describing the changes and implementation details.
