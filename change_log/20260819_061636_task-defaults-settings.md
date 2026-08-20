# Task Defaults Settings

Implements: `plans/20260819_054815_task-defaults-settings.md`

**Version:** 1.11.0+20 → 1.12.0+21
**Database schema:** 8 → 9

---

## What changed, in short

Settings gained a new **Task defaults** hub with four pages. Two new task fields —
priority and target time — were added to make some of those settings mean anything.

---

## 1. New task fields

### Priority

- New enum `TodoPriority` (`low`, `normal`, `high`, `urgent`) in
  `lib/data/models/todo_priority.dart`. Stored as text, like `TodoStatus`.
- `TodoPriority.fromDbString` never throws. An unknown value reads as `normal`, so a
  downgrade or a hand-edited database cannot stop the day list loading.
- New `todos.priority` column (TEXT, not null, default `'normal'`).
- Shown as a chip row on the create/edit form and as a small coloured dot on the day
  tile. `normal` has no colour and so shows no dot, which keeps a plain list plain.
- New **Priority (high first)** sort. Ties keep the manual order, because `List.sort` is
  not stable on its own.

### Target time

- New `todos.target_seconds` column (INTEGER, nullable). Null means no target.
- Entered on the form as two number boxes, hours and minutes. Both at zero clears it.
- On the day tile a task with a target shows `01:12:00 of 02:00:00` with a thin bar
  underneath. Past the target the text and bar turn to the error colour.
- **Display only.** Passing a target never stops a timer and never changes a status.

---

## 2. Migration v9

`lib/data/database/migrations/migration_v9.dart` adds both columns and an
`idx_todos_priority` index on `(date, priority)`. Every step is guarded by a
`PRAGMA table_info` / `IF NOT EXISTS` check, so running it twice is safe.

`migration_v1.dart` also creates the two columns, so a fresh install matches an upgraded
database exactly.

**Older data keeps working:**

- A backup made by an older build restores as an older database and is upgraded on open.
- An older P2P peer or handoff file has both columns defaulted in
  `P2pSyncPayload._sanitizeFieldLengths`, next to the existing `sort_order` default, so
  the row still inserts instead of failing on a NOT NULL column.

---

## 3. Settings → Task defaults

Four pages, all backed by `TaskDefaultsNotifier`
(`lib/application/task_defaults_notifier.dart`), which reads and writes
`SharedPreferences` the same way `TimeTrackingSettingsNotifier` does. **Every default
reproduces the behaviour the app already had.**

### New task
| Setting | Default |
|---------|---------|
| Default status (`pending` / `working`) | `pending` |
| Default priority | `normal` |
| Default target time | none |

Choosing `working` pre-selects the status but does **not** start a timer.

### Day list
| Setting | Default |
|---------|---------|
| Default order (9 sort modes) | Manual |
| Remember the last order I pick | on |
| Show completed tasks | on |
| Show dropped tasks | on |
| Move finished tasks to the bottom | off |

When a filter hides anything, the day list shows a **"N finished tasks hidden — Show"**
line. "Show" reveals them for that visit only and is never saved.

### Task actions
| Setting | Default |
|---------|---------|
| Ask before completing | off |
| Ask before dropping | on (the old fixed behaviour) |
| Ask to carry over unfinished tasks | off |
| How far back to look | previous day only |

Both confirmations apply on the day tile quick actions **and** on the status chips in the
create/edit form, so the two routes to a status change behave the same.

The carry-over sheet is offered on the first open of a new day. It lists the `pending` and
`working` tasks from the most recent earlier day that had any, all ticked, and copies the
ticked ones through the existing `CopyTodos` use case — so duplicate titles are skipped
and the day lock and NFC normalisation are not re-implemented. **Tasks on the earlier day
are never changed**, because past days are read-only. The "asked on" date is written
*before* the sheet opens, so a crash cannot make it reappear all day.

### Autocomplete
| Setting | Default |
|---------|---------|
| Suggest titles while typing | on |
| How many suggestions (5 / 10 / 20 / 50) | 20 |

The count is a real SQL `LIMIT`, not a list trimmed in Dart. With suggestions off, no
query runs at all — the debounce timer is not even started.

---

## 4. Files

### New

