# Plan: Fourth accuracy pass on docs/features.md

**Status:** completed

## Files to be changed

- `docs/features.md` (documentation only — no app code changes)

## What the issue is

I did a fresh, critical read of `docs/features.md` against the real code in the
Statistics dashboard (Section 10). Three earlier passes already fixed other
issues (sort options, language switch, content width, a made-up heatmap
feature, wrong debounce number, missing root route). This pass checked
Section 10 in detail against the actual widgets and found new, real gaps:

1. **Status Breakdown Bar Chart is missing a status.** The doc (Section 10.1)
   says the bar chart shows counts for `completed`, `dropped`, `ported`,
   `pending`. The real code
   (`lib/presentation/screens/statistics/widgets/daily_bar_chart.dart`) draws
   **five** bars per day, including `working`, which the doc leaves out.

2. **Summary Metrics Cards list is incomplete.** The doc says there are three
   summary cards: total task count, average completed per day, average time
   per day. The real code
   (`lib/presentation/screens/statistics/statistics_screen.dart`, `_SummaryCards`)
   shows **five** cards: those three, plus a "Productive Time" card (total
   completed-task time) and a "Dropped Time" card (total dropped-task time).

3. **Daily Metrics Data Table description is wrong.** The doc says this table
   shows "completion rates" and a per-row split of "Completed Productive Time
   vs Dropped Sunk Time." Neither is true. The real table
   (`daily_stats_table.dart`) has columns: Date, Total, Pending, Working,
   Completed, Dropped, Ported, and one combined Total Time column. There is no
   completion-rate column, and the productive/dropped time split only exists
   as the two *aggregate* summary cards from point 2 above — not as per-day
   table columns.

4. **Title Summary Table (Section 10.2) is missing two columns.** The doc
   says this table shows appearance count, completion count, dropped count,
   ported count, and total time. The real table
   (`per_item_stats_table.dart`) also has **Pending** and **Working** count
   columns, which the doc does not mention.

## The plan for the fix

Edit `docs/features.md` only, in Section 10:

1. Section 10.1, "Status Breakdown Bar Chart" bullet: change the status list
   to `pending`, `working`, `completed`, `dropped`, `ported` (all five).

2. Section 10.1, "Summary Metrics Cards" bullet: expand to list all five
   cards — total task count, average completed tasks per day, average time
   spent per day, total productive time (completed tasks), total dropped time
   (dropped tasks).

3. Section 10.1, "Daily Metrics Data Table" bullet: rewrite to accurately
   describe the real columns (Date, Total, Pending, Working, Completed,
   Dropped, Ported, Total Time) and remove the false "completion rates" and
   per-row productive/dropped split claims.

4. Section 10.2, "Title Summary Table" bullet: add Pending count and Working
   count to the listed columns.

No other sections need changes — routes, exceptions, entities, use-cases,
undo system, backup/restore, and recurrence engine were already re-checked
in earlier passes and remain accurate.

## Why

The user asked for another critical review to confirm every feature is
listed and the app description is complete and accurate. The Statistics
section had the most detailed numeric/UI claims left unchecked by prior
passes, and checking it against the actual chart and table widget code
turned up the four gaps above.
