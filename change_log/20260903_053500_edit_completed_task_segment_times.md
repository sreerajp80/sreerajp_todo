# Edit start/end time of segments on completed tasks

Implements `plans/20260903_052015_edit_completed_task_segment_times.md`.

## What changed

The start and end time of a recorded time slot can now be corrected on a task that is already
**completed** or **dropped**. Every such edit is written to the task history and leaves a
permanent "Edited" mark on the slot.

### Database

* New `lib/data/database/migrations/migration_v11.dart` adds two columns to `time_segments`:
  * `edited_after_completion` (`INTEGER NOT NULL DEFAULT 0`) — set to 1 when the times were
    changed while the parent task was completed or dropped. The mark is sticky and is never
    cleared again.
  * `times_edited_at` (`TEXT`) — ISO 8601 UTC stamp of the last time edit, written for every
    time edit whether the task was finished or not.
* Both columns are added only when missing, so the migration can be re-run safely.
* Registered in `migration_runner.dart`; `kDatabaseVersion` raised from 10 to 11 in
  `lib/core/constants/app_constants.dart`.

### Model

* `TimeSegmentEntity` gained `editedAfterCompletion` (default false) and `timesEditedAt`.
* `fromMap` reads them defensively, so a backup or a QR / Wi-Fi hand-off payload made by an older
  build still loads.

### Data access

* `TimeSegmentDao.updateTimes` takes two new named parameters, `markEditedAfterCompletion` and
  `editedAt`. It always stamps `times_edited_at`, and only ever sets `edited_after_completion`
  to 1 — it never writes 0 back.

### Repository

* `TimeSegmentRepositoryImpl.updateSegmentTimes` no longer calls `_checkTerminalStatus`, so a
  completed or dropped task is editable. Every other guard is unchanged: day lock, "stop the
  running timer first", start-before-end, and the overlap check.
* The task-history entry it writes is now specific, for example:

  `Segment time edited after completion: 09:00 -> 10:00 changed to 09:15 -> 10:30 (01:15:00)`

  For a task that is still open the same line is written without "after completion". The metadata
  JSON carries `segment_id`, `old_start`, `old_end`, `new_start`, `new_end`, `duration_seconds`
  and `after_completion`.
* The interface doc comment in `lib/domain/repositories/time_segment_repository.dart` now explains
  why the terminal-status lock does not apply to this one method.

### User interface

* `time_segments_screen.dart`: the tap-to-edit time control is shown for completed and dropped
  tasks as well. It is still hidden for a running segment and for a past day.
* A red "Edited" chip appears next to the Auto/Manual badge on any slot marked
  `editedAfterCompletion`. Its tooltip reads "Edited after the task was completed" and gives the
  local date and time of the edit. The tile's accessibility label mentions it too.
* The now-unused `isTerminal` parameter was removed from the segment tile widget.
* The task history screen needed no change — the existing `edited` timeline entry carries the new
  text.

### Strings

* `lib/l10n/app_en.arb` and `lib/l10n/app_ml.arb` gained `segmentEditedBadge`,
  `segmentEditedAfterCompletionTooltip` and `segmentEditedOn`.

## Rules kept

* **Day lock (hard rule 3) is untouched.** Only tasks dated today can have their segment times
  edited. A completed task on a past day still throws `DayLockedException`.
* **Terminal status lock (hard rule 4) still applies everywhere else.** Starting a timer on a
  finished task and adding a new manual slot to it are still blocked; only correcting an existing
  slot is allowed.
* The one-open-segment rule is unchanged: a running segment must be stopped before its times can
  be edited.

## Tests

* New `test/data/migration_v11_test.dart` — the columns are added, old rows default to not
  edited, the migration is idempotent, and a fresh database reports version 11.
* `test/data/time_segment_dao_test.dart` — three new cases: the edit stamp is written, the
  after-completion mark is set only when asked, and the mark is never cleared by a later edit.
* New `test/domain/usecases/edit_segment_times_test.dart` — editing on a completed and on a
  dropped task marks the slot; exactly one history row is written with the old and new window;
  an open task gets the plain description; a past day still throws `DayLockedException`;
  overlapping and reversed times are still refused.
* `test/data/migration_v10_test.dart` — the fresh-database check now compares against
  `kDatabaseVersion` instead of the literal 10.

## Verification

* `flutter analyze` — no issues found.
* `flutter test` — 645 tests, all passed.
* `dart format lib/ test/ integration_test/` applied.
