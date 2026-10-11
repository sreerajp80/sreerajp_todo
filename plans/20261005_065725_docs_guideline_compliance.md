# Plan — Make `docs/` follow the docs-folder guideline strictly

**Status:** completed

## 1. What the issue is

The shared guideline [DOCS_FOLDER_GUIDELINE.md](../docs/guidelines/DOCS_FOLDER_GUIDELINE.md)
sets the rules for every file in `docs/`. An audit of `docs/` against it found these gaps:

| # | Gap | Guideline rule |
|---|-----|----------------|
| 1 | `docs/GUIDELINES_MANIFEST.md` is an old copy. It differs from the current submodule copy (missing `PROJECT_PROFILE`, `AI_AGENT_START_HERE`, store readiness, "templates vs references"). | §1 — copy it in unchanged |
| 2 | `docs/PROJECT_PROFILE.md` does not exist. It is the first of the 9 mandatory baseline docs. | §6 item 1; `AI_AGENT_START_HERE.md` §4 step 2 |
| 3 | `docs/flutter_project_engineering_standard.md` is a full local copy of a **reference** doc (3,212 lines, already out of date with the submodule). | §2 — never copy references; link to `docs/guidelines/<file>` |
| 4 | `docs/flutter_build_flavors_guide.md` is a trimmed local copy of a **reference** doc. Its few app-specific facts repeat `release_process.md` §5. | §2; §8 "one concept, one home" |
| 5 | Section numbers `## 4a.` (`dependencies.md`) and `## 9A.` (`release_process.md`) break the plain `## 1.`, `## 2.` … numbering. | §4 item 4 |
| 6 | `docs/unique_features_and_improvements.md` is not a recognized doc type. It holds a dated status table ("Last checked … 2026-08-27") but has no `**Date:**` line. | §5, §7, §8 |
| 7 | `docs/features.md` is not a recognized doc type by name. Its content (the product "what") matches the `<app>_idea.md` type. | §7 |

Things already compliant (no change): snake_case names, H1 + app name, purpose paragraph,
"Read first" links, numbered `##` sections with `---` separators, `**Date:**` lines on
`implementation_plan.md`, `implementation_progress.md` and `phase8_performance.md`, all
relative links resolve, no absolute paths, language-tagged code fences.

## 2. Files to be changed

| File | Change |
|------|--------|
| `docs/GUIDELINES_MANIFEST.md` | Replace with an exact copy of `docs/guidelines/GUIDELINES_MANIFEST.md`. |
| `docs/PROJECT_PROFILE.md` | **New.** Filled in from `docs/guidelines/PROJECT_PROFILE_TEMPLATE.md`. |
| `docs/flutter_project_engineering_standard.md` | **Delete** (copied reference). |
| `docs/flutter_build_flavors_guide.md` | **Delete** after moving its app-specific facts into `release_process.md`. |
| `docs/release_process.md` | Add a short "Artifacts" note to §5 (split-APK file names, `--split-per-abi` vs `--target-platform`, `dev` release QA build). Point the flavor link to `guidelines/flutter_build_flavors_guide.md`. Renumber `9A` → `10` (and `9A.1`–`9A.5` → `10.1`–`10.5`), shift old §10–§13 to §11–§14, and update the three `§9A` references inside the file. |
| `docs/dependencies.md` | Renumber `4a` → `5` and old `5` → `6`. |
| `docs/architecture.md` | §17 Related Documents: point the engineering-standard link to `guidelines/…`; add `PROJECT_PROFILE.md`. |
| `docs/project_structure.md` | Make the `flutter_project_engineering_standard.md §3.2` mention a relative link into `guidelines/`. |
| `docs/unique_features_and_improvements.md` | Add `**Date:** 2026-08-27` and a `**Scope:**` line under the purpose paragraph, marking it a point-in-time record. (See decision B.) |
| `CLAUDE.md`, `AGENTS.md` | Docs table: point the two deleted rows to `docs/guidelines/…`; add rows for `docs/PROJECT_PROFILE.md` and `docs/guidelines/AI_AGENT_START_HERE.md`. Keep both files in sync. |
| `prompts/*.md` (11 files) | Change the path `docs/flutter_project_engineering_standard.md` → `docs/guidelines/flutter_project_engineering_standard.md` so the paths do not break. Text only, no other change. |

Not touched: anything inside `docs/guidelines/` (the submodule — §1 forbids it), source code.

## 3. Plan for the fix

1. Copy the submodule manifest over `docs/GUIDELINES_MANIFEST.md` byte-for-byte.
2. Create `docs/PROJECT_PROFILE.md` with the template's sections, filled from the code:
   - Identity: name `SreerajP ToDo`, id `in.sreerajp.sreerajp_todo`, Dart package
     `sreerajp_todo`, publisher/copyright `Sreeraj P` (from `LICENSE`, `© 2026 Sreeraj P`),
     license `MIT`.
   - Profiles: all three ticked (matches `architecture.md`, `security.md`, `release_process.md`).
   - Platforms: Android yes (minSdk 21; direct APK; Google Play gate prepared), Windows yes
     (portable folder), iOS / macOS / Linux "future", Web no. Flavors `dev + prod` (Android only).
   - Languages: `en`, `ml`, `sa`; picker required; Sanskrit language pack
     `language_packs/sanskrit_malayalam.md`.
   - About: rows `author, email, license, aiUsed, ideUsed` (from `assets/config/app_config.json`),
     "Made with ❤️ from India" badge on.
   - Optional: Riverpod, Tier 1 layer-first, release owner "maintainer".
   - Values the code cannot tell me (website, privacy-policy URL, public support contact)
     are written as `none` / `to be decided` — see decision C. No personal email goes in.
3. Move the app-specific flavor facts into `release_process.md` §5, then delete
   `docs/flutter_build_flavors_guide.md` and `docs/flutter_project_engineering_standard.md`.
4. Renumber sections in `dependencies.md` and `release_process.md`, fixing internal `§` refs.
5. Update every link to the deleted files (`CLAUDE.md`, `AGENTS.md`, `architecture.md`,
   `project_structure.md`, `release_process.md`, `prompts/*.md`).
6. Add the date header to `unique_features_and_improvements.md`.
7. Verify: re-run the link checker over `docs/*.md`, `CLAUDE.md`, `AGENTS.md`; confirm the
   manifest matches the submodule (`diff` empty); confirm no `## <n><letter>.` headings remain;
   walk the §10 checklist of the guideline for each file. No code changes, so `flutter analyze`
   / `flutter test` are not needed.
8. Write the change log in `change_log/`.

## 4. Decisions for the user

- **A. `features.md` name.** Recommended: **keep `features.md`**. The guideline says old files
  are not renamed just for style, and many files link to it. Alternative: rename to
  `sreerajp_todo_idea.md` to match the §7 type exactly and update all links.
- **B. `unique_features_and_improvements.md`.** Recommended: **keep it as a dated
  point-in-time record** (add `**Date:**`). Alternative: move its roadmap into
  `implementation_plan.md` and its status table into `implementation_progress.md`, then delete it.
- **C. `PROJECT_PROFILE.md` gaps** (website, privacy-policy URL, public support contact).
  Recommended: write `none` / `to be decided before a public store release`. Or tell me the values.
