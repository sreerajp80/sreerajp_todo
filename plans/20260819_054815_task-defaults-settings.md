# Task Defaults Settings

**Status:** completed

## 1. The issue

Settings today has six entries: Appearance, Language, Time tracking, Backup, About and
Permissions. Nothing about how a **task** behaves can be changed. Every choice about a
new task, and about how the day list looks, is fixed in code.

What is wrong right now:

- **No default status for a new task.** `create_edit_todo_screen.dart:49` always starts
  at `TodoStatus.pending`. There is no way to say "new tasks start as working".
- **No priority at all.** `TodoEntity` has no priority field. You cannot mark a task as
  high or low, so you also cannot set a default.
- **Sort order is lost on every restart.** `daily_list_screen.dart:39` keeps
  `_sortOption` in plain widget state. Pick "Name A-Z", close the app, and you are back
  to "Manual".
- **Completed and dropped tasks cannot be hidden.** The day list always shows every
  task, so finished work keeps taking up the top of the screen.
- **No confirmation before complete or drop.** The tick and cross buttons on the tile
  (`todo_list_tile.dart` around lines 444-463) fire straight away. A mis-tap changes a
  task's status, and only the app-bar undo saves you.
- **Carry-over is fully manual.** Unfinished tasks from yesterday stay on yesterday.
  You have to open the Copy/Port wizard by hand every morning.
- **No target or estimated time.** `TodoEntity` has no such field, so a task can never
  say "this should take 30 minutes", and time tracking has nothing to compare against.
- **Autocomplete cannot be turned off, and its size is fixed.**
  `kAutocompleteLimit = 20` in `app_constants.dart` is a compile-time constant.

## 2. What we will build

A new **Settings -> Task defaults** hub, plus two new task fields that the settings
need in order to mean anything.

### 2.1 Priority (new task field)

- New enum `TodoPriority`: `low`, `normal`, `high`, `urgent`. Default `normal`.
- New `priority` column on `todos` (TEXT, not null, default `'normal'`).
- Shown on the create/edit form as a small choice row, and on the day tile as a
  coloured dot with a tooltip. `normal` shows no dot, so the list stays quiet for
  people who never use priority.
- New sort option **Priority (high first)** in the day list sort menu.
- Setting: **Default priority for a new task** (default `normal`).

### 2.2 Target time (new task field)

- New `target_seconds` column on `todos` (INTEGER, nullable). Null means "no target".
- Shown on the create/edit form as an hours + minutes picker with a "no target" option.
- On the day tile, when a target is set, the tracked time is shown as
  `01:12:00 / 02:00:00` with a thin progress bar. The bar turns to the "over" colour
  once the tracked time passes the target. This is display only; nothing is blocked and
  no timer is auto-stopped.
- Setting: **Default target time for a new task** (default: none).

### 2.3 Default status for a new task

- Choice: `pending` (default) / `working`.
- Only these two. `completed`, `dropped` and `ported` make no sense for a brand new
  task. Picking `working` pre-selects the status but still does **not** start a timer,
  because a running timer is what normally drives `working`. That is stated in the
  option's help line.

### 2.4 Saved default sort order

- The current `TodoSortOption` list, plus the new `priorityHigh` option.
- The day list reads its first sort value from this setting instead of hard-coding
  `manual`.
- Second switch: **Remember the last sort I pick** (default on). When on, changing the
  sort from the day list menu also writes it back to the saved setting, so the choice
  survives a restart. When off, the menu choice lasts only for that screen and the
  saved default is used again next time.

### 2.5 Show or hide finished tasks

Three settings in one card:

- **Show completed tasks** (default on).
- **Show dropped tasks** (default on).
- **Move finished tasks to the bottom** (default off). When on, `completed`, `dropped`
  and `ported` tasks are pushed below the rest, whatever the sort is — including manual
  order. Drag-to-reorder then works only inside the unfinished group, because moving a
  sunk or hidden task would write a confusing `sort_order`.

When a filter hides tasks, the day list shows a small line at the bottom:
"3 finished tasks hidden — Show". Tapping "Show" reveals them for that visit only.
Without this you cannot tell the difference between "all done" and "nothing there".

### 2.6 Confirm before complete or drop

- Two switches: **Confirm before completing** (default off) and **Confirm before
  dropping** (default on, because dropping is the more surprising of the two).
- Uses the existing `showConfirmDialog` helper. Applied on the day tile quick actions
  **and** on the status chips in the create/edit form, so both paths behave the same.
- The existing undo SnackBar and app-bar undo button are untouched.

### 2.7 Auto carry-over of unfinished tasks

Per the choice made: **ask each time**.

- Setting: **Ask to carry over unfinished tasks** (default off).
- When on, the first time today's list is opened on a given day, a sheet lists every
  `pending` and `working` task from the most recent earlier day that still has tasks,
  each with a checkbox, all ticked by default. "Carry over" copies the ticked ones to
  today; "Not now" closes it.
