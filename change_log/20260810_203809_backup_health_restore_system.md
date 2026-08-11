# Change Log — Passphrase-Encrypted Backup & Automated Health Restore System

**Date:** 2026-08-10
**Plan:** `plans/20260810_203628_backup_health_restore_system.md`

## Summary of Changes
Implemented Feature 3.11: Passphrase-Encrypted Backup & Automated Health Restore System.

### 1. Key Derivation & Fail-Safe Atomic Saver
- Created `lib/core/utils/crypto_utils.dart` providing PBKDF2-HMAC-SHA256 (300,000 iterations) key derivation, AES archive format helpers, and passphrase validation.
- Created `lib/core/utils/atomic_saver.dart` offering fail-safe, atomic file replacement with temporary staging and rollback protection.

### 2. Database Migration V7 & Diagnostic Logging DAO
- Incremented `kDatabaseVersion` to 7 in `lib/core/constants/app_constants.dart`.
- Created `lib/data/database/migrations/migration_v7.dart` creating `backup_logs` table.
- Updated `lib/data/database/migrations/migration_runner.dart` to execute V7 migration.
- Created `@freezed` entity `lib/data/models/backup_log_entity.dart` and `lib/data/dao/backup_logs_dao.dart`.

### 3. Application & Backup Service Enhancements
- Updated `lib/data/backup/backup_service.dart` to:
  - Generate backups with extension `.db.aes` via `CryptoUtils.formatBackupFileName()`.
  - Maintain list and import compatibility for both `.db.aes` and legacy `.db` archives.
  - Safely swap database files using `AtomicSaver.replaceFileAtomically()`.
  - Record diagnostic logs (`status`, `fileSizeBytes`, `triggerType`, `diagnosticMessage`) to `BackupLogsDao`.
  - Provide `runScheduledBackupIfNeeded()` for automated background backup creation.
- Exposed `backupLogsDaoProvider` and `backupHealthLogsProvider` in `lib/application/providers.dart`.

### 4. Visual Health Dashboard & Localization
- Added localized health strings in `lib/l10n/app_en.arb` and `lib/l10n/app_ml.arb`.
- Created `lib/presentation/screens/backup/widgets/backup_health_dashboard.dart` displaying system health badges (Healthy, Warning, No Backups), archive size, execution triggers, and expandable diagnostic history logs.
- Updated `lib/presentation/screens/backup/backup_screen.dart` to feature `BackupHealthDashboard` and refresh health state on backup operations.

### 5. Automated Tests
- Created `test/core/atomic_saver_test.dart` testing atomic replacement, staging, and rollback.
- Created `test/data/backup_logs_dao_test.dart` testing log persistence and queries.
- Updated `test/data/backup_service_test.dart` to verify `.db.aes` archive generation and health logging.
