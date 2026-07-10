# Change Log: Multilingual support (English + Malayalam), device-language driven

**Date:** 2026-06-24
**Implements plan:** `plans/20260624_092538_multilingual-en-ml.md`
**Approach approved:** Full `gen_l10n`, delete `AppStrings` (idiomatic Flutter localization)

---

## Summary

Added two-language support (English `en` + Malayalam `ml`) to **SreerajP ToDo**, driven
**automatically by the device language**. No in-app language switcher: Flutter's locale
resolution selects Malayalam when the device is set to Malayalam, otherwise falls back to
English (the fallback for every unsupported locale).

All user-visible text moved from the static `AppStrings` constant class into Flutter ARB
files compiled by `gen_l10n`, and every call site now resolves strings from `BuildContext`
via a `context.l10n` extension. `AppStrings` was deleted.

`flutter analyze` → **No issues found**. `flutter test` → **221 tests pass**.

## Offline compliance

- **No new packages.** `flutter_localizations` and `intl` were already in `pubspec.yaml`.
  Only `flutter: generate: true` was added. The dependency graph is unchanged from baseline.
- The dep-audit (`flutter pub deps --json | Select-String "http|socket|firebase|..."`) returns
  only pre-existing **dev-tooling transitive deps** (`build_runner`/`test`/`shelf` →
  `http`, `web_socket_channel`, `http_parser`, …). These are not runtime/app dependencies and
  are not bundled in release builds. No networking/cloud/analytics dependency was introduced.

## Files created

- `l10n.yaml` — gen_l10n config (arb dir `lib/l10n`, template `app_en.arb`, output class
  `AppLocalizations`, output dir `lib/l10n`, `nullable-getter: false`).
- `lib/l10n/app_en.arb` — English source strings (all former `AppStrings` entries, flattened;
  nested groups prefixed: `backup*`, `settings*`, `permissions*`, `about*`, `stats*`, `error*`).
  Placeholder metadata added for parameterised messages (`selectedCount`,
  `noSearchResultsForQuery`, `segmentSemantics`, `statsPageOf`, `statsHistoryFor`, etc.).
- `lib/l10n/app_ml.arb` — Malayalam translations of every key. Proper nouns left untranslated
  (`appName`, `aboutAuthorName`, `aboutAiModels`).
- `lib/l10n/app_localizations*.dart` — **generated** by `flutter gen-l10n` (3 files).
- `lib/core/extensions/localization_extensions.dart` — `context.l10n` getter
  (`AppLocalizations.of(this)`).
- `test/helpers/test_l10n.dart` — `testL10n` (English `AppLocalizationsEn` instance) for
  asserting on UI text in widget tests.

## Files edited

- `pubspec.yaml` — added `flutter: generate: true`.
- `lib/core/constants/app_constants.dart` — added `kAppName` constant (for the OS window/task
  title in `MaterialApp.router`, which has no localized `BuildContext`).
- `lib/app.dart` — wired `localizationsDelegates: AppLocalizations.localizationsDelegates`,
  `supportedLocales: AppLocalizations.supportedLocales`; `title:` now uses `kAppName`.
  No explicit `locale` → device language drives selection with English fallback.
- `lib/core/errors/error_message_mapper.dart` — `mapErrorToMessage` now takes an
  `AppLocalizations l10n` parameter; callers pass `context.l10n`.
- `lib/application/statistics_notifier.dart` — no longer stores a localized error string in
  state. Stores a non-localized sentinel (`_kErrorSentinel`); the statistics screen localizes
  its own message when `state.error` is non-null (it already did, via `errorRetryableGeneric`).
