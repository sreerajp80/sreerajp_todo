# Fix Completed Todos Being Brought Forward and Preserve Todo ID Across Carry-Forward Journey

## Summary
Fixed the issue where completed tasks from previous days were brought forward into subsequent days, and ensured that carrying forward a task preserves its unique Todo ID across its entire journey.

## Reference
Plan: [plans/20260916_071000_fix_completed_todos_carried_forward.md](plans/20260916_071000_fix_completed_todos_carried_forward.md)

## Changes Made

1. **Preserve Todo ID and Move Tasks Instead of Copying During Carry-Forward**:
   - Updated `CarryOverSheet._carryOver` (`lib/presentation/screens/daily_list/widgets/carry_over_sheet.dart`) to move each selected todo to `targetDate` via `moveTodo` instead of creating new duplicates with `copyTodos`.
   - Updated automatic carry-over in `DailyListScreen._maybeOfferCarryOver` (`lib/presentation/screens/daily_list/daily_list_screen.dart`) to move candidate todos to `today` via `moveTodo`.
   - Updated `PendingAlertWatcher` (`lib/presentation/shared/widgets/pending_alert_watcher.dart`) auto carry-over execution to move candidate todos to `today` via `moveTodo`.
   - Updated `RitualSettleStep._carryOver` (`lib/presentation/screens/ritual/widgets/ritual_settle_step.dart`) to move leftover tasks to the target day via `moveTodo`.
   - Moving a task preserves the unique `todo.id`, retains all associated time segments and subtasks, logs movement in `todo_history`, and ensures no duplicate pending task is left behind on the previous day.

2. **Omit Completed / Dropped / Ported Tasks in Candidate Scanners**:
   - Updated `CarryOverSheet.findAllUnfinishedCandidates`:
     - Populates `seenTitles` with all tasks existing on `targetDate` using NFC-normalized lowercase titles (`nfcNormalize(t.title).trim().toLowerCase()`).
     - Scans backwards day by day from yesterday up to `lookBackDays`.
     - Skips any task whose title is already present in `seenTitles`.
     - Always records seen titles in `seenTitles`.
     - Adds a task to `allUnfinished` only if its status is `pending` or `working`. Completed, dropped, or ported tasks are omitted and their titles recorded, suppressing any older pending duplicates from earlier days.
   - Updated `CarryOverSheet.findCandidates` with identical `seenTitles` tracking.
   - Updated `pendingAlertPayloadProvider` (`lib/application/providers.dart`) with `seenTitles` tracking across previous days so completed or dropped tasks do not show up as pending alerts.

3. **Automated Tests**:
   - Added `test/presentation/daily_list/carry_over_completed_test.dart` covering:
     - Completed tasks on a more recent day are never included in carry-over candidates.
     - Moving a task preserves its unique Todo ID, updates its date, and leaves no duplicate on the previous day.
     - Completed tasks cannot be carried over to future days.
     - Days where all tasks were completed do not cause older pending versions to be returned.
     - Dropped tasks are not resurrected from older days.
     - Pending alert payload omits completed tasks.

## Verification
- `flutter test test/presentation/daily_list/carry_over_completed_test.dart`: All 5 new tests passed.
- `flutter test`: All 747 tests passed with 0 errors.
- `flutter analyze`: Passed with 0 issues.
- `dart format`: Applied to modified files.