| File | Purpose |
|------|---------|
| `lib/data/models/todo_priority.dart` | The priority enum |
| `lib/data/database/migrations/migration_v9.dart` | The two new columns and their index |
| `lib/application/task_defaults_notifier.dart` | State, keys and setters for every task default |
| `lib/core/utils/task_default_rules.dart` | Pure Dart: setting enums, target split/join, once-a-day carry-over check |
| `lib/core/constants/todo_sort_option.dart` | The sort enum, moved out of `presentation/` |
| `lib/presentation/screens/settings/task_defaults_screen.dart` | The hub |
| `lib/presentation/screens/settings/task_defaults/defaults_new_task_screen.dart` | New task page |
| `lib/presentation/screens/settings/task_defaults/defaults_day_list_screen.dart` | Day list page |
| `lib/presentation/screens/settings/task_defaults/defaults_task_actions_screen.dart` | Task actions page |
| `lib/presentation/screens/settings/task_defaults/defaults_autocomplete_screen.dart` | Autocomplete page |
| `lib/presentation/screens/daily_list/day_list_filters.dart` | Show/hide and sink rules, pulled out so they can be tested |
| `lib/presentation/screens/daily_list/widgets/carry_over_sheet.dart` | The carry-over picker |
| `lib/presentation/screens/create_edit_todo/widgets/priority_selector.dart` | Priority chips |
| `lib/presentation/screens/create_edit_todo/widgets/target_time_field.dart` | Hours + minutes target boxes |
| `lib/presentation/shared/task_default_labels.dart` | Shared priority / sort / target names and colours |

### Changed

`app_constants.dart` (schema 9), `migration_runner.dart`, `migration_v1.dart`,
`todo_entity.dart` (+ regenerated freezed), `todo_dao.dart`,
`todo_repository_impl.dart`, `todo_repository.dart`, `copy_todos.dart`, `port_todo.dart`,
`p2p_sync_payload.dart`, `providers.dart`, `settings_screen.dart`, `app_routes.dart`,
`app.dart`, `daily_list_screen.dart`, `todo_list_tile.dart`,
`create_edit_todo_screen.dart`, `title_autocomplete_field.dart`, `app_en.arb`,
`app_ml.arb` (+ regenerated localizations), `docs/features.md`,
`docs/architecture.md`, `pubspec.yaml`, `assets/config/app_config.json`.

`lib/presentation/screens/daily_list/todo_sort_option.dart` was **removed**; the enum now
lives in `core/`, because the saved default is held in the application layer and the
application layer must never import from `presentation/`.

### Tests

New: `test/data/migration_v9_test.dart`,
`test/data/todo_dao_priority_target_test.dart`,
`test/application/task_defaults_notifier_test.dart`,
`test/core/task_default_rules_test.dart`,
`test/presentation/day_list_filter_test.dart`.

Updated (setup only, no behaviour claims changed):

- Three repository fakes gained the new `limit` argument on
  `getAutocompleteSuggestions`.
- `settings_screen_test.dart` now expects seven cards and uses a tall test window,
  because a `ListView` only builds what fits and the seventh card sat past the fold.
- `create_edit_todo_screen_test.dart`: the narrow-screen check now scrolls to the status
  card, which sits lower with priority and target time above it; and the new-task test
  now provides `SharedPreferences`, because a new task reads its opening values from the
  task defaults.

---

## 5. Two things done differently from the plan

Both were judgement calls made during the work and are worth knowing about:

1. **Recurring and mastery-deck tasks do not carry a priority or target.** The plan said
   `generate_recurring_tasks.dart` and `generate_spaced_repetition_tasks.dart` would pass
   both through. They cannot: a recurrence rule and a mastery item have no priority or
   target of their own to pass, and giving them one would mean more columns on
   `recurrence_rules` and `spaced_repetition_items` — a larger change than this plan
   covers. Tasks they generate therefore open at `normal` with no target. **Copy and Port
   do carry both through**, because there is a real source task to copy from.

2. **`backup_service.dart` needed no change.** The plan listed it. On reading it, the
   backup is a whole-file copy of the encrypted database with a `user_version` check, not
   a per-column export, so an older backup is simply upgraded by migration v9 on open.

One string clash was caught and fixed during the work: the day list already had a Drop
confirmation using `confirmDropBody`, and the first pass at the new strings overwrote it
with a version taking a `{title}` placeholder. The original value was restored from git
and the duplicate key removed, so the new setting reuses the strings that already existed.

---

## 6. Verification

- `flutter analyze` — **0 issues**
- `flutter test` — **426 tests, all passing**
- `dart format lib/ test/ integration_test/` — applied
- Both ARB files carry all 69 new strings in English and Malayalam; `flutter gen-l10n`
  reports no new untranslated messages (the 17 it lists are pre-existing and untouched).
