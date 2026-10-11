# Phase 3B — Recurring Tasks

## Objective
Allow users to define recurrence rules (daily, weekly, monthly, yearly — full iCalendar RRULE support via RFC 5545) so that tasks are auto-created on matching dates without manual copy/port.

## Pre-Requisites
- Phase 2 complete (DB layer with `RecurrenceRuleDao`, `RecurrenceRuleEntity` model).
- Phase 3 complete (core todo CRUD, daily list screen, use-case pattern established).
- Read `CLAUDE.md` — non-negotiable rules, architecture constraints.
- Read `docs/architecture.md` — data flow (§6), use-case pattern, navigation (§9).
- Read `docs/guidelines/flutter_project_engineering_standard.md` — testing standard (§9), coding standards (§8), Definition of Done (§14).

## Architecture Reminder
- Generated recurring tasks behave identically to manually created tasks.
- Editing a generated task does NOT affect the recurrence rule or future tasks.
- Deleting a generated task does NOT stop the recurrence.
- To stop recurrence: pause or delete the rule.
- All user-visible strings in `app_strings.dart`.
- No networking packages — `rrule` package must pass offline dep audit.

---

## Tasks

### 1. Add `rrule` Package

Add `rrule` to `pubspec.yaml` dependencies. Before proceeding:
```powershell
flutter pub get
flutter pub deps --json | Select-String -Pattern "http|socket|firebase|supabase|sentry|crashlytics|analytics|dio|chopper|retrofit|amplitude|mixpanel|datadog"
```
Zero matches required. If `rrule` fails the audit, implement a subset RRULE parser in `lib/core/utils/rrule_utils.dart` covering: FREQ, INTERVAL, BYDAY, BYMONTH, BYMONTHDAY, UNTIL, and COUNT.

### 2. Create `GenerateRecurringTasks` Use-Case (`lib/domain/usecases/generate_recurring_tasks.dart`)

Called on **app startup** (after `RepairOrphanedSegments`).

Logic:
1. Fetch all active recurrence rules via `RecurrenceRuleDao.findActive()`.
2. For each rule:
   a. Parse the RRULE string.
   b. Expand to get all matching dates in range `[today, today + 7 days]`.
   c. For each matching date:
      - NFC-normalise the title.
      - Check if a todo with the same title already exists on that date via `TodoDao.existsTitleOnDate()`.
      - If NOT exists: insert a new `TodoEntity` with:
        - Fresh UUID
        - `status = pending`
        - `recurrence_rule_id = rule.id`
        - `sort_order` = appended at the end (max existing sort_order + 1)
        - `source_date = null`
        - NFC-normalised title and description from the rule template
      - If exists: skip (user may have created/edited/ported the task manually).
3. Wrap all inserts for each rule in a single transaction.
4. Log the number of tasks generated (debug only, not user-visible).

### 3. Integrate Startup Sequence in `main.dart`

After database initialisation, before `runApp`:
```dart
// 1. Repair orphaned segments
await ref.read(repairOrphanedSegmentsProvider).call();
// 2. Generate recurring tasks
await ref.read(generateRecurringTasksProvider).call();
```

Or in the appropriate initialization notifier.

### 4. Recurring Tasks Management Screen (`/recurring`) — `lib/presentation/screens/recurring_tasks/recurring_tasks_screen.dart`

- Lists all recurrence rules (active and paused).
- Each tile shows:
  - Title
  - Human-readable RRULE description (e.g., "Every weekday", "Every Monday and Thursday", "Daily", "Every 3 days", "First Monday of every month")
  - Start date
  - End date (or "No end date")
  - Active/paused toggle switch
- **Tap** a rule → navigates to `/recurring/:id` (edit mode).
- **Swipe to delete** → confirmation dialog ("Delete this recurrence rule? Existing tasks created by this rule will not be affected.").
- **FAB** → navigates to `/recurring/new`.
- Accessible from the main app bar overflow menu on the daily list screen.

### 5. Recurrence Editor Screen (`/recurring/new` and `/recurring/:id`) — `lib/presentation/screens/recurring_tasks/recurrence_editor_screen.dart`

#### Fields:
- **Title** — `TextFormField` with autocomplete (same as create/edit todo). Mandatory.
- **Description** — multiline `TextFormField`, optional.
- **Frequency picker** — segmented control: `Daily`, `Weekly`, `Monthly`, `Yearly`.
- **Interval** — "Every N [days/weeks/months/years]" number field (default 1).
- **Day-of-week picker** (visible for Weekly frequency): toggle buttons for Mon–Sun. Multiple selection allowed.
- **Day-of-month picker** (visible for Monthly frequency):
  - Option A: specific date number (1–31).
  - Option B: ordinal weekday (e.g., "1st Monday", "2nd Wednesday", "Last Friday").
- **Month picker** (visible for Yearly frequency): month dropdown + day-of-month.
- **Start date** — date picker (default: today).
- **End date** — optional date picker, with a "No end date" toggle (default: no end date).
- **Preview section**: shows the **next 5 occurrence dates** based on the current RRULE configuration. Updates dynamically as the user changes settings.
- **Save button**: constructs the RRULE string from the UI fields, validates, and saves.

