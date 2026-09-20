# Change Log: Align Project Documentation Strictly to Guidelines

**Plan Reference:** [plans/20260920_174500_align_docs_strictly_to_guidelines.md](../plans/20260920_174500_align_docs_strictly_to_guidelines.md)

## Summary of Changes

A comprehensive audit was performed across all project documentation files in `docs/` and root instruction files (`AGENTS.md`, `CLAUDE.md`) against the shared Flutter guidelines in `docs/guidelines/`. All identified gaps, obsolete notes, and missing sections were updated to ensure strict guideline compliance.

### 1. `docs/release_process.md`
- Added the mandatory Section 9A: Google Play Store Readiness Gate (`## 9A. Google Play Store Readiness (Mandatory Gate)`) covering Application Identity, API level/ABI/compatibility (target SDK 35), Signing and upload, Language splitting disabled in App Bundle (`bundle.language.enableSplit = false`), Manifest and permissions justifications, Store account declarations, Store listing assets, Localization of the listing (English and Malayalam listings; Sanskrit supported in-app), and Pre-launch verification.
- Added Play Store Readiness checklist to Section 7 Release Checklist.
- Added Step 12 to Section 8 Android Release Steps to require completion of the §9A gate before store upload.
- Updated release version baseline to `2.1.0+45` (tag `v2.1.0`).

### 2. `docs/architecture.md`
- Updated Section 1 Scope: Android target SDK 35 (`compileSdk = maxOf(flutter.compileSdkVersion, 35)`).
- Updated Section 2 Non-Goals to remove stale reference to app lock, and updated Section 3 Architecture Summary to document the trilingual UI baseline (English, Malayalam, Sanskrit) with dynamic per-field directionality (`AdaptiveDirectionality`).
- Replaced the obsolete "No build flavors in v1.0" entry in Section 15 Decisions and Tradeoffs with Android build flavors (`dev` and `prod`).

### 3. `docs/security.md`
- Updated Section 7 (Authentication And Access Control) and Section 9 (Platform Security Controls) to document the active PIN/biometric app lock and `FLAG_SECURE` window shielding via the native `in.sreerajp.todo/app_lock` channel.
- Updated Section 14 (Open Risks And Future Hardening) to reflect implemented app lock and screenshot protection.

### 4. `docs/dependencies.md`, `docs/features.md`, and `docs/project_structure.md`
- In `docs/dependencies.md`, updated `flutter_localizations` description to specify trilingual localization (English, Malayalam & Sanskrit).
- In `docs/features.md`, updated Section 1 Inclusive Design, Section 1.5, and Section 4.5 to specify trilingual inclusion (EN, ML, SA), the in-app language picker choices, and Android target SDK 35.
- In `docs/project_structure.md`, updated Section 2 `lib/l10n/` to reference the trilingual ARB suite (`app_en.arb`, `app_ml.arb`, `app_sa.arb`) and Section 3 to specify Android target SDK 35.

### 5. `docs/implementation_plan.md` and `docs/implementation_progress.md`
- Updated Phase 5 localization tasks from bilingual to trilingual support.

### 6. `AGENTS.md` and `CLAUDE.md`
- Updated Package / Org ID to `in.sreerajp.sreerajp_todo` and Android target SDK to 35.
- Updated Build Flavors table with application IDs `in.sreerajp.sreerajp_todo.dev` and `in.sreerajp.sreerajp_todo`.
- Updated Localization Rules to include all mandatory requirements from the guidelines:
  - English (`en`), Malayalam (`ml`), and Sanskrit (`sa`) triad (never drop Sanskrit).
  - Strict key parity across all three ARB files.
  - Sanskrit-not-Hindi rule.
  - In-app language picker rule.
  - Tooltip rule on every icon-only control.
  - Short-label budget rule.
  - About-screen rule including the "Made with ❤️ from India" badge (`MadeWithLove`).
- Added strict key parity to Always item 6 in both files.

### 7. Tests
- Updated `test/domain/usecases/update_recurring_todos_test.dart` to compute future test dates dynamically relative to `todayAsIso()`, preventing fixed-date collisions.

## Verification Results

- `flutter analyze`: 0 issues found.
- `flutter test`: 771 of 771 tests passed clean.
- Offline dependency audit: verified clean.
- Path and privacy check: zero absolute paths (`C:\`, `l:\`, `file:///`) or machine/user identifiers introduced.
