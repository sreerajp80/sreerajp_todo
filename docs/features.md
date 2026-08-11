# SreerajP ToDo — Features & App Specification

## 1. App Overview & Identity

**SreerajP ToDo** is a personal, fully offline, privacy-first daily todo and time-tracking application engineered for individuals, daily planners, time-tracking professionals, multi-lingual users, and privacy-conscious users across mobile and desktop platforms. It empowers users to organize daily tasks, track precise time spent using live concurrent timers or manual segment entries, defer unfinished work across days, automate recurring task schedules using an RFC 5545 iCalendar RRULE engine, analyze productivity trends with interactive charts and paginated tables, manage encrypted database backups locally, customize appearance (Light, Dark, or System theme), and operate seamlessly in multiple languages (English and Malayalam) with dynamic, per-field text direction handling (LTR and RTL).

### Inclusive Design & Accessibility Profile
- **Multi-Lingual & Multi-Script Inclusion:** Native support for English (`en`) and Malayalam (`ml`), following the device's system language automatically (no in-app language switch), combined with per-field dynamic LTR/RTL text direction auto-detection (`unicodeUtils.detectTextDirection()`) wrapped via `AdaptiveDirectionality`. This ensures native script layout flow whether typing in Latin, Malayalam, Arabic, Hebrew, or mixed scripts.
- **Visual & Colorblind Accessibility:** Modern, hand-crafted Light and Dark visual design systems (`AppTheme.light` and `AppTheme.dark`) paired with distinct iconography (check marks, alert flags, forward arrows, crosses) alongside custom color badges, ensuring status clarity for users with color vision deficiencies.
- **Keyboard & Motor Accessibility:** Desktop and tablet keyboard focus traversal support (`FocusTraversalGroup`) enabling full Tab/Shift+Tab keyboard navigation across form fields, daily list tiles, dialogs, and navigation scaffolds for users with motor impairments or desktop productivity workflows.
- **Screen-Reader Accessibility:** Interactive elements expose explicit `Semantics` roles and labels — task tiles, the select/toggle and delete actions, status badges, and the locked-day indicator all carry screen-reader-readable labels (e.g. for TalkBack on Android or Narrator on Windows), so blind and low-vision users can navigate the daily list and task actions non-visually.
- **Cross-Device Adaptiveness:** Responsive navigation layout adapting dynamically to screen width (side `NavigationRail` for desktop/tablet screens `>=600dp` vs bottom `NavigationBar` for compact mobile screens `<600dp`), with main content width capped at `1440dp` (`kContentMaxWidthDp`) for optimal readability.
- **Offline & Digital Inclusion:** 100% offline operational guarantee with zero network permissions, zero cloud dependencies, and zero analytics, ensuring individuals in low-connectivity areas or high-security environments have equal, unmonitored digital productivity capabilities.

### Technical Profile
- **App Name:** `SreerajP ToDo`
- **Target Audience:** Daily planners, time-tracking professionals, multi-lingual users, and privacy-conscious individuals requiring 100% offline data security.
- **Platforms:** Android, Windows (v1.0 active targets); iOS, Linux, macOS (planned targets)
- **Framework & Language:** Flutter (`3.44.8 stable`) / Dart (`3.12.2`)
- **Database Storage:** Local SQLite database (`sreerajp_todo.db`) via `sqflite_sqlcipher` (mobile) / `sqflite_common_ffi` (desktop). The live database is currently opened **without** a password — device-key encryption (Android Keystore / Windows DPAPI) is a planned feature, not yet implemented. Only exported backup files are encrypted today (user passphrase, AES-256 ZIP encryption).
- **Database PRAGMAs & Migrations:** `PRAGMA journal_mode=WAL; PRAGMA foreign_keys=ON;` managed via `MigrationRunner` supporting incremental schema evolution (v1 baseline schema, v2 status sync for tasks with recorded time segments).
- **State Management:** Riverpod (`flutter_riverpod`) with root `ProviderScope` and immutable `@freezed` state objects.
- **Navigation & Routing:** `go_router` with custom cubic page transitions (`FadeTransition` + `SlideTransition` with `Curves.easeOutCubic`)
- **Adaptive Layout:** Responsive scaffold adapting to screen width (side `NavigationRail` for desktop/tablet `>=600dp` vs bottom `NavigationBar` for compact mobile `<600dp`), with content width constrained to `1440dp` (`kContentMaxWidthDp`).
- **Recurrence Engine:** iCalendar RRULE standard (RFC 5545 via `rrule` package) with human-readable sentence rendering via `describeRrule()`.
- **Data Visualization:** `fl_chart` (Bar & Line charts for daily status breakdown and item duration trends)
- **Localization:** `flutter_localizations` (Bilingual support: English `app_en.arb` & Malayalam `app_ml.arb`)
- **Unicode & Text Handling:** `unorm_dart` (NFC Unicode normalization and per-field dynamic LTR/RTL text direction detection)
- **Data & Security Policy:** 100% offline, zero network access, zero cloud synchronization, zero analytics, zero crash reporting, zero telemetry.
- **Launch Experience:** Native splash screen on app start via `flutter_native_splash`.

