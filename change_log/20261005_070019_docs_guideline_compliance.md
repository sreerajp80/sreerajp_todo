# Change Log — Make `docs/` follow the docs-folder guideline strictly

**Plan:** [plans/20261005_065725_docs_guideline_compliance.md](../plans/20261005_065725_docs_guideline_compliance.md)

## What changed

| File | Change |
|------|--------|
| `docs/GUIDELINES_MANIFEST.md` | Replaced with an exact copy of `docs/guidelines/GUIDELINES_MANIFEST.md`. |
| `docs/PROJECT_PROFILE.md` | **New.** Filled in from the submodule template: identity, all three profiles, platforms (Android + Windows; iOS/macOS/Linux future), `dev + prod` flavors, `en`/`ml`/`sa` languages, About rows and badge text. Website is `none`; support contact, privacy-policy URL and store-listing languages are "to be decided before a public store release". |
| `docs/flutter_project_engineering_standard.md` | **Deleted.** It was an out-of-date local copy of a reference doc. Links now point to `docs/guidelines/`. |
| `docs/flutter_build_flavors_guide.md` | **Deleted.** It was a trimmed copy of a reference doc. Its app-specific facts moved to `release_process.md` §5. |
| `docs/release_process.md` | §5: added the `dev` release QA command, artifact file names, the `--split-per-abi` vs `--target-platform` note, and a link to the submodule flavor guide. Renumbered `9A` → `10` (`9A.1`–`9A.8` → `10.1`–`10.8`), old §10–§13 → §11–§14, and updated the three `§9A` references. |
| `docs/dependencies.md` | Renumbered `4a` → `5` and `5` → `6`. |
| `docs/architecture.md` | §17: added `PROJECT_PROFILE.md`; engineering standard link now points into `guidelines/`. |
| `docs/project_structure.md` | Engineering standard mention is now a relative link into `guidelines/`. |
| `docs/unique_features_and_improvements.md` | Added `**Date:** 2026-08-27` and a `**Scope:**` line, marking it a point-in-time record. |
| `CLAUDE.md`, `AGENTS.md` | Docs table: the two deleted docs now point to `docs/guidelines/…`; added rows for `docs/PROJECT_PROFILE.md` and `docs/guidelines/AI_AGENT_START_HERE.md`. Both tables stay identical. |
| `prompts/*.md` (12 files) | Path `docs/flutter_project_engineering_standard.md` → `docs/guidelines/flutter_project_engineering_standard.md`. |

Decisions taken (approved): kept `features.md` under its current name; kept
`unique_features_and_improvements.md` as a dated record.

## Verification

- Manifest matches the submodule copy (`diff` reports no difference).
- All 9 baseline docs exist in `docs/`.
- No relative link in `docs/*.md`, `CLAUDE.md`, `AGENTS.md` or `prompts/*.md` is broken.
- No `## <number><letter>.` headings remain.
- No references to the deleted local copies remain.
- No code changed, so `flutter analyze` and `flutter test` were not run.
