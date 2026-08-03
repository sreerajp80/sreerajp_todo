# Fix accuracy gaps in docs/features.md

**Status:** completed

## Files to change

- `docs/features.md`

## What is wrong

I compared `docs/features.md` against the real code and found three problems:

1. **Sort options are incomplete.** The doc lists only 4 sort modes (Manual, By Status,
   By Title, By Time Tracked). The real code
   (`lib/presentation/screens/daily_list/todo_sort_option.dart` and the sort menu in
   `daily_list_screen.dart`) has 8 sort options the user can pick from:
   Manual, Name A→Z, Name Z→A, Created Oldest, Created Newest, Most Time Tracked,
   Least Time Tracked, By Status.

2. **Wrong claim about language switching.** The doc says (in two places) that the app
   supports "runtime language switching via settings." I checked the Settings screen
   (`lib/presentation/screens/settings/settings_screen.dart`) and the rest of the code —
   there is no language switcher anywhere. The app only follows the phone/PC's system
   language automatically. There is no in-app way to change the language.

3. **Wrong number for content width.** The doc says the main content area is capped at
   `1100dp` (in two places). The real constant in `lib/core/constants/app_constants.dart`
   is `kContentMaxWidthDp = 1440`, not `1100`.

## Plan for the fix

In `docs/features.md`:

1. In section **3.1 Daily Task List**, replace the 4-item sort list with the full
   8-option list (Manual, Name A→Z, Name Z→A, Created Oldest, Created Newest,
   Most Time Tracked, Least Time Tracked, By Status).

2. In the **Inclusive Design & Accessibility Profile** bullet (section 1) and in
   **Core Architectural Guarantees** section 2, item 5 (Bilingual Localization),
   remove the "runtime language switching via settings" claim and replace it with
   wording that says the app language follows the device's system language
   automatically, with no in-app language switch.

3. Fix both occurrences of `1100dp` (section 1 "Cross-Device Adaptiveness" bullet and
   section 1 "Technical Profile" adaptive layout bullet) to say `1440dp`, matching
   `kContentMaxWidthDp`.

4. Update the **Summary Matrix of App Capabilities** (section 13) "Task Management" row
   to mention the full set of sort options instead of the shortened list.

No app code changes — this is a documentation-only fix.

## After approval

Write a change log in `change_log/` describing the corrections, referencing this plan.
