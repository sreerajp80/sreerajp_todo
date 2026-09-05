# Plan: Comprehensive 18-App Audit & Unique Features Specification Update for SreerajP ToDo

**Status:** Awaiting Approval

## Target File
- `docs/unique_features_and_improvements.md`

## Issue / User Request
The user noted that generic features such as backup, restore, export, import, QR sync, and serverless sync were included in `docs/unique_features_and_improvements.md` without thoroughly analyzing all 18 Android applications listed in `myapps.md`. 
Backup, restore, export, import, and sync are already implemented across the user's suite of applications (`sms-sentry`, `SreerajP_Authenticator`, `SreerajPContactSphere`, `SreerajP_TextApp`, `vault-files`, etc.) and are standard features across Android ToDo apps. 
The user requested an exhaustive audit of all 18 `features.md` files in `myapps.md` and an update to `docs/unique_features_and_improvements.md` focusing strictly on **truly unique features that are NOT implemented in any Android ToDo application**.

## Proposed Changes & Audit Summary

### 1. Exhaustive 18-App Audit Matrix
We audited all 18 `features.md` documents from `myapps.md`:
1. `chronotune-smart-clock`: Kotlin, 100% offline natural language voice parser (`en-IN`/`ml-IN`), anti-oversleeping cognitive wake-up challenges (Math, Memory, Phrase Typing), 16-bit PCM procedural audio synth (ADSR envelope), Canvas analog/digital widgets, holiday awareness (`SKIP_HOLIDAYS`, `WORKDAYS_ONLY`).
2. `daily_rule_cards`: Flutter, 18 reflection cards, parchment theme, 18-iteration binary search text layout engine (`_RuleCardMetrics.resolve`), dynamic control bar reflowing.
3. `MantraJapaCounter`: Flutter, 108-bead mala counting, sankalpa tracking, daily vs lifetime goals, native DTMF audio beep & pulse vibration, 2-tier persistence (SharedPreferences + sqflite).
4. `Sanathana_Dharma_Clock`: Flutter, 60 Ghaṭikā Vedic timekeeping, sunrise-anchored day (*Ahorātra*), NOAA/Jean Meeus on-device algorithms, 30 Muhūrtas, 24 Horās, solar almanac.
5. `sms-sentry`: Kotlin, weighted offline spam engine, OTP auto-extraction, bank transaction extraction, P2P LAN sync over AES-256-GCM, exact `AlarmManager` due alerts.
6. `sreeraj_qr_reader`: Flutter, 6-layer URL safety check, zero-trust sandboxed preview, Quishing Guard physical tamper detector, StegoQR (hidden AES-256 payload behind biometrics/PIN), AirQR (optical animated QR data streaming).
7. `SreerajP_Authenticator`: Flutter, TOTP/HOTP/Steam/Blizzard/mOTP, hardware Keystore AES-256-GCM, App PIN & biometrics, recovery key, `FLAG_SECURE` window protection, P2P LAN & Air-Gap sync.
8. `SreerajP_CodeApp`: Flutter, SAF scoped storage, atomic file saver, draft recovery, virtualized streaming, degraded view (>50MB), TTS code reading (en-US, ml-IN), PIN lock with `FLAG_SECURE`.
9. `SreerajP_Devi`: Flutter, 3D Y-axis card flipping, procedural Pushpanjali parabolic flower flying animation, multi-script Devanagari/Malayalam/English, audio duration pre-probing.
10. `SreerajP_Journal_Vault`: Flutter, Drift SQLite ORM, hardware Keystore AES-256-GCM attachment crypto, FTS5 search (`entries_fts`, `attachment_text_fts`), revision history (`EntryRevisions`), backlink engine (`[[Entry Title]]`), "On This Day" memory resurfacing, streak tracking, mood trends.
11. `SreerajP_LalithaSahasranamam`: Flutter, Isar NoSQL DB, 3D flip cards, 3 interpretation levels, spaced repetition (Anki-style interval system: Hard, Revision, Easy), Indic grapheme-cluster line wrapping, home screen widget.
12. `SreerajP_lyricchord`: Flutter, Drift SQLite, ChordPro parser, semitone transposition (-11 to +11), auto-scroll (manual multiplier & tempo BPM duration math), Stage HUD gesture controls, PCM synth click metronome, Shruti box drone (Sa-Pa, Sa-Ma just intonation).
13. `SreerajP_PDFApp`: Flutter, pdfrx rendering, PdfBox-Android, Bouncy Castle signature verification, Indic phonetic & Sandhi-aware search (NFC, Chillu unification, ZWJ/ZWNJ stripping, Sanskrit cantillation accent stripping), copy-on-write page ops, annotations overlay.
14. `SreerajP_TextApp`: Flutter, re_editor, CSV 2D grid, JSON tree & table view, JSONPath & XPath query builders, JSON/XML quick fixes, P2P LAN sync, export PDF/DOCX/XLSX/ZIP.
15. `sreerajp_todo`: Flutter, 100% offline todo & time tracker, Day-Lock, Terminal Status Lock, Single Open Segment, NFC normalization, iCalendar RRULE, fl_chart analytics.
16. `sreerajp_youtube_shortcut`: Flutter, YouTube launcher shortcuts, handle expansion, feed-free access, 7 theme palettes, QR generator & camera scanner.
17. `SreerajPContactSphere`: Flutter, default dialer, in-call screen, T9 multi-script dialpad, relationship sphere & scoring, relationship-tier quiet hours, Smart Redial exact alarms, ephemeral self-destructing contacts, audit log with hash chain verification, ICE card.
18. `vault-files`: Kotlin/Jetpack Compose, file manager, storage analyzer, secure notes (AES-256-GCM), shielded folders, file picker.

