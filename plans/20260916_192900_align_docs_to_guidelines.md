# Align Project Docs Strictly to Guidelines

**Status:** completed

## The ask

Ensure all project documentation files in `docs/` strictly adhere to the guidelines defined in `docs/guidelines` (specifically `DOCS_FOLDER_GUIDELINE.md`, `GUIDELINES_MANIFEST.md`, `architecture.md`, `security.md`, `release_process.md`, and `guideline.md`).

## The issues found

A comprehensive audit of all files in `docs/` against `docs/guidelines/DOCS_FOLDER_GUIDELINE.md` revealed several non-conformances:

1. **`docs/GUIDELINES_MANIFEST.md`:**
   - Out of sync with `docs/guidelines/GUIDELINES_MANIFEST.md`.
   - `DOCS_FOLDER_GUIDELINE.md §1` specifies that `docs/GUIDELINES_MANIFEST.md` is the shared portable pointer file copied in unchanged from the standard set and must not be rewritten.

2. **`docs/architecture.md`:**
   - Title is `# Architecture` instead of `# Architecture — SreerajP ToDo` (`DOCS_FOLDER_GUIDELINE.md §4.1`).
   - Missing the mandatory one-paragraph purpose under `# H1` (`§4.2`).
   - Missing "Read first" links (`§4.3`).
   - Missing `---` separator before `## 1. Scope` and missing `---` dividers between major numbered sections (`§4.4`).
   - Section 11 states "Flavors used: None", which contradicts the actual `dev`/`prod` flavor configuration documented in `release_process.md`, `flutter_build_flavors_guide.md`, and `build.gradle.kts`.
   - Section 17 contains raw unlinked filenames instead of relative markdown links (`§9`).

3. **`docs/security.md`:**
   - Title is `# Security` instead of `# Security — SreerajP ToDo` (`§4.1`).
   - Missing purpose paragraph directly under `# H1` (`§4.2`).
   - Missing "Read first" links (`§4.3`).
   - Missing `---` separator before `## 1. Security Scope` and between major numbered sections (`§4.4`).
   - Section 13 contains a raw unlinked path `docs/release_process.md` instead of a relative markdown link (`§9`).

4. **`docs/release_process.md`:**
   - Title is `# Release Process` instead of `# Release Process — SreerajP ToDo` (`§4.1`).
   - Missing purpose paragraph under `# H1` (`§4.2`).
   - Missing "Read first" links (`§4.3`).
   - Missing `---` separator before `## 1. Release Scope` and between major sections (`§4.4`).
   - Duplicate numbering `7.` in Android release steps.
   - Trailing blank lines at the end of the file.

5. **`docs/features.md`:**
   - Title is `# SreerajP ToDo — Features & App Specification` instead of `# Features & App Specification — SreerajP ToDo` (`§4.1`).
   - Missing standard purpose paragraph directly under `# H1` (`§4.2`).
   - Missing "Read first" links (`§4.3`).
   - Missing `---` separator before `## 1. App Overview & Identity` (`§4.4`).

6. **`docs/phase8_performance.md`:**
   - Title is `# Phase 8 Performance Profiling` instead of `# Phase 8 Performance Profiling — SreerajP ToDo` (`§4.1`).
   - Point-in-time document missing the mandatory `**Date:**` line (`§5`).
   - Line 3 contains a Windows backslash in `prompts\phase8_testing.md` instead of forward slash relative path (`§9`).
   - Missing "Read first" links (`§4.3`).
   - Sections are not numbered and lack `---` divider before Section 1 (`§4.4`).

7. **`docs/unique_features_and_improvements.md`:**
   - Title is `# SreerajP ToDo — Unique Features & Architectural Improvements Specification` instead of `# Unique Features & Architectural Improvements Specification — SreerajP ToDo` (`§4.1`).
   - Missing standard purpose paragraph directly under `# H1` (`§4.2`).
   - Missing "Read first" links (`§4.3`).
   - Missing `---` separator before `## 1. Executive Summary & Ecosystem Context` (`§4.4`).
   - Line 9 contains an absolute system path with a drive letter, which violates `DOCS_FOLDER_GUIDELINE.md §3 & §9` and workflow privacy rules.