---

## 2. Core Architectural Guarantees & Constraints

1. **Strict Offline Enforcement:**
   - No network permissions in `AndroidManifest.xml` (no `INTERNET`, `ACCESS_NETWORK_STATE`, or `ACCESS_WIFI_STATE`).
   - No firewall rules or WinRT network capabilities requested or registered on Windows builds.
   - All runtime assets are locally bundled (`AssetImage`, `Image.asset()`, `Image.file()`). `NetworkImage` and `Image.network()` are hard-prohibited.
   - Zero external HTTP/WebSocket libraries, analytics SDKs, or telemetry tools permitted.

2. **Database Encryption Status (Live DB Not Yet Encrypted; Passphrase Backups Are):**
   - **Live Database:** Currently stored as a **plain, unencrypted** SQLite file on device (`sqflite_sqlcipher` / `sqflite_common_ffi` are used, but no password is passed when opening it). Transparent device-key encryption (Android Keystore on Android, Windows DPAPI on Windows) is a planned enhancement, not yet built — the desktop (FFI) code path does not currently support opening a password-protected database at all.
   - **Backup Archives:** Encrypted with a user-supplied passphrase (AES-256, minimum 8 characters). Exported backups (`sreerajp_todo_backup_YYYYMMDD_HHMMSS.db`) are standalone encrypted ZIP archives containing the database file, portable across devices and factory resets. This is the only encryption currently applied anywhere in the app.

3. **Immutable Past (Day Lock Constraint):**
   - Tasks assigned to any date prior to today are automatically read-only.
   - Creating new tasks backdated to past dates or mutating past-day tasks (editing title/description, changing status, toggling timers, adding manual time entries, or deleting) throws `DayLockedException` in the repository layer.
   - UI reflects locked state with a padlock icon (`locked_overlay.dart`) and disabled action controls.
   - Historical tasks remain readable, searchable, and copyable/portable to today or future dates.

4. **Unicode-First & Right-to-Left (RTL) Support:**
   - Every string written to SQLite is NFC-normalized using `unicodeUtils.nfcNormalize(value)`.
   - Title uniqueness per day is enforced after NFC normalization to prevent visually identical duplicate entries.
   - Text direction (LTR vs RTL) is dynamically auto-detected per text field using `unicodeUtils.detectTextDirection()` and rendered natively via `AdaptiveDirectionality`.

5. **Bilingual Localization (English & Malayalam):**
   - Full user interface and system messages localized in English (`app_en.arb`) and Malayalam (`app_ml.arb`).
   - The app language follows the device's system locale automatically. There is no in-app language switch — to change the app's language, the user changes their device's system language setting.

