# SreerajP ToDo

A personal, fully offline daily ToDo and time-tracking app built with Flutter. Every piece of
data stays on your device — no accounts, no cloud, no internet required.

---

## Table of Contents

- [What This App Does](#what-this-app-does)
- [Screenshots](#screenshots)
- [Installation](#installation)
- [Build Instructions](#build-instructions)
- [Offline Guarantee](#offline-guarantee)
- [Features at a Glance](#features-at-a-glance)
- [How the App Works](#how-the-app-works)
  - [Daily ToDo List](#daily-todo-list)
  - [Creating and Editing a ToDo](#creating-and-editing-a-todo)
  - [Task Statuses](#task-statuses)
  - [Undo After a Status Change](#undo-after-a-status-change)
  - [Day Lock (Past Days Are Read-Only)](#day-lock-past-days-are-read-only)
  - [Time Tracking](#time-tracking)
  - [Manual Time Entry](#manual-time-entry)
  - [Copy and Port](#copy-and-port)
  - [Recurring Tasks](#recurring-tasks)
  - [Bulk Operations](#bulk-operations)
  - [Cross-Day Search](#cross-day-search)
  - [Title Autocomplete](#title-autocomplete)
  - [Statistics Dashboard](#statistics-dashboard)
- [How the App Stores Data](#how-the-app-stores-data)
- [Exporting and Importing Data (Backup and Restore)](#exporting-and-importing-data-backup-and-restore)
  - [Exporting a Backup](#exporting-a-backup)
  - [Restoring from a Backup](#restoring-from-a-backup)
  - [What Happens During Export](#what-happens-during-export)
  - [What Happens During Import](#what-happens-during-import)
  - [Managing Backups](#managing-backups)
- [Permissions](#permissions)
  - [Permissions the App Needs](#permissions-the-app-needs)
  - [Permissions the App Does NOT Have](#permissions-the-app-does-not-have)
- [Unicode and Language Support](#unicode-and-language-support)
- [Supported Platforms](#supported-platforms)
- [App Screens](#app-screens)
- [Privacy and Security](#privacy-and-security)
- [Known Limitations](#known-limitations)

---

## What This App Does

SreerajP ToDo is a personal daily task manager that helps you:

- **Plan your day** by creating a list of tasks for each calendar date.
- **Track time** spent on each task using a built-in start/stop timer (or by entering time
  manually).
- **Review past days** with a read-only view of what you accomplished.
- **Move unfinished tasks forward** by copying or porting them to a future date.
- **Analyse your productivity** through charts and tables that show how you spend your time
  across days and tasks.
- **Back up and restore** your entire database to a file on your device, so you never lose
  your data.

The app is designed to work **entirely offline**. It never connects to the internet, never
sends data anywhere, and never requires an account or login. You own your data completely.

---

## Screenshots

Release screenshots should be captured from the final v1.0 builds and added here before any
public-facing distribution:

- `docs\screenshots\daily_list.png` - daily list screen
- `docs\screenshots\statistics.png` - statistics dashboard
- `docs\screenshots\time_tracking.png` - time-tracking and segments flow

---

## Installation

### Android

1. Copy `build\app\outputs\flutter-apk\app-release.apk` to the device.
2. Enable sideloading for the installer if Android prompts for it.
3. Install the APK from the device file manager.
4. Launch the app and verify it runs normally in airplane mode.

### Windows

1. Copy the entire `build\windows\x64\runner\Release\` folder to the target machine.
2. Keep the folder contents together; do not move the `.exe` out on its own.
3. Run `sreerajp_todo.exe`.
4. Verify the app runs normally with the network adapter disabled.

---

## Build Instructions

### Prerequisites

- Flutter `3.41.4` stable
- Dart `3.11.1`
- Android release signing files at `L:\Android\key.properties` and `L:\Android\key.properties.jks`

### Android

```powershell
flutter pub get
flutter build apk --debug
flutter build apk --release
flutter build appbundle --release
```

Android builds automatically regenerate the About screen version and build date from `pubspec.yaml` and the current local date before compilation.

### Windows

```powershell
flutter pub get
.\tool\refresh_build_metadata.ps1
flutter build windows --release
```

### Release Validation

```powershell
dart format lib/ test/ integration_test/
flutter analyze
flutter test
flutter test integration_test/app_test.dart
flutter pub deps --json | Select-String -Pattern "http|socket|firebase|supabase|sentry|crashlytics|analytics|dio|chopper|retrofit|amplitude|mixpanel|datadog"
Select-String -Path "android\app\src\main\AndroidManifest.xml" -Pattern "INTERNET|NETWORK"
Select-String -Path "build\app\intermediates\merged_manifests\release\AndroidManifest.xml" -Pattern "INTERNET|NETWORK"
Select-String -Path "lib\**\*.dart" -Pattern "Image\.network|NetworkImage" -Recurse
Test-Path "build\windows\x64\runner\Release\sqlite3.dll"
```

More detail is in [docs/release_process.md](/l:/Android/sreerajp_todo/docs/release_process.md).

---

## Offline Guarantee

SreerajP ToDo is intentionally built to function with zero network access:

- No internet permission is declared in the Android manifest.
- No network or telemetry package is included in the dependency graph.
- No data is sent to cloud services, analytics systems, or remote APIs.
- The Android release APK and the Windows portable build are both intended to be smoke-tested
  with Wi-Fi and mobile data disabled before release.

If a dependency or build artifact ever introduces network access, that release is treated as
blocked until the issue is removed.

---

## Features at a Glance

| Feature | Description |
|---------|-------------|
| Daily task list | Create, edit, delete, and reorder tasks for any day |
| Four task statuses | Pending, Completed, Dropped, Ported |
| Time tracking | Start/stop timer with live display; multiple timers can run at once |
| Manual time entry | Add a time segment by picking start and end times |
| Recurring tasks | Define tasks that auto-create on a schedule (daily, weekly, monthly, yearly) |
| Copy tasks | Copy one or more tasks to another day |
| Port tasks | Move a task to a future day (marks original as ported) |
| Bulk operations | Long-press to select multiple tasks and change their status at once |
| Undo | 5-second undo after any status change or bulk operation |
| Day lock | Past days are automatically read-only |
| Cross-day search | Search for a task title across your entire history |
| Title autocomplete | Suggests titles from past tasks as you type |
| Statistics | Charts and tables showing completion rates and time spent |
| Backup and restore | Export your database to a file; restore it later |
| Full Unicode | Supports every script and language, including right-to-left text |
| Light and dark themes | Follows your device's theme setting |
| Responsive layout | Adapts to phones, tablets, and desktop windows |

---

## How the App Works

### Daily ToDo List

When you open the app, you see today's task list. Each task shows:

- Its **title**
- A colour-coded **status badge** (pending, completed, dropped, or ported)
- The **total time** tracked for that task (in `HH:MM:SS` format)
- A **start/stop button** for the timer (only on today's tasks that are still pending)
- An **action menu** with options to edit, delete, port, or copy the task

You can navigate between days using the **left/right arrows** in the header, tap the
**calendar icon** to jump to any date, or tap the **"Today" button** to return to the
current date.

Tasks can be **reordered by dragging** them up or down in the list.

### Creating and Editing a ToDo

Tap the **floating action button (+)** on today's list to create a new task. You will see:

- A **title field** (required) — as you type, the app suggests titles from tasks you have
  created before. The title must be unique for that day; the app warns you in real time if
  a duplicate is detected.
- A **description field** (optional) — for longer notes about the task.
- A **status selector** — choose Pending, Completed, Dropped, or Ported.

When you save, the app normalises the title text (using Unicode NFC normalisation) so that
visually identical characters are always stored consistently, then checks for duplicates,
and writes the task to the database.

To edit an existing task, tap it or choose "Edit" from the action menu.

### Task Statuses

Every task has one of four statuses:

| Status | Meaning | What happens |
|--------|---------|--------------|
| **Pending** | Not yet acted on | This is the default. You can start/stop the timer and edit the task freely. |
| **Completed** | Done | The timer is permanently stopped for this task. No new time segments can be added. The start/stop button is hidden. |
| **Dropped** | No longer being pursued | The task has been abandoned — whether because it became irrelevant, priorities shifted, or it simply could not be done. Any running timer is stopped and no new time can be tracked. In statistics, time spent on dropped tasks is reported separately from completed tasks as "dropped time" (not counted as productive time). |
| **Ported** | Moved to another day | The task is marked as moved. You pick a target date (tomorrow or later), and the app creates a fresh copy of the task on that date with "pending" status. Time tracking does not carry over — it starts fresh on the new day. |

Once a task is marked as completed, dropped, or ported, these are considered **terminal
statuses**. You can still change between terminal statuses (e.g., from "completed" to
"dropped"), but the app provides undo protection in case you tapped by mistake.
Additionally, changing to **dropped** or **ported** requires a **confirmation dialog**
before the change is applied — this prevents accidental taps on destructive actions.

### Undo After a Status Change

The app provides **two ways to undo** a status change:

**1. SnackBar (immediate)**

Every time you change a task's status (or change multiple tasks at once using bulk
operations), a **SnackBar** appears at the bottom of the screen with an **"Undo"** button.

- The SnackBar auto-dismisses after **5 seconds**.
- Tapping "Undo" immediately reverts the status change.
- If you ported a task (which created a copy on the target day), the undo also **deletes
  the copy** that was created.
- For bulk operations, a single "Undo" reverts the entire batch.

**2. Undo button in the app bar (persistent)**

If you miss the SnackBar, a persistent **undo button (↩)** appears in the app bar whenever
there are recent changes that can be undone.

- The button is visible as long as the undo history is non-empty.
- Tapping it undoes the **most recent** change, one step at a time.
- The app remembers the **last 5 status changes**.
- The undo history clears when you navigate to a different day or after **2 minutes** of
  inactivity.

This means you have a much larger window to undo mistakes — not just the 5-second SnackBar.

### Day Lock (Past Days Are Read-Only)

Any task whose date is **before today** is automatically locked. This means:

- You **cannot edit** the title, description, or status.
- You **cannot start or stop** the timer.
- You **cannot delete** the task.
- You **cannot add manual time entries**.
- A **padlock icon** appears on locked tasks.
- All interactive controls are greyed out and disabled.

This lock is enforced both in the user interface and in the database layer — there is no
way to bypass it through the app. It ensures that your historical record remains
unchanged.

You can still **view** past days, **search** across them, and **copy** tasks from a past
day to today or a future day.

### Time Tracking

Each pending task on today's list has a **start/stop button**:

1. Tap **Start (▶)** to begin tracking time. A live timer appears, counting up every second.
2. Tap **Stop (⏹)** to end the current time segment. The elapsed time is saved.
3. You can start and stop as many times as you like — each start/stop pair creates a separate
   **time segment**.

**Key rules:**

- Only **one timer** can be running per task at any time. You must stop the current segment
  before starting a new one on the same task.
- **Different tasks** can have timers running simultaneously. For example, you might track
  time on "Meeting" and "Note-taking" at the same time.
- Once a task is marked **completed**, the timer is permanently stopped and the start/stop
  button is hidden.
- Timers only work on **today's** tasks. Past-day tasks are locked.

**What happens if the app closes unexpectedly?**

If you force-close the app or your device restarts while a timer is running, the app detects
the orphaned timer the next time it starts up. It automatically closes the timer with **zero
duration** and marks it as "interrupted" (shown with a warning icon in the segments list).

To view all time segments for a task, tap the task and navigate to the **Time Segments**
screen. Each segment shows its start time, end time, duration, and type (auto-recorded or
manually entered).

### Manual Time Entry

If you forgot to start the timer, you can add a time segment manually:

1. Open the **Time Segments** screen for a task (only works for today's pending tasks).
2. Tap **"Add Manual Segment"**.
3. Pick a **start time** and **end time** using the time pickers.
4. The app validates that:
   - The start time is before the end time.
   - The times do not overlap with any existing segment for that task.
   - Both times fall on today's date.
5. The duration is calculated automatically and the segment is saved with an **"M" badge**
   to distinguish it from auto-recorded segments.

### Copy and Port

These two features let you move tasks between days:

**Copy** — duplicates tasks to another day without changing the originals.

1. Open the **action menu** on a task and choose "Copy", or enter **multi-select mode**
   (long-press) and tap the "Copy" button.
2. Select which tasks to copy.
3. Pick a **target date** (today or any future date).
4. Review the list and confirm.
5. New tasks are created on the target date with "pending" status. The original tasks are
   unchanged.
6. If a task with the same title already exists on the target date, it is **skipped** and
   you see a warning.
7. Time segments are **not** copied — tracking starts fresh on the new day.
8. Copied tasks show a small "Copied from YYYY-MM-DD" note below the title.

**Port** — moves a task forward and marks the original as "ported".

1. Edit a task and change its status to **Ported**.
2. A date picker appears — choose the target date (tomorrow or later).
3. The app **atomically** (in one operation):
   - Marks the original task as "ported" with a reference to the target date.
   - Creates a new "pending" copy on the target date.
4. The original shows a "→ YYYY-MM-DD" badge. The copy shows "Copied from YYYY-MM-DD".
5. Time segments are **not** carried over.
6. You can **undo** within 5 seconds — the original reverts and the copy is deleted.

### Recurring Tasks

Instead of manually creating or copying the same task every day (or every Monday, etc.),
you can define a **recurrence rule** that auto-creates tasks on matching dates.

**Setting up a recurring task:**

1. Open the **Recurring Tasks** screen (from the navigation menu).
2. Tap the **+** button to create a new rule.
3. Fill in:
   - **Title** — the task name (with autocomplete from your history).
   - **Description** — optional notes.
   - **Frequency** — Daily, Weekly, Monthly, or Yearly.
   - **Interval** — e.g., "Every 2 weeks" or "Every 3 days".
   - **Specific days** — for weekly: pick which days (Mon, Tue, etc.). For monthly: pick
     a date or an ordinal weekday (e.g., "1st Monday", "Last Friday").
   - **Start date** — when the recurrence begins (default: today).
   - **End date** — optional. Leave blank for "no end date".
4. A **preview** shows the next 5 dates when the task will be created.
5. Save the rule.

**How generation works:**

- Every time you open the app, the app checks all active recurrence rules and generates
  tasks for **today and the next 7 days**.
- If a task with the same title already exists on a target date (because you created it
  manually, or from a previous generation), it is **skipped** — no duplicates are created.
- Generated tasks show a small **repeat icon (🔁)** on the daily list. Tapping it takes you
  to the rule editor.

**Managing rules:**

- **Pause** a rule to temporarily stop generation without deleting it.
- **Delete** a rule to stop it permanently. Tasks already generated remain untouched.
- **Edit** a rule to change the frequency, days, or end date. Future generated tasks will
  follow the updated rule.

**Recurrence uses the iCalendar RRULE standard (RFC 5545)**, which supports:

| Pattern | Example |
|---------|---------|
| Every day | "Daily" |
| Every weekday | "Weekly on Mon, Tue, Wed, Thu, Fri" |
| Specific days | "Weekly on Monday and Thursday" |
| Every N days | "Every 3 days" |
| Monthly by date | "Monthly on the 15th" |
| Monthly by weekday | "Monthly on the 1st Monday" |
| Yearly | "Yearly on March 15" |

**Generated tasks behave like any other task.** You can edit their title, track time, change
their status, copy, or port them. Editing a generated task only changes that specific
instance — it does not affect the recurrence rule or future tasks.

### Bulk Operations

Long-press on any task to enter **multi-select mode**. Tap additional tasks to add them to
the selection. The app bar changes to show:

- **"X selected"** — the count of selected tasks.
- **"Complete All"** — marks all selected tasks as completed (closes any running timers).
- **"Mark Dropped"** — marks all selected tasks as dropped.
- **"Copy"** — opens the copy wizard with the selected tasks pre-loaded.

All bulk status changes happen in a **single database transaction** (all succeed or all
fail). A single "Undo" SnackBar lets you revert the entire batch.

Bulk **port** is not available because each port requires choosing a different target date.

### Cross-Day Search

Tap the **search icon** in the app bar to search for a task title across your entire history.

- Type a search term and results appear grouped by date.
- The search matches any part of the title (not just the beginning).
- Tap a result to navigate to that day's task list.
- The search is Unicode-aware — you can search in any language or script.

### Title Autocomplete

When you create or edit a task, the title field offers **autocomplete suggestions** drawn
from every title you have ever used across all dates.

- Suggestions appear as you type, filtered by prefix.
- Up to 20 suggestions are shown at a time.
- Selecting a suggestion fills in the title field.
- This helps maintain consistent naming and avoids typos.

### Statistics Dashboard

The Statistics screen gives you insight into your productivity over time. It has two tabs:

**Daily Overview:**

- A **date range filter** lets you view the last 7 days, last 30 days, all time, or a
  custom range.
- A **bar chart** shows the count of tasks per day, colour-coded by status: completed
  (green), dropped (red), ported (amber), pending (grey).
- **Summary cards** show: total tasks all-time, average completed per day, average time
  per day.
- A **data table** lists each day with columns: date, total tasks, completed, dropped,
  ported, pending, total time. The table shows 20 rows per page with pagination controls.
- Time spent on **completed** tasks and **dropped** tasks is reported separately —
  completed time counts as productive, dropped time counts as sunk cost.

**Per-Item Overview:**

- A **search bar** lets you find a specific task title.
- A **line chart** shows time spent on the selected title over time (minutes on the Y-axis,
  dates on the X-axis).
- A **data table** lists each title with columns: title, number of appearances, completed
  count, dropped count, ported count, total time. Paginated at 20 rows per page.
- Tapping a row shows a **calendar view** of which days that task appeared and what its
  status was.

---

## How the App Stores Data

All data is stored in a **single encrypted SQLite database file** on your device's local
filesystem.

- **Location:** The app's private documents directory (determined automatically by the
  operating system). On Android, this is typically under
  `/data/data/in.sreerajp.sreerajp_todo/databases/`. On Windows, it is in the app's
  AppData directory.
- **Format:** SQLite database file (`.db`), encrypted with **AES-256**.
- **Encryption:** The database is encrypted at rest using **AES-256** with a dual-key
  approach:
  - **For daily use:** A device-derived key (Android Keystore on Android, Windows DPAPI on
    Windows) encrypts the live database. This is completely transparent — you never see,
    enter, or manage the key. It is generated automatically on first launch.
  - **For backups:** When you export a backup, the app asks you to set a **passphrase**.
    The backup file is re-encrypted with your passphrase instead of the device key. This
    means backups are **portable** — you can restore them on a different device, or after
    a factory reset, as long as you remember the passphrase.
- **Encoding:** All text is stored as UTF-8.
- **Reliability:** The database uses Write-Ahead Logging (WAL mode) for crash resilience
  and foreign key constraints for data integrity.

The database contains three tables:

**Tasks (`todos`)** — one row per task per day, storing the title, description, status,
date, display order, and timestamps.

**Time Segments (`time_segments`)** — one row per start/stop pair, linked to a task. Stores
start time, end time, computed duration in seconds, and flags for whether the segment was
interrupted (auto-closed on restart) or manually entered.

**Recurrence Rules (`recurrence_rules`)** — one row per recurring task template, storing
the title, description, iCalendar RRULE string, start/end dates, and active/paused state.
Tasks generated from these rules are stored in the `todos` table like any other task.

**No data is stored anywhere else.** There is no cloud database, no shared preferences synced
to an account, no remote server, and no temporary files outside the app's sandbox.

---

## Exporting and Importing Data (Backup and Restore)

The Backup screen is accessible from the app's main menu or navigation rail.

### Exporting a Backup

1. Open the **Backup** screen.
2. Tap **"Export Backup"**.
3. The app asks you to **set a passphrase** for this backup (minimum 8 characters). You must
   confirm it by typing it twice. **Write this passphrase down** — if you forget it, the
   backup cannot be recovered.
4. Choose where to save the file (a file picker appears, or the app uses a default directory
   like Downloads).
5. The app creates a file named `sreerajp_todo_backup_YYYYMMDD_HHMMSS.db` — this is a
   complete, encrypted copy of your database.
6. A success message confirms the export and shows the file path.

The exported file is an **encrypted** SQLite database protected by your passphrase. It
contains **all** your tasks, time segments, and metadata. You can copy it to a USB drive,
move it to another device, or keep it as an archive.

**Backups are portable.** Unlike the live database (which uses a device-specific key), backup
files are encrypted with **your passphrase**. This means you can restore a backup on a
different device, or after a factory reset — as long as you know the passphrase.

### Restoring from a Backup

1. Open the **Backup** screen.
2. Tap **"Restore from Backup"**.
3. Select a `.db` backup file using the file picker.
4. The app asks you to **enter the passphrase** you set when the backup was created.
5. A confirmation dialog appears: **"This will replace ALL current data. This cannot be
   undone."**
6. If you confirm, the app validates the backup file (see below) and replaces the current
   database.
7. The app restarts with the restored data.

### What Happens During Export

Behind the scenes, the export process:

1. **Flushes** the Write-Ahead Log to ensure all pending writes are in the main database
   file.
2. **Closes** the database connection to ensure no writes are in progress.
3. **Creates a temporary copy** of the database file.
4. **Re-encrypts** the copy from the device key to your passphrase. After this step, the
   backup file is no longer tied to your device — anyone with the passphrase can open it.
5. **Verifies** the re-encrypted copy by opening it with the passphrase and running
   SQLite's built-in integrity check.
6. **Moves** the verified copy to the destination path.
7. **Reopens** the original database and resumes normal operation.

If any step fails, the export is aborted and an error message is shown. Your original
database is never modified during export.

### What Happens During Import

Behind the scenes, the import process:

1. **Attempts to open** the backup file using the passphrase you entered.
   - If the passphrase is wrong, the import fails with: "Incorrect passphrase or corrupted
     backup file." You can try again with a different passphrase.
2. **Checks the schema version**:
   - If the backup is from an **older** version of the app, the app automatically runs the
     necessary migrations to bring it up to date.
   - If the backup is from a **newer** version of the app (i.e., you downgraded the app),
     the import is **rejected** with an error message.
3. **Runs an integrity check**:
   - If the file is corrupted, the import is **rejected** with an error message.
4. **Closes** the current database connection.
5. **Re-encrypts** the imported file from your passphrase to the current device's key (so
   it works transparently during daily use).
6. **Replaces** the current database file with the re-encrypted file.
7. **Reopens** the database and restarts the app.

If anything fails during steps 1–3, the current database is untouched. The replacement only
happens after all validation passes.

### Managing Backups

The Backup screen also shows a **list of recent backups** in the default backup directory,
with each file's date, size, and a delete button. You can remove old backups you no longer
need.

---

## Permissions

### Permissions the App Needs

| Permission | Platform | Why |
|------------|----------|-----|
| Local file storage | Android, Windows | To create and read the SQLite database file in the app's private directory. This is an implicit permission — the operating system grants it automatically to every app for its own data directory. |
| External storage access | Android (for backup) | When exporting or importing a backup file to/from a user-accessible location (e.g., Downloads). The `file_picker` package handles the platform-specific permission prompts. |
| File system access | Windows (for backup) | When selecting a save/open location for backup files via the file picker dialog. |

### Permissions the App Does NOT Have

The app **explicitly does not request** and **does not have** the following permissions:

| Permission | Why it is absent |
|------------|-----------------|
| `INTERNET` | The app never connects to the internet. This permission is deliberately absent from the Android manifest, which means the Android OS will block any network access at the system level — even if a bug in a third-party library tried to make a connection. |
| `ACCESS_NETWORK_STATE` | The app does not check or monitor network connectivity. |
| `ACCESS_WIFI_STATE` | The app does not interact with Wi-Fi in any way. |
| Camera | Not needed — there is no photo or scanning feature. |
| Microphone | Not needed — there is no audio feature. |
| Location | Not needed — the app has no location-based features. |
| Contacts | Not needed — the app is single-user with no sharing. |
| Phone | Not needed — the app does not make or receive calls. |
| Notifications | Not needed in v1.0 — there are no reminders or alerts. |

On **Windows**, the app does not register any firewall rules and makes no outbound network
connections. No WinRT network capabilities are declared.

---

## Unicode and Language Support

The app fully supports text input in **any language or script**, including:

- **Latin** (English, French, German, Spanish, etc.)
- **CJK** (Chinese, Japanese, Korean)
- **Arabic and Hebrew** (right-to-left scripts — text direction is auto-detected)
- **Devanagari** (Hindi, Sanskrit, etc.)
- **Emoji** and special symbols
- **Mixed scripts** in the same field

All text is **NFC-normalised** before being stored, which means that characters that look
the same but are encoded differently (e.g., "e" + combining accent vs. a single accented
"e" character) are always treated as identical. This prevents subtle duplicate-title issues
across different keyboards and input methods.

Text direction (left-to-right or right-to-left) is **automatically detected** for each text
field — you do not need to change any settings when switching between languages.

---

## Supported Platforms

| Platform | Status | Minimum Version |
|----------|--------|-----------------|
| **Android** | Supported (v1.0) | Android 5.0 (API level 21) |
| **Windows** | Supported (v1.0) | Windows 10 |
| iOS | Planned (future release) | — |
| Linux | Planned (future release) | — |
| macOS | Planned (future release) | — |

The app's architecture is designed to support all five platforms. The v1.0 release targets
Android and Windows.

---

## App Screens

| Screen | What you see |
|--------|-------------|
| **Daily List** | Today's (or any day's) task list with timers, statuses, and action menus. The main screen of the app. |
| **Create / Edit ToDo** | A form to create a new task or edit an existing one. Includes title autocomplete and real-time duplicate detection. |
| **Time Segments** | A detailed list of all start/stop pairs for a task, with manual entry form. |
| **Copy ToDos** | A multi-step wizard to select tasks, pick a target date, preview, and confirm the copy. |
| **Search Results** | Results from a cross-day title search, grouped by date. |
| **Recurring Tasks** | View, create, edit, pause, and delete recurrence rules. |
| **Recurrence Editor** | Configure frequency, interval, days, start/end date, with a 5-date preview. |
| **Backup** | Export, import, and manage database backup files. |
| **Statistics** | Charts and tables showing productivity metrics, with two tabs (daily overview and per-item overview). |

---

## Privacy and Security

- **Offline by design.** The app has no networking code, no networking permissions, and no
  networking dependencies. It works identically whether your device is connected to the
  internet or in airplane mode.
- **No accounts.** There is no login, no registration, and no user profile.
- **No analytics.** The app does not track usage, screen views, tap counts, or any other
  metric.
- **No crash reporting.** Errors are handled locally. No crash data is sent anywhere.
- **No ads.** There are no advertisements, no ad SDKs, and no ad-related tracking.
- **No telemetry.** The app does not phone home, check for updates over the network, or
  communicate with any server.
- **Data stays on your device.** The only way data leaves your device is if you manually
  export a backup file and physically transfer it (e.g., via USB). Even then, the backup
  file is encrypted and unreadable without the passphrase you set during export.
- **Database encryption.** The SQLite database is encrypted at rest using **AES-256**:
  - The **live database** uses a device-derived key (Android Keystore on Android, Windows
    DPAPI on Windows). On Android, even if the device is rooted, the database file cannot
    be read without access to the hardware-backed Keystore. On Windows, the key is tied to
    the Windows user account via DPAPI.
  - **Backup files** are encrypted with a **passphrase you choose** at export time. This
    makes backups portable across devices but also means a forgotten passphrase makes the
    backup unrecoverable.
  - The daily-use encryption is transparent — you never need to enter a password to use
    the app. You only enter a passphrase when exporting or importing a backup.

---

## Known Limitations

- **Single user only.** There is no multi-user support, no sharing, and no sync between
  devices.
- **No reminders or notifications.** The app does not alert you about upcoming or overdue
  tasks.
- **Forgotten backup passphrase = lost backup.** Backup files are encrypted with a
  passphrase you set during export. If you forget the passphrase, the backup cannot be
  recovered — there is no reset mechanism. Always write down your backup passphrase.
- **No MSIX installer for Windows.** The Windows release is a portable folder — you run the
  `.exe` directly. An installer may be added in a future version.
- **Time precision is whole seconds.** Sub-second tracking is not supported.
- **Past days cannot be edited.** Once a day has passed, its tasks are permanently locked.
  There is no admin override.

---

*SreerajP ToDo — your data, your device, your control.*


