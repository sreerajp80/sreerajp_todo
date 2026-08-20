# SreerajP ToDo — Features & App Specification

> Every item in this document is implemented in the current code base. Planned or
> proposed ideas are kept out of this file on purpose.

## 1. App Overview & Identity

**SreerajP ToDo** is a personal, fully offline, privacy-first daily todo and time-tracking
application for individuals, daily planners, time-tracking professionals, multi-lingual
users, and privacy-conscious users on mobile and desktop. It lets you organise daily
tasks, track exact time with live timers or manual entries, break tasks into sub-tasks,
block a task until its prerequisites are done, defer unfinished work to another day,
automate repeating tasks with an RFC 5545 iCalendar RRULE engine, revise things on a
spaced-repetition schedule, set a morning intention and write an evening reflection,
study productivity trends with charts and tables, search across all days with a full-text
index, make encrypted local backups, move data between devices with QR codes, local Wi-Fi,
or JSON/Markdown files, and switch theme and language inside the app.

### Inclusive Design & Accessibility Profile
- **Multi-Lingual & Multi-Script Inclusion:** English (`en`) and Malayalam (`ml`). The app
  follows the device language by default, and the Settings screen also has an in-app
  language selector (System / English / Malayalam). Text direction is detected per field
  with `unicodeUtils.detectTextDirection()` and applied through `AdaptiveDirectionality`,
  so Latin, Malayalam, Arabic, Hebrew, and mixed text all flow correctly.
- **Visual & Colorblind Accessibility:** Hand-made Light and Dark themes (`AppTheme.light`
  and `AppTheme.dark`) with distinct icons (check marks, alert flags, forward arrows,
  crosses) next to colour badges, so status is clear without relying on colour alone.
- **Keyboard & Motor Accessibility:** Keyboard focus traversal (`FocusTraversalGroup`)
  gives full Tab / Shift+Tab movement across form fields, list tiles, dialogs, and the
  navigation scaffold on desktop and tablets.
- **Screen-Reader Accessibility:** Task tiles, the select/toggle and delete actions, status
  badges, and the locked-day indicator expose `Semantics` roles and labels, so TalkBack on
  Android and Narrator on Windows can read them.
- **Cross-Device Adaptiveness:** The layout changes with screen width — a side
  `NavigationRail` at `>=600dp`, a bottom `NavigationBar` below that — and main content is
  capped at `1440dp` (`kContentMaxWidthDp`) for readability.
- **Offline & Digital Inclusion:** No internet use, no cloud account, no analytics, so the
  app works the same in low-connectivity or high-security places.

### Technical Profile
- **App Name:** `SreerajP ToDo` (version and build come from `assets/config/app_config.json`
  through `ConfigService`)
- **Target Audience:** Daily planners, time-tracking professionals, multi-lingual users,
  and privacy-conscious individuals who need fully local data.
- **Platforms:** Android, Windows (v1.0 active targets); iOS, Linux, macOS (not built yet)
- **Framework & Language:** Flutter (`3.44.8 stable`) / Dart (`3.12.2`)
- **Database Storage:** Local SQLite database (`sreerajp_todo.db`) via `sqflite_sqlcipher`
  (mobile) and `sqflite_common_ffi` with SQLCipher (desktop). The live database is opened
  **with a password** taken from `DatabaseKeyService`. See section 2.2.
- **Database PRAGMAs & Migrations:** `PRAGMA journal_mode=WAL; PRAGMA foreign_keys=ON;`
  applied by `MigrationRunner`, which runs schema versions v1 to v7:
  - v1 — baseline schema (todos, time segments, recurrence rules)
  - v2 — status sync for tasks that already have time segments
  - v3 — `todos_fts` FTS5 full-text search index
  - v4 — `sub_tasks` and `task_dependencies` tables
  - v5 — `daily_intentions` and `daily_reflections` tables
  - v6 — `spaced_repetition_items` table and `todos.spaced_repetition_item_id`
  - v7 — `backup_logs` table for backup history and the health dashboard
- **State Management:** Riverpod (`flutter_riverpod`) with a root `ProviderScope` and
  immutable `@freezed` state objects.
- **Navigation & Routing:** `go_router` with custom page transitions (`FadeTransition` +
  `SlideTransition`, `Curves.easeOutCubic`).
- **Adaptive Layout:** Responsive scaffold (`NavigationRail` `>=600dp`, `NavigationBar`
  `<600dp`), content width capped at `1440dp` (`kContentMaxWidthDp`).
- **Recurrence Engine:** iCalendar RRULE (RFC 5545) through the `rrule` package, with
  human-readable text from `describeRrule()`.
- **Data Visualization:** `fl_chart` (bar chart for daily status counts, line chart for
  per-title time trends).
- **Localization:** `flutter_localizations` with `app_en.arb` and `app_ml.arb`; the chosen
  language is stored with `shared_preferences`.
- **Unicode & Text Handling:** `unorm_dart` for NFC normalization and per-field LTR/RTL
  detection.
- **Optical Transfer:** `qr_flutter` (showing QR frames) and `mobile_scanner` (camera
  scanning) for the AirQR transfer feature.
- **Backup Archiving:** ZIP creation and passphrase encryption using the `archive` package
  plus helpers in `core/utils/crypto_utils.dart` and `core/utils/atomic_saver.dart`.
- **Data & Security Policy:** No internet, no cloud sync, no analytics, no crash
  reporting, no telemetry. The only network use is optional device-to-device sync over the
  local network (section 2.1).
- **Launch Experience:** Native splash screen on app start via `flutter_native_splash`.

---

## 2. Core Architectural Guarantees & Constraints

