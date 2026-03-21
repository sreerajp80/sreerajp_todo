# Phase 4 — Time Tracking

## Objective
Implement reliable multi-segment start/stop time tracking per ToDo per day, including manual time entry, orphan repair on startup, and live timer display.

## Pre-Requisites
- Phases 1–3 complete (DB layer, core CRUD, daily list with status changes).
- `TimeSegmentDao` and `TimeSegmentRepository` already created in Phase 2.
- `StartTimeSegment` and `RepairOrphanedSegments` use-cases defined in plan.
- Read `CLAUDE.md` — rules on segments, terminal status lock, one-open-segment constraint.
- Read `docs/architecture.md` — data flow (§6), use-case pattern, provider types (§5).
- Read `docs/flutter_project_engineering_standard.md` — testing standard (§9), coding standards (§8), Definition of Done (§14).

## Key Business Rules (from CLAUDE.md)
1. **One open segment per todo**: at most one `TimeSegmentEntity` with `end_time IS NULL` per `todo_id`. Throw `SegmentAlreadyRunningException` if violated.
2. **Multiple simultaneous timers** across different todos ARE permitted. No global single-timer constraint.
3. **Terminal status lock**: completed/dropped todos cannot have new segments started or existing segments closed. Hide start/stop button entirely (not just disable).
4. **Day lock**: past-date todos cannot have segments started/stopped.
5. **Precision**: `duration_seconds` stored as whole integer (truncated). Display uses `duration_seconds` for consistency.
6. **Orphan repair**: on app startup, close all segments where `end_time IS NULL` and parent `todos.date < today` with `end_time = start_time` (zero duration), `interrupted = 1`.

---

## Tasks

### 1. `StartTimeSegment` Use-Case (`lib/domain/usecases/start_time_segment.dart`)

Orchestration:
1. Load the todo by ID → verify it exists (throw `TodoNotFoundException` if not).
2. Check day lock: `isPastDate(todo.date)` → throw `DayLockedException`.
3. Check terminal status: `todo.status == completed || dropped` → throw `CompletedLockException`.
4. Check no running segment: `TimeSegmentDao.findRunningSegment(todoId)` → throw `SegmentAlreadyRunningException` if found.
5. Insert new `TimeSegmentEntity`:
   - Fresh UUID
   - `todoId`
   - `startTime = DateTime.now().toIso8601String()`
   - `endTime = null`
   - `durationSeconds = null`
   - `interrupted = false`
   - `manual = false`
   - `createdAt = DateTime.now().toUtc().toIso8601String()`

### 2. `RepairOrphanedSegments` Use-Case (`lib/domain/usecases/repair_orphaned_segments.dart`)

Called on app startup (before `GenerateRecurringTasks`):
1. Find all segments where `end_time IS NULL` and the parent todo's `date < today`.
   - Query: join `time_segments` with `todos` on `todo_id`, filter by `end_time IS NULL AND todos.date < ?` where `?` is today's date.
2. For each orphaned segment:
   - Set `end_time = start_time` (zero duration).
   - Set `duration_seconds = 0`.
   - Set `interrupted = 1`.
3. Wrap in a single transaction.
4. Log count of repaired segments (debug only).

### 3. `TimeTrackingNotifier` (`lib/application/time_tracking_notifier.dart`)

Exposed via `StateNotifierProvider.family<TimeTrackingNotifier, TimeTrackingState, String>` where family param = `todoId`.

#### State:
```dart
@freezed
class TimeTrackingState with _$TimeTrackingState {
  const factory TimeTrackingState({
    @Default([]) List<TimeSegmentEntity> segments,
    TimeSegmentEntity? runningSegment,
    @Default(0) int totalDurationSeconds,
    @Default(false) bool isLoading,
    String? error,
  }) = _TimeTrackingState;
}
```

#### Methods:
- `loadSegments(String todoId)` — fetches all segments, finds running one, computes total.
- `startSegment(String todoId)` — calls `StartTimeSegment` use-case, refreshes state.
- `stopSegment(String todoId)` — calls `TimeSegmentDao.closeSegment()`, refreshes state.
- `addManualSegment(TimeSegmentEntity segment)` — validates, inserts, refreshes.

### 4. Live Timer Provider

In `providers.dart`:
```dart
final liveTimerProvider = StreamProvider.family<int, String>((ref, todoId) {
  return Stream.periodic(const Duration(seconds: 1), (count) {
    final state = ref.read(timeTrackingProvider(todoId));
    if (state.runningSegment == null) return state.totalDurationSeconds;
    final runningElapsed = DateTime.now()
        .difference(DateTime.parse(state.runningSegment!.startTime))
        .inSeconds;
    return state.totalDurationSeconds + runningElapsed;
  });
});
```

