# Recurring todos keep priority, target time and sub-tasks

Plan: [plans/20260928_092501_recurring_todo_keep_priority.md](../plans/20260928_092501_recurring_todo_keep_priority.md)

## Problem

A recurring todo showed its priority only on the first day. The days made
later by the recurring task generator used the default "Normal" priority.
Target time and sub-tasks were lost in the same way.

## What changed

- `lib/domain/usecases/generate_recurring_tasks.dart`
  - For each rule, the generator now loads the todos the rule already made and
    uses the latest one as a template.
  - New days copy the template's `priority`, `targetSeconds` and sub-tasks.
  - Copied sub-tasks get new ids, point to the new todo, and start as not
    completed. The original todo's sub-tasks are not changed.
  - If the rule has no todos yet, the old defaults are used (normal priority,
    no target time, no sub-tasks).
  - No database change or migration was needed.
- `test/domain/usecases/generate_recurring_tasks_test.dart`
  - New test: generated days copy priority, target time and sub-tasks
    (reset to not completed, new ids, linked to the new todo).
  - New test: with no existing instance, defaults are used.

## Checks

- `dart format`: done.
- `flutter analyze`: no issues.
- `flutter test`: all 817 tests passed.

## Note

Todos generated before this fix keep their old (wrong) values. Edit one of them
and choose "this and future" or "all instances" to fix them.
