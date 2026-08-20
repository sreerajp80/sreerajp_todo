# Time Tracking Settings

**Status:** completed

## 1. The issue

The Settings page has only five entries: Appearance, Language, Backup, About and
Permissions. Everything about how the timer behaves is fixed in code. A user cannot
change any of it.

Today:

- A timer that is left running past midnight is only cleaned up on the next app start,
  by `repairOrphanedSegments`, which closes it with **zero** length. Real work time is
  lost.
- There is no way to pause a timer. You can only stop it.
- Two or more todos can run their timers at the same time. Nothing warns you.
- Reported times are raw seconds. There is no rounding for reporting.
- A one second mis-tap creates a one second segment that stays in the list forever.
- There is no Pomodoro / focus interval support at all.
- The screen sleeps while a timer runs.
- Manual time entry always opens at 09:00 to 10:00, fixed in
  `manual_segment_form.dart`.
- Every duration is shown as `HH:MM:SS`, fixed in `duration_utils.dart`.

## 2. What we will build

A new **Settings -> Time tracking** hub with nine settings, plus the timer behaviour
each one drives.

### 2.1 Auto-stop the timer

- Choice: `off` (default) / `at midnight` / `at a set time`.
- When "at a set time" is picked, a time picker sets the hour and minute.
- A running segment is closed at that moment with its true length, not zero.
- Works two ways, because an offline app cannot run in the background forever:
  1. **Live**, while the app is open: a timer fires at the cut-off moment and stops
     any running segment.
  2. **On next start / resume**: `RepairOrphanedSegments` is upgraded. Instead of
     always closing an orphan at zero length, it closes it at the auto-stop moment
     that falls after the segment start. If auto-stop is `off`, it keeps today's old
     behaviour of a zero length interrupted segment, so nothing changes for a user
     who never turns this on.

### 2.2 Pause and resume the timer

Chosen instead of idle detection.

- A new **Pause** button next to Start / Stop, on the day list tile and on the Time
  Segments screen.
- Pause closes the current segment normally, so the time already worked is kept.
- Resume opens a fresh segment. The total is the sum, which is exactly how the
  existing segment model already works. **No database migration is needed.**
- The paused todo id is remembered in `SharedPreferences` so the tile can show a
  "Paused" chip and a Resume button instead of a plain Start button. Pause state is
  screen state, not user data, so it is deliberately not put in the database and not
  synced or backed up.
- The paused mark is cleared when the todo is resumed, stopped, becomes
  `completed` / `dropped`, or when the day rolls over.
- Extra setting: **Auto-pause when the app goes to the background** (default off).
  When on, leaving the app pauses a running timer and returning shows the Resume
  button. This is the honest offline substitute for idle detection.

### 2.3 One timer at a time