#### RRULE Construction Examples:
| UI Selection | RRULE String |
|-------------|-------------|
| Daily, interval 1 | `FREQ=DAILY` |
| Every weekday | `FREQ=WEEKLY;BYDAY=MO,TU,WE,TH,FR` |
| Every Mon & Thu | `FREQ=WEEKLY;BYDAY=MO,TH` |
| Every 3 days | `FREQ=DAILY;INTERVAL=3` |
| First Monday of every month | `FREQ=MONTHLY;BYDAY=1MO` |
| Every year on Mar 15 | `FREQ=YEARLY;BYMONTH=3;BYMONTHDAY=15` |
| Daily until Dec 31, 2026 | `FREQ=DAILY;UNTIL=20261231` |

#### Widgets (`lib/presentation/screens/recurring_tasks/widgets/`):
- `rrule_frequency_picker.dart` — segmented control for frequency.
- `rrule_preview.dart` — displays next 5 occurrence dates.

### 6. Recurrence Rules Notifier (`lib/application/`)

Add to `providers.dart`:
```dart
final recurrenceRulesProvider = StateNotifierProvider<RecurrenceRulesNotifier, AsyncValue<List<RecurrenceRuleEntity>>>((ref) {
  return RecurrenceRulesNotifier(ref.read(recurrenceRuleDaoProvider));
});
```

#### `RecurrenceRulesNotifier` methods:
- `loadRules()` — fetch all rules
- `createRule(RecurrenceRuleEntity)` — NFC-normalise title, insert, refresh
- `updateRule(RecurrenceRuleEntity)` — NFC-normalise title, update, refresh
- `deleteRule(String id)` — delete, refresh
- `toggleActive(String id)` — toggle active/paused, refresh

### 7. Visual Indicator on Generated Todos

On the daily list screen (`todo_list_tile.dart`):
- If `todo.recurrenceRuleId != null`, show a small **repeat icon (🔁)** next to the title.
- Tapping the icon navigates to `/recurring/:ruleId` to edit the rule.
- Use an `IconButton` or `GestureDetector` on the icon only — tapping the tile itself still opens the todo editor.

### 8. RRULE ↔ Human-Readable Utility

Create `lib/core/utils/rrule_display_utils.dart`:
- `String describeRrule(String rruleString)` — converts RRULE to human-readable text.
  - `FREQ=DAILY` → "Daily"
  - `FREQ=DAILY;INTERVAL=3` → "Every 3 days"
  - `FREQ=WEEKLY;BYDAY=MO,TU,WE,TH,FR` → "Every weekday"
  - `FREQ=WEEKLY;BYDAY=MO,TH` → "Every Monday and Thursday"
  - `FREQ=MONTHLY;BYDAY=1MO` → "First Monday of every month"
  - etc.

### 9. Integration with Existing Features

- Generated tasks can be: edited, status-changed, time-tracked, copied, ported, deleted — all identical to manual tasks.
- Editing the title of a generated task does NOT affect the rule or future tasks.
- Deleting a generated task does NOT stop the recurrence. The rule will regenerate it on next startup if the date is still in the 7-day window.
- Deleting a recurrence rule: existing generated tasks remain (FK ON DELETE SET NULL sets `recurrence_rule_id` to null).

---

## Tests to Write During This Phase

### Unit Tests — `test/data/recurrence_rule_dao_test.dart`
(May already exist from Phase 2 — extend if needed.)
- Insert, update, delete, findAll, findActive, findById
- `findActive` returns only `active = 1` rules
- Delete rule → verify FK SET NULL on existing todos

### Unit Tests — `test/domain/usecases/generate_recurring_tasks_test.dart`
- Daily rule → generates 8 tasks (today + 7 days)
- Weekly rule (Mon, Thu) → generates correct subset of dates
- Monthly rule → handles month boundaries correctly
- Duplicate detection: rule does NOT regenerate a task that already exists on a date
- Paused rule (`active = 0`) → generates zero tasks
- Rule with `end_date` in the past → generates zero tasks
- Rule with `end_date` within the 7-day window → generates tasks only up to `end_date`
- NFC normalisation: rule title with decomposed characters matches existing todo with composed title

### Widget Tests
- Recurrence editor screen: renders frequency picker, interval field, preview section
- Preview updates when frequency changes
- Save button disabled when title is empty

---

## Constraints
- All strings in `app_strings.dart`.
- NFC-normalise rule titles before any DB write or existence check.
- `rrule` package must pass offline dep audit.
- No business logic in widget files.
- No networking packages.

## Deliverables
- [ ] Recurrence rules can be created, edited, paused, and deleted
- [ ] RRULE editor with frequency picker, day-of-week, preview
- [ ] Tasks auto-generated on app startup for today + 7 days
- [ ] Duplicate detection prevents double-creation
- [ ] Generated tasks visually distinguishable (🔁 icon) but functionally identical
- [ ] Human-readable RRULE descriptions
- [ ] All tests passing
