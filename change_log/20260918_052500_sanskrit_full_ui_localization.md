# Change Log: Implement Full Sanskrit (Devanagari) UI Localization

**Plan:** `plans/20260918_050500_sanskrit_full_ui_localization.md`

## What changed

1. **`lib/core/l10n/sa_framework_localizations.dart`:**
   - Implemented `SaMaterialLocalizationsDelegate`, `SaCupertinoLocalizationsDelegate`, and `SaWidgetsLocalizationsDelegate`.
   - Delegates provide English framework localizations as fallback for `Locale('sa')`, preventing missing framework translation crashes on Material/Cupertino dialogs, date pickers, and toolbars.

2. **`lib/app.dart`:**
   - Registered the Sanskrit fallback delegates (`SaMaterialLocalizationsDelegate()`, `SaCupertinoLocalizationsDelegate()`, `SaWidgetsLocalizationsDelegate()`) in `localizationsDelegates` before Flutter's global delegates.
   - Added `const Locale('sa')` to `supportedLocales`.

3. **`android/app/src/main/res/xml/locales_config.xml`:**
   - Added `<locale android:name="sa"/>` for Android 13+ per-app language settings support.

4. **`lib/application/locale_notifier.dart`:**
   - Added `'sa'` support to `_loadInitialLocale` and `setLocale` methods, enabling persistence of Sanskrit language selection across app restarts.

5. **`lib/l10n/app_en.arb` and `lib/l10n/app_ml.arb`:**
   - Added `settingsLanguageSanskrit` localization key with complete descriptions.

6. **`lib/presentation/screens/settings/language_screen.dart`:**
   - Added Sanskrit option (`sa`, `संस्कृतम्`, `Sanskrit`) to the language selection list.

7. **`lib/l10n/app_sa.arb`:**
   - Created full Sanskrit UI translation file with 100% key parity (1,169 keys).
   - Follows pure classical Sanskrit: Devanagari script, NFC normalized, zero Hindi markers, zero nuktas, and correct placeholder matching.

8. **Tests Added and Updated:**
   - `test/core/l10n/sa_framework_localizations_test.dart`: Added unit tests for Sanskrit framework fallback delegates.
   - `test/application/locale_notifier_test.dart`: Added unit tests for loading and setting `'sa'` locale.
   - `test/presentation/settings_screen_test.dart`: Updated and verified language selection screen with Sanskrit.
   - `test/l10n/sanskrit_quality_test.dart`: Added test suite verifying 100% key parity with `app_en.arb`, valid ICU syntax, exact placeholder matching, NFC normalization, zero nuktas, and absence of Hindi markers.

## Verification

- `flutter gen-l10n`: successfully generated `AppLocalizationsSa` and updated `AppLocalizations`.
- `flutter analyze`: 0 issues found across entire codebase.
- `flutter test`: all 771 tests passed clean.
