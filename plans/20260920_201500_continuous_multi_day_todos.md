# Continuous Multi-Day Active Tasks Specification & Implementation Plan

**Status:** Completed

## Problem & Feature Goal

Currently, tasks in the app belong to a single date (`date` column). When an unfinished task was carried forward via `moveTodo`, its date was changed to the new date. As a result:
1. The task vanished from the earlier date where it was created or worked on.
2. If it was not carried forward, it remained stuck in the past under "Day Lock" and did not appear on subsequent days unless manually copied (which created duplicate task IDs) or moved.

The user clarified the desired design:
> *"By jumping I did not mean to move. It will be shown in 20th Sep 2026 as partially done or not done. It will also be shown on next day, the day after next day until it is completed or user manually discards or marks as completed."*

### Key Requirements

1. **Continuous Multi-Day Visibility:**
   - A task created on Date A that remains uncompleted (`pending` or `working`) automatically appears on Date A, Date A+1, Date A+2... up until the day it is marked `completed` or `dropped`.
   - On past days (e.g. Sept 20), the task displays its state on that day (e.g., `pending` or `working` with only Sept 20's recorded time).
   - On today (e.g. Sept 21), it appears active, showing today's time.

2. **Time Details with Two Tabs:**
   - When tapping into the task's time details:
     - Tab 1: **Today's Time Details** (shows only segments and total time recorded today).
     - Tab 2: **Full Task Time Details** (shows all segments and total cumulative time across all days).

3. **Cumulative Target Duration:**
   - The target duration (e.g. 60 minutes) is **total** across all days.
   - The UI shows total progress toward the target (e.g., `45m / 60m total · 15m today`).
   - When the cumulative elapsed time reaches the target duration, the user is alerted.

4. **Multi-Day Title Uniqueness Validation:**
   - If a user edits/renames the task title on the current day, the uniqueness check must verify that the new title is unique on **all dates** where this task was active.
   - If a clash is found on any of those dates, the rename is blocked and an alert is shown: *"A task with this title already exists on [Date]. Please choose a different title."*

5. **Safe Deletion with Prompt:**
   - If the user deletes an active task that has recorded time segments on past days, the app asks:
     > *"This task has recorded time on past days. Do you want to remove it only from today or delete its entire history?"*
     - **Remove from today only:** Closes/drops the task from today forward, preserving past historical logs and time segments intact.
     - **Delete entire history:** Completely deletes the task and all associated time segments from the database.

---

## Technical & Architectural Design

### 1. Data Layer & Schema

#### Approach for Multi-Day Task Life-Cycle:
To ensure past days show accurate historical snapshots while today shows the live active task:
* `todos` table tracks:
  * `source_date` / `start_date`: The original date the task was created (e.g., `2026-09-20`).
  * `completed_date`: The date when the task was finished or dropped (NULL while active).
  * `date`: The current active date for the task.
* In SQLite queries for a given `date`:
  * For **past dates** (`date < today`): A task is displayed if:
    * It had time segments on that date, OR
    * It was created on or before that date and was not completed/dropped before that date.
    * The displayed elapsed time on that past date is computed specifically for that date: `SUM(duration_seconds)` of segments whose `start_time` falls on that date.
    * The status shown for that past date is `pending` or `working` (it was not yet completed on that date).
  * For **today**:
    * All tasks with `date == today`, PLUS all active tasks where `source_date <= today` and `status IN ('pending', 'working')`.
    * `todayElapsedSeconds`: `SUM(duration_seconds)` for segments recorded today.
    * `totalElapsedSeconds`: `SUM(duration_seconds)` across all segments for this task ID.

### 2. Time Details Screen / Sheet
* Updated `TimeSegmentsScreen` (or details sheet) with a `TabBar` containing:
  * Tab 1: **Today** (`context.l10n.timeDetailsTabToday`). Shows today's segments and today's total.
  * Tab 2: **All Time / Full History** (`context.l10n.timeDetailsTabAllTime`). Shows segments grouped by date and the grand total.

### 3. Target Duration Progress & Alert
* The task tile progress bar calculates percentage based on `totalElapsedSeconds / targetSeconds`.
* Secondary text or tooltip displays: `Xm / Ym total (Zm today)`.
* When `totalElapsedSeconds >= targetSeconds`, a target reached notification / badge is shown.

### 4. Title Uniqueness Validation
* When updating a task's title:
  * Check active date range `[source_date ... today]`.
  * If `existsTitleOnDate(newTitle, date, excludeId: id)` is true for any date in that range, throw `MultiDayDuplicateTitleException(conflictingDate)`.
  * UI catches this exception and presents an alert dialog to the user.

### 5. Deletion Flow
* In `DailyTodoNotifier.deleteTodo(id)`:
  * Check if the task has time segments on dates prior to today.
  * If yes, display confirmation dialog with two choices:
    1. "Remove from today only" (marks ported/dropped from today onwards, preserves past).
    2. "Delete entire history" (hard delete `todos` and `time_segments`).

---

## Files to Change

| Layer | File Path | Proposed Change |
|-------|-----------|-----------------|
| **Data (DAO)** | `lib/data/dao/todo_dao.dart` | Update `findByDate` to query multi-day active tasks; add title uniqueness check across date range. |
| **Data (DAO)** | `lib/data/dao/time_segment_dao.dart` | Add methods to get elapsed seconds for a task on a specific date vs total lifetime. |
| **Data (Repo)** | `lib/data/repositories/todo_repository_impl.dart` | Implement multi-day title check and date-specific status/time resolution. |
| **Domain (Repo)** | `lib/domain/repositories/todo_repository.dart` | Add title check across date ranges and multi-day deletion options. |
| **Domain (Exceptions)** | `lib/core/errors/exceptions.dart` | Add `MultiDayDuplicateTitleException(String conflictingDate)`. |
| **Application** | `lib/application/daily_todo_notifier.dart` | Support multi-day loading, delete options (today only vs all), title collision alert handling. |
| **Presentation (Widgets)** | `lib/presentation/screens/daily_list/widgets/todo_tile.dart` | Display today's time vs total time; cumulative target duration indicator. |
| **Presentation (Screens)** | `lib/presentation/screens/time_segments/time_segments_screen.dart` | Add Two-Tab view: Today's Time Details vs Full Task Time Details. |
| **Presentation (Dialogs)** | `lib/presentation/screens/daily_list/widgets/delete_task_dialog.dart` | Add dialog for "Remove from today only" vs "Delete entire history". |
| **Localization** | `lib/l10n/app_en.arb`, `app_ml.arb`, `app_sa.arb` | Add all localized strings across English, Malayalam, and Sanskrit with strict key parity. |
| **Tests** | `test/domain/` & `test/presentation/` | Add comprehensive unit, DAO, and widget tests. |

---

## Verification Plan

### Automated Tests
1. `flutter test test/data/dao/todo_dao_test.dart`
2. `flutter test test/data/repositories/todo_repository_test.dart`
3. `flutter test test/presentation/screens/time_segments/`
4. `flutter test` (full suite)
5. `flutter analyze` (must be 0 warnings)

### Manual Verification
1. Create a task on Sept 20, log 15 minutes, leave it incomplete.
2. Advance to Sept 21: verify it appears on Sept 21 with 0m today and 15m total.
3. Open Time Details on Sept 21: verify Tab 1 (Today: 0m) and Tab 2 (All Time: 15m).
4. Log 10 minutes on Sept 21: verify today shows 10m, total shows 25m.
5. Go back to Sept 20 in calendar: verify Sept 20 shows the task as pending with only 15m.
6. Try renaming on Sept 21 to a title that already existed on Sept 20: verify alert dialog blocks it.
7. Tap Delete on Sept 21: verify dialog asks "Remove from today only" vs "Delete entire history".