- **Presentation layer (all widgets/screens using strings)** — migrated `AppStrings.x` →
  `context.l10n.x`, with nested groups flattened (e.g. `AppStrings.backup.label` →
  `context.l10n.backupLabel`). Files:
  - shared widgets: `undo_status_snackbar.dart`, `status_badge.dart`, `responsive_scaffold.dart`,
    `confirm_dialog.dart`, `app_error_state.dart`
  - screens: `daily_list/daily_list_screen.dart`, `daily_list/widgets/todo_list_tile.dart`,
    `create_edit_todo/create_edit_todo_screen.dart` + `widgets/repeat_option_picker.dart`,
    `widgets/title_autocomplete_field.dart`, `time_segments/time_segments_screen.dart` +
    `widgets/manual_segment_form.dart`, `copy_todos/copy_todos_screen.dart`,
    `search_results/search_results_screen.dart`, `backup/backup_screen.dart` +
    `widgets/backup_list_tile.dart`, `settings/settings_screen.dart`,
    `settings/permissions_screen.dart`, `about/about_screen.dart`,
    `statistics/statistics_screen.dart` + `widgets/daily_stats_table.dart`,
    `widgets/daily_bar_chart.dart`, `widgets/per_item_stats_table.dart`,
    `widgets/per_item_line_chart.dart`, `recurring_tasks/widgets/rrule_preview.dart`,
    `recurring_tasks/widgets/rrule_frequency_picker.dart`
- **Tests** — pumped widget trees now include the localization delegates; `AppStrings.x`
  references replaced with `testL10n.x`:
  `test/presentation/shared_widgets_test.dart`, `undo_snackbar_test.dart`,
  `todo_list_tile_test.dart`, `backup_screen_test.dart`, `search_results_screen_test.dart`,
  `create_edit_todo_screen_test.dart`, `statistics_screen_test.dart`,
  `statistics/widgets/per_item_line_chart_test.dart`, and
  `integration_test/app_test.dart` (local `testL10n` instance).

## Files deleted

- `lib/core/constants/app_strings.dart` — fully superseded by the ARB files + `context.l10n`.

## Notable implementation details

- **`gen_l10n` generates positional placeholders**, not named. `segmentSemantics` changed from
  named args to positional at its call site in `time_segments_screen.dart`.
- Several `const` widgets that embedded `AppStrings` constants were de-`const`ed (their `Text`
  now reads from `context.l10n`); inner `Icon`/`SizedBox` kept `const` where possible.
- Two compile-time `const` lists that held strings were handled: the copy-wizard step list
  (labels were unused — replaced with a `stepCount` constant) and the recurrence day-of-week
  list and status-option list (converted to runtime lists using `context.l10n`).
- `_buildHeader` (time segments) and `_buildCompactRangeSelector` (statistics) gained a
  `BuildContext` parameter so they can resolve localized strings.
- `_statusLabel` helpers in `todo_list_tile.dart` and `search_results_screen.dart` gained a
  `BuildContext` parameter.
- `backup_screen.dart` `_handleExport` captures `context.l10n` before its first `await` to
  avoid a `use_build_context_synchronously` lint.

## ⚠️ Follow-up for the user

The Malayalam translations are AI-generated and should be **reviewed by a native speaker**
before release. Strings worth double-checking in particular:
- Status labels: `statusPending` ("ബാക്കി"), `statusWorking` ("പ്രവർത്തനത്തിൽ"),
  `statusPorted` ("മാറ്റി").
- The recurrence "Ends → For" label `endsAfterDays` ("ഇത്രയും") — terse, context-dependent.
- Abbreviated weekday names (`monday`–`sunday`).
- `aboutMadeWithLoveIn` ("ഇന്ത്യയിൽ ❤ യോടെ നിർമ്മിച്ചത്").

Edit `lib/l10n/app_ml.arb` and re-run `flutter gen-l10n` to apply any wording changes.

## Verification performed

```powershell
flutter gen-l10n                # generated AppLocalizations
flutter analyze                 # No issues found!
flutter test                    # 221 tests passed
flutter pub deps --json | Select-String "http|socket|firebase|supabase|sentry|crashlytics|analytics"
# Only pre-existing dev-tooling transitive deps; no app/runtime networking deps.
```

Not run (require a device/emulator): manual smoke test switching the device language between
Malayalam and English, and a release APK manifest `INTERNET`-permission check (unaffected by
this change — no manifest edits were made).