6. **Domain Exception Mapping:**
   - `DayLockedException`: Thrown on attempts to create or mutate tasks on past dates.
   - `CompletedLockException`: Thrown on attempts to start/add time segments to completed or dropped tasks.
   - `DuplicateTitleException`: Thrown on attempts to create/edit a task with a title already existing on the target date.
   - `SegmentAlreadyRunningException`: Thrown on attempts to start a second active timer on the same task.
   - `SegmentOverlapException`: Thrown on attempts to add a manual time segment overlapping an existing segment.
   - `TodoNotFoundException`: Thrown when a task lookup fails.
   - `BackupVersionTooNewException`: Thrown when attempting to restore a backup created by a newer database schema version.
   - `BackupCorruptedException`: Thrown when backup passphrase verification, archive extraction, or SQLite integrity check fails.

---

## 3. Daily Task Management & Lifecycle Features

### 3.1 Daily Task List
- **Date Navigation:** Navigate across calendar dates using previous/next day arrows, a "Today" quick jump button, a date picker modal dialog, or an inline expandable calendar view (`table_calendar`).
- **Drag-and-Drop Reordering:** Custom manual reordering of tasks within any given day's list using drag handles, updating `sortOrder` in SQLite. Drag handles are active in "Manual" sort mode and automatically hidden in auto-sort modes.
- **Task Sorting Options:** Switch dynamically between 8 list sorting modes via the sort menu:
  - Manual (custom drag-and-drop order)
  - Name A→Z
  - Name Z→A
  - Created Oldest First
  - Created Newest First
  - Most Time Tracked
  - Least Time Tracked
  - By Status
- **Task Attributes (`TodoEntity`):**
  - `id`: Unique identifier (UUID v4).
  - `date`: Assigned ISO date (`YYYY-MM-DD`).
  - `title`: Task title (NFC-normalized, unique per date).
  - `description`: Optional multi-line notes.
  - `status`: Lifecycle state (`pending`, `working`, `completed`, `dropped`, `ported`).
  - `portedTo`: Target date reference for ported tasks (`YYYY-MM-DD`).
  - `sourceDate`: Original date reference for copied/ported tasks (`YYYY-MM-DD`).
  - `recurrenceRuleId`: Identifier linking task to its parent recurrence rule (if applicable).
  - `sortOrder`: Integer position order in the daily list.
  - `createdAt`: ISO 8601 creation timestamp.
  - `updatedAt`: ISO 8601 modification timestamp.
  - *Note:* Total tracked time (`HH:MM:SS`) shown on a task is **not** a stored
    field — it is calculated on the fly from that task's time segments.

### 3.2 Task Lifecycle & Terminal Status Lock
- **`pending`**: Default status upon creation. Timers can be started and stopped freely.
- **`working`**: In-progress state assigned automatically when a task has at least one recorded time segment.
- **`completed`**: Terminal state indicating completion. Running timers are automatically stopped and finalized. Timer controls are hidden and new time segments cannot be added (`CompletedLockException` enforced at repository level).
- **`dropped`**: Terminal state indicating abandonment (e.g., priority shift or cancelled work). Running timers are automatically stopped. Tracked time is recorded separately as "dropped time" in analytics. Requires explicit confirmation dialog.
- **`ported`**: State indicating the task was deferred/moved to a future date. Requires picking a target date and explicit confirmation dialog. Generates a fresh `pending` copy on the target date.
- **Status Transitions:** Allowed transitions include `pending -> working -> completed`, `pending -> completed`, `pending -> working -> dropped`, `pending -> dropped`, `ported`. Terminal status changes can be modified between terminal states or reverted via Undo.

### 3.3 Granular Deletion & Recurring Task Options
- **Standard Task Deletion:** Single task deletion requires confirmation and cleans up associated time segments.
- **Recurring Task Deletion:** Deleting a task generated by a recurrence rule presents granular options:
  - *Delete only this occurrence* (`deleteOnlyThis`)
  - *Delete this and future occurrences* (`deleteThisAndFuture`)
  - *Delete all occurrences and remove rule* (`deleteAllOccurrences`)

### 3.4 Duplicate Detection & Real-time Validation
- Enforces strict single-title uniqueness per calendar day.
- Live debounced validation in task creation/editing form warns the user immediately if the NFC-normalized title matches an existing task on the selected date (`DuplicateTitleException`).

### 3.5 History-Wide Title Autocomplete
- When typing a task title, the app queries historical task titles across all dates.
- Shows up to 20 prefix-matched autocomplete suggestions (with 300ms debouncing) to maintain naming consistency.