1. **Offline Enforcement (No Internet, Local Network Only When You Ask):**
   - `AndroidManifest.xml` has no `INTERNET`, `ACCESS_NETWORK_STATE`, or
     `ACCESS_WIFI_STATE` permission. The only declared permission is `CAMERA`, used by the
     AirQR scanner.
   - No HTTP client, WebSocket client, cloud SDK, analytics SDK, or telemetry package is
     used. The app never contacts a server on the internet.
   - The optional Wi-Fi Sync feature (section 12) opens a plain TCP `ServerSocket` on the
     device and connects to another device on the **same local network** only, and only
     while you keep that screen open.
   - All runtime assets are bundled (`AssetImage`, `Image.asset()`, `Image.file()`).
     `NetworkImage` and `Image.network()` are not used.

2. **Database Encryption:**
   - **Live Database:** Opened with a password from `DatabaseKeyService`. The key is a
     random 256-bit value created on first run and kept by the platform: on Android through
     a `MethodChannel` (`in.sreerajp.todo/database_key`) backed by the Android Keystore in
     `MainActivity.kt`, and on Windows through DPAPI (`core/utils/win32_dpapi.dart`), which
     stores the protected key file in the app documents directory. If an older
     plain database is found, `DatabaseService` opens it once, re-encrypts it with the
     device key, and continues with the encrypted file.
   - **Backup Archives:** Exported backups are ZIP archives encrypted with a passphrase you
     type (AES-256, at least 8 characters), named
     `sreerajp_todo_backup_YYYYMMDD_HHMMSS.db`. They can be carried to another device.
   - **Wi-Fi Sync Payloads:** Encrypted in transit with AES-256-CTR plus HMAC-SHA256, using
     a key derived from a 6-digit pairing PIN with PBKDF2-HMAC-SHA256 (300,000 iterations).

3. **Immutable Past (Day Lock Constraint):**
   - Tasks dated before today are read-only.
   - Creating a backdated task or changing a past-day task (title/description, status,
     timers, manual time entries, deletion) throws `DayLockedException` in the repository
     layer.
   - The UI shows the locked state with a padlock (`locked_overlay.dart`) and disabled
     controls.
   - Past tasks stay readable, searchable, and can still be copied to today or a later day.

4. **Unicode-First & Right-to-Left (RTL) Support:**
   - Every string written to SQLite is NFC-normalized with `unicodeUtils.nfcNormalize()`.
   - Title uniqueness per day is checked after NFC normalization.
   - Text direction is detected per field and rendered through `AdaptiveDirectionality`.

5. **Bilingual Localization (English & Malayalam):**
   - The whole interface and its messages exist in `app_en.arb` and `app_ml.arb`.
   - Default is the device language; Settings can override it to English or Malayalam and
     the choice is remembered.

6. **Domain Exception Mapping:**
   - `DayLockedException`: creating or changing a task on a past date.
   - `CompletedLockException`: adding or starting time on a completed or dropped task.
   - `DuplicateTitleException`: a task with the same title already exists on that date.
   - `SegmentAlreadyRunningException`: starting a second timer on the same task.
   - `SegmentOverlapException`: a manual segment overlaps an existing one.
   - `TodoNotFoundException`: task lookup failed.
   - `BackupVersionTooNewException`: the backup was made by a newer schema version.
   - `BackupCorruptedException`: wrong passphrase, broken archive, or failed integrity
     check.

---

## 3. Daily Task Management & Lifecycle Features

### 3.1 Daily Task List
- **Date Navigation:** Move between days with previous/next arrows, a "Today" button, a
  date picker dialog, or the inline expandable calendar (`table_calendar`).
- **Drag-and-Drop Reordering:** Reorder tasks with drag handles, saved to `sortOrder`.
  Handles show in "Manual" sort mode and hide in the automatic sort modes.
- **Task Sorting Options:** 9 sort modes in the sort menu:
  - Manual (custom drag-and-drop order)
  - Name A→Z
  - Name Z→A
  - Created Oldest First
  - Created Newest First
  - Most Time Tracked
  - Least Time Tracked
  - By Status
  - Priority (high first)

  The order the list opens in is a saved preference (see section 3.8). Ties in the
  priority sort keep the manual order.
- **Task Attributes (`TodoEntity`):**
  - `id`: Unique identifier (UUID v4).
  - `date`: Assigned ISO date (`YYYY-MM-DD`).
  - `title`: Task title (NFC-normalized, unique per date).
  - `description`: Optional multi-line notes.
  - `status`: Lifecycle state (`pending`, `working`, `completed`, `dropped`, `ported`).
  - `priority`: How important the task is (`low`, `normal`, `high`, `urgent`). Default
    `normal`, which shows no dot on the tile.
  - `targetSeconds`: How long the task is expected to take, or null for no target.
    Display only — passing it never stops a timer or changes a status.
  - `portedTo`: Target date for ported tasks (`YYYY-MM-DD`).
  - `sourceDate`: Original date for copied/ported tasks (`YYYY-MM-DD`).
  - `recurrenceRuleId`: Link to the recurrence rule that created it, if any.
  - `spacedRepetitionItemId`: Link to the mastery-deck item that created it, if any.
  - `subTasks`: Checklist items belonging to this task.
  - `prerequisiteTodoIds`: Tasks that must be completed before this one.
  - `sortOrder`: Position in the daily list.
  - `createdAt` / `updatedAt`: ISO 8601 timestamps.
  - *Note:* Total tracked time (`HH:MM:SS`) is **not** stored; it is calculated from the
    task's time segments.

