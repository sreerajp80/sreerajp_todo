# Change Log — Mark Implemented Features in the Unique Features Document

**Plan:** `plans/20260819_071047_mark-implemented-unique-features.md`
**Date:** 2026-08-19
**Type:** Documentation only. No Dart, test, or build file was touched.

## Why

`docs/unique_features_and_improvements.md` still described several features as planned
even though the code for them is already in the repository. Three more features are half
built, and the document said nothing about that. One section also contradicted another.

## Files changed

- `docs/unique_features_and_improvements.md`

## What changed

### 1. Status legend added

A small table at the top of section 3 explains the three marks now used:
`✅ Implemented`, `🟡 Partly implemented`, and no mark for planned.

### 2. Three features marked partly implemented 🟡

Each got a `**Status:**` line, a `**Current Implementation:**` block, and a
`**Not Included:**` line naming the piece that is still missing.

| Section | What is built | What is missing |
|---|---|---|
| 3.4 Focus Sprints + Procedural Audio | `PomodoroNotifier` work/break cycle, Pomodoro settings page, `FocusPulseNotifier` nudge every 5–120 minutes, full-screen focus view | The 16-bit PCM procedural synth. Nudges use `HapticFeedback` and `SystemSound` instead. |
| 3.7 "On This Day" + Evening Reflection | Migration V5 tables `daily_reflections` and `daily_intentions`, `EveningReflectionModal`, `MorningIntentionCard`, DAO, repository and providers | The "On This Day" memory flashback card. |
| 3.8 Biometric Vault + `FLAG_SECURE` | App lock modes (off / PIN / password / device credential), auto-lock delay, wrong-try slow-down, native `FLAG_SECURE` channel, database key screen | The per-task `#private` vault and the encrypted attachment store. The lock is app-wide only. |

### 3. Section 4.2 corrected

The FTS5 section said the table uses SQL triggers and a plain `unicode61` tokenizer.
Section 3.6 says Migration V8 replaced both. 4.2 now records that it was superseded:
the table was rebuilt with the Indic tokenizer, and insert/update index maintenance moved
from SQL triggers into `TodoSearchIndexDao`, with only the delete trigger left in SQL.

### 4. Section 4.8 given a status line

Now states plainly that the Statistics screen today has a daily bar chart, a per-item line
chart, and two tables — no streaks, no hourly heatmap, no efficiency score.

### 5. Section 6 roadmap updated

- The three partly-done bars in the Mermaid gantt chart are now marked `active`.
- The Phase 1, 2 and 3 bullet lists carry the matching 🟡 marks with a short note on
  what is done and what is pending.

### 6. New section 7 — Implementation Status Summary

A single table listing all 23 features (3.1–3.15 and 4.1–4.8) with status and a short note,
so the whole picture is visible in one place. Current count: **12 done ✅, 3 partly done 🟡,
8 planned.**

## Confirmed still planned (left unmarked)

3.1 friction engine and hash-chained `todo_revisions`, 3.2 bilingual voice parser,
3.3 Vedic circadian mode, 3.9 home screen widgets, 3.10 PDF/CSV timecard export suite,
3.15 desktop sync adapter, 4.7 recurrence heatmap and holidays, 4.8 advanced analytics.

## Verification

- Section and status lines re-read after editing; every mark matches the code evidence.
- No `flutter analyze` or `flutter test` run, because no Dart file changed.
