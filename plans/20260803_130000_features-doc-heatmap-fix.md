# Fix inaccuracies in docs/features.md (calendar heatmap, totalTimeSeconds, splash screen)

**Status:** completed

## Files to be changed

- `docs/features.md`

## What the issue is

A critical review of `docs/features.md` against the actual code found:

1. **Made-up feature.** Section 10.2, the route table (section 12), and the summary
   matrix (section 13) describe a "Task Calendar Heatmap / Details View" — an
   interactive modal showing a task's status on a calendar. This does not exist
   anywhere in the code. The real Per-Item Overview tab has a title dropdown,
   a line chart, and a paginated table only.

2. **Wrong field placement.** Section 3.1 lists `totalTimeSeconds` as a field of
   `TodoEntity`. It is not a stored field — it is a value calculated on the fly
   from time segments when showing statistics. Listing it as an entity attribute
   is misleading.

3. **Small gap.** The Technical Profile does not mention `flutter_native_splash`,
   which is a real, used dependency (it draws the app's native splash screen).

## Plan for the fix

1. In section 10.2 ("Per-Item Overview Tab"), remove the "Task Calendar Heatmap /
   Details View" bullet. Replace it with an accurate description of what is
   actually there: a task title dropdown selector used to filter the line chart
   and table.

2. In section 12 (Application Screens & Navigation Map), remove "calendar
   heatmap" from the Statistics Dashboard row's capability list.

3. In section 13 (Summary Matrix), remove "title calendar heatmap" from the
   "Search & Stats" row.

4. In section 3.1, move `totalTimeSeconds` out of the `TodoEntity` attribute
   list. Add a short separate note that total tracked time is a computed
   display value (from time segments), not a stored column.

5. In the Technical Profile (section 1), add one line noting
   `flutter_native_splash` is used for the native splash screen.

No code changes — documentation only.