### 3.2 Task Lifecycle & Terminal Status Lock
- **`pending`**: Default on creation. Timers can start and stop freely.
- **`working`**: Set automatically once the task has at least one time segment.
- **`completed`**: Terminal. Running timers stop and close. Timer controls hide and new
  segments are refused (`CompletedLockException`).
- **`dropped`**: Terminal, for abandoned work. Running timers stop. The time already spent
  is counted as "dropped time" in statistics. Asks for confirmation when the "Ask before
  dropping" setting is on (it is on by default; see section 3.8).
- **`ported`**: The task was moved to a later date. Needs a target date and a confirmation
  dialog, and creates a fresh `pending` copy on that date.
- **Status Transitions:** `pending -> working -> completed`, `pending -> completed`,
  `pending -> working -> dropped`, `pending -> dropped`, and `ported`. A terminal status
  can be changed to the other terminal status or reverted with Undo.

### 3.3 Sub-Tasks (Checklists)
- Each task can hold an ordered checklist of sub-tasks, edited in the Create/Edit ToDo
  screen (add, tick, delete; the order follows the order they were added).
- Sub-task fields (`SubTaskItem`): `id`, `todoId`, `title`, `isCompleted`, `sortOrder`,
  `createdAt`, `updatedAt`.
- The task tile shows a progress pill (for example `2/5`) when sub-tasks exist.
- Deleting a task deletes its sub-tasks.

### 3.4 Task Dependencies (Blocking)
- A task can list other tasks of the same day as prerequisites, picked in the Create/Edit
  ToDo screen.
- While any prerequisite is still unfinished, the task tile shows a "Blocked by N" badge
  and a warning line, so the order of work stays visible.
- Stored in `task_dependencies` and served by `TaskDependencyDao.getPendingPrerequisites()`.

### 3.5 Granular Deletion & Recurring Task Options
- **Standard Task Deletion:** Asks for confirmation and cleans up the task's time
  segments, sub-tasks, and dependency links.
- **Recurring Task Deletion:** For a task made by a recurrence rule, three choices:
  - *Delete only this occurrence* (`deleteOnlyThis`)
  - *Delete this and future occurrences* (`deleteThisAndFuture`)
  - *Delete all occurrences and remove rule* (`deleteAllOccurrences`)

### 3.6 Duplicate Detection & Real-time Validation
- One title per calendar day, enforced in SQLite, the repository, and the form.
- The create/edit form checks the NFC-normalized title while you type (debounced) and warns
  before you save (`DuplicateTitleException`).

### 3.7 History-Wide Title Autocomplete
- While typing a title, the app looks up past titles from all dates.
- Up to 20 prefix matches are offered by default, with 300 ms debouncing, to keep naming
  consistent. Both the on/off switch and the number of matches are settings (section 3.8).
- With suggestions switched off, nothing is read from the database while typing at all.

### 3.8 Task Defaults (Settings → Task defaults)
Four pages of preferences, all stored in `SharedPreferences` and all with defaults that
keep the behaviour the app had before they existed.

**New task**
- *Default status* — `pending` (default) or `working`. Choosing `working` pre-selects the
  status but does **not** start a timer.
- *Default priority* — `normal` by default.
- *Default target time* — none by default; otherwise 15 min, 30 min, 45 min, 1 h, 90 min
  or 2 h. Any task can still be given any target on the form.

**Day list**
- *Default order* — which of the 9 sort modes the day list opens in. Manual by default.
- *Remember the last order I pick* — on by default. Choosing a sort from the day list menu
  also saves it, so the choice survives a restart.
- *Show completed tasks* / *Show dropped tasks* — both on by default.
- *Move finished tasks to the bottom* — off by default. When on, `completed`, `dropped`
  and `ported` tasks sit below the rest whatever the sort is.
- When a filter hides anything, the day list shows a "N finished tasks hidden — Show" line,
  so an empty-looking day is never a mystery. "Show" reveals them for that visit only.
- *Voice input* — **off by default**. When on, a small microphone button sits above the add
  button on the day list and opens the voice task sheet (see 3.9). Turning it on is what
  leads to the microphone permission being asked for, so a fresh install never sees that
  prompt.

**Task actions**
- *Ask before completing* — off by default.
- *Ask before dropping* — on by default, matching the old fixed behaviour.
- Both apply on the day tile quick actions **and** on the status chips in the create/edit
  form, so the two routes to a status change behave the same.
- *Ask to carry over unfinished tasks* — off by default. The first time today's list is
  opened on a given day, a sheet lists the `pending` and `working` tasks from the most
  recent earlier day that had any, all ticked. "Carry over" copies the ticked ones to
  today through the existing `CopyTodos` use case, so duplicate titles are skipped and
  the day lock applies. The tasks on the earlier day are **never changed** — past days are
  read-only. *How far back to look* is "previous day only" (default) or "last 7 days".

**Autocomplete**
- *Suggest titles while typing* — on by default.
- *How many suggestions* — 5, 10, 20 (default) or 50. This is a real SQL `LIMIT`, not a
  list trimmed in Dart.

**Known limit:** drag-to-reorder writes `sort_order` over the whole day. While finished
tasks are sunk to the bottom, or while a filter hides some of them, a drag is translated
into a move in the full list — the dragged task lands just before whatever it was dropped
in front of. Dragging an unfinished task into the finished group will therefore appear to
snap back, because sinking is re-applied on the next build.

### 3.9 Voice Task Entry (Offline, English & Malayalam)
One plain sentence in, one ready-made task out. Everything is worked out on the device.

**Opening it.** With *Voice input* on (3.8), a small microphone button sits above the add
button on the day list, on today and on future days. It is hidden on a past day, which is
read-only. It opens a floating sheet with a language toggle (English / Malayalam), a
microphone button, a text box, and a row of chips showing what was understood.

