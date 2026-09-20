# Strictly Align Project Structure with Guidelines

**Status:** completed

## 1. What the issue is

A review of the repository layout and structure against `docs/guidelines/` (`guideline.md`, `flutter_project_engineering_standard.md §3`, and `DOCS_FOLDER_GUIDELINE.md`) identified the following areas for strict alignment:

1. **`docs/project_structure.md`:**
   - Section 1 (Directory Tree Overview) omits required root configuration and license files specified in `flutter_project_engineering_standard.md §3.3`: `analysis_options.yaml`, `.gitignore`, `l10n.yaml`, and `LICENSE`.
   - The tree overview omits `docs/GUIDELINES_MANIFEST.md`, which is a mandatory project pointer file required by `DOCS_FOLDER_GUIDELINE.md` and `flutter_project_engineering_standard.md §3.3`.
   - The tree overview omits `assets/tessdata/` under `assets/`.
   - Section 4 (Test Directory Layout) omits `test/l10n/` (localization quality and parity tests) and `test/widgets/`.

2. **Test structure mirroring `lib/` (`flutter_project_engineering_standard.md §3.2` & §8.7):**
   - `test/` should mirror `lib/` closely. While `lib/widgets/made_with_love.dart` exists, there is no corresponding `test/widgets/` directory in `test/`.
   - `flutter_project_engineering_standard.md §8.7` requires a dedicated translation parity test at `test/l10n/translation_parity_test.dart` to assert key and placeholder parity across English, Malayalam, and Sanskrit, verify `{heart}` placeholder preservation, and check About JSON config consistency.

3. **About badge string in `lib/l10n/app_sa.arb` (`guideline.md §1.7`):**
   - `guideline.md §1.7` explicitly mandates verbatim strings for the About signature badge:
     - English: `Made with {heart} from India`
     - Malayalam: `സ്നേഹത്തോടെ {heart} ഇന്ത്യയിൽ നിന്ന്`
     - Sanskrit: `सस्नेहं निर्मितम् {heart} भारततः` (`madeWithLoveA11y`: `सस्नेहं निर्मितम् भारततः`)
   - In `lib/l10n/app_sa.arb`, lines 374-375 currently use non-standard text: `"भारतात् {heart} सह निर्मितम्"` and `"भारते प्रेम्णा निर्मितम्"`.

## 2. Files to be changed

| File | Action | Proposed Change |
|---|---|---|
| `docs/project_structure.md` | MODIFY | Update Directory Tree Overview and Test Layout sections to accurately document all mandatory root files, documentation pointers, assets, and test layers. |
| `lib/l10n/app_sa.arb` | MODIFY | Align `madeWithLove` and `madeWithLoveA11y` Sanskrit entries to the exact wording in `guideline.md §1.7`. |
| `test/l10n/translation_parity_test.dart` | NEW | Add the standard translation parity test suite specified in `flutter_project_engineering_standard.md §8.7`. |
| `test/widgets/made_with_love_test.dart` | NEW | Add a unit/widget test for `lib/widgets/made_with_love.dart` so `test/widgets/` directly mirrors `lib/widgets/`. |
| Generated localization files (`lib/l10n/*.dart`) | MODIFY | Regenerate via `flutter gen-l10n`. |

## 3. The plan for the fix

### 3.1 Update `docs/project_structure.md`
1. Update Section 1 directory tree:
   - Add `analysis_options.yaml`, `.gitignore`, `l10n.yaml`, `LICENSE`.
   - Under `docs/`, explicitly show `GUIDELINES_MANIFEST.md` and document the 8 baseline documents.
   - Under `assets/`, include `tessdata/`.
2. Update Section 4 test layout:
   - Add `test/l10n/` (Translation parity and Sanskrit quality tests).
   - Add `test/widgets/` (Reusable widget tests mirroring `lib/widgets/`).

### 3.2 Align Sanskrit Badge Strings in `lib/l10n/app_sa.arb`
1. Update `madeWithLove`: `"सस्नेहं निर्मितम् {heart} भारततः"`.
2. Update `madeWithLoveA11y`: `"सस्नेहं निर्मितम् भारततः"`.
3. Run `flutter gen-l10n` to update generated Dart localization classes.

### 3.3 Add `test/l10n/translation_parity_test.dart`
1. Implement the standard parity test from `flutter_project_engineering_standard.md §8.7`:
   - ARB key parity across `en`, `ml`, `sa`.
   - Check `{heart}` placeholder in `madeWithLove`.
   - Check `app_config.json` locale keys and detail labels.

### 3.4 Add `test/widgets/made_with_love_test.dart`
1. Test `lib/widgets/made_with_love.dart` directly across English, Malayalam, and Sanskrit.
2. Verify semantic label and vector heart icon rendering.

## 4. Verification Plan

### Automated Tests
- Run `flutter gen-l10n`.
- Run `flutter test test/l10n/`.
- Run `flutter test test/widgets/`.
- Run `flutter test`.
- Run `flutter analyze` to ensure 0 errors and 0 warnings.
