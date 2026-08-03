# Change log: Fix accuracy gaps in docs/features.md

Implements plan `plans/20260803_120000_features-doc-accuracy-fix.md`.

## What changed

All changes are in `docs/features.md` only. No app code was touched.

1. **Sort options list corrected.** Section 3.1 and the Summary Matrix (section 13) used
   to list only 4 sort modes. Checked the real code
   (`lib/presentation/screens/daily_list/todo_sort_option.dart` and the sort menu in
   `daily_list_screen.dart`) and found 8 sort options. The doc now lists all 8: Manual,
   Name A→Z, Name Z→A, Created Oldest First, Created Newest First, Most Time Tracked,
   Least Time Tracked, By Status.

2. **Removed a wrong claim about language switching.** The doc said the app has
   "runtime language switching via settings." Checked the Settings screen and the rest
   of the code — there is no language switcher anywhere in the app. The wording in
   section 1 (Inclusive Design bullet) and section 2 item 5 (Bilingual Localization) now
   says the app language follows the device's system language automatically, and there
   is no in-app way to change it.

3. **Fixed a wrong number.** The doc said the content area max width is `1100dp` in two
   places. The real constant `kContentMaxWidthDp` in
   `lib/core/constants/app_constants.dart` is `1440`. Both mentions are now `1440dp`.

## Why

The user asked for a critical review of `docs/features.md` to confirm every feature is
listed and the app description is accurate. Comparing the doc against the actual code
turned up the three issues above; everything else in the doc (exceptions, routes,
statuses, undo system, backup/restore, recurrence engine, statistics fields, debounce
timings, passphrase minimum length) matched the code and needed no change.
