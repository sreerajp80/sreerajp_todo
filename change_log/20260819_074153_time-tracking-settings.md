# Change Log — Time Tracking Settings

Implements `plans/20260818_230155_time-tracking-settings.md`.

Version moved from `1.9.3+18` to `1.10.0+19`.

## What changed

Settings had only five entries, and everything about how the timer behaved was fixed in
code. There is now a **Settings → Time tracking** hub with nine settings, plus the timer
behaviour each one drives.

Every default reproduces the behaviour the app had before, so a user who never opens the
new page sees no change at all.

### 1. Auto-stop the timer

Never (default), at midnight, or at a time the user picks.

This also fixes a real bug. Before, a timer left running past midnight was closed with
**zero** length on the next launch, so the work time was simply lost. With auto-stop on,
the segment is now closed at the cut-off that followed its start, keeping the real time.
An end time is never written into the future, so a clock that moved backwards cannot
invent time.

While the app is open a single timer fires at the cut-off. While the app is closed nothing
can fire, so the next launch corrects it. This limit is stated on the settings page.

### 2. Pause and resume

Chosen instead of idle detection, which an offline Flutter app cannot do honestly.

A **Pause** button now sits beside Stop on the day tile and on the Time Segments screen.
Pause closes the running segment exactly like Stop, so time already worked is kept and the
one-open-segment-per-todo rule still holds. Resume opens a fresh segment and the total is
the sum. **No database migration was needed.**

The paused mark is screen state, not user data, so it is held in `SharedPreferences` for
the current day only and kept out of the database, backups and sync. It is cleared on
resume, on stop, when the task becomes completed or dropped, and when the day rolls over.
A "Paused" badge on the tile makes the Resume button unsurprising.

An optional **Pause when the app is closed** switch (default off) pauses a running timer as
the app leaves the foreground.

### 3. Only one timer at a time

Default off, which is today's behaviour. When on, starting a timer stops any timer running
on another task first and a SnackBar says how many were stopped. The rule lives in the
`StartTimeSegment` use case rather than a widget, so every path obeys it. Other timers are
stopped only after the new one has passed every check, so a refused start never leaves the
user with their previous timer stopped for nothing.

### 4. Rounding in reports

Exact (default), nearest minute, nearest 5, or nearest 15.

**Display only.** Stored segment seconds are never rewritten.

### 5. Shortest segment to keep

Off (default), 10s, 30s, 1 minute, or 5 minutes. Applies only when the user stops or pauses
a live timer; a shorter segment is deleted rather than saved, with a 5 second SnackBar and
an **Undo** button, matching the undo pattern used elsewhere.

Never applies to manual entries, imports or restored backups. Deliberately skipped by
auto-stop as well: the user did not end that segment, so their work is never silently
thrown away.

### 6. Pomodoro

Default off. Work block (25 min), short break (5), long break (15), long break after 4 work
blocks, and start-the-next-block-on-its-own. Lengths are set with steppers rather than free
text, so a length can never be left empty or set to something the engine cannot run.

`PomodoroNotifier` owns the cycle and calls back into `TimeTrackingNotifier` to start and
stop segments, so no database work happens inside the engine. The running block and its
countdown show on the Time Segments screen.

**Stated limit:** the alert is in-app only. This app sends no notifications, so a block
that ends while the app is closed or in the background makes no sound. The elapsed time is
still counted correctly on return, via `syncWithClock()`. This is written on the settings
page and in `docs/features.md`, not hidden.

### 7. Keep the screen on

Default off, Android only. Done with a small `MethodChannel`
(`in.sreerajp.todo/screen_wake`) beside the existing database-key channel, which sets and
clears `FLAG_KEEP_SCREEN_ON`. **No new package**, so the audited dependency list is
unchanged. The flag is cleared in `onDestroy()` and whenever no timer is running. The
switch is hidden on other platforms rather than shown doing nothing.

### 8. Manual entry length

15 min, 30 min, 1 hour (default), or 2 hours. Picking a start time now fills the end time
that far ahead, stopping at 23:59 rather than crossing midnight. The user can still change
it. Before, the form always opened at a fixed 09:00 to 10:00.

### 9. How times are written

`HH:MM:SS` (default), `HH:MM`, or decimal hours. A **running** timer always keeps its
seconds, whatever the setting, because a live clock that jumps a minute at a time reads as
broken.

## Files added