### 2. Elimination of Generic Features
Remove generic features (backup/restore, CSV/JSON export, P2P LAN sync, QR sync) from the "unique features" designation, as they are already standard capabilities across the user's app ecosystem and standard Android todo tools.

### 3. Truly Unique Features to Document in `docs/unique_features_and_improvements.md`
Document 10 hyper-unique, novel features tailored to `SreerajP ToDo` that DO NOT exist in any standard Android ToDo app:
1. **Day-Locked Time-Travel Friction Engine & Deferral Audit Trail:** Combines Day-Lock immutability with cognitive friction challenges (arithmetic/phrase verification from `chronotune-smart-clock`) when a task is ported $\ge 3$ times, backed by `TodoRevisions` audit trail (adapted from `SreerajP_Journal_Vault`).
2. **Bilingual Offline Natural Language Voice Task Parser (`en-IN` & `ml-IN`):** 100% offline voice task creation parsing titles, Malayalam/English relative dates, and time-box estimates, applying NFC normalization and LTR/RTL text direction auto-detection (adapted from `chronotune-smart-clock`).
3. **Vedic Circadian Time-Boxing & Elastic Ghaṭikā Productivity Mode:** Sunrise-anchored time tracking mapping daily tasks onto 30 named Muhūrtas (*Brahma Muhūrta*, *Abhijit Muhūrta*) and 24-minute elastic *Ghaṭikā* focus blocks computed locally via NOAA/Meeus algorithms (adapted from `Sanathana_Dharma_Clock`).
4. **Multi-Task Concurrent Focus Sprints with Zero-Asset Procedural Audio Synth:** Structured Pomodoro focus sprints with live multi-timer tracking and pure 16-bit PCM ADSR-enveloped procedural audio chimes synthesized directly in code (adapted from `chronotune-smart-clock` and `SreerajP_lyricchord`).
5. **Spaced Repetition Task Mastery Deck (Anki-Style Habit & Skill Engine):** Integrates SM-2 spaced repetition (adapted from `SreerajP_LalithaSahasranamam`) into daily todo maintenance and learning tasks, scheduling tasks dynamically by recall confidence (*Hard*, *Revision*, *Easy*).
6. **Indic Phonetic & Sandhi-Aware Cross-Day Task Search:** SQLite FTS5 search (adapted from `SreerajP_Journal_Vault` & `SreerajP_PDFApp`) featuring Chillu character unification (`ൺ`, `ൻ`, `ർ`, `ൽ`, `ൾ`), joiner-ignorable matching (`ZWJ`/`ZWNJ` stripping), and Malayalam/Devanagari phonetic matching.
7. **"On This Day" Productivity Memory Flashbacks & Evening Reflection Ritual:** Resurfaces historical task milestones from 1 year or 6 months ago (adapted from `SreerajP_Journal_Vault`) paired with an Evening Reflection Ritual card (adapted from `daily_rule_cards`).
8. **Biometric & Hardware Keystore Task Vault with `FLAG_SECURE` Screen Shield:** Confidential task privacy protection utilizing `local_auth`, hardware Keystore 6-digit PIN lock, `FLAG_SECURE` window screenshot prevention, and AES-256-GCM encrypted notes (adapted from `SreerajP_Journal_Vault`, `SreerajP_Authenticator`, and `vault-files`).
9. **Canvas-Rendered Dynamic Home Screen & Lock Screen Complication Widgets:** Real-time completion rings, active multi-timer countdowns, and 1-tap controls rendered via native Android `Canvas` with non-wakeup `AlarmManager` ticks for zero Doze battery drain (adapted from `chronotune-smart-clock`).
10. **Multi-Format Professional Timecard & Audit Export Suite:** Formatted PDF timecard reports with interval tables, status breakdown charts, and billable duration totals (adapted from `SreerajPContactSphere` & `SreerajP_PDFApp`), alongside Markdown summary exports.

## Verification Plan
1. Inspect `docs/unique_features_and_improvements.md` after updating to ensure all 18 apps are correctly referenced, generic sync/backup features are categorized properly, and all 10 unique features are clearly specified.
2. Run `dart format` or Markdown validation if required.
