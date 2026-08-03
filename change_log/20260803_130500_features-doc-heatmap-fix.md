# Fixed inaccuracies in docs/features.md

Implements: `plans/20260803_130000_features-doc-heatmap-fix.md`

## What changed

A codebase audit found that `docs/features.md` described a "Task Calendar
Heatmap" feature on the Statistics screen that does not exist in the app.
The following fixes were made, documentation only, no code changes:

1. Section 10.2 (Per-Item Overview Tab): removed the made-up "Task Calendar
   Heatmap / Details View" bullet. Replaced with an accurate description of
   the real UI — a task title dropdown that filters the line chart and table.
2. Section 12 (Screens table) and Section 13 (Summary Matrix): removed
   "calendar heatmap" mentions, replaced with the accurate "title selector"
   wording.
3. Section 3.1 (`TodoEntity` attributes): moved `totalTimeSeconds` out of the
   entity's field list and added a note explaining it is a value calculated
   from time segments, not a stored database column.
4. Section 1 (Technical Profile): added a line noting `flutter_native_splash`
   is used for the app's native splash screen — it was a real dependency that
   the doc did not mention.

## Why

A background audit compared the doc against the actual code (routes, DAOs,
entities, use-cases, screens) and confirmed the heatmap feature and the
`totalTimeSeconds` entity field were not real. Everything else in the doc
(routes, exceptions, use-cases, other entity fields) was verified accurate
and left unchanged.