- Uses `StreamProvider.family` — scoped to only the time display widget to prevent excessive rebuilds.
- Ticks every 1 second.
- Returns total seconds (closed segments + live running segment elapsed).

### 5. Start/Stop Button on List Tile

In `todo_list_tile.dart` (from Phase 3):
- **Start button (▶)**: visible only when `status == pending` AND `date == today` AND no segment running.
- **Stop button (⏹)**: visible only when a segment is running for this todo.
- **Hidden entirely** when `status == completed || dropped` (terminal status lock — hide, don't just disable).
- **Disabled** for past dates.
- Display live elapsed time next to the button when running (formatted HH:MM:SS).
- Display total time in subtitle when not running.

### 6. Time Segments Detail Screen (`/todo/:id/segments`) — `lib/presentation/screens/time_segments/`

#### `time_segments_screen.dart`
- Header: todo title and date.
- **Segments table** showing all segments:

| # | Start | End | Duration | Type |
|---|-------|-----|----------|------|
| 1 | 09:15 | 10:30 | 01:15:00 | Auto |
| 2 | 14:00 | — | running… | Auto |
| 3 | 11:00 | 11:45 | 00:45:00 | Manual (M) |

- **Running segment**: shown with a blinking dot indicator and live elapsed time.
- **Interrupted segments** (`interrupted = 1`): show a warning icon (⚠) and tooltip "Auto-closed on app restart".
- **Manual segments** (`manual = 1`): show an "M" badge.
- **Past-date segments**: read-only (no start/stop controls, no manual entry button).
- **"Add Manual Segment" button**: visible only for today's date AND status = pending.

#### `widgets/manual_segment_form.dart`
- Two `TimePicker` fields: start time, end time.
- Validation:
  - `start < end`
  - No overlap with any existing segment for the same todo.
  - Both times must fall within the todo's calendar date (same day).
- On save:
  - Insert via `TimeSegmentDao.insert()` with both `start_time` and `end_time` pre-filled.
  - `duration_seconds = end - start` in seconds.
  - `manual = 1`.
  - `interrupted = 0`.
- Available only when `status == pending` and `date == today`.

### 7. Stop Running Timer on Status Change

When `MarkTodoCompleted` or `MarkTodoDropped` use-case is called:
- Check for a running segment.
- If found: close it with `end_time = now`, compute `duration_seconds`.
- Then change the status.

This is already specified in Phase 3's use-cases but ensure it's implemented correctly.

### 8. Duration Display Utility

`lib/core/utils/duration_utils.dart` — `formatDuration(int seconds)`:
- Returns `HH:MM:SS` string.
- Handles > 24 hours gracefully (e.g., `25:30:00` not `01:30:00`).
- Zero seconds → `00:00:00`.

---

## Tests to Write During This Phase

### Unit Tests — `test/domain/usecases/start_time_segment_test.dart`
(or extend existing file)
- Start segment on pending today todo → succeeds, creates segment with null end_time.
- Start segment on past-date todo → throws `DayLockedException`.
- Start segment on completed todo → throws `CompletedLockException`.
- Start segment on dropped todo → throws `CompletedLockException`.
- Start segment when one already running → throws `SegmentAlreadyRunningException`.

### Unit Tests — Orphan Repair
- `test/domain/usecases/repair_orphaned_segments_test.dart`:
  - Create segments with null end_time on past-date todos → run repair → verify closed with zero duration and `interrupted = 1`.
  - Today's running segments are NOT repaired.
  - Multiple orphans across different todos → all repaired.

### Unit Tests — Manual Time Entry
- Insert manual segment → verify `manual = 1`, `duration_seconds` computed correctly.
- Overlapping manual segment → rejected (validation logic).
- Manual segment on past-date → rejected.
- Manual segment on completed todo → rejected.

### Widget Tests
- `test/presentation/time_tracking_tile_test.dart`:
  - Start button shown for pending today todo.
  - Stop button shown when segment running.
  - Start/stop hidden for completed todo.
  - Start/stop hidden for past-date todo.
  - Live timer text updates (mock stream).

---

## Constraints
- `StreamProvider` used ONLY for the live timer — nothing else.
- No `compute()` or `Isolate.spawn()` for sqflite queries.
- All user-visible strings in `app_strings.dart`.
- Duration formatted as `HH:MM:SS` everywhere.
- `duration_seconds` is truncated (not rounded).

## Deliverables
- [ ] Start/stop works reliably with live timer display
- [ ] Manual time entry with validation (overlap, day lock, status lock)
- [ ] Completed-status lock hides start/stop button
- [ ] Past-date lock prevents new segments
- [ ] Orphan segment recovery works on app restart
- [ ] Time segments detail screen with all segment types displayed
- [ ] Running segment shown with blinking indicator
- [ ] Interrupted and manual segments visually distinguished
- [ ] All tests passing