8. **`docs/flutter_build_flavors_guide.md`:**
   - Title is `# Flutter Build Flavors Guide` instead of `# Flutter Build Flavors Guide — SreerajP ToDo` (`§4.1`).
   - Missing standard purpose paragraph under `# H1` (`§4.2`).
   - Missing "Read first" links (`§4.3`).
   - Sections are unnumbered (`## Flavor Basics`, etc.) and lack `---` dividers (`§4.4`).
   - Contains an unlinked path `docs/release_process.md` in the callout (`§9`).

9. **`docs/flutter_project_engineering_standard.md`:**
   - Outdated 15-section copy of the engineering standard, missing Sections 16–24 (including Section 21 `Documentation Standard` with §21.1.1 relative paths and privacy rule).
   - Needs synchronization with `docs/guidelines/flutter_project_engineering_standard.md` so that the local copy carries the complete, authoritative standard.

10. **`docs/implementation_plan.md` & `docs/implementation_progress.md`:**
    - Align section headers to ensure consistent numbered formatting (`## 1. Phase 1: ...`, etc.) matching §4.4.

## Proposed changes

### 1. `docs/GUIDELINES_MANIFEST.md`
- Synchronize verbatim with `docs/guidelines/GUIDELINES_MANIFEST.md`.

### 2. `docs/architecture.md`
- Update title to `# Architecture — SreerajP ToDo`.
- Add purpose paragraph and "Read first" relative links to `../AGENTS.md`, `../CLAUDE.md`, `guidelines/architecture.md`, and `guidelines/flutter_project_engineering_standard.md`.
- Add `---` separator before `## 1. Scope` and between all 17 numbered sections.
- Update Section 11 to correctly reflect `dev` and `prod` flavors.
- Update Section 17 to use relative markdown links.

### 3. `docs/security.md`
- Update title to `# Security — SreerajP ToDo`.
- Add purpose paragraph and "Read first" relative links.
- Add `---` separator before `## 1. Security Scope` and between all numbered sections.
- Format unlinked references as relative markdown links.

### 4. `docs/release_process.md`
- Update title to `# Release Process — SreerajP ToDo`.
- Add purpose paragraph and "Read first" relative links.
- Add `---` separator before `## 1. Release Scope` and between all numbered sections.
- Fix duplicate step numbering in Section 8.
- Remove trailing empty lines.

### 5. `docs/features.md`
- Update title to `# Features & App Specification — SreerajP ToDo`.
- Add purpose paragraph and "Read first" relative links.
- Add `---` separator before `## 1. App Overview & Identity`.

### 6. `docs/phase8_performance.md`
- Update title to `# Phase 8 Performance Profiling — SreerajP ToDo`.
- Add `**Date:** 2026-08-10` line.
- Add purpose paragraph and "Read first" relative links.
- Number sections `## 1. How To Run`, `## 2. Results Table`, `## 3. Notes` with `---` dividers.
- Fix backslash path to forward slash.

### 7. `docs/unique_features_and_improvements.md`
- Update title to `# Unique Features & Architectural Improvements Specification — SreerajP ToDo`.
- Add purpose paragraph and "Read first" relative links.
- Add `---` separator before Section 1.
- Replace the absolute system path on line 9 with clean relative text.

### 8. `docs/flutter_build_flavors_guide.md`
- Update title to `# Flutter Build Flavors Guide — SreerajP ToDo`.
- Add purpose paragraph and "Read first" relative links.
- Add `---` dividers and number sections `## 1.` through `## 7.`.
- Format unlinked file references as relative markdown links.

### 9. `docs/flutter_project_engineering_standard.md`
- Synchronize with the full master standard from `docs/guidelines/flutter_project_engineering_standard.md`.

### 10. `docs/implementation_plan.md` & `docs/implementation_progress.md`
- Number section headings cleanly to adhere to §4.4.

## Verification plan

### Automated Tests
- Run `flutter analyze` to ensure zero static analysis warnings or errors.
- Run `flutter test` to ensure all 221 tests continue passing clean.
- Check relative paths: Ensure no absolute machine paths (`C:\`, `l:\`, `file:///`) exist in any modified doc.
- Validate cross-links: Verify that all markdown links between `docs/` files resolve correctly.
