# Change Log — In-App Language Override (English / Malayalam / System Default)

**Plan reference:** [plans/20260810_121549_in-app-language-override.md](plans/20260810_121549_in-app-language-override.md)

## Summary of Changes

Implemented **Feature 4.8 In-App Language Override**, providing multi-lingual users with full dynamic control over their preferred app language interface (System Default, English, or Malayalam) from Settings without requiring device-wide system language changes.

### Key Changes:

1. **Dependency & Documentation Update**:
   - Added `shared_preferences: ^2.3.2` to `pubspec.yaml` for offline key-value preference persistence.
   - Updated `AGENTS.md` and `docs/dependencies.md` to register `shared_preferences` in approved local-only runtime packages.

2. **Localization Strings**:
   - Added localized UI strings (`settingsLanguage`, `settingsLanguageSystem`, `settingsLanguageEnglish`, `settingsLanguageMalayalam`) to `lib/l10n/app_en.arb` and `lib/l10n/app_ml.arb`.

3. **Locale State Management**:
   - Created `lib/application/locale_notifier.dart` (`LocaleNotifier` extending `StateNotifier<Locale?>`) to manage active locale state (`null` for system default, `Locale('en')` for English, `Locale('ml')` for Malayalam) and handle `SharedPreferences` persistence.
   - Exposed `sharedPreferencesProvider` and `localeProvider` in `lib/application/providers.dart`.

4. **App Startup & Dynamic Binding**:
   - Updated `lib/main.dart` to initialize `SharedPreferences.getInstance()` asynchronously at startup and override `sharedPreferencesProvider` in `ProviderContainer`.
   - Updated `lib/app.dart` to watch `localeProvider` and bind `locale: ref.watch(localeProvider)` to `MaterialApp.router`.

5. **Settings UI**:
   - Updated `lib/presentation/screens/settings/settings_screen.dart` with an explicit Language section card featuring a `SegmentedButton<String>` for System Default, English, and Malayalam selection.

6. **Unit Tests & Quality Assurance**:
   - Created `test/application/locale_notifier_test.dart` to test initial state loading, setting locale options, and `SharedPreferences` persistence.
   - Verified static analysis (`flutter analyze`: zero issues) and full test suite (`flutter test`: 233 passing tests).