**What it understands.** Both language word lists are always tried, so a sentence may mix
the two freely.

| Sentence | Title | Day | Time | Target |
|---|---|---|---|---|
| `Call the bank tomorrow at 10 am for 30 minutes` | Call the bank | tomorrow | 10:00 | 30 min |
| `Study Dart next Monday for 1 hour 30 minutes` | Study Dart | next Monday | — | 90 min |
| `urgent: Pay rent tomorrow` | Pay rent (urgent) | tomorrow | — | — |
| `ഏഴരയ്ക്ക് നടക്കാൻ പോകണം` | നടക്കാൻ പോകണം | today | 07:30 | — |
| `അടുത്ത തിങ്കളാഴ്ച 45 മിനിറ്റ് പഠനം` | പഠനം | next Monday | — | 45 min |
| `പത്തു മണിക്ക് ഡോക്ടറെ കാണണം` | ഡോക്ടറെ കാണണം | today | 10:00 | — |
| `രണ്ട് മണിക്കൂർ വായന` | വായന | today | — | 2 h |

Also handled: `today`, `the day after tomorrow`, `in 3 days`, `in 2 weeks`, any weekday,
`half past seven`, `quarter to 8`, `10:30 pm`, `half an hour`, `forty five minutes`,
`low priority`, an opening `remind me to`, and the Malayalam forms `ഇന്ന്`, `നാളെ`,
`മറ്റന്നാൾ`, `അടുത്ത ആഴ്ച`, `മൂന്ന് ദിവസം`, `രാവിലെ` / `വൈകുന്നേരം`, and every half-past
form from `ഒന്നര` to `പന്ത്രണ്ടര`.

**Rules it keeps.**
- **It never invents.** No date words means today — or, if the sheet was opened on another
  day, the day being looked at. An hour with no `am`, `pm` or part-of-day word is kept
  exactly as said, so `at 5` is 05:00 and is not "helpfully" turned into 17:00.
- **Day-Lock holds.** A day already past is moved to today, and the sheet says so.
- **Nothing is saved by the sheet.** "Create task" opens the ordinary create form with the
  fields filled in, so the duplicate-title check, the day lock and NFC normalisation are
  all enforced in the one place they always were. The form can be edited before saving.
- A task has no time-of-day column, so a spoken time is written into the description as a
  short note (`At 10:30`) rather than being dropped.
- `unicodeUtils.nfcNormalize()` runs on the sentence before matching and on the title
  after; `detectTextDirection()` drives the text box and the chips.

**Speaking is optional.** Typing works everywhere and always — on Windows, on a phone with
no speech app, and on a phone with no offline language pack — and is read exactly the same
way. Where the microphone cannot be used, the sheet says why in one line and shows the text
box only. The keyboard's own microphone key still works in that box.

**Staying offline.** The app declares no network permission of any kind. The phone
recogniser is always asked for its on-device engine, and listening is refused rather than
allowed to go online; a recogniser that reaches for the network is reported as a missing
offline language pack. No audio is recorded or kept. The full reasoning, and the honest
limit that the recogniser is a separate app that cannot be audited from here, is in
`docs/security.md` section 10.

---

## 4. Time Tracking & Segment Management

### 4.1 Live Timer
- **Start / Pause / Resume / Stop Control:** Start (▶) begins a segment; Pause (⏸) closes
  it but marks the task as paused so it offers Resume; Stop (⏹) closes it for good.
- **Real-Time Display:** Live `HH:MM:SS` counter driven by `liveTimerProvider` ticks. A
  running timer always shows seconds, whatever the duration format setting is.
- **Multi-Task Timer Concurrency:**
  - Different tasks may run timers at the same time by default. The **Only one timer at a
    time** setting (§4.4) changes this.
  - One task may have only one open segment (`SegmentAlreadyRunningException` otherwise).
    Pause does not create a second open segment: it closes the current one.

### 4.2 Manual Time Entry & Segment Manager
- Per-task **Time Segments Screen** (`/todo/:id/segments`) listing all recorded intervals.
- Add a segment afterwards with start and end time, checked for overlap
  (`SegmentOverlapException`) and same-day bounds.
- **Time Segment Attributes (`TimeSegmentEntity`):**
  - `id`: Unique identifier (UUID v4).
  - `todoId`: Parent task id.
  - `startTime`: ISO 8601 start timestamp.
  - `endTime`: ISO 8601 end timestamp (null while running).
  - `durationSeconds`: Duration in seconds (null while running).
  - `interrupted`: `true` if the segment was force-closed by startup repair or day lock.
  - `manual`: `true` for entries typed afterwards, `false` for live timer entries.
  - `createdAt`: ISO 8601 creation timestamp.
- **Visual Badges:**
  - **"M" (Manual)** for typed entries.
  - **Timestamped range** for live timer entries.
  - **Warning indicator (!)** for interrupted or repaired segments.

### 4.3 Automatic Orphaned Segment Repair
- On app launch, `RepairOrphanedSegments` looks for open segments on past-day tasks (for
  example, a timer left running when the app closed).
- **With auto-stop off (the default):** such segments are closed with 0 duration and
  marked `interrupted = 1`, because there is no honest way to know how long the user
  really worked.
- **With auto-stop on (§4.4):** the segment is closed at the cut-off that followed its
  start and still marked `interrupted = 1`, so real worked time is no longer thrown away.
  An end time is never written into the future, so a clock that moved backwards cannot
  invent time.

### 4.4 Time Tracking Settings

