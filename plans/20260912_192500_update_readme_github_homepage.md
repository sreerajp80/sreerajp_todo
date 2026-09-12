# Plan: Update README.md for GitHub Home Page

**Status:** Completed

## Issue
The root `README.md` is the primary landing page for the repository on GitHub. While it contains extensive technical details, it needs to be elevated to serve as an engaging, professional, and completely accurate GitHub project home page:
1. Missing repository badges (Flutter, Dart, Android/Windows platforms, SQLCipher AES-256 security, 100% Offline privacy guarantee, MIT license).
2. App showcase layout can be improved using centered responsive image containers for the 6 showcased screenshots (`docs/screenshots/`).
3. Outdated route links in the screens table (e.g. `/create`, `/edit/:id`, `/ocr-scanner` vs canonical routes in `lib/core/constants/app_routes.dart`).
4. Missing architecture tree and tech stack matrix showing the 5-layer Clean Architecture.
5. Incomplete recent feature documentation regarding on-device OCR enhancements (cropping, rotation, contrast adjustment), background scheduled alarms, and mastery deck manual todos/grouping.
6. Needs a clear visual hierarchy and friendly, simple English prose suited for GitHub visitors, contributors, and users.

## Proposed Changes

### [README.md](README.md)
1. **Header & Badges**:
   - Add centered app branding with logo (`assets/splash/splash_logo.png`).
   - Add status badges for Platform, Flutter, Dart, Security, Privacy, and MIT License.
2. **Overview & Key Highlights**:
   - Concise value proposition: 100% offline, zero internet permission, strict day-lock integrity, time tracking, mindful habits, on-device intelligence.
   - High-impact bulleted highlights with visual cues.
3. **App Showcase**:
   - Centered visual gallery displaying high-resolution screenshots from `docs/screenshots/`:
     - Daily Task List & Progress Header (`daily_list.png`)
     - Focus Mode & Daily Ritual (`focus_ritual.png`)
     - Spaced Repetition Mastery Deck (`mastery_deck.png`)
     - Offline OCR & Bilingual Voice Parser (`ocr_voice.png`)
     - Productivity Statistics (`statistics.png`)
     - Encrypted Backup & Air-QR Transfer (`backup_sync.png`)
4. **Feature Tour**:
   - Update and polish feature descriptions:
     - Daily planning & progress header
     - Terminal status lock & strict Day Lock
     - Live multi-timers & manual segments with overlap validation
     - Focus mode
     - Offline OCR document scanner with contrast/crop/rotation tools
     - Bilingual voice task parser (English & Malayalam)
     - Spaced repetition mastery deck (SM-2 retention engine & tag grouping)
     - Mindful daily rituals (morning intention & evening reflection)
     - Air-QR optical transfer & local peer-to-peer Wi-Fi sync
     - RFC 5545 RRULE recurring tasks
     - FTS5 full-text search & Indic phonetic sandhi search
     - Multi-format data handoff (Markdown & JSON)
     - Background notifications & exact alarms for pending tasks
5. **Technical Architecture & Clean Layering**:
   - 5-layer architectural diagram (`presentation`, `application`, `domain`, `data`, `core`).
   - Technology stack matrix detailing Flutter, Riverpod, Drift/SQLCipher, ML Kit, FTS5.
6. **Accurate App Screens & Route Mapping**:
   - Align all routes with `lib/core/constants/app_routes.dart` (`/`, `/day/:date`, `/todo/new`, `/todo/:id`, `/todo/:id/segments`, `/mastery-deck`, `/ritual`, `/ocr-scan`, `/air-qr-scan`, `/wifi-sync`, `/data-handoff`, etc.).
7. **Transparent Permissions Ledger**:
   - Explicit breakdown of permissions used (Camera for Air-QR/OCR, Record Audio for Voice parser, Post Notifications, Schedule Exact Alarm) and deliberately absent permissions (zero Internet, zero network state, zero location/contacts).
8. **Installation & Build Instructions**:
   - Android APK sideloading and Windows desktop instructions.
   - Development and verification commands (`flutter analyze`, `flutter test`, offline dependency audit).
9. **License & Privacy Commitment**:
   - MIT License reference and 100% offline data ownership guarantee.

## Verification Plan
1. Check formatting and links in `README.md`.
2. Verify all image links (`assets/splash/splash_logo.png`, `docs/screenshots/*.png`) resolve to valid repository assets.
3. Verify all routes against `lib/core/constants/app_routes.dart`.
4. Run markdown path audit to ensure no machine-specific absolute paths or private details exist.
