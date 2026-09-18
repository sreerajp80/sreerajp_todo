# Fix Completed Todos Being Brought Forward and Preserve Todo ID Across Carry-Forward Journey

**Status:** Completed

## Problem
1. **Completed Tasks Resurrected on Later Days:**
   When a task is carried forward from an earlier day (e.g., 2026-09-11) to the next day (2026-09-12) and completed on 2026-09-12, the carry-forward logic previously used `CopyTodos`. This created a new todo with a new UUID on 2026-09-12, leaving the original todo on 2026-09-11 with status `pending`.
   On 2026-09-13, the carry-over finder looked back across past days. On 2026-09-12, it saw the task was completed, but did not record the title in `seenTitles`. On 2026-09-11, it found the old pending record and carried it forward to 2026-09-13 as a pending task ("Copied from 2026-09-11").

2. **Todo ID Mutation Across Days:**
   The user highlighted:
   > "carrying a todo to another day should not change the todo ID. The todo Id for a todo should be unique across the app even if it is carried forward. Carry forward means the todo was not completed the previous day, that is also. It is the journey of the same todo."
   
   Using `CopyTodos` mutated the todo ID to a new UUID every time it was carried forward, breaking task identity, separating time segments, and creating orphan duplicates on earlier days.

## Proposed Solution

1. **Carry-Forward Preserves Todo ID via `moveTodo`**:
   - Update automatic carry-over (`DailyListScreen._maybeOfferCarryOver`), `PendingAlertWatcher._evaluateAlertConditions`, `CarryOverSheet._carryOver`, and `RitualSettleStep._carryOver` to use `moveTodo` instead of `copyTodos`.
   - `moveTodo`:
     - Keeps the exact same `todo.id` throughout the task's entire lifecycle.
     - Updates `date` to `targetDate`.
     - Preserves the original `sourceDate` (`todo.sourceDate ?? fromDate`).
     - Logs the move in `todo_history` for full audit trail.
     - Moves the task so no duplicate pending task is left behind on the previous day.
     - Preserves all time segments and subtasks linked to `todo.id`.

2. **Omit Completed / Dropped / Ported Tasks and Deduplicate in Candidate Scans**:
   - In `CarryOverSheet.findAllUnfinishedCandidates`:
     - Initialize `seenTitles` with all tasks on `targetDate` (`nfcNormalize(t.title).trim().toLowerCase()`).
     - Scan backwards from `back = 1` (yesterday) to `lookBackDays`.
     - For each task:
       - Normalize title: `final norm = nfcNormalize(todo.title).trim().toLowerCase()`.
       - If `seenTitles.contains(norm)`, skip it.
       - Always add `seenTitles.add(norm)` so any older instance of this task from prior days is suppressed.
       - Only add to `allUnfinished` if `todo.status == TodoStatus.pending || todo.status == TodoStatus.working`.
   - In `CarryOverSheet.findCandidates`:
     - Apply identical `seenTitles` tracking so completed tasks on yesterday suppress older pending copies on earlier days.
   - In `pendingAlertPayloadProvider`:
     - Apply identical `seenTitles` tracking so completed tasks do not appear in `previousTodos`.

## Files to Change
- `lib/presentation/screens/daily_list/widgets/carry_over_sheet.dart`
- `lib/presentation/screens/daily_list/daily_list_screen.dart`
- `lib/presentation/shared/widgets/pending_alert_watcher.dart`
- `lib/presentation/screens/ritual/widgets/ritual_settle_step.dart`
- `lib/application/providers.dart`
- `test/presentation/daily_list/carry_over_completed_test.dart` (new test file)

## Verification Plan
1. Run `flutter test test/presentation/daily_list/carry_over_completed_test.dart`
2. Run full test suite: `flutter test`
3. Run static code analysis: `flutter analyze`