All nine settings live under **Settings → Time tracking** (`/settings/time-tracking`) and
are saved in `SharedPreferences`. Every default reproduces the behaviour the app had
before the settings existed, so nothing changes for a user who never opens the page.

**Auto-stop the timer** (`/settings/time-tracking/auto-stop`)
- Never (default), at midnight, or at a time the user picks.
- While the app is open a single timer fires at the cut-off and closes any running
  segment at that exact moment.
- While the app is closed nothing can fire. The next launch corrects it: see §4.3.

**Pause and resume**
- A **Pause** button sits beside Stop on the day tile and on the Time Segments screen.
- Pause closes the running segment exactly like Stop, so time already worked is kept and
  the one-open-segment-per-todo rule still holds. Resume opens a fresh segment.
- The paused mark is screen state, not user data. It is held in `SharedPreferences` for
  the current day only, and is deliberately kept out of the database, out of backups and
  out of sync. It is cleared on resume, on stop, when the task becomes `completed` or
  `dropped`, and when the day rolls over.
- **Pause when the app is closed** (default off) pauses a running timer as the app leaves
  the foreground.

**Only one timer at a time** (default off)
- When on, starting a timer stops any timer running on another task first, and a
  SnackBar says how many were stopped. Enforced in the `StartTimeSegment` use case, so
  every path obeys it. A start that is refused never stops the previous timer.

**Shortest segment to keep** (default: keep everything)
- Off, 10s, 30s, 1 minute, or 5 minutes.
- Applies only when the user stops or pauses a **live** timer. A shorter segment is
  deleted instead of saved, with a 5 second SnackBar and an **Undo** button.
- Never applies to manual entries, imports, or restored backups.
- Deliberately skipped by auto-stop: the user did not end that segment, so their work is
  never silently thrown away.

**Pomodoro** (`/settings/time-tracking/pomodoro`, default off)
- Work block (default 25 min), short break (5), long break (15), long break after N work
  blocks (4), and start-the-next-block-on-its-own (off).
- `PomodoroNotifier` drives the cycle; the segment start and stop stay in
  `TimeTrackingNotifier`, so no database work happens in the engine.
- The running block and its countdown show on the Time Segments screen.
- **Known limit:** the alert is in-app only. This app sends no notifications, so a block
  that ends while the app is closed or in the background makes no sound. The elapsed time
  is still counted correctly when the app comes back, via `syncWithClock()`.

**Focus mode** (`/settings/time-tracking/focus`)
- **Full-screen Focus view** (`/focus/:id`): tapping the time chip on a task tile, or the
  focus button on the Time Segments screen, opens an immersive view for that one task:
  the elapsed time in large type on a dark ground, the task title and description, a slow
  ambient ring (which fills up to the target when the task has one), the tickable step
  list, and pause / stop controls. Stopping the timer takes the user back where they came
  from. The view is always dark, whatever the app theme is, but keeps the user's own
  accent colour and font.
- Ticks on the step list go through `DailyTodoNotifier.toggleSubTask`, so day-lock and
  every other repository rule still applies. A past day or a finished task is read-only.
- **Immersive full screen** (default on): hides the status and navigation bars while the
  Focus view is open, and puts them back on the way out.
- **Nudge while a timer runs** (default off): off, vibration only, sound only, or both,
  every 5 to 120 minutes (default 30). `FocusPulseNotifier` owns the schedule and
  `TimerLifecycleWatcher` tells it which timer to follow; the nudge itself is
  `SystemSound.play` and `HapticFeedback`, both from the Flutter engine, so no sound file
  is shipped and no package was added.
- Nudges are counted from the start of the running segment, so "every 30 minutes" means
  30 minutes of tracked work. The schedule is worked out from the clock every time, so a
  spell in the background cannot make it drift.
- While Pomodoro is on the nudge stays quiet, because Pomodoro already sounds its own
  alert at the end of every block.
- **Known limit:** like the Pomodoro alert, the nudge is in-app only. Nothing sounds
  while the app is closed or in the background, and a nudge that fell due while the app
  was away is dropped rather than replayed. The tracked time is unaffected.

**Keep the screen on** (default off, Android only)
- Set through a small `MethodChannel` (`in.sreerajp.todo/screen_wake`) beside the
  existing database-key channel, which sets and clears `FLAG_KEEP_SCREEN_ON`. No new
  package, so the audited dependency list is unchanged. The flag is cleared in
  `onDestroy()` and whenever no timer is running. The switch is hidden on other
  platforms rather than shown doing nothing.

**Time display** (`/settings/time-tracking/display`)
- **Rounding in reports:** exact (default), nearest minute, nearest 5, nearest 15.
  **Display only** — stored segment seconds are never rewritten.
- **How times are written:** `HH:MM:SS` (default), `HH:MM`, or decimal hours.
- A **running** timer always keeps its seconds, whatever the format, because a live clock
  that jumps a minute at a time reads as broken.
- Both are applied inside `formatDuration`, and handed to deeply nested report widgets
  through the `TrackedDurationFormat` inherited widget, so Statistics, the Time Segments
  screen, the day tile and the evening reflection all agree.
- **Manual entry length:** 15 min, 30 min, 1 hour (default), or 2 hours. Picking a start
  time fills the end time that far ahead, stopping at 23:59 rather than crossing midnight.
  The user can still change it.

`TimerLifecycleWatcher` wraps the whole app and owns auto-stop, auto-pause on background,
and the keep-awake flag.

---

## 5. Task Progression & Movement (Copy & Port)

