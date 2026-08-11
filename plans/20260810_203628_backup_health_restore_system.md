# Implementation Plan — Passphrase-Encrypted Backup & Automated Health Restore System

**Status:** Proposed

## Overview
Implement Feature 3.11: Passphrase-Encrypted Backup & Automated Health Restore System for SreerajP ToDo.
This feature provides:
1. **Passphrase Encryption:** AES-256 ZIP & PBKDF2 archive container (`.db.aes` & `.db`) exporting full SQLite state.
2. **Automated Health Dashboard & `BackupLogsDao`:** Migration V7 creating `backup_logs` table, `BackupLogsDao` for diagnostic execution logging (success/failed, file size, diagnostic message), auto-backup scheduling helper, and visual health log dashboard widget in Backup screen.
3. **Atomic Safe Import/Restore:** `AtomicSaver` fail-safe atomic file replace mechanism, schema version compatibility checks (rejecting newer versions via `BackupVersionTooNewException` and running migrations for older versions), and `PRAGMA integrity_check` verification.

---

## User Review Required

> [!IMPORTANT]
> - Database version incremented from 6 to 7 to introduce `backup_logs` table.
> - Filename export extension updated to `.db.aes` while preserving full import compatibility for legacy `.db` archives.
> - Fully offline operation guaranteed. No external network access or external APIs used.

---

## Proposed Changes

### Layer 1: Core Utilities

#### [NEW] [atomic_saver.dart](file:///l:/Android/sreerajp_todo/lib/core/utils/atomic_saver.dart)
- Provides safe atomic file replacement using temporary file staging and rollback copies.
- Ensures live database file replacement is fail-safe and reversible if any step fails.

#### [NEW] [crypto_utils.dart](file:///l:/Android/sreerajp_todo/lib/core/utils/crypto_utils.dart)
- Provides helper functions for key derivation (PBKDF2-HMAC-SHA256, 300,000 iterations) and AES payload verification / encryption wrapper functions.

#### [MODIFY] [app_constants.dart](file:///l:/Android/sreerajp_todo/lib/core/constants/app_constants.dart)
- Increment `kDatabaseVersion` from 6 to 7.

#### [MODIFY] [app_strings.dart](file:///l:/Android/sreerajp_todo/lib/core/constants/app_strings.dart)
- Add user-visible strings for Backup Health Log, Health Status (Healthy, Warning, Error), Automated Scheduling, and Log Diagnostics.

---

### Layer 2: Data Models & Database Migrations

#### [NEW] [migration_v7.dart](file:///l:/Android/sreerajp_todo/lib/data/database/migrations/migration_v7.dart)
- SQL migration script creating `backup_logs` table:
  - `id` TEXT PRIMARY KEY
  - `timestamp` TEXT NOT NULL
  - `status` TEXT NOT NULL ('success', 'failed')
  - `file_path` TEXT NOT NULL
  - `file_size_bytes` INTEGER NOT NULL DEFAULT 0
  - `trigger_type` TEXT NOT NULL ('manual', 'scheduled')
  - `diagnostic_message` TEXT NOT NULL DEFAULT ''
  - `created_at` TEXT NOT NULL

#### [MODIFY] [migration_runner.dart](file:///l:/Android/sreerajp_todo/lib/data/database/migrations/migration_runner.dart)
- Register V7 migration execution when upgrading from version 6 to 7.

#### [NEW] [backup_log_entity.dart](file:///l:/Android/sreerajp_todo/lib/data/models/backup_log_entity.dart)
- `@freezed` immutable entity model for backup health log entries.

#### [NEW] [backup_logs_dao.dart](file:///l:/Android/sreerajp_todo/lib/data/dao/backup_logs_dao.dart)
- DAO for inserting logs, retrieving logs sorted by timestamp, and fetching latest status.

---

### Layer 3: Application & Domain Layer

#### [MODIFY] [backup_service.dart](file:///l:/Android/sreerajp_todo/lib/data/backup/backup_service.dart)
- Update default backup file extension to `.db.aes`.
- Update `listBackups` to discover both `.db.aes` and `.db` files.
- Integrate `AtomicSaver` into `importDatabase` for safe database swapping.
- Integrate `BackupLogsDao` into `exportDatabase` and automated backup methods to record diagnostic logs.
- Add background automated backup trigger helper method `runScheduledBackupIfNeeded()`.

#### [MODIFY] [providers.dart](file:///l:/Android/sreerajp_todo/lib/application/providers.dart)
- Expose `backupLogsDaoProvider` and `backupHealthLogsProvider`.

---

### Layer 4: Presentation Layer

#### [NEW] [backup_health_dashboard.dart](file:///l:/Android/sreerajp_todo/lib/presentation/screens/backup/widgets/backup_health_dashboard.dart)
- Visual Health Log Dashboard displaying current backup health badge (Healthy / Warning / No Backups), last successful backup timestamp, automated schedule status, and expandable list of past diagnostic execution logs.

#### [MODIFY] [backup_screen.dart](file:///l:/Android/sreerajp_todo/lib/presentation/screens/backup/backup_screen.dart)
- Embed `BackupHealthDashboard` card at top of `BackupScreen`.
- Support `.db.aes` and `.db` file picker filters for import.

---

## Verification Plan

### Automated Tests
- `flutter test test/core/atomic_saver_test.dart`
- `flutter test test/data/backup_logs_dao_test.dart`
- `flutter test test/data/backup_service_test.dart`
- `flutter test test/presentation/backup_screen_test.dart`
- `flutter test`
- `flutter analyze`

### Manual Verification
- Launch app, open Settings -> Backup & Restore.
- Verify Health Log Dashboard displays status correctly.
- Perform a passphrase-encrypted backup export (`.db.aes`).
- Check that health log records the successful backup with file size and timestamp.
- Import backup file and verify `AtomicSaver` restores full database state successfully.