- Choice: `allow many` (default, today's behaviour) / `only one`.
- When "only one" is set, starting a timer on todo B first stops any timer running on
  any other todo. A SnackBar says which todo was stopped.
- Enforced in the `StartTimeSegment` use case, not in the widget, so every path gets
  it.

### 2.4 Rounding for reporting

- Choice: `off` (default) / `nearest 1 min` / `nearest 5 min` / `nearest 15 min`.
- **Display only.** Stored segment seconds are never changed. Rounding is applied in
  `duration_utils.dart` when a duration is formatted, so Statistics, the Time Segments
  screen, the day tile and the reflection modal all agree.

### 2.5 Minimum segment length

- Choice: `off` (default) / `10s` / `30s` / `1 min` / `5 min`.
- Applies **only when you stop or pause a live timer**. If the segment is shorter than
  the limit it is deleted instead of saved, and a SnackBar says so with an **Undo**
  button, matching the existing undo pattern.
- Never applies to manual entries, imports, or restored backups.

### 2.6 Pomodoro / focus intervals

Full engine, with in-app alerts only.

- Settings: enabled on/off (default off), work length (default 25 min), short break
  (default 5 min), long break (default 15 min), long break after N work blocks
  (default 4), auto-start the next block on/off (default off).
- A new `PomodoroNotifier` watches the running segment. When the work length is
  reached it stops the segment, plays an alert (system sound plus
  `HapticFeedback.heavyImpact`), and either starts the break automatically or waits
  for a tap.
- The day tile and the Time Segments screen show the block type and the time left.
- **Known limit, stated plainly:** with no notification support in the app, an alert
  will not fire while the app is closed or in the background. The block is still
  counted correctly on resume, but you will hear nothing at the time. Full background
  alerts need the notifications work, which is a separate change.

### 2.7 Keep the screen awake while a timer runs

- On/off, default off.
- Implemented with a small `MethodChannel` added next to the existing
  `in.sreerajp.todo/database_key` channel in `MainActivity.kt`, setting and clearing
  `FLAG_KEEP_SCREEN_ON`. **No new package**, so the approved dependency list is
  unchanged.
- On Windows and any other platform the Dart side is a safe no-op.

### 2.8 Default manual entry duration

- Choice: `15 min` / `30 min` / `1 hour` (default) / `2 hours`.
- In `ManualSegmentForm`, picking a start time auto-fills the end time at start plus
  this default. The user can still change the end time freely.

### 2.9 Duration display format

- Choice: `HH:MM:SS` (default) / `HH:MM` / decimal hours (`1.75 h`).
- Applied inside `formatDuration`, so every screen follows it.
- The live running timer always keeps seconds, whatever this is set to, because a
  ticking clock with no seconds looks broken.

## 3. Files to change

All paths are relative to the repository root.

### New files

| File | Purpose |
|------|---------|
| `lib/application/time_tracking_settings_notifier.dart` | `TimeTrackingSettings` state, all enums, `SharedPreferences` keys, and the notifier. Mirrors `appearance_notifier.dart`. |
| `lib/application/pomodoro_notifier.dart` | Pomodoro block state machine and in-app alerts. |
| `lib/application/timer_paused_store.dart` | Reads and writes the paused todo id set in `SharedPreferences`. |
| `lib/core/utils/time_tracking_rules.dart` | Pure Dart helpers: rounding, minimum length check, next auto-stop instant. No Flutter imports. |
| `lib/core/platform/screen_wake_channel.dart` | Dart side of the keep-awake `MethodChannel`, no-op off Android. |
| `lib/presentation/screens/settings/time_tracking_screen.dart` | The Time tracking hub, links to the pages below. |
| `lib/presentation/screens/settings/time_tracking/auto_stop_screen.dart` | Auto-stop choice and time picker. |
| `lib/presentation/screens/settings/time_tracking/timer_behaviour_screen.dart` | One-timer-at-a-time, auto-pause on background, keep screen awake, minimum segment length. |
| `lib/presentation/screens/settings/time_tracking/pomodoro_screen.dart` | Pomodoro settings. |
| `lib/presentation/screens/settings/time_tracking/time_display_screen.dart` | Rounding, duration format, default manual entry duration. |
| `lib/presentation/shared/widgets/timer_controls.dart` | Shared Start / Pause / Resume / Stop control, used by the day tile and the Time Segments screen. |
| `test/core/time_tracking_rules_test.dart` | Unit tests for rounding, minimum length, auto-stop instant. |
| `test/application/time_tracking_settings_notifier_test.dart` | Load, save and default tests. |
| `test/application/pomodoro_notifier_test.dart` | Block sequence and long-break interval tests. |
| `test/domain/start_time_segment_one_timer_test.dart` | "Only one timer" enforcement test. |

### Changed files

| File | Change |
|------|--------|
| `lib/application/providers.dart` | Add `timeTrackingSettingsProvider`, `pomodoroProvider`, `timerPausedStoreProvider`; pass settings into `StartTimeSegment` and `TimeTrackingNotifier`. |
| `lib/application/time_tracking_notifier.dart` | Add `pauseTimer()` / `resumeTimer()`; apply the minimum-length rule on stop and pause; expose the undo hook. |
| `lib/domain/usecases/start_time_segment.dart` | Enforce "only one timer at a time" when the setting is on. |
| `lib/domain/usecases/repair_orphaned_segments.dart` | Close orphans at the auto-stop moment instead of at zero length when auto-stop is on. |
| `lib/domain/repositories/time_segment_repository.dart` | Add `stopAllRunningSegments()`, `deleteSegment(String id)`, `closeSegmentAt(String todoId, DateTime at)`. |
| `lib/data/repositories/time_segment_repository_impl.dart` | Implement the three new methods. |
| `lib/data/dao/time_segment_dao.dart` | Add `findAllRunningSegments()` and `delete(String id)`. Reindex the parent todo after a delete. |
| `lib/core/utils/duration_utils.dart` | `formatDuration` gains optional rounding and format arguments, with today's behaviour as the default so existing calls keep working. |
| `lib/presentation/screens/settings/settings_screen.dart` | Add the "Time tracking" nav card. |
| `lib/core/constants/app_routes.dart` | Add `timeTracking` and its four child routes. |
| `lib/app.dart` | Register the five new routes; add a `WidgetsBindingObserver` for auto-pause on background and for the live auto-stop timer. |
| `lib/presentation/screens/daily_list/widgets/todo_list_tile.dart` | Use the shared timer control; show the Paused chip and the Pomodoro block countdown. |
| `lib/presentation/screens/time_segments/time_segments_screen.dart` | Same control, plus Pomodoro state. |
| `lib/presentation/screens/time_segments/widgets/manual_segment_form.dart` | Auto-fill the end time from the default manual duration setting. |
| `lib/l10n/app_en.arb`, `lib/l10n/app_ml.arb` | About 55 new strings for every label, option and message. |
| `lib/l10n/app_localizations*.dart` | Regenerated by `flutter gen-l10n`. |
| `android/app/src/main/kotlin/in/sreerajp/sreerajp_todo/MainActivity.kt` | Add the `in.sreerajp.todo/screen_wake` channel. |
| `docs/features.md` | New section 4.4 "Time tracking settings"; update section 4.3 for the new orphan repair rule. |
| `docs/architecture.md` | Note the new notifiers, providers and the wake channel. |
| `assets/config/app_config.json`, `pubspec.yaml` | Version bump. |

**No database migration and no new package.**

## 4. Order of work

1. `time_tracking_rules.dart` plus its unit tests. Pure logic first.
2. `time_tracking_settings_notifier.dart` plus tests, and the providers.
3. The five settings screens, routes, and the ARB strings.
4. Repository, DAO and use-case changes plus their tests.
5. Pause / resume, the shared timer control, and the two screens that use it.
6. `duration_utils.dart` rounding and format.
7. Pomodoro notifier and its UI.
8. The wake `MethodChannel` and `MainActivity.kt`.
9. Manual entry default duration.
10. `flutter analyze` at zero issues, `flutter test`, `dart format`.
11. Docs and version bump.
12. Change log in `change_log/`.

## 5. Risks

- **Existing tests may break.** `formatDuration` gains parameters and
  `RepairOrphanedSegments` changes behaviour. Both keep today's behaviour as the
  default so the fallout should be small, but every existing time test will be re-run.
- **Pomodoro is the biggest piece.** If it starts to pull the change out of shape it
  will be split into its own plan, and this one will be marked
  `partial_completion` with the reason recorded.
- **Alerts do not fire in the background.** Stated above and it will also be written
  into `docs/features.md`, so the limit is not a surprise.

## 6. Rules honoured

- Layers respected: pure logic in `core/`, state in `application/`, rules in
  `domain/usecases/`, SQL in the DAO only. No widget touches a DAO.
- All new user-visible text goes through the ARB files in both English and Malayalam.
- Rounding never rewrites stored data. Day lock and terminal status lock are unchanged.
- The one-open-segment-per-todo rule is unchanged. Pause closes a segment, it does not
  open a second one.
- The undo pattern is reused for a discarded short segment.
- Fully offline. No new dependency, no network, no notification permission.

---

**Do you approve this plan?**