---

## 4. Time Tracking & Segment Management

### 4.1 Live Timer
- **Start / Stop Control:** Tap Start (▶) to begin tracking time; tap Stop (⏹) to end the active segment.
- **Real-Time Display:** Displays live counting duration formatted as `HH:MM:SS` updated via `liveTimerProvider` stream ticks.
- **Multi-Task Timer Concurrency:**
  - Multiple *different* tasks can run active timers simultaneously.
  - At most *one* open segment is permitted per task (attempting to start a second segment on the same task throws `SegmentAlreadyRunningException`).

### 4.2 Manual Time Entry & Segment Manager
- Per-task **Time Segments Screen** (`/todo/:id/segments`) detailing all recorded time intervals.
- Retroactively add manual time segments with start time, end time, non-overlapping interval validation (`SegmentOverlapException`), and same-day bounds checks.
- **Time Segment Attributes (`TimeSegmentEntity`):**
  - `id`: Unique identifier (UUID v4).
  - `todoId`: Foreign key reference to parent task `id`.
  - `startTime`: ISO 8601 start timestamp.
  - `endTime`: ISO 8601 end timestamp (null while segment is actively running).
  - `durationSeconds`: Calculated segment duration in seconds (null while running).
  - `interrupted`: Boolean flag (`true` if segment was force-closed by startup repair or past-day lock).
  - `manual`: Boolean flag (`true` for retroactive manual entries, `false` for live timer entries).
  - `createdAt`: ISO 8601 creation timestamp.
- **Visual Badges:**
  - **"M" (Manual)** badge for retroactive manual entries.
  - **Timestamped range** for auto-recorded live timer segments.
  - **Warning indicator (!)** for interrupted or repaired segments.

### 4.3 Automatic Orphaned Segment Repair
- On app launch, `RepairOrphanedSegments` scans for open segments on past-day tasks (e.g., left running when app/device closed unexpectedly).
- Automatically closes orphaned past segments with 0 duration and sets `interrupted = 1`.

---

## 5. Task Progression & Movement (Copy & Port)

### 5.1 Copy Tasks Wizard
- **Screen:** `/copy`
- Multi-step wizard to duplicate one or multiple selected tasks from any day to today or a future target date.
- Supports pre-selected task lists passed via route arguments from bulk multi-selection.
- Original tasks remain untouched in their existing state and day.
- Target tasks are created as fresh `pending` tasks with zero time segments.
- Automatically skips copying if a task with the exact NFC-normalized title already exists on the target date.
- Displays an origin badge ("Copied from YYYY-MM-DD") on newly created tasks.

### 5.2 Port Tasks
- Atomic operation moving an active task forward to a target date (tomorrow or later).
- Marks original task as `ported` with target date reference ("→ YYYY-MM-DD").
- Creates a new `pending` task on target date ("Copied from YYYY-MM-DD").
- Time segments remain on original task and start fresh on new target task.

---

## 6. Recurring Tasks Engine (iCalendar RRULE)

- **RFC 5545 Compliance:** Built on the iCalendar RRULE specification via `rrule` package.
- **Integrated Recurrence Editor:** Configured directly inside the Create/Edit ToDo screen (`/todo/new`, `/todo/:id`) via `RepeatOptionPicker` and `rrule_frequency_picker` / `rrule_preview` modal bottom sheet.
- **Natural Language Parsing:** Converts raw RRULE strings into human-readable descriptions (e.g., *"Every 2 weeks on Monday and Thursday"*, *"Monthly on day 15"*, *"Annually on March 22"*, *"Every weekday"*, *"Every weekend"*) via `describeRrule()`.
- **Frequencies & Patterns:** Daily, Weekly, Monthly, Yearly with custom intervals (e.g., every 3 days, every 2 weeks), specific weekdays (e.g., Mon + Thu, Weekdays, Weekends), and ending criteria (*Never*, *On Date*, *After Days*).
- **Recurrence Rule Attributes (`RecurrenceRuleEntity`):**
  - `id`: Unique identifier (UUID v4).
  - `title`: Template title for generated tasks.
  - `description`: Optional template notes.
  - `rrule`: Standard RFC 5545 iCalendar recurrence rule string.
  - `startDate`: ISO date string (`YYYY-MM-DD`) when recurrence rule becomes effective.
  - `endDate`: Optional ISO date string (`YYYY-MM-DD`) when recurrence rule expires.
  - `active`: Boolean flag indicating if rule actively generates tasks (`true`/`false`).
  - `createdAt`: ISO 8601 creation timestamp.
  - `updatedAt`: ISO 8601 modification timestamp.
