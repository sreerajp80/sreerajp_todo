# Mark Implemented Features in `docs/unique_features_and_improvements.md`

**Status:** completed

## Files to be changed

- `docs/unique_features_and_improvements.md` (only file touched)

## The issue

The document still shows several features as "planned" even though the code for them
is already in the repository. Someone reading the document today would get a wrong
picture of what is built. Two more features are half built, and the document says
nothing about that either.

Findings from reading the code:

| Section | Doc says now | Code shows |
|---|---|---|
| 3.4 Focus Sprints + Procedural Audio | not marked | **Partly done.** `lib/application/pomodoro_notifier.dart`, `lib/application/focus_pulse_notifier.dart`, `lib/core/utils/focus_pulse_rules.dart`, settings route `/settings/time-tracking/pomodoro`. Uses `HapticFeedback` / `SystemSound`, **not** a 16-bit PCM synth. |
| 3.7 "On This Day" + Evening Reflection | not marked | **Partly done.** Migration V5 adds `daily_reflections` and `daily_intentions`; `evening_reflection_modal.dart`, `morning_intention_card.dart`, `daily_reflection_dao.dart`, repository + provider all exist. No "On This Day" flashback card. |
| 3.8 Biometric Vault + `FLAG_SECURE` | not marked | **Partly done.** `lib/core/platform/app_lock_channel.dart`, `MainActivity.kt`, `lib/core/utils/app_lock_rules.dart`, `app_lock_notifier.dart`, routes `/settings/security/app-lock` and `/auto-lock`. Whole-app lock (PIN / password / device credential) + `FLAG_SECURE` + auto-lock delay. No per-task `#private` vault, no encrypted attachments. |
| Phase 1 / Phase 3 lists in section 6 | no ticks on the above | same as above |
| Roadmap gantt in section 6 | no `done` on the above | same as above |

Confirmed still **not** built (leave as planned): 3.1 friction engine and `todo_revisions`
hash chain, 3.2 bilingual voice parser, 3.3 Vedic circadian mode, 3.9 home screen widgets,
3.10 timecard export suite (only JSON / Markdown handoff exists, no PDF or CSV),
3.15 desktop sync adapter, 4.7 recurrence heatmap and holidays, 4.8 advanced analytics
(statistics screen has only daily bar chart, per-item line chart and two tables).

## The plan for the fix

1. Add a short **status legend** near the top of section 3 explaining the three marks:
   `✅ Implemented`, `🟡 Partly implemented`, and no mark for planned.
2. Section 3.4: add `**Status:** Partly implemented 🟡` and a
   `**Current Implementation:**` block listing the Pomodoro engine, focus pulse, and the
   settings pages. Add a `**Not Included:**` line for the PCM synth.
3. Section 3.7: add `**Status:** Partly implemented 🟡` with a
   `**Current Implementation:**` block for the morning intention card, evening reflection
   modal, and Migration V5 tables. Add a `**Not Included:**` line for the memory flashback card.
4. Section 3.8: add `**Status:** Partly implemented 🟡` with a
   `**Current Implementation:**` block for the app lock modes, auto-lock delay, lockout
   slow-down and `FLAG_SECURE`. Add a `**Not Included:**` line for the per-task `#private`
   vault and encrypted attachments.
5. Section 4.2: keep the ✅ but correct the text, because the FTS5 table was later rebuilt
   by Migration V8 with the Indic tokenizer and Dart-side index maintenance (see 3.6). The
   present wording contradicts 3.6.
6. Section 4.8: no tick. Add a one-line note saying what the statistics screen has today,
   so the gap is clear.
7. Section 6: mark the gantt bars for the three partly-done items and update the Phase 1,
   2 and 3 bullet lists with the matching ✅ / 🟡 marks.
8. Add a small **implementation status summary table** at the end of section 6 listing
   every feature and its state, so the reader gets the whole picture in one place.

No code, test, or behaviour change. Only documentation text.

## Verification

- Re-read the file after editing to confirm the marks match the findings table above.
- No `flutter analyze` / `flutter test` run needed, as no Dart file is touched.
