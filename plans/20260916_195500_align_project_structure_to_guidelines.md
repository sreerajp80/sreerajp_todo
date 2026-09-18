# Align Project Structure Strictly to Guidelines

**Status:** completed

## The ask

Ensure the project structure of `sreerajp_todo` strictly adheres to the guidelines in `docs/guidelines/` (specifically `guideline.md`, `flutter_project_engineering_standard.md §3`, and `docs/project_structure.md`).

## The issues found

A comprehensive audit of the project structure against `docs/guidelines/guideline.md` and `docs/guidelines/flutter_project_engineering_standard.md §3` revealed the following discrepancies:

1. **About-Screen Config Data (`assets/config/app_config.json`):**
   - In `guideline.md §1.2`, detail keys MUST be identifiers in `lowerCamelCase` (`author`, `email`, `license`, `aiUsed`, `ideUsed`), not human labels. The current file has `"Author"`, `"Email"`, `"License"`, `"AI used"`, `"IDE used"`.
   - In `guideline.md §1.2`, prose values (such as `description` and `license`) MUST use a locale map `{"en": ..., "ml": ...}` rather than plain strings so they can be rendered in the active language. The current file provides only plain English strings.

2. **`AppConfig` Model (`lib/core/config/app_config.dart`):**
   - In `guideline.md §1.4`, `AppConfig` MUST use a `LocalizedText` value type that resolves against the active language code with fallback to English.
   - `description` MUST be of type `LocalizedText` and `details` MUST be of type `Map<String, LocalizedText>`.
   - The current file uses plain `String` for `description` and `Map<String, String>` for `details`, lacking the `LocalizedText` model.

3. **`ConfigService` Loader (`lib/core/config/config_service.dart`):**
   - In `guideline.md §1.5`, `ConfigService` MUST define `loadAndVerify()` in addition to `load()`, checking config version and build against app build metadata and logging a debug message on drift. The current file lacks `loadAndVerify()`.

4. **Dynamic Details and "Made with ❤️ from India" Badge (`lib/presentation/screens/about/about_screen.dart`):**
   - In `guideline.md §1.6`, detail row labels MUST be localized via ARB keys `aboutDetail<Key>` (e.g. `aboutDetailAuthor`, `aboutDetailEmail`, `aboutDetailLicense`, `aboutDetailAiUsed`, `aboutDetailIdeUsed`) with fallback to the raw key, and values MUST resolve against active language via `LocalizedText.resolve(languageCode)`.
   - In `guideline.md §1.7`, every app's About screen MUST end with the signature "Made with ❤️ from India" badge (`MadeWithLove` widget) below all content, centered, with a red vector heart (`Color(0xFFE53935)` via `WidgetSpan`), localized words via `madeWithLove` (with `{heart}` placeholder), and screen-reader accessibility (`madeWithLoveA11y`).
   - The current screen renders raw string keys directly and has an inline text message without the red heart widget or a11y semantics.

5. **ARB Localization Files (`lib/l10n/app_en.arb` and `lib/l10n/app_ml.arb`):**
   - Missing required keys: `madeWithLove`, `madeWithLoveA11y`, `aboutDetailAuthor`, `aboutDetailEmail`, `aboutDetailLicense`, `aboutDetailAiUsed`, and `aboutDetailIdeUsed`.

6. **Keystore Git-Ignore Rules (`.gitignore`):**
   - In `guideline.md §2.3`, `.gitignore` MUST explicitly include `android/key.properties`, `android/*.jks`, and `android/*.keystore`. Currently, `.gitignore` only specifies unqualified root patterns (`key.properties`, `*.jks`, `*.keystore`).

7. **Project Structure Documentation (`docs/project_structure.md`):**
   - Section 4 "Test Directory Layout" does not document `test/application/` (which contains 10 Riverpod StateNotifier test suites) and `test/helpers/`.
   - Section 2 does not document the About-screen config loader specification in `lib/core/config/`.

## Proposed changes

### 1. `assets/config/app_config.json`
- Update detail keys to `lowerCamelCase` identifiers: `author`, `email`, `license`, `aiUsed`, `ideUsed`.
- Provide localized maps `{"en": ..., "ml": ...}` for `description` and `license`.

### 2. `lib/core/config/app_config.dart`
- Implement `LocalizedText` supporting plain strings and locale maps with locale resolution (`resolve(languageCode)`).
- Update `AppConfig` to use `LocalizedText` for `description` and `Map<String, LocalizedText>` for `details`.
- Update `AppConfig.fromJson` and `AppConfig.fallback`.

### 3. `lib/core/config/config_service.dart`
- Add `loadAndVerify({String? packageVersion, String? packageBuild})` method logging version drift in debug mode.

### 4. `lib/presentation/shared/widgets/made_with_love.dart`
- Create the standard `MadeWithLove` signature badge widget adhering strictly to `guideline.md §1.7`.

### 5. `lib/presentation/screens/about/about_screen.dart`
- Update dynamic detail rows to resolve labels via `aboutDetailLabel(l10n, entry.key)` and values via `entry.value.resolve(lang)`.
- Make `email` detail row tappable (`mailto:`).
- Replace plain text footer with `const MadeWithLove()` placed at the end of the About screen.

### 6. `lib/l10n/app_en.arb` and `lib/l10n/app_ml.arb`
- Add `madeWithLove`, `madeWithLoveA11y`, `aboutDetailAuthor`, `aboutDetailEmail`, `aboutDetailLicense`, `aboutDetailAiUsed`, `aboutDetailIdeUsed`.
- Run `flutter gen-l10n`.

### 7. `.gitignore`
- Add explicit entries: `android/key.properties`, `android/*.jks`, `android/*.keystore`.

### 8. `docs/project_structure.md`
- Add `test/application/` and `test/helpers/` to Section 4.
- Update Section 2 to describe `lib/core/config/` and `lib/presentation/shared/widgets/made_with_love.dart`.

### 9. Unit tests (`test/core/config/app_config_test.dart` and `test/core/config/config_service_test.dart`)
- Update tests to verify `LocalizedText`, locale map parsing, fallback values, and `loadAndVerify`.

## Verification plan

### Automated Tests
- Run `flutter gen-l10n` to regenerate localization classes.
- Run `flutter analyze` to ensure 0 static analysis issues.
- Run `flutter test` to ensure all 747 tests pass clean.