### 5.1 Copy Tasks Wizard
- **Screen:** `/copy`
- Step-by-step wizard to copy one or more tasks from any day to today or a later date.
- Accepts a pre-selected task list handed over from bulk multi-selection.
- Original tasks stay untouched on their own day.
- New tasks are created as `pending` with no time segments.
- A task is skipped if the same NFC-normalized title already exists on the target date.
- New tasks show an origin badge ("Copied from YYYY-MM-DD").

### 5.2 Port Tasks
- One atomic action that moves an unfinished task to a later date (tomorrow or after).
- The original task becomes `ported` with a target reference ("→ YYYY-MM-DD").
- A new `pending` task is created on the target date ("Copied from YYYY-MM-DD").
- Time segments stay with the original task; the new task starts at zero.

---

## 6. Recurring Tasks Engine (iCalendar RRULE)

- **RFC 5545 Compliance:** Built on the iCalendar RRULE standard via the `rrule` package.
- **Integrated Recurrence Editor:** Set inside the Create/Edit ToDo screen (`/todo/new`,
  `/todo/:id`) using `RepeatOptionPicker` with the `rrule_frequency_picker` /
  `rrule_preview` bottom sheet.
- **Natural Language Text:** RRULE strings are shown as plain sentences (for example
  *"Every 2 weeks on Monday and Thursday"*, *"Monthly on day 15"*, *"Annually on March 22"*,
  *"Every weekday"*, *"Every weekend"*) by `describeRrule()`.
- **Frequencies & Patterns:** Daily, Weekly, Monthly, Yearly with intervals (every 3 days,
  every 2 weeks), chosen weekdays (Mon + Thu, Weekdays, Weekends), and end conditions
  (*Never*, *On Date*, *After Days*).
- **Recurrence Rule Attributes (`RecurrenceRuleEntity`):**
  - `id`: Unique identifier (UUID v4).
  - `title`: Template title for generated tasks.
  - `description`: Optional template notes.
  - `rrule`: RFC 5545 recurrence rule string.
  - `startDate`: ISO date (`YYYY-MM-DD`) when the rule starts.
  - `endDate`: Optional ISO date (`YYYY-MM-DD`) when the rule stops.
  - `active`: Whether the rule still creates tasks.
  - `createdAt` / `updatedAt`: ISO 8601 timestamps.
- **Real-Time Occurrence Preview:** A live 5-date preview (`rrule_preview.dart`).
- **Automatic Task Generation:** On app launch, after a backup restore, and on task
  create/update, `GenerateRecurringTasks` reads the active rules and creates tasks for the
  next 7 days (`[today, today + 7 days]`), skipping dates where the title already exists.
- **Generated Task Indicator:** Tasks made by a rule carry a repeat badge (🔁).

---

## 7. Spaced Repetition "Mastery Deck"

- **Screen:** `/mastery-deck`, also a destination in the bottom bar / navigation rail.
- Keep a deck of things you want to revise. Each deck item creates a task on the day it is
  due.
- **Item attributes (`SpacedRepetitionItemEntity`):** `id`, `title`, `description`,
  `level`, `easeFactor` (starts at 2.5), `intervalDays`, `nextReviewDate`, `active`,
  `createdAt`, `updatedAt`.
- **Automatic Generation:** On app launch, `GenerateSpacedRepetitionTasks` creates today's
  task for every active item whose `nextReviewDate` is today or earlier.
- **Recall Confidence:** Completing a mastery task opens a dialog with three answers —
  *Hard*, *Revision*, *Easy*. `CompleteSrsTodo` uses the answer to update the ease factor
  and interval, and to set the next review date.
- **Tag Support:** A normal task whose title contains `#mastery` (or
  `#spaced-repetition`) is treated as a mastery task as well.

---

## 8. Daily Intention & Evening Reflection

- **Morning Intention Card:** At the top of the daily list, a card shows the intention for
  the day. You can write your own or cycle through the built-in suggestions. Saved per date
  in `daily_intentions`.
- **Evening Reflection Modal:** Opened from the intention card. It shows the day's summary
  — completed time, dropped time, task counts, and completion ratio — and takes a free-text
  note. Saved per date in `daily_reflections` together with `completedSeconds` and
  `droppedSeconds`.

---

## 9. Bulk Operations & Multi-Select UX

- **Trigger:** Long-press any task in the daily list to start selection mode.
- **Selection Actions:**
  - **Bulk Complete:** Marks all selected tasks `completed` and closes their open timers in
    one transaction.
  - **Bulk Drop:** Marks all selected tasks `dropped` in one transaction.
  - **Bulk Copy:** Sends the selected tasks into the Copy Tasks wizard.
- **Transactional Consistency:** Bulk status updates run inside a single SQLite
  transaction.

---

## 10. Undo System & History Protection

- **5-Second Toast (SnackBar):** An undo prompt appears after any status change, port, or
  bulk action. Undoing a port or copy deletes the tasks that action created.
- **Persistent App-Bar Undo Button (`↩`):** Keeps an in-memory stack of the last 5 status
  changes.
- **Stack Invalidation:** The undo stack clears when you change date or after 2 minutes of
  inactivity.

---

## 11. Cross-Day Full-Text Search

- **Screen:** `/search` (`/search?q=query`)
- Search runs against the FTS5 index `todos_fts` (`MATCH`), covering task titles,
  descriptions, and time segment notes across all dates, with a `LIKE` query as a
  fallback when the index cannot serve the term.
