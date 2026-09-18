# Plan: Implement Full Sanskrit (Devanagari) UI Localization

**Status:** COMPLETED

## The Ask

Implement full UI localization for Sanskrit (`sa`) across the application, matching the implementation in reference repositories (`SreerajP_Journal_Vault` and `MantraJapaCounter`) and strictly following the project engineering standard (`docs/flutter_project_engineering_standard.md` §8.3, §8.4, §8.5, §8.7). Enable Sanskrit selection in **Settings → Language** alongside System Default, English, and Malayalam.

## Current State & Issues Found

1. **Missing Sanskrit UI translation (`app_sa.arb`):**
   - The app currently provides `lib/l10n/app_en.arb` (1,168 keys) and `lib/l10n/app_ml.arb` (1,168 keys).
   - There is no `lib/l10n/app_sa.arb`, so Flutter cannot generate `AppLocalizationsSa` or include `Locale('sa')` in supported locales.
2. **Missing Framework Localizations Delegates:**
   - Flutter's official `flutter_localizations` package has no translations for Sanskrit (`sa`).
   - Without custom fallback delegates (`SaMaterialLocalizationsDelegate`, `SaCupertinoLocalizationsDelegate`, `SaWidgetsLocalizationsDelegate`) forwarding to English framework strings, any Material widget requiring framework text (e.g. date pickers, dialog buttons, text selection toolbars) throws a runtime exception under `Locale('sa')` (§8.3.1).
3. **Language Selection Screen & Notifier Gaps:**
   - `lib/presentation/screens/settings/language_screen.dart` only presents `'system'`, `'en'`, and `'ml'`.
   - `lib/application/locale_notifier.dart` only recognizes and persists `'en'`, `'ml'`, or `'system'`.
   - `lib/l10n/app_en.arb` and `lib/l10n/app_ml.arb` lack the `settingsLanguageSanskrit` localization key.
4. **App Wiring & Android Manifest Config:**
   - `lib/app.dart` does not register the Sanskrit framework fallback delegates before `Global*Localizations.delegate`.
   - `android/app/src/main/res/xml/locales_config.xml` only lists `en` and `ml`, missing `sa` for Android 13+ per-app language settings.

## Proposed Changes

| File | Layer | Action | Details |
|---|---|---|---|
| `lib/core/l10n/sa_framework_localizations.dart` | core | NEW | Implement `SaMaterialLocalizationsDelegate`, `SaCupertinoLocalizationsDelegate`, and `SaWidgetsLocalizationsDelegate` returning English framework localizations for `sa`. |
| `lib/l10n/app_sa.arb` | l10n | NEW | Complete authentic Sanskrit translations for all 1,168+ keys matching `app_en.arb`, conforming to §8.5 (pure Sanskrit, no Hindi markers, standard UI glossary, NFC normalized). |
| `lib/l10n/app_en.arb` | l10n | MODIFY | Add `settingsLanguageSanskrit` ("Sanskrit") with description. |
| `lib/l10n/app_ml.arb` | l10n | MODIFY | Add `settingsLanguageSanskrit` ("സംസ്കൃതം"). |
| `lib/application/locale_notifier.dart` | application | MODIFY | Support `'sa'` in `_loadInitialLocale` and `setLocale('sa')`. |
| `lib/presentation/screens/settings/language_screen.dart` | presentation | MODIFY | Add Sanskrit (`sa`) to options list using `l10n.settingsLanguageSanskrit` (or endonym `संस्कृतम्`) and an appropriate icon. |
| `lib/app.dart` | app / presentation | MODIFY | Add Sanskrit delegates to `localizationsDelegates` before `Global*Localizations.delegate`. |
| `android/app/src/main/res/xml/locales_config.xml` | android | MODIFY | Add `<locale android:name="sa"/>` to locale config. |
| `test/core/l10n/sa_framework_localizations_test.dart` | test | NEW | Unit tests asserting delegates report `isSupported == true` for `sa` and load English delegates. |
| `test/application/locale_notifier_test.dart` | test | MODIFY | Add tests for initial load with `sa` preference and `setLocale('sa')`. |
| `test/presentation/settings_screen_test.dart` | test | MODIFY | Assert `settingsLanguageSanskrit` appears on the Language settings screen. |
| `test/l10n/sanskrit_quality_test.dart` | test | NEW | Automated regression test verifying `app_sa.arb` has exact key parity with `app_en.arb`, zero Hindi markers, zero nukta characters, and valid NFC normalization. |

## Sanskrit Quality Rules & Glossary Mapping (§8.5)

- **Pure Sanskrit (Zero Hindi Leakage):**
  - No Hindi auxiliaries (`है`, `था`, `होगा`, `रहा`, `गया`, `चुका`), verbs (`करना`, `होना`, `देना`, `लेना`), pronouns/postpositions (`का`, `के`, `की`, `को`, `से`, `में`, `पर`, `आप`), conjunctions (`और`, `या`), or negation (`नहीं`, `मत`).
  - No nukta characters (`क़`, `ख़`, `ग़`, `ज़`, `फ़`, `ड़`, `ढ़`).
- **Standard UI Glossary:**
  - Settings: `विन्यासः`
  - Language: `भाषा`
  - System Default: `तन्त्रसिद्धम्`
  - Sanskrit: `संस्कृतम्`
  - Save: `रक्ष्यताम्`
  - Cancel: `निरस्यताम्`
  - Delete: `लुप्यताम्`
  - Edit: `सम्पाद्यताम्`
  - Add: `योज्यताम्`
  - Copy: `प्रतिलिख्यताम्`
  - Search: `अन्वेषणम्`
  - Todo / Task: `कार्यम्`
  - Time Segments: `समयखण्डाः`
  - Pending: `अवशिष्टम्`
  - Completed: `समापितम्`
  - Dropped: `त्यक्तम्`
  - Working / In progress: `प्रवर्तमानम्`
  - Export: `निर्याप्यताम्`
  - Backup: `प्रतिरक्षा`
  - Restore: `पुनःस्थाप्यताम्`

## Verification Plan

### Automated Tests
1. Run `flutter gen-l10n` to compile ARB files into `app_localizations_sa.dart` and `app_localizations.dart`.
2. Run `flutter test test/core/l10n/sa_framework_localizations_test.dart`
3. Run `flutter test test/application/locale_notifier_test.dart`
4. Run `flutter test test/presentation/settings_screen_test.dart`
5. Run `flutter test test/l10n/sanskrit_quality_test.dart`
6. Run full test suite: `flutter test`
7. Static analysis: `flutter analyze` (must be 0 issues).

### Manual / Integration Verification
- Verify in **Settings → Language** that Sanskrit appears with its localized label / endonym.
- Switch to Sanskrit and verify the entire UI switches dynamically to Sanskrit without requiring app restart.
- Open date pickers and dialogs under Sanskrit to ensure framework localizations fallback smoothly to English without throwing exceptions.