- Copying reuses the existing `CopyTodos` use case, so duplicate titles are skipped and
  NFC normalisation and day lock are already handled. **Originals are left alone** —
  past days are read-only, and changing them would need a day-lock exception.
- A "last asked on" date is kept in `SharedPreferences` so the sheet appears at most
  once per day. A "Do not ask again" button in the sheet turns the setting off.
- Extra setting: **How far back to look** — `previous day only` (default) /
  `last 7 days`.

### 2.8 Autocomplete

- **Title autocomplete** on/off (default on). When off, `TitleAutocompleteField` skips
  the query completely, so nothing is read from the database while typing.
- **How many suggestions** — `5` / `10` / `20` (default) / `50`.
- The limit is passed down to `getAutocompleteSuggestions` as a parameter instead of
  reading the constant, so the SQL `LIMIT` really changes. `kAutocompleteLimit` stays
  as the default value of the new parameter.
- The rule "never cache the full title list in memory" is unchanged — this only changes
  the `LIMIT` on the existing prefix query.

## 3. Files to change

All paths are relative to the repository root.

### New files

| File | Purpose |
|------|---------|
| `lib/data/models/todo_priority.dart` | The `TodoPriority` enum with `toDbString` / `fromDbString`, matching `todo_status.dart`. |
| `lib/data/database/migrations/migration_v9.dart` | Adds `priority` and `target_seconds` to `todos`, guarded by a `PRAGMA table_info` check like `migration_v8.dart`. |
| `lib/application/task_defaults_notifier.dart` | `TaskDefaults` state, `SharedPreferences` keys, and the notifier. Mirrors `time_tracking_settings_notifier.dart`. |
| `lib/core/utils/task_default_rules.dart` | Pure Dart: the target-time choice enum, the suggestion-count enum, the carry-over look-back enum, and the "should ask today" date check. No Flutter imports. |
| `lib/presentation/screens/settings/task_defaults_screen.dart` | The Task defaults hub, links to the four pages below. |
| `lib/presentation/screens/settings/task_defaults/new_task_screen.dart` | Default status, default priority, default target time. |
| `lib/presentation/screens/settings/task_defaults/day_list_screen.dart` | Default sort, remember-last-sort, show completed, show dropped, sink finished. |
| `lib/presentation/screens/settings/task_defaults/task_actions_screen.dart` | Confirm before complete, confirm before drop, carry-over on/off and look-back. |
| `lib/presentation/screens/settings/task_defaults/autocomplete_screen.dart` | Autocomplete on/off and suggestion count. |
| `lib/presentation/screens/daily_list/widgets/carry_over_sheet.dart` | The "carry over unfinished tasks" sheet. |
| `lib/presentation/screens/create_edit_todo/widgets/priority_selector.dart` | The priority choice row on the form. |
| `lib/presentation/screens/create_edit_todo/widgets/target_time_field.dart` | The hours + minutes target picker on the form. |
| `test/data/migration_v9_test.dart` | Migration adds both columns, is safe to run twice, and old rows get `normal` / null. |
| `test/data/todo_dao_priority_target_test.dart` | DAO writes and reads the two new columns, and honours the new autocomplete limit. |
| `test/application/task_defaults_notifier_test.dart` | Defaults, load, and save. |
| `test/core/task_default_rules_test.dart` | Target-time conversion and the "should ask today" check. |
| `test/presentation/day_list_filter_test.dart` | Show/hide and sink-to-bottom produce the right list. |

### Changed files

