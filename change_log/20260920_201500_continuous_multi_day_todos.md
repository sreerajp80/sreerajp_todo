# Change Log: Continuous Multi-Day Active Tasks & Time Details

**Plan:** [plans/20260920_201500_continuous_multi_day_todos.md](plans/20260920_201500_continuous_multi_day_todos.md)
**Date:** 2026-09-20

## Summary of Changes

Implemented continuous multi-day visibility for tasks, two-tab time details (Today vs Full History), multi-day title conflict validation, and historical-aware task deletion.

### 1. Core & Domain Layers
- **Exceptions (`lib/core/errors/exceptions.dart`):**
  - Added `MultiDayDuplicateTitleException(final String conflictingDate)` to signal title collisions on any date where an active multi-day task exists.
- **Error Mapping (`lib/core/errors/error_message_mapper.dart`):**
  - Mapped `MultiDayDuplicateTitleException` to localized message `l10n.multiDayDuplicateTitleAlert(e.conflictingDate)`.
- **Repository Contracts (`lib/domain/repositories/`):**
  - Added `getElapsedSecondsOnDate(todoId, date)`, `getTotalElapsedSeconds(todoId)`, and `hasSegmentsBeforeDate(todoId, date)` to `TimeSegmentRepository`.
  - Added `findConflictingDateForTitle(title, fromDate, toDate, {excludeId})` and `deleteTodoFromDate(id, date, {bypassLock})` to `TodoRepository`.

### 2. Data Layer
- **DAOs (`lib/data/dao/`):**
  - `TodoDao.findByDate(date)`: Enhanced query to match tasks active on `date` (`date = ?` OR `source_date <= ? AND date >= ?` OR segments on `date`). Accurately projects historical status on past days before completion.
  - `TodoDao.findConflictingDateForTitle(...)`: Scans dates between `fromDate` and `toDate` for title uniqueness collisions.
  - `TimeSegmentDao`: Implemented `getElapsedSecondsForTodoOnDate`, `getTotalElapsedSecondsForTodo`, and `hasSegmentsBeforeDate`.
- **Repository Implementations (`lib/data/repositories/`):**
  - `TodoRepositoryImpl.updateTodo`: Validates title uniqueness across all dates where the task existed (`sourceDate` through `date`). Throws `MultiDayDuplicateTitleException` if a clash occurs.
  - `TodoRepositoryImpl.deleteTodoFromDate`: Closes task on previous day (`status = dropped`) when user chooses to drop from today only, preserving historical time logs and daily entries.
  - `TimeSegmentRepositoryImpl`: Implemented segment duration calculations and past history checks.

### 3. Localization
- **ARB files (`lib/l10n/`):**
  - Added 9 localized keys across English (`app_en.arb`), Malayalam (`app_ml.arb`), and authentic classical Sanskrit (`app_sa.arb`):
    - `timeDetailsTabToday`
    - `timeDetailsTabAllTime`
    - `multiDayDuplicateTitleAlert`
    - `deleteMultiDayTaskTitle`
    - `deleteMultiDayTaskMessage`
    - `deleteFromTodayOnly`
    - `deleteEntireHistory`
    - `targetReachedBadge`
    - `todayAndTotalTime`
  - Fully verified 100% key parity, zero nuktas, and zero Hindi markers in Sanskrit quality tests.

### 4. Application & Presentation Layers
- **Notifier (`lib/application/daily_todo_notifier.dart`):**
  - Added `deleteTodoFromDate(todoId, date, {bypassLock})`.
  - Rethrows `MultiDayDuplicateTitleException` for UI alert display.
- **Delete Choice Dialog (`lib/presentation/screens/daily_list/widgets/delete_task_choice_dialog.dart`):**
  - Dialog prompts user when deleting a task with historical time records: "Remove from today only" (preserves past history) vs "Delete entire history".
- **Daily List Screen (`lib/presentation/screens/daily_list/daily_list_screen.dart`):**
  - Checks `hasSegmentsBeforeDate` during delete action and launches `DeleteTaskChoiceDialog` when history exists.
- **Time Segments Screen (`lib/presentation/screens/time_segments/time_segments_screen.dart`):**
  - Replaced single list view with a two-tab interface (`Today` vs `All Time`).
  - Added time summary banner showing today's time, full lifetime time, and cumulative target duration badge (`Target reached!`).
- **Todo List Tile (`lib/presentation/screens/daily_list/widgets/todo_list_tile.dart`):**
  - Displays formatted time chip showing today's elapsed time and lifetime total elapsed time (`HH:MM:SS / HH:MM:SS`) when multi-day history exists.
  - Shows target reached badge when total elapsed time meets or exceeds target duration.

### 5. Verification & Tests
- Added `test/data/multi_day_continuous_todo_test.dart` covering multi-day persistence, temporal status projection, two-tab segment queries, multi-day title clash detection, and safe deletion.
- Updated unit and widget test repository fakes to support new methods.
- Executed `flutter analyze`: 0 issues found.
- Executed `flutter test`: 784/784 tests passed across all suites.