- **Real-Time Occurrence Preview:** Displays a live 5-date preview widget (`rrule_preview.dart`) calculating upcoming execution dates.
- **Automatic Task Generation:** On app launch, backup restore, or task creation/update, `GenerateRecurringTasks` scans active rules and generates task instances for a 7-day look-ahead window (`[today, today + 7 days]`). Skips generation if title already exists on target date.
- **Generated Task Indicator:** Tasks generated by recurrence rules display a repeat badge (🔁).

---

## 7. Bulk Operations & Multi-Select UX

- **Trigger:** Long-press any task on the daily list to activate selection mode.
- **Selection Actions:**
  - **Bulk Complete:** Marks all selected tasks as `completed` and closes any open timers in a single transaction.
  - **Bulk Drop:** Marks all selected tasks as `dropped` in a single transaction.
  - **Bulk Copy:** Pre-loads selected tasks into the Copy Tasks wizard.
- **Transactional Consistency:** All bulk status updates execute within a single SQLite transaction.

---

## 8. Undo System & History Protection

- **5-Second Toast (SnackBar):** Immediate undo prompt following any status change, port action, or bulk operation. Undoing a port or copy operation automatically deletes the newly generated tasks.
- **Persistent App-Bar Undo Button (`↩`):** Persistent undo button in the app bar managing an in-memory stack of up to 5 recent status modifications.
- **Stack Invalidation:** Undo stack automatically clears upon date navigation or 2 minutes of user inactivity.

---

## 9. Cross-Day History Search

- **Screen:** `/search`
- Substring search matching any part of a task title across all recorded dates (`/search?q=query`).
- Search results grouped chronologically by date.
- Full Unicode, multi-script, and bilingual search capability.
- Tapping a search result navigates directly to that date's Daily List screen.

---

## 10. Statistics & Productivity Analytics Dashboard

### 10.1 Daily Overview Tab
- **Date Range Filters:** Last 7 days, Last 30 days, All time, Custom date range.
- **Status Breakdown Bar Chart (`fl_chart`):** Visual distribution of task counts by status (`pending`, `working`, `completed`, `dropped`, `ported`) — five bars per day.
- **Summary Metrics Cards:** Five cards — total task count, average completed tasks per day, average time spent per day, total productive time (time on completed tasks), and total dropped time (time on dropped tasks).
- **Daily Metrics Data Table:** Paginated table (20 rows/page) with one row per day, columns: Date, Total, Pending, Working, Completed, Dropped, Ported, and combined Total Time. (The productive-vs-dropped time split is shown only as the two aggregate summary cards above, not as per-day table columns.)

### 10.2 Per-Item Overview Tab
- **Task Title Selector:** Dropdown to pick a specific task title, filtering the chart and table below to that title.
- **Time Trend Line Chart (`fl_chart`):** Visualizes tracked time (minutes) per task title over time across dates.
- **Title Summary Table:** Paginated table (20 rows/page) showing task appearance count, pending count, working count, completion count, dropped count, ported count, and total accumulated time.

---

## 11. Database Backup, Restore & Data Portability

### 11.1 Export Backup
- Creates a portable, standalone passphrase-encrypted ZIP archive containing SQLite database (`sreerajp_todo_backup_YYYYMMDD_HHMMSS.db`).
- Encrypts the archive using a user-defined passphrase (AES-256 / ZIP password encryption, minimum 8 characters).
- Performs WAL checkpointing, temporary copy generation, archive password encryption, and SQLite integrity validation before final write.

