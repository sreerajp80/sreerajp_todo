# Edit start/end time of segments on completed tasks

**Status:** completed

## The ask

The user wants to be able to edit the start time and end time of time segments that belong to
a **completed** (or dropped) task. The edit must:

1. Show up in the task history timeline.
2. Leave a permanent mark on the edited segment, so the user can see that this time slot was
   changed *after* the task was finished.

## The issue today

* `TimeSegmentRepositoryImpl.updateSegmentTimes` calls `_checkTerminalStatus`, so any segment on a
  `completed` or `dropped` todo throws `CompletedLockException`. Editing is blocked.
* The UI (`_SegmentTile._canEditTimes`) also hides the tap-to-edit time control when the todo is
  terminal.
* A segment row has no field that records "this was edited after the task was completed", so even
  if the edit were allowed there would be nothing to show in the list.
* The history event written on a time edit is generic ("Segment times updated (Ns)"); it does not
  say what the old times were, and does not say the task was already finished.

## Decisions already agreed

* **Day lock stays.** Only todos dated **today** can have their segment times edited. A completed
  todo on a past day is still read-only and still throws `DayLockedException`. Hard rule 3 is
  untouched.
* Scope is **editing existing segments only**. Adding a new manual segment to a completed task
  stays blocked, and the terminal-status lock stays in place for starting timers and for manual
  entry. Only `updateSegmentTimes` is relaxed.

## The plan

### 1. Database — new migration V11

New file `lib/data/database/migrations/migration_v11.dart`.

Add two columns to `time_segments` (guarded with a `PRAGMA table_info` check, same style as
`migration_v8.dart`, so a re-run is safe):

| Column | Type | Meaning |
|--------|------|---------|
| `edited_after_completion` | `INTEGER NOT NULL DEFAULT 0` | 1 once the times were changed while the parent todo was completed or dropped |
| `times_edited_at` | `TEXT` | ISO 8601 UTC timestamp of the last time edit (set for every time edit, finished or not) |

Register it in `lib/data/database/migrations/migration_runner.dart` and bump
`kDatabaseVersion` from 10 to 11 in `lib/core/constants/app_constants.dart`.

### 2. Model

`lib/data/models/time_segment_entity.dart`:

* Add `@Default(false) bool editedAfterCompletion` and `String? timesEditedAt`.
* Map them in `toMap()` / `fromMap()`. `fromMap` must tolerate a missing or NULL column
  (`(map['edited_after_completion'] as int?) == 1`) because QR hand-off and Wi-Fi sync payloads
  built by an older build will not carry the field.
* Re-run `dart run build_runner build --delete-conflicting-outputs`.

### 3. DAO

`lib/data/dao/time_segment_dao.dart` — `updateTimes` gains two named parameters:

```dart
Future<void> updateTimes(
  String segId,
  DateTime newStart,
  DateTime newEnd, {
  bool markEditedAfterCompletion = false,
  DateTime? editedAt,
})
```

It writes `times_edited_at` always, and sets `edited_after_completion = 1` only when
`markEditedAfterCompletion` is true. The flag is **sticky**: it is never reset back to 0, so a
later edit made while the task is open cannot erase the mark.

### 4. Repository

`lib/data/repositories/time_segment_repository_impl.dart` — `updateSegmentTimes`:

* **Remove** the `_checkTerminalStatus(todo.status)` call (in this method only).
* Keep the day-lock check, the "running segment must be stopped first" check, the
  start-before-end check, and the overlap check exactly as they are.
* Compute `isTerminal = status == completed || status == dropped` and pass
  `markEditedAfterCompletion: isTerminal` to the DAO.
* Write a richer history event (`TodoHistoryEventType.edited`) whose description names the old and
  the new window, and says so when the task was already finished, for example:

  `Segment time edited after completion: 09:00 -> 10:00 changed to 09:15 -> 10:30 (01:15:00)`

  and for an open task the same line without "after completion". Metadata JSON keeps
  `segment_id`, `old_start`, `old_end`, `new_start`, `new_end`, `duration_seconds`,
  `after_completion`.

The interface doc comment in `lib/domain/repositories/time_segment_repository.dart` is updated to
say the terminal-status lock does not apply here, and why.

### 5. UI — time segments screen

`lib/presentation/screens/time_segments/time_segments_screen.dart`:

* `_canEditTimes` becomes `!isRunning && !isPast && segment.endTime != null` (drop `!isTerminal`).
* Add an "Edited" chip next to the existing type badge when `segment.editedAfterCompletion` is
  true, using a colour that stands out, wrapped in a `Tooltip` that reads
  "Edited after the task was completed" plus the local `times_edited_at` date and time.
* Include the edited state in the tile's `Semantics` label so a screen reader announces it.

### 6. UI — task history screen

`lib/presentation/screens/task_history/task_history_screen.dart`: no structural change needed —
the `edited` event type already has an icon and a colour, and the new description text flows
through the existing timeline tile.

### 7. Strings

`lib/l10n/app_en.arb` and `lib/l10n/app_ml.arb` gain:

* `segmentEditedBadge` — "Edited"
* `segmentEditedAfterCompletionTooltip` — "Edited after the task was completed"
* `segmentEditedOn` — parameterised, "Edited on {when}"

The history description is built in the data layer, which cannot reach `l10n`, so those templates
stay plain-English strings created in the repository (the same as the existing
"Segment times updated (Ns)" text). The new ARB keys cover only the UI badge and tooltip.

### 8. Tests

* `test/data/migration_v11_test.dart` (new) — a v10 database upgraded to v11 gains both columns,
  existing rows default to 0 and NULL, and running the migration twice is safe.
* `test/data/time_segment_dao_test.dart` — `updateTimes` sets `times_edited_at`, sets
  `edited_after_completion` only when asked, and never clears it once set.
* Repository test under `test/domain/` (new or extended) — editing a segment on a **completed**
  todo dated today succeeds, marks the segment, and writes one `edited` history row; editing a
  segment on a completed todo dated **yesterday** still throws `DayLockedException`; overlap and
  start-after-end still throw.

### 9. Verify

Run `flutter analyze` (0 issues) and `flutter test`, then `dart format lib/ test/`.

## Files to change

| File | Change |
|------|--------|
| `lib/core/constants/app_constants.dart` | `kDatabaseVersion` 10 to 11 |
| `lib/data/database/migrations/migration_v11.dart` | new — add the two columns |
| `lib/data/database/migrations/migration_runner.dart` | run V11 |
| `lib/data/models/time_segment_entity.dart` | two new fields plus map/unmap |
| `lib/data/dao/time_segment_dao.dart` | `updateTimes` writes the new columns |
| `lib/data/repositories/time_segment_repository_impl.dart` | drop terminal lock here, mark segment, richer history event |
| `lib/domain/repositories/time_segment_repository.dart` | doc comment update |
| `lib/presentation/screens/time_segments/time_segments_screen.dart` | allow edit when terminal, show "Edited" badge |
| `lib/l10n/app_en.arb`, `lib/l10n/app_ml.arb` | new strings |
| `test/data/migration_v11_test.dart` | new |
| `test/data/time_segment_dao_test.dart` | new cases |
| `test/domain/` time segment repository test | new cases |

## Risks

* **Statistics change.** Editing a completed task's segment changes that day's totals. This is
  intended, and the badge plus the history row make it traceable.
* **Backup and hand-off compatibility.** A backup made by an older build has no
  `edited_after_completion` column; the migration adds it with a default, and `fromMap` treats a
  missing key as false, so restore keeps working. A backup made by this build restored on an older
  build is already blocked by the existing `BackupVersionTooNewException` check.
