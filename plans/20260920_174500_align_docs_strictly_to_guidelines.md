# Align Project Documentation Strictly to Guidelines

**Status:** completed

## 1. What the issue is

A comprehensive audit of the project documentation in `docs/` and root instruction files (`AGENTS.md`, `CLAUDE.md`) against the shared Flutter guidelines in `docs/guidelines/` revealed several discrepancies and gaps:

1. **`docs/release_process.md`:**
   - Missing the mandatory Section 9A: Google Play Store Readiness (`## 9A. Google Play Store Readiness (Mandatory Gate)`) specified in `docs/guidelines/release_process.md`.
   - Missing the Play Store Readiness checklist items under Section 7 (`bundle.language.enableSplit = false`, `targetSdkVersion` policy, `versionCode`, Play App Signing, native debug symbols, manifest and permission justifications, data safety, localized store listings).
   - Contains outdated version strings (`1.0.0+1`) instead of the current versioning baseline (`2.1.0+45`).
   - Missing step in Android release steps directing developer to complete §9A gate before uploading.

2. **`docs/architecture.md`:**
   - Section 15 (Decisions and Tradeoffs) table contains an obsolete row stating "No build flavors in v1.0 | Single build configuration", which contradicts Section 11 ("Flavors used: dev and prod for Android builds") and `build.gradle.kts`.
   - Section 1 Scope lists Android targetSdk 34 while Gradle now targets SDK 35 (`compileSdk = maxOf(flutter.compileSdkVersion, 35)`).
   - System design summary does not mention the trilingual UI baseline (English, Malayalam, and Sanskrit) and dynamic text directionality.

3. **`docs/security.md`:**
   - Sections 7 and 9 state "App-lock strategy: None in v1.0" and "Screenshot protection: Not enabled in v1.0", despite `FLAG_SECURE` window shielding and PIN/biometric authentication having been implemented via the `in.sreerajp.todo/app_lock` channel.
   - Section 14 (Open Risks And Future Hardening) lists App Lock as a future v2.0 item rather than documenting its live implementation.

4. **`docs/dependencies.md`:**
   - Section 2 labels `flutter_localizations` as "Bilingual localization (English & Malayalam)", ignoring the full Sanskrit (`sa`) localization support.

5. **`docs/features.md`:**
   - Section 1, Section 1.5, and Section 4.5 refer to bilingual support (English and Malayalam) and omit Sanskrit (`sa`).
   - Settings in-app language picker list omits Sanskrit.
   - Platform profile specifies target SDK 34 instead of 35.

6. **`docs/project_structure.md`:**
   - Section 2 describes `lib/l10n/` as bilingual ARB localization files (`app_en.arb`, `app_ml.arb`) and omits `app_sa.arb`.
   - Section 3 lists target SDK 34 instead of 35.

7. **`docs/implementation_plan.md` & `docs/implementation_progress.md`:**
   - Localization tasks in Phase 5 cite bilingual support rather than trilingual support.

8. **`AGENTS.md` and `CLAUDE.md`:**
   - Both files lack the updated strict localization rules mandated by `docs/guidelines/AGENTS_MD_GUIDELINE.md` and `docs/guidelines/CLAUDE_MD_GUIDELINE.md` (naming all three mandatory languages: English, Malayalam, Sanskrit; key parity across `app_en.arb`, `app_ml.arb`, `app_sa.arb`; Sanskrit-not-Hindi rule; in-app language picker rule; tooltip rule on icon-only controls; short-label budget rule; About-screen badge rule).
   - Package / org ID and application IDs lack the `.sreerajp_todo` component (`in.sreerajp.sreerajp_todo` and `in.sreerajp.sreerajp_todo.dev`).
   - Target SDK listed as 34 instead of 35.

9. **Git Submodule Pointer (`docs/guidelines`):**
   - The submodule has been updated upstream to commit `eb4b4629e4e0c849d5e60176daa8bb3f1509a6cd`. The project repository should track this latest commit.

## 2. Files to be changed

| File | Proposed Change |
|---|---|
| `docs/release_process.md` | Add Section 9A Google Play Store Readiness (Mandatory Gate), add Play Store Readiness checklist items in Section 7, update release steps and version references to `2.1.0+45`. |
| `docs/architecture.md` | Fix Section 15 flavors tradeoff row, update target SDK to 35 in Section 1, and document trilingual UI architecture. |
| `docs/security.md` | Update Sections 7, 9, and 14 to document the active PIN/biometric app lock and `FLAG_SECURE` window shielding. |
| `docs/dependencies.md` | Update `flutter_localizations` description to trilingual (English, Malayalam & Sanskrit). |
| `docs/features.md` | Update multi-lingual inclusion, in-app language selector, and specification sections to reflect trilingual support (EN, ML, SA) and target SDK 35. |
| `docs/project_structure.md` | Update `lib/l10n/` description to trilingual ARB suite (`app_en.arb`, `app_ml.arb`, `app_sa.arb`) and target SDK to 35. |
| `docs/implementation_plan.md` | Note trilingual localization in Phase 5. |
| `docs/implementation_progress.md` | Note trilingual localization in Phase 5 checklist. |
| `AGENTS.md` | Update localization rules with the mandatory trilingual triad, key parity, Sanskrit-not-Hindi, tooltips, short labels, About badge, correct package ID and target SDK 35. |
| `CLAUDE.md` | Synchronize verbatim with `AGENTS.md`. |
| `docs/guidelines` | Stage submodule commit `eb4b4629e4e0c849d5e60176daa8bb3f1509a6cd`. |