| File | Purpose |
|------|---------|
| `lib/core/utils/time_tracking_rules.dart` | Pure Dart: setting enums, rounding, minimum-length check, next auto-stop instant, orphan close time. No Flutter imports |
| `lib/core/platform/screen_wake_channel.dart` | Dart side of the keep-awake channel; a safe no-op off Android |
| `lib/application/time_tracking_settings_notifier.dart` | All nine settings, their `SharedPreferences` keys, and range guards |
| `lib/application/pomodoro_notifier.dart` | Work / break cycle with an injectable clock and alert |
| `lib/application/timer_paused_store.dart` | `TimerPausedStore` and `PausedTodosNotifier` |
| `lib/presentation/screens/settings/time_tracking_screen.dart` | The hub |
| `lib/presentation/screens/settings/time_tracking/auto_stop_screen.dart` | Auto-stop mode and time picker |
| `lib/presentation/screens/settings/time_tracking/timer_behaviour_screen.dart` | Single timer, auto-pause, keep awake, minimum length |
| `lib/presentation/screens/settings/time_tracking/pomodoro_screen.dart` | Pomodoro settings |
| `lib/presentation/screens/settings/time_tracking/time_display_screen.dart` | Rounding, format, manual default, live sample |
| `lib/presentation/screens/settings/widgets/settings_choice_list.dart` | Shared radio-choice card |
| `lib/presentation/screens/settings/widgets/settings_note_card.dart` | Shared quiet note card |
| `lib/presentation/shared/widgets/timer_controls.dart` | `TimerActions` — one place for start / pause / stop and their messages |
| `lib/presentation/shared/widgets/timer_lifecycle_watcher.dart` | Auto-stop, auto-pause on background, keep awake |
| `lib/presentation/shared/widgets/pomodoro_banner.dart` | Block type and countdown |
| `lib/presentation/shared/utils/tracked_duration_format.dart` | Inherited widget carrying the display choices to nested report widgets |
| `test/core/time_tracking_rules_test.dart` | 16 tests for the pure rules |
| `test/application/time_tracking_settings_notifier_test.dart` | Defaults, saving, clamping, bad stored values |
| `test/application/pomodoro_notifier_test.dart` | Block sequence, long-break interval, auto-start, clock sync |
| `test/domain/usecases/start_time_segment_one_timer_test.dart` | The single-timer rule, including that a refused start stops nothing |

## Files changed

| File | Change |
|------|--------|
| `lib/core/utils/duration_utils.dart` | `formatDuration` gained optional `rounding` and `format`, defaulting to the original output so every existing call site is unaffected |
| `lib/domain/repositories/time_segment_repository.dart` | `stopSegment` now returns the closed segment; added `closeSegmentAt`, `getAllRunningSegments`, `stopAllRunningSegments`, `deleteSegment`, `restoreSegment`; `repairOrphanedSegments` gained an optional `closeAt` |
| `lib/data/repositories/time_segment_repository_impl.dart` | Implemented the above. A close time is never allowed before the segment start |
| `lib/data/dao/time_segment_dao.dart` | Added `findAllRunningSegments()` and `delete(id)`, which reindexes the parent todo so a deleted segment's note leaves the search index |
| `lib/domain/usecases/start_time_segment.dart` | Enforces the single-timer rule; returns the ids it stopped |
| `lib/domain/usecases/repair_orphaned_segments.dart` | Closes orphans at the auto-stop cut-off when auto-stop is on; unchanged when off |
| `lib/application/time_tracking_notifier.dart` | Added `pauseTimer`, `resumeTimer`, `autoStopAt`, `undoDiscardedSegment`; applies the minimum-length rule; returns typed results |
| `lib/application/providers.dart` | New providers; settings read through callbacks; clears the paused mark when a task becomes terminal |
| `lib/app.dart` | Five new routes; wraps the app in `TimerLifecycleWatcher` |
| `lib/core/constants/app_routes.dart` | Five new route paths |
| `lib/presentation/screens/settings/settings_screen.dart` | New Time tracking card |
| `lib/presentation/screens/daily_list/widgets/todo_list_tile.dart` | Pause button, Paused badge, settings-aware duration |
| `lib/presentation/screens/time_segments/time_segments_screen.dart` | Start / Pause / Stop row, Pomodoro banner, settings-aware durations |
| `lib/presentation/screens/time_segments/widgets/manual_segment_form.dart` | Fills the end time from the saved default |
| `lib/presentation/screens/statistics/*` (4 files), `evening_reflection_modal.dart` | Use `context.trackedDuration(...)` so reports follow the rounding and format |
| `lib/l10n/app_en.arb`, `lib/l10n/app_ml.arb` | 76 new strings in both English and Malayalam |
| `lib/l10n/app_localizations*.dart` | Regenerated |
| `android/.../MainActivity.kt` | The `screen_wake` channel and an `onDestroy` that clears the flag |
| `docs/features.md` | New §4.4; §4.1 and §4.3 updated; screen table updated |
| `docs/architecture.md` | New state-management section, route rows, key-value storage, platform channels |
| `pubspec.yaml`, `assets/config/app_config.json` | Version bump |
| `test/presentation/settings_screen_test.dart` | Expects six cards; scrolls to the offline notice, which is now below the fold |
| `test/presentation/todo_list_tile_test.dart`, `test/presentation/undo_snackbar_test.dart` | Fakes gained the new repository methods; both now override `sharedPreferencesProvider`, because the tile reads the settings |

**No database migration and no new package.**

## Verification

- `flutter analyze` — **0 issues**.
- `flutter test` — **377 tests, all passing** (up from 357).
- `dart format lib/ test/ integration_test/` — clean.

## Rules honoured

- Layers respected: pure rules in `core/`, state in `application/`, the single-timer rule
  in `domain/usecases/`, SQL only in the DAO. No widget touches a DAO.
- All new user-visible text goes through the ARB files in both languages.
- Rounding never rewrites stored data. Day lock and terminal status lock are unchanged.
- The one-open-segment-per-todo rule is unchanged: pause closes a segment, it never opens
  a second one.
- Fully offline. No new dependency, no network, no notification permission.

## Known limits, stated plainly

1. **Pomodoro alerts do not fire in the background.** The app has no notification support,
   so nothing can raise an alert while it is closed. The time is still counted correctly.
   Real background alerts need notification work, which is a separate change.
2. **Auto-stop cannot fire at the exact minute while the app is closed.** It is corrected
   on the next launch.
3. **Keep the screen on is Android only.** The switch is hidden elsewhere.
