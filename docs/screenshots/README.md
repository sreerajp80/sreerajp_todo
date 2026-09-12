# SreerajP ToDo — App Screenshots Guide

This directory holds release screenshots and preview images used in the project's [README.md](../../README.md), GitHub releases, documentation, and app store listings.

---

## 1. Recommended Image Specs

| Category | Recommended Resolution | Aspect Ratio | Format |
|----------|------------------------|--------------|--------|
| **Mobile (Android Phone)** | 1080 × 2400 px (or 1440 × 3200 px) | 9:20 or 9:19.5 | PNG (lossless) |
| **Tablet** | 1600 × 2560 px | 16:10 | PNG (lossless) |
| **Desktop (Windows)** | 1920 × 1080 px | 16:9 | PNG (lossless) |

> [!TIP]
> Use PNG with lossless compression (e.g. `pngcrush` or `optipng`) to keep file sizes small while keeping typography and crisp UI lines sharp.

---

## 2. Standard Screenshot Showcase Files

The main `README.md` references the following key showcase files:

| File Name | Screen / Feature Shown | Description |
|-----------|------------------------|-------------|
| `daily_list.png` | **Daily Task List** | Main screen showing task list with status badges, ongoing live timer, progress header, and floating action button. |
| `focus_ritual.png` | **Focus Mode & Rituals** | Single-task distraction-free Focus Mode card and the Morning Intention / Evening Reflection journal. |
| `mastery_deck.png` | **Task Mastery Deck** | Spaced repetition flashcard deck showing review intervals, retention ratings, and practice schedule. |
| `ocr_voice.png` | **OCR Scanner & Voice Parser** | Camera text recognition scanner with crop/contrast adjustment, and the offline voice input sheet. |
| `statistics.png` | **Statistics Dashboard** | Daily overview bar charts, completion metrics, and per-item time trend charts. |
| `backup_sync.png` | **Backup & Air-QR Transfer** | Backup health dashboard and device-to-device optical QR transfer screen. |

---

## 3. How to Capture Screenshots

### Option A: From an Android Device or Emulator

1. Open the app on an Android device or emulator with representative sample data.
2. Capture screenshots:
   - **Hardware shortcut:** Press `Power + Volume Down`.
   - **ADB command:**
     ```powershell
     adb shell screencap -p /sdcard/screen.png
     adb pull /sdcard/screen.png docs/screenshots/daily_list.png
     ```
3. Set the system theme to clean Light or Dark mode, and ensure the status bar is clean (e.g., full battery, demo mode).

### Option B: From Windows Desktop Build

1. Run the desktop version:
   ```powershell
   flutter run -d windows
   ```
2. Adjust the window to standard desktop proportions (e.g., 1280×800 or 1920×1080).
3. Capture the window using `Alt + PrintScreen` or the Windows Snipping Tool (`Win + Shift + S`) and save the file into `docs/screenshots/`.

---

## 4. Privacy and Content Rules

- Never use real personal data, private notes, contact details, or sensitive passwords in screenshots.
- Use clear, realistic sample tasks (e.g., "Morning meditation", "Review quarterly report", "Grocery shopping", "Read Chapter 4").
- Show a mix of task statuses (Pending, Completed, Dropped, Ported) and time segments to illustrate the app's full capabilities.