- **Indic phonetic and sandhi-aware matching.** Indexed text and the typed query both
  pass through one folding step (`lib/core/utils/indic_search_utils.dart`) before they
  meet:
  - Malayalam Chillu is unified, so `ണ` + virama + ZWJ and the single letter `ൺ` match
    each other (same for `ന`/`ൻ`, `ര`/`ർ`, `ല`/`ൽ`, `ള`/`ൾ`, `ക`/`ൿ`).
  - Zero-width joiners (`ZWJ`, `ZWNJ`) are removed, so an invisible character can no
    longer split one word into two.
  - Latin accents are stripped (`café` matches `cafe`). Malayalam vowel signs and the
    virama are never stripped, because they change the word.
  - Folding walks grapheme clusters (`characters` package), so a multi-code-point letter
    is never cut in half.
  - The FTS5 tokenizer keeps combining marks inside a token, so a Malayalam word indexes
    as one word rather than as separate letters.
- Results are grouped by date, in date order.
- When a result matched on a time segment note, that note is shown as the result
  subtitle so the reason for the hit is visible.
- Full Unicode, multi-script, and bilingual search.
- Tapping a result opens that date's Daily List screen.

---

## 12. Device-to-Device Transfer (No Internet)

### 12.1 AirQR Optical Transfer
- **Share:** From the daily list overflow menu or the Backup screen, the app turns the
  chosen data (today's tasks, a daily timecard summary, or a database backup) into a
  stream of QR frames shown one after another on screen (`qr_flutter`). Extra parity frames
  (an LT fountain code) are added so the receiver can rebuild the data even if some frames
  are missed.
- **Scan:** `/air-qr-scan` uses the camera (`mobile_scanner`) to read the frame stream,
  shows live progress, checks a CRC32 checksum, and rebuilds the payload.
- **Import:** After a successful scan you can *Import All* or *Skip Duplicates*.
- This is the only feature that needs the `CAMERA` permission.

### 12.2 Peer-to-Peer Wi-Fi Sync
- **Screen:** `/wifi-sync`
- One device hosts a plain TCP server on a random port on the local network; the other
  device connects to it. Nothing leaves the local network and no server on the internet is
  involved.
- Pairing uses a 6-digit PIN, shown as a QR / link string
  (`wifi_sync://<ip>:<port>?pin=<pin>&salt=<salt_hex>`).
- The payload is encrypted with AES-256-CTR + HMAC-SHA256, keyed by PBKDF2-HMAC-SHA256
  (300,000 iterations) over the PIN and salt.
- You choose what to send (sync scope categories), and the merge on the receiving side is
  **add-only**: records are matched by date plus NFC-normalized title, and nothing existing
  is overwritten or deleted.

### 12.3 Multi-Format Data Handoff
- **Screen:** `/data-handoff`
- **Export JSON:** Tasks, sub-tasks, time segments, and recurrence rules as a readable JSON
  payload (`DataHandoffPayload`, version 1).
- **Export Markdown:** A formatted daily document with tasks and timecard figures.
- **Import:** Pick a `.json`, `.md`, or `.txt` file. Markdown checklists (`- [ ]` /
  `- [x]`) are parsed into tasks. Import into a past date is refused with
  `DayLockedException`.

---

## 13. Statistics & Productivity Analytics Dashboard

### 13.1 Daily Overview Tab
- **Date Range Filters:** Last 7 days, Last 30 days, All time, Custom date range.
- **Status Breakdown Bar Chart (`fl_chart`):** Task counts by status (`pending`, `working`,
  `completed`, `dropped`, `ported`) — five bars per day.
- **Summary Metrics Cards:** Five cards — total tasks, average completed tasks per day,
  average time per day, total productive time (time on completed tasks), and total dropped
  time (time on dropped tasks).
- **Daily Metrics Data Table:** Paginated table (20 rows per page), one row per day, with
  columns Date, Total, Pending, Working, Completed, Dropped, Ported, and total time. (The
  productive-vs-dropped split appears only in the two summary cards, not as table columns.)

### 13.2 Per-Item Overview Tab
- **Task Title Selector:** Choose one task title to filter the chart and table below.
- **Time Trend Line Chart (`fl_chart`):** Tracked minutes for that title over time.
- **Title Summary Table:** Paginated table (20 rows per page) with appearance count,
  pending, working, completed, dropped and ported counts, and total time.

---

## 14. Database Backup, Restore & Data Portability

### 14.1 Export Backup
- Creates a standalone passphrase-encrypted ZIP archive holding the SQLite database, named
  `sreerajp_todo_backup_YYYYMMDD_HHMMSS.db`.
- The passphrase is yours (AES-256 ZIP encryption, at least 8 characters).
- Export runs a WAL checkpoint, writes to a temporary copy, encrypts the archive, and runs
  an integrity check before the final file is written.
- The default destination is a `SreerajP ToDo/Backups` folder under the platform downloads
  or documents directory.

### 14.2 Import Restore
- Restores a backup file chosen with the system file picker.
- Checks the passphrase, checks the schema version (older versions are migrated forward,
  newer versions are refused with `BackupVersionTooNewException`), runs
  `PRAGMA integrity_check`, replaces the live database atomically, and then regenerates
  recurring tasks.

### 14.3 Local Backup Management & Health
- The Backup screen (`/backup`) lists stored backup files with date and size, and lets you
  delete them.
- Every export and restore is written to `backup_logs`, and the **Backup Health Dashboard**
  on the same screen shows the latest status (healthy / warning / no backups), the last run
  and its trigger, the archive size, and an expandable log list.

---

## 15. Application Screens & Navigation Map

| Screen | Route Path | Purpose & Capabilities |
|--------|------------|------------------------|
| *(redirect)* | `/` | Root route — redirects to today's Daily List (`/day/<today>`). Defined as a `GoRouter` redirect in `lib/app.dart`. |
| **Daily List** | `/day/:date` | Main screen: daily tasks, live timers, status changes, date navigation, drag reorder, sorting, inline calendar, morning intention card, bulk selection, and the overflow menu (Settings, Wi-Fi Sync, AirQR share, AirQR scan, Data Handoff). |
| **Create / Edit ToDo** | `/todo/new`, `/todo/:id` | Task form with live duplicate check, NFC title normalization, title autocomplete, sub-task checklist, prerequisite picker, and the RRULE recurrence editor. |
| **Time Segments** | `/todo/:id/segments` | Per-task time intervals (Auto / Manual / Interrupted badges) and the manual segment form. |
| **Copy ToDos** | `/copy?from=:date` | Wizard to pick tasks and a target date, preview skipped duplicates, and copy. |
| **Search Results** | `/search?q=:query` | FTS5 cross-day search results grouped by date, with direct navigation. |
| **Mastery Deck** | `/mastery-deck` | Spaced-repetition deck: create items, see next review dates, track levels. |
| **Statistics Dashboard** | `/statistics` | Daily Overview and Per-Item Overview tabs (`fl_chart` bar/line charts, paginated tables, title selector). |
| **Backup & Restore** | `/backup` | Passphrase-encrypted export/import, local backup file manager, and backup health dashboard. |
| **Wi-Fi Sync** | `/wifi-sync` | Host or join an encrypted local-network sync session with PIN pairing and add-only merge. |
| **AirQR Scan** | `/air-qr-scan` | Camera scanner that rebuilds a QR frame stream and imports the data. |
| **Focus view** | `/focus/:id` | Full-screen, dark, distraction-free view of one running task: large elapsed time, ambient ring, step checklist, pause and stop. |
| **Data Handoff** | `/data-handoff` | JSON and Markdown export and import. |
| **Settings** | `/settings` | Hub with cards for Appearance, Language, Time tracking, Backup, About and Permissions, plus offline policy info. |
| **Time Tracking** | `/settings/time-tracking` | Hub for how the timer behaves: Auto-stop, Timer behaviour, Pomodoro, Focus mode, and Time display. |
| **Auto-stop** | `/settings/time-tracking/auto-stop` | Never / at midnight / at a set time, plus the time picker and a plain note about the offline limit. |
| **Timer behaviour** | `/settings/time-tracking/timer` | Only one timer at a time, pause when the app is closed, keep the screen on (Android), and the shortest segment worth keeping. |
| **Pomodoro** | `/settings/time-tracking/pomodoro` | Focus blocks on/off, work and break lengths, blocks before a long break, auto-start, and a note that the alert is in-app only. |
| **Focus mode** | `/settings/time-tracking/focus` | The nudge given while a timer runs (off / vibration / sound / both), how often it comes, and the immersive full-screen switch for the Focus view. |
| **Time display** | `/settings/time-tracking/display` | Rounding in reports, how times are written, the manual entry default length, and a live sample. |
| **Appearance** | `/settings/appearance` | Hub for the look of the app: Theme Mode, Typography, and Accent Color. |
| **Accent Color** | `/settings/appearance/accent-color` | Picks the highlight colour used on buttons, chips, switches and selected labels. Presets, colour wheel, live preview, stored separately for light and dark mode. |
| **Permissions Info** | `/permissions` | Transparency screen listing the local permission categories used (storage, file picker, system clock, text processing). |
| **About App** | `/about` | App version and build from `app_config.json`, author details, AI and IDE attribution, offline guarantees, and a Unicode-first note. |

Bottom bar / navigation rail destinations: **Daily List**, **Mastery**, **Statistics**.
Everything else is reached from the app bar, the overflow menu, or Settings.

---

## 16. Summary Matrix of App Capabilities

| Feature Category | Included Capabilities |
|------------------|-----------------------|
| **Task Management** | Daily list, drag reorder, 8 sort modes, NFC title normalization, duplicate prevention, history autocomplete, inline calendar, sub-task checklists, task dependencies with blocked badge |
| **Task Statuses** | Pending, Working, Completed (locked), Dropped (sunk time), Ported (moved) |
| **Time Tracking** | Live timer (`HH:MM:SS`), multi-task concurrency, manual segment entry, startup orphaned-segment repair, segment manager screen |
| **Task Movement** | Copy wizard, atomic port to a later date, origin/destination badges |
| **Recurrence** | RFC 5545 RRULE engine (daily, weekly, monthly, yearly), `describeRrule()` text, editor inside the task form, 7-day auto-generation on launch/restore, 5-date preview, granular deletion options |
| **Spaced Repetition** | Mastery deck screen, ease factor and interval scheduling, Hard/Revision/Easy recall dialog, daily auto-generation, `#mastery` tag |
| **Daily Practice** | Morning intention card with suggestion cycling, evening reflection modal with day summary and note |
| **Bulk Operations** | Long-press multi-select, bulk complete, bulk drop, bulk copy, single transaction |
| **Undo System** | 5-second SnackBar undo, 5-deep app-bar undo history, clears on date change or 2-minute idle |
| **Search & Stats** | FTS5 cross-day search, status bar chart, per-title time line chart, paginated tables, title selector |
| **Transfer** | AirQR optical frame streaming with parity frames and CRC32, encrypted local-network Wi-Fi sync with PIN pairing and add-only merge, JSON/Markdown data handoff |
| **Security & Backup** | Device-key encrypted live database (Android Keystore / Windows DPAPI), passphrase AES-256 backup archives, integrity checks, backup logs and health dashboard, no internet or telemetry |
| **UI & UX** | Light/Dark/System theme, in-app language selector, auto RTL/LTR direction (`AdaptiveDirectionality`), English/Malayalam localization, keyboard focus traversal, responsive navigation, custom page transitions |