## 3. The plan for the fix

### 3.1 Synchronize `docs/release_process.md` with Guidelines
1. Add the Play Store Readiness checklist under Section 7:
   - Language splitting disabled in App Bundle (`bundle.language.enableSplit = false`, §9A.3).
   - `targetSdkVersion` meets Play's current target API level policy (tested on SDK 35).
   - `versionCode` strictly greater than previous builds.
   - App Bundle built; Play App Signing enabled; native debug symbols uploaded.
   - Manifest and permissions justified; data safety form matches behavior.
   - Store listing assets ready; English and Malayalam listings complete with localized screenshots.
2. In Section 8 Android Release Steps, add step to verify the Google Play readiness gate (§9A) before uploading.
3. Add Section 9A: `## 9A. Google Play Store Readiness (Mandatory Gate)` matching `docs/guidelines/release_process.md` (§9A.1 to §9A.8).
4. Update version string references from `1.0.0+1` to `2.1.0+45`.

### 3.2 Align `docs/architecture.md`
1. Update Section 1 Scope: platforms `Android (minSdk 21, targetSdk 35)` and `Windows`.
2. Update Section 15 Decisions and Tradeoffs: replace the obsolete "No build flavors in v1.0" entry with "Android build flavors (`dev`/`prod`)" explaining separate application IDs (`in.sreerajp.sreerajp_todo.dev` and `in.sreerajp.sreerajp_todo`).
3. Mention trilingual architecture (English, Malayalam, Sanskrit) in the Architecture Summary.

### 3.3 Align `docs/security.md`
1. Update Section 7 (Authentication and Access Control): Document the live PIN/biometric app lock via `in.sreerajp.todo/app_lock`.
2. Update Section 9 (Platform Security Controls): Note that screenshot protection via `FLAG_SECURE` is active via `in.sreerajp.todo/app_lock`.
3. Update Section 14 (Open Risks And Future Hardening): Mark PIN/biometric app lock and screenshot protection as implemented.

### 3.4 Update `docs/dependencies.md`, `docs/features.md`, and `docs/project_structure.md`
1. In `docs/dependencies.md`, update `flutter_localizations` entry to specify trilingual localization (English, Malayalam & Sanskrit).
2. In `docs/features.md`, update Section 1, 1.5, and 4.5 to reflect trilingual inclusion (`en`, `ml`, `sa`), in-app language picker choices, and target SDK 35.
3. In `docs/project_structure.md`, update Section 2 `lib/l10n/` to list `app_en.arb`, `app_ml.arb`, `app_sa.arb` and Section 3 to target SDK 35.
4. Update `docs/implementation_plan.md` and `docs/implementation_progress.md` to note trilingual support.

### 3.5 Align `AGENTS.md` and `CLAUDE.md` with `AGENTS_MD_GUIDELINE.md` and `CLAUDE_MD_GUIDELINE.md`
1. Update Project Identity table: package/org ID `in.sreerajp.sreerajp_todo`, targetSdk 35.
2. Update Build Flavors table: dev `in.sreerajp.sreerajp_todo.dev`, prod `in.sreerajp.sreerajp_todo`.
3. Update Localization rules:
   - Mandatory trilingual support: English (`en`), Malayalam (`ml`), and Sanskrit (`sa`).
   - Key parity across `app_en.arb`, `app_ml.arb`, and `app_sa.arb`. Never drop Sanskrit.
   - Sanskrit-not-Hindi rule: Sanskrit must be genuine classical Sanskrit, never Hindi loans or crutches.
   - In-app language picker rule: System, English, Malayalam, Sanskrit.
   - Tooltip rule: Every icon-only button/control must have an explicit localized tooltip.
   - Short-label budget rule: Action buttons and navigation labels must fit within compact width constraints.
   - About-screen rule: Single source of truth in `assets/config/app_config.json`, including the "Made with ❤️ from India" badge.
4. Keep `AGENTS.md` and `CLAUDE.md` completely synchronized.

### 3.6 Stage Submodule Commit
1. Verify git submodule status and stage commit `eb4b4629e4e0c849d5e60176daa8bb3f1509a6cd`.

## 4. Verification Plan

### Automated Tests
- Run `flutter analyze` to ensure zero static analysis warnings or errors.
- Run `flutter test` to ensure all tests continue passing clean.
- Verify no absolute paths (`C:\`, `l:\`, `file:///`) or machine/user identifiers were introduced into any documentation or plan file.
- Verify all relative markdown links between `docs/`, `AGENTS.md`, and `CLAUDE.md` resolve correctly.
