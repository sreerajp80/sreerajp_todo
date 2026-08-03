# Change log: Fourth accuracy pass on docs/features.md

Implements plan `plans/20260803_182929_features-doc-fourth-accuracy-pass.md`.

## What changed

All changes are in `docs/features.md`, Section 10 (Statistics & Productivity
Analytics Dashboard). No app code was touched.

1. **Status Breakdown Bar Chart bullet fixed.** Was missing the `working`
   status. The real chart (`daily_bar_chart.dart`) draws five bars per day:
   pending, working, completed, dropped, ported. Doc now lists all five.

2. **Summary Metrics Cards bullet fixed.** Was missing two of the five real
   cards. The real screen (`statistics_screen.dart`, `_SummaryCards`) shows:
   total task count, average completed per day, average time per day, total
   productive time, and total dropped time. Doc now lists all five.

3. **Daily Metrics Data Table bullet corrected.** The doc wrongly claimed this
   table shows "completion rates" and a per-row productive-vs-dropped time
   split. Neither exists in the real table (`daily_stats_table.dart`), which
   has columns Date, Total, Pending, Working, Completed, Dropped, Ported, and
   one combined Total Time column. The productive/dropped split is only the
   two aggregate summary cards from point 2 — not per-day table columns. Doc
   now describes the real columns and clarifies where the split actually
   appears.

4. **Title Summary Table bullet fixed.** Was missing Pending count and
   Working count columns that the real table (`per_item_stats_table.dart`)
   has. Doc now lists all seven columns.

## Why

The user asked for a further critical review of `docs/features.md` after
three earlier passes. This pass focused on Section 10 (Statistics), which
had the most detailed numeric/UI claims left unchecked. Comparing the doc
against the actual chart and table widget code found the four gaps above.
Routes, exceptions, entities, use-cases, the undo system, backup/restore, and
the recurrence engine were re-checked and remain accurate — no further
changes needed there.