### 11.2 Import Restore
- Restores an exported backup file selected via system file picker.
- Validates user passphrase, checks schema version compatibility (runs automatic migrations for older versions, rejects newer versions via `BackupVersionTooNewException`), executes `PRAGMA integrity_check` validation, replaces the live database atomically with the restored (currently unencrypted) database file, and triggers automatic recurring task generation.

### 11.3 Local Backup Management
- View, inspect (date, file size), and delete stored local backup files directly within the Backup screen (`/backup`).

---

## 12. Application Screens & Navigation Map

| Screen | Route Path | Purpose & Capabilities |
|--------|------------|------------------------|
| *(redirect)* | `/` | Root route — redirects to today's Daily List (`/day/<today>`). No dedicated screen; defined as a `GoRouter` redirect in `lib/app.dart`. |
| **Daily List** | `/day/:date` | Main screen showing daily tasks, live timers, status updates, date navigation, drag reordering, dynamic sorting, inline calendar view, and bulk selection. |
| **Create / Edit ToDo** | `/todo/new`, `/todo/:id` | Task form with real-time duplicate validation, NFC title normalization, history title autocomplete, and integrated iCalendar RRULE recurrence editor. |
| **Time Segments** | `/todo/:id/segments` | Per-task list of tracked time intervals (Auto vs Manual vs Interrupted badges) and retroactive manual segment entry form. |
| **Copy ToDos** | `/copy?from=:date` | Multi-step wizard to select tasks, target date, preview duplicate skips, and copy tasks. |
| **Search Results** | `/search?q=:query` | Cross-day title search results grouped chronologically by date with direct navigation. |
| **Statistics Dashboard** | `/statistics` | Productivity metrics with Daily Overview and Per-Item Overview tabs (`fl_chart` bar/line charts, paginated tables, title selector). |
| **Backup & Restore** | `/backup` | Passphrase-encrypted export/import backup system and local backup file manager. |
| **Settings** | `/settings` | System/Light/Dark theme selector, navigation shortcuts, and offline security policy info. |
| **Permissions Info** | `/permissions` | Transparency screen listing implicit local permission categories used (storage, file picker access, system clock, text processing) and confirming no explicit network/privacy permissions are required. |
| **About App** | `/about` | Displays app version, build date, author metadata, AI pair-programming attribution, offline guarantees, a Unicode-first input note, and a "built for daily navigation flow" note. |

---

## 13. Summary Matrix of App Capabilities

| Feature Category | Included Capabilities |
|------------------|-----------------------|
| **Task Management** | Daily list, drag reorder, dynamic sorting (manual, name A→Z/Z→A, created oldest/newest, most/least time tracked, status), NFC title normalization, duplicate prevention, history autocomplete, inline calendar view |
| **Task Statuses** | Pending, Working, Completed (locked), Dropped (sunk time), Ported (moved) |
| **Time Tracking** | Live timer (`HH:MM:SS`), multi-task concurrency, manual segment entry, automatic startup orphaned segment repair, segment manager screen |
| **Task Movement** | Task copy wizard, atomic port to future date, origin/destination tracking badges |
| **Recurrence** | iCalendar RFC 5545 RRULE engine (daily, weekly, monthly, yearly), natural language parser (`describeRrule()`), integrated editor in task form, 7-day auto-generation on launch/restore, 5-date preview, granular deletion options |
| **Bulk Operations** | Multi-select long-press, bulk complete, bulk drop, bulk copy, single transaction execution |
| **Undo System** | 5-second SnackBar undo, 5-depth app-bar undo history, auto-clears on date change / 2-min idle |
| **Search & Stats** | Cross-day search, status bar charts (`fl_chart`), title time line charts, paginated tables, per-title selector |
| **Security & Backup**| Passphrase-protected AES-256 backup encryption (live database is not yet encrypted), backup integrity check, zero network/telemetry |
| **UI & UX** | Light/Dark/System theme, auto RTL/LTR text direction (`AdaptiveDirectionality`), English/Malayalam localization, keyboard focus traversal, responsive navigation, custom page transitions |
