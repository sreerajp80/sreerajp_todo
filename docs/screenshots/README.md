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

The repository maintains 15 screenshots used across `README.md` and feature documentation:

### Main App Showcase (9 Screens)

| File Name | Screen / Feature Shown | Description |
|-----------|------------------------|-------------|
| `daily_list.png` | **Daily Task List** | Main screen showing task list with status badges, ongoing live multi-timer, progress header, and floating action button. |
| `focus_mode.png` | **Distraction-Free Focus Mode** | Single-task focused workspace with radial progress countdown, play/pause controls, and sleek dark aesthetic. |
| `mastery_deck.png` | **Spaced Repetition Mastery Deck** | SM-2 mastery decks showing study progress indicators, deck cards, and practice management. |
| `daily_ritual.png` | **Guided Daily Ritual** | Guided multi-step daily planning and task carryover wizard with progress stepper. |
| `ocr_scanner.png` | **Offline OCR Scanner** | Camera viewfinder with document targeting bounds, zoom slider (1x, 2x, 3x), and offline shutter capture. |
| `ocr_crop_editor.png` | **OCR Crop & Document Editor** | Image enhancement studio with B&W / grayscale filters, perspective rotation, and live bilingual text recognition. |
| `statistics.png` | **Productivity Statistics Dashboard** | Daily overview bar charts, completion metrics, period filters, and KPI summary cards. |
| `backup_sync.png` | **Encrypted Backup & Air-QR Transfer** | Backup management dashboard and air-gapped animated optical QR code data transfer stream. |
| `settings_hub.png` | **Settings & Preferences Hub** | Central customization hub for appearance, themes, language, task defaults, and security policies. |

### Feature Tour & Deep-Dive Screens (6 Screens)

| File Name | Screen / Feature Shown | Description |
|-----------|------------------------|-------------|
| `create_task.png` | **Creating and Editing Tasks** | Task creation form with title autocomplete, description, priority selector, target duration, and sub-task input. |
| `voice_parser.png` | **Bilingual Voice Task Parser** | Hands-free voice parser bottom sheet with English and Malayalam language toggle and live speech capture. |
| `time_segments.png` | **Time Segments & Manual Entry** | Per-task time tracking log with active timer controls, segment list, and manual time entry button. |
| `search_phonetic.png` | **FTS5 & Phonetic Search** | SQLite FTS5 search interface with search results, status chips, and Indic phonetic matching. |
| `wifi_sync.png` | **Local P2P Wi-Fi Sync** | Peer-to-peer Wi-Fi synchronization screen with sync scope selection and host/peer connection controls. |
| `data_handoff.png` | **Multi-Format Data Handoff** | Markdown and JSON export interface with copy, share, and preview options. |

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
