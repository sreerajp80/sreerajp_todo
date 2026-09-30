# Keep priority on every day of a recurring todo

**Status:** completed

## The issue

When the user creates a recurring todo with a priority (for example "High"),
only the first day shows that priority. The copies made for the next days show
the default "Normal" priority.

Why it happens:

- The first day's todo is saved from the create screen with the chosen priority.
- The next days are made by `GenerateRecurringTasks`
  (`lib/domain/usecases/generate_recurring_tasks.dart`). It builds each new
  `TodoEntity` using only the rule's title and description. It never sets
  `priority`, so the default (`normal`) is used.
- The recurrence rule table (`recurrence_rules`) has no priority column, so the
  generator has nowhere to read it from.

The same gap also drops the **target time** (`targetSeconds`) on later days.

## The fix

Target layer: **Domain** (use case). No database change is needed.

In `GenerateRecurringTasks`, for each rule, look up the todos already created
for that rule (`getTodosByRecurrenceRuleId`, already exists and is ordered by
date). Use the **latest** existing instance as a template and copy its
`priority`, `targetSeconds` and sub-tasks into each new day's todo. If there is no
instance yet, keep the current defaults.

Why the latest instance: when the user edits "this and future" or "all"
instances, the new priority is written to the existing instances, so the latest
one always holds the most recent choice. This avoids adding a new database
column and a migration.

Sub-tasks are copied too (user asked for this on approval). Each copied
sub-task gets a new id, points to the new todo, and starts as not completed.

## Files to change

1. `lib/domain/usecases/generate_recurring_tasks.dart` — read the latest
   instance per rule and copy `priority`, `targetSeconds` and sub-tasks into new todos.
2. `test/domain/usecases/generate_recurring_tasks_test.dart` — add tests:
   - new instances copy priority, target time and sub-tasks (not completed) from the existing instance;
   - with no existing instance, defaults (`normal`, no target, no sub-tasks) are used.
3. `change_log/<timestamp>_recurring_todo_keep_priority.md` — change log.

## Checks

- `dart format`, `flutter analyze` (0 issues), `flutter test`.

## Note for existing data

Todos that were already generated with the wrong priority will not change by
themselves. The user can fix them by editing one instance and choosing
"this and future" or "all instances".
