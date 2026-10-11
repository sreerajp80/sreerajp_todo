# Update the docs/guidelines submodule

Implements plan: `plans/20261005_065455_update_guidelines_submodule.md`

## What changed

- `docs/guidelines` submodule moved from `3f1aa0b` to `519e7f3` (upstream
  `master`, 2 new commits, 30 files changed).
- No app code was changed.

## What is new in the guidelines

- Flutter 3.47 / Dart 3.13 toolchain notes, and an Android toolchain baseline
  on AGP 9+ / Gradle 9+.
- "Use latest stable" instead of fixed tool versions.
- Guidelines made generic and multi-platform. New files:
  `AI_AGENT_START_HERE.md`, `PROJECT_PROFILE_TEMPLATE.md`,
  `platform_store_readiness.md`, `language_packs/sanskrit_malayalam.md`,
  `profiles/example_en_ml_sa_profile.md`.
- A critical-review pass fixing errors, contradictions and wording.

## Follow-ups (not done here — each needs its own plan)

1. **Flutter 3.47 upgrade.** The app is on Flutter 3.44.8. The new guidelines
   expect the latest stable Flutter.
2. **AGP 9.** The app uses AGP 8.11.1, and `CLAUDE.md` says "stay on AGP 8.x".
   The new guidelines say to use the AGP version Flutter generates (AGP 9+ with
   Flutter 3.47). This rule conflicts and needs a decision.
3. **`material_ui` / `cupertino_ui` packages.** From Flutter 3.47, the
   guidelines require importing these instead of
   `package:flutter/material.dart`. This only applies after the Flutter
   upgrade, and the packages must be added to the approved list.
4. **`docs/PROJECT_PROFILE.md`** is now a mandatory doc. The project does not
   have one yet. `profiles/example_en_ml_sa_profile.md` matches this app
   closely.
5. **Doc links.** `CLAUDE.md` and `AGENTS.md` link reference guides as
   `docs/<file>`; the new guidelines read them at `docs/guidelines/<file>`.
   Links to standard §8.5.1–§8.5.4 now belong in
   `language_packs/sanskrit_malayalam.md` §4.1–§4.4, and `release_process.md`
   §9A now points to `platform_store_readiness.md` §2.
