# Plan: Make app_config.json Trilingual (EN/ML/SA) and Update AppConfig Model

**Status:** completed

## The ask

Ensure `assets/config/app_config.json` and related code strictly adhere to the guidelines in `docs/guidelines/` (`guideline.md` §1.2/§1.4 and `flutter_project_engineering_standard.md` §8.3/§8.5/§8.7).
Specifically:
1. Sanskrit (`sa`) is missing from `app_config.json` (for `description` and `license`).
2. `appName`, `author`, `aiUsed`, and `ideUsed` are in English only. They must provide localized values for English (`en`), Malayalam (`ml`), and Sanskrit (`sa`).
3. The `AppConfig` model in `lib/core/config/app_config.dart` and `AboutScreen` in `lib/presentation/screens/about/about_screen.dart` must support a localized `appName` via `LocalizedText`.

## Files to change

| File | Change |
|---|---|
| `assets/config/app_config.json` | Add `en`, `ml`, and `sa` translations for `appName`, `description`, `author`, `license`, `aiUsed`, and `ideUsed`. |
| `lib/core/config/app_config.dart` | Change `appName` from `String` to `LocalizedText` so it supports both plain strings and locale maps with language resolution. Update `fromJson` and `fallback`. |
| `lib/presentation/screens/about/about_screen.dart` | Resolve `appName` using `config.appName.resolve(lang)` for the about card title. |
| `test/core/config/app_config_test.dart` | Update unit tests to verify `appName` as `LocalizedText`, test trilingual parsing, and assert `app_config.json` has complete `en`, `ml`, `sa` entries with no Hindi markers. |
| `test/core/config/config_service_test.dart` | Update `appName` assertions to use `.resolve('en')`. |
| `test/presentation/screens/about/about_screen_test.dart` | Update mock `AppConfig` to use `LocalizedText.plain(...)` for `appName`. |

## The issues found

1. **Missing Sanskrit in `app_config.json`:**
   - `description` contains only `en` and `ml`. `sa` is absent.
   - `license` contains only `en` and `ml`. `sa` is absent.
2. **English-only values in `app_config.json`:**
   - `appName` is a single English string `"SreerajP ToDo"`.
   - `author` is a single English string `"Sreeraj P"`.
   - `aiUsed` is a single English string `"Anthropic Claude, Google Gemini"`.
   - `ideUsed` is a single English string `"VS Code / Antigravity"`.
3. **`AppConfig` model restricts `appName` to plain `String`:**
   - `final String appName;` cannot resolve a locale map `{"en": ..., "ml": ..., "sa": ...}`.
   - `AppConfig.fromJson` ignores maps for `appName` and falls back to default English string.

## The proposed fix

### 1. `assets/config/app_config.json`
Update the file to supply authentic, NFC-normalized translations in English (`en`), Malayalam (`ml`), and Sanskrit (`sa`):
- `appName`:
  - `en`: `"SreerajP ToDo"`
  - `ml`: `"ശ്രീരാജ്പി ടുഡു"`
  - `sa`: `"श्रीराज्-पी कार्यसूची"`
- `description`:
  - `en`: `"Personal offline-first daily ToDo and time-tracker."`
  - `ml`: `"വ്യക്തിഗത ഓഫ്‌ലൈൻ-ആദ്യ പ്രതിദിന ചെയ്യേണ്ട കാര്യങ്ങളും സമയ ട്രാക്കറും."`
  - `sa`: `"व्यक्तिगतम् असंयुक्तप्रथमं प्रतिदिनकार्यसूची समयगणकञ्च।"`
- `author`:
  - `en`: `"Sreeraj P"`
  - `ml`: `"ശ്രീരാജ് പി"`
  - `sa`: `"श्रीराज् पी"`
- `license`:
  - `en`: `"All libraries used are open source."`
  - `ml`: `"ഉപയോഗിച്ച എല്ലാ ലൈബ്രറികളും ഓപ്പൺ സോഴ്സ് ആണ്."`
  - `sa`: `"सर्वाणि प्रयुक्तानि पुस्तकालयानि मुक्तस्रोतानि सन्ति।"` (matches guideline standard verbatim)
- `aiUsed`:
  - `en`: `"Anthropic Claude, Google Gemini"`
  - `ml`: `"ആന്ത്രോപിക് ക്ലോഡ്, ഗൂഗിൾ ജെമിനി"`
  - `sa`: `"एन्थ्रोपिक्-क्लौड्, गूगल्-जेमिनि"` (no nuktas, no Hindi markers)
- `ideUsed`:
  - `en`: `"VS Code / Antigravity"`
  - `ml`: `"വിഎസ് കോഡ് / ആന്റിഗ്രാവിറ്റി"`
  - `sa`: `"वीएस् कोड् / ऐन्टिग्रेविटी"` (no nuktas, no Hindi markers)

### 2. `lib/core/config/app_config.dart`
- Update `AppConfig` class to have `final LocalizedText appName`.
- Update `AppConfig.fallback` with `appName: LocalizedText.plain('SreerajP ToDo')`.
- Update `AppConfig.fromJson` to parse `appName` via `LocalizedText.fromJson(json['appName'], fallback: fallback.appName.resolve('en'))`.

### 3. `lib/presentation/screens/about/about_screen.dart`
- Resolve `appName` for current locale: `final resolvedAppName = config.appName.resolve(lang);`.
- Use `resolvedAppName.isNotEmpty ? resolvedAppName : kAppName` as card title.

### 4. Tests
- Update `test/core/config/app_config_test.dart` to assert `appName` resolution for plain strings and locale maps.
- Add test verifying `assets/config/app_config.json` conforms to guideline §1.2 & §8.7 (all three languages present for localized fields, no empty translations, no Hindi markers in Sanskrit).
- Update `test/core/config/config_service_test.dart` and `test/presentation/screens/about/about_screen_test.dart`.

## Verification plan

### Automated tests
- Run `flutter analyze` to ensure 0 static analysis issues.
- Run `flutter test` to ensure all tests pass.
- Run Sanskrit marker check against `assets/config/app_config.json` to verify zero Hindi markers.