| File | Change |
|------|--------|
| `lib/core/constants/app_constants.dart` | Bump `kDatabaseVersion` to 9. Keep `kAutocompleteLimit` as the default argument value. |
| `lib/data/database/migrations/migration_runner.dart` | Run migration v9. |
| `lib/data/database/migrations/migration_v1.dart` | Add the two columns to the fresh-install `todos` table so a new database matches a migrated one. |
| `lib/data/models/todo_entity.dart` | Add `priority` and `targetSeconds`; extend `toMap` and `fromMap`. |
| `lib/data/models/todo_entity.freezed.dart` | Regenerated by `build_runner`. Not hand-edited. |
| `lib/data/dao/todo_dao.dart` | Carry the two new columns in insert/update/select. Add a `limit` parameter to the autocomplete query. |
| `lib/data/repositories/todo_repository_impl.dart` | Pass the autocomplete limit through. |
| `lib/domain/repositories/todo_repository.dart` | `getAutocompleteSuggestions(String prefix, {int limit})`. |
| `lib/domain/usecases/copy_todos.dart` | Carry `priority` and `targetSeconds` onto the copy. |
| `lib/domain/usecases/port_todo.dart` | Same. |
| `lib/domain/usecases/generate_recurring_tasks.dart` | Same, so a repeat keeps its priority and target. |
| `lib/domain/usecases/generate_spaced_repetition_tasks.dart` | Same. |
| `lib/domain/entities/p2p_sync_payload.dart` | Add the two columns to the sanitiser defaults, next to the existing `sort_order` line, so an older peer's rows still load. |
| `lib/data/services/data_handoff_service.dart` | Same defaulting for imported rows. |
| `lib/data/backup/backup_service.dart` | Confirm the two columns ride along in export/restore; add defaults for older backups. |
| `lib/application/providers.dart` | Add `taskDefaultsProvider`; pass the autocomplete limit into `autocompleteProvider`. |
| `lib/presentation/screens/settings/settings_screen.dart` | Add the "Task defaults" nav card. |
| `lib/core/constants/app_routes.dart` | Add `taskDefaults` and its four child routes. |
| `lib/app.dart` | Register the five new routes. |
| `lib/presentation/screens/daily_list/todo_sort_option.dart` | Add `priorityHigh`. |
| `lib/presentation/screens/daily_list/daily_list_screen.dart` | Seed `_sortOption` from the setting; write it back when "remember last sort" is on; apply the show/hide and sink-to-bottom filters; add the priority sort case and menu item; show the "N hidden — Show" line; open the carry-over sheet on the first visit of a day. |
| `lib/presentation/screens/daily_list/widgets/todo_list_tile.dart` | Priority dot; target-time progress; run the confirm dialogs before `onComplete` / `onDrop`. |
| `lib/presentation/screens/create_edit_todo/create_edit_todo_screen.dart` | Seed status, priority and target from the settings for a new task; add the two new fields; run the confirm dialogs on the status chips. |
| `lib/presentation/screens/create_edit_todo/widgets/title_autocomplete_field.dart` | Skip the query when autocomplete is off; pass the chosen limit. |
| `lib/l10n/app_en.arb`, `lib/l10n/app_ml.arb` | About 60 new strings for every label, option, dialog and message. |
| `lib/l10n/app_localizations*.dart` | Regenerated by `flutter gen-l10n`. |
| `docs/features.md` | New section for Task defaults; update the task-field list with priority and target time. |
| `docs/architecture.md` | Note the new notifier, provider, migration v9, and the two new columns. |
| `assets/config/app_config.json`, `pubspec.yaml` | Version bump. |

**One database migration (v9). No new package.**

## 4. Order of work

1. `todo_priority.dart`, `migration_v9.dart`, `migration_v1.dart` and `kDatabaseVersion`,
   plus the migration test.
2. `todo_entity.dart` and `build_runner`; then the DAO, repository and use-case changes
   with their tests.
3. `task_default_rules.dart` and `task_defaults_notifier.dart` plus tests, and the
   provider.
4. The five settings screens, routes, and the ARB strings.
5. Create/edit form: default status, priority selector, target field, confirm dialogs.
6. Day list: saved sort, priority sort, filters, sink-to-bottom, hidden-count line.
7. Tile: priority dot, target progress, confirm dialogs.
8. Carry-over sheet and the once-per-day check.
9. Autocomplete on/off and the limit.
10. Payload and backup defaulting for older data.
11. `flutter analyze` at zero issues, `flutter test`, `dart format`.
12. Docs and version bump.
13. Change log in `change_log/`.

## 5. Risks

- **This is a schema change, so it is the riskiest kind.** Migration v9 is written to be
  safe to run twice and is tested against a database built from v1. A restore of an
  older backup, an older P2P peer, and an older handoff file are all handled by
  defaulting the two missing columns rather than failing.
- **Existing tests will break.** `TodoEntity` gains two fields and
  `getAutocompleteSuggestions` gains a parameter. Both new pieces have defaults, so most
  call sites keep working, but every todo test will be re-run.
- **Two jobs in one plan.** The new fields (priority, target time) and the settings are
  separate pieces sharing a plan. If the field work starts to pull the change out of
  shape, the settings that need no schema change will be finished first and the plan
  marked `partial_completion` with the reason recorded.
- **Sink-to-bottom versus drag order.** Manual reorder writes `sort_order`. Dragging is
  therefore limited to the unfinished group while sinking is on, and this limit will be
  written into `docs/features.md` so it is not a surprise.

## 6. Rules honoured

- Layers respected: pure logic in `core/`, state in `application/`, rules in
  `domain/usecases/`, SQL in the DAO only. No widget touches a DAO.
- All new user-visible text goes through the ARB files in English and Malayalam.
- NFC normalisation, day lock, terminal status lock, one-open-segment and title
  uniqueness are all unchanged. Carry-over goes through `CopyTodos`, which already
  obeys them.
- The undo pattern (5-second SnackBar plus app-bar undo) is kept exactly as it is.
- Generated `*.freezed.dart` files are produced by `build_runner`, never hand-edited.
- Every new DAO method and the new migration get unit tests in the same change.
- Fully offline. No new dependency, no network, no new permission.

---

**Do you approve this plan?**
