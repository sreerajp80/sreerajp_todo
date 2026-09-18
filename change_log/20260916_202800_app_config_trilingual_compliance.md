# Change Log: Make app_config.json Trilingual (EN/ML/SA) and Update AppConfig Model

**Plan:** `plans/20260916_202000_app_config_trilingual_compliance.md`

## What changed

1. **`assets/config/app_config.json`:**
   - Added complete English (`en`), Malayalam (`ml`), and Sanskrit (`sa`) translations for:
     - `appName` (`SreerajP ToDo` / `ശ്രീരാജ്പി ടുഡു` / `श्रीराज्-पी कार्यसूची`)
     - `description` (`Personal offline-first daily ToDo and time-tracker.` / `വ്യക്തിഗത ഓഫ്‌ലൈൻ-ആദ്യ പ്രതിദിന ചെയ്യേണ്ട കാര്യങ്ങളും സമയ ട്രാക്കറും.` / `व्यक्तिगतम् असंयुक्तप्रथमं प्रतिदिनकार्यसूची समयगणकञ्च।`)
     - `details.author` (`Sreeraj P` / `ശ്രീരാജ് പി` / `श्रीराज् पी`)
     - `details.license` (`All libraries used are open source.` / `ഉപയോഗിച്ച എല്ലാ ലൈബ്രറികളും ഓപ്പൺ സോഴ്സ് ആണ്.` / `सर्वाणि प्रयुक्तानि पुस्तकालयानि मुक्तस्रोतानि सन्ति।`)
     - `details.aiUsed` (`Anthropic Claude, Google Gemini` / `ആന്ത്രോപിക് ക്ലോഡ്, ഗൂഗിൾ ജെമിനി` / `एन्थ्रोपिक्-क्लौड्, गूगल्-जेमिनि`)
     - `details.ideUsed` (`VS Code / Antigravity` / `വിഎസ് കോഡ് / ആന്റിഗ്രാവിറ്റി` / `वीएस् कोड् / ऐन्टिग्रेविटी`)
   - All Sanskrit values use authentic classical Sanskrit with zero Hindi markers or nuktas, ending with a daṇḍa (`।`) for prose sentences.

2. **`lib/core/config/app_config.dart`:**
   - Updated `AppConfig.appName` type from `String` to `LocalizedText`.
   - Updated `AppConfig.fallback` to use `LocalizedText.plain('SreerajP ToDo')` for `appName`.
   - Updated `AppConfig.fromJson` to parse `appName` via `LocalizedText.fromJson(json['appName'], fallback: fallback.appName.resolve('en'))`.

3. **`lib/presentation/screens/about/about_screen.dart`:**
   - Resolved `appName` for the active language: `final resolvedAppName = config.appName.resolve(lang);`.
   - Used `resolvedAppName.isNotEmpty ? resolvedAppName : kAppName` as the About section card title.

4. **`test/core/config/app_config_test.dart`:**
   - Updated tests to verify `appName` resolution for plain strings, fallback values, and trilingual maps.
   - Added compliance test suite validating `assets/config/app_config.json`:
     - Asserts `en`, `ml`, and `sa` are non-empty for `appName`, `description`, and all localized detail rows.
     - Asserts zero nuktas and zero forbidden Hindi markers in Sanskrit strings according to standard §8.5.

5. **`test/core/config/config_service_test.dart`:**
   - Updated assertions on `config.appName` to `.resolve('en')`.

6. **`test/presentation/screens/about/about_screen_test.dart`:**
   - Updated `customConfig` to use `LocalizedText.plain('Custom App')` for `appName`.
   - Added widget test verifying that `AboutScreen` renders localized `appName` and description when rendered in Malayalam (`Locale('ml')`).

## Verification

- `flutter analyze`: 0 issues found.
- `flutter test`: all 756 tests passed clean.
