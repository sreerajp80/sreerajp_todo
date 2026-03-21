# Phase 5B — Local Backup & Restore

## Objective
Allow the user to export the full encrypted SQLite database to user-accessible storage (re-encrypted with a user passphrase for portability) and restore from a previous backup file.

## Pre-Requisites
- Phases 1–5 complete (full CRUD, time tracking, copy/port).
- `DatabaseService` exists and manages the encrypted live database.
- `file_picker` package installed (or fallback to `path_provider` default directory).
- Read `CLAUDE.md` — encryption strategy, backup exceptions, offline constraint.
- Read `docs/security.md` — dual-key architecture (§6), backup/import/export validation (§11), never-log rules (§8), sensitive data inventory (§4).
- Read `docs/architecture.md` — persistence model (§10), data flow (§6).
- Read `docs/flutter_project_engineering_standard.md` — sensitive data extension (§7.2 — encrypted export by default, backup/recovery tested as critical flows), testing standard (§9), Definition of Done (§14.3).

## Key Design Decisions
- **Dual-key encryption:**
  - Live database: device-derived key (Android Keystore / Windows DPAPI) — transparent to user.
  - Backup files: re-encrypted with **user-set passphrase** at export time → portable across devices.
- **Passphrase is never stored on disk.** If forgotten, the backup is unrecoverable.
- **No data leaves the device.** Backup files are written to local filesystem only.
- **All operations are local** — no cloud, no network.

---

## Tasks

### 1. Create `BackupService` (`lib/data/backup/backup_service.dart`)

```dart
class BackupService {
  final DatabaseService _dbService;

  /// Exports the database to [destinationPath].
  /// File name format: sreerajp_todo_backup_YYYYMMDD_HHMMSS.db
  Future<String> exportDatabase({
    required String destinationPath,
    required String passphrase,
  });

  /// Validates and imports a database from [sourcePath].
  Future<void> importDatabase({
    required String sourcePath,
    required String passphrase,
  });

  /// Lists .db backup files in [directory], sorted newest first.
  Future<List<BackupFileInfo>> listBackups(String directory);

  /// Deletes a backup file.
  Future<void> deleteBackup(String filePath);
}
```

#### `BackupFileInfo` model:
```dart
class BackupFileInfo {
  final String filePath;
  final String fileName;
  final DateTime createdAt;
  final int fileSizeBytes;
}
```

### 2. Export Flow

1. Run `PRAGMA wal_checkpoint(TRUNCATE)` to flush WAL to main DB file.
2. Close the database connection.
3. Create a temporary copy of the `.db` file.
4. Open the temporary copy with the **device-derived key**.
5. Re-key the copy to the **user's passphrase**: `PRAGMA rekey = '<passphrase>'` via SQLCipher.
6. Close the temporary copy.
7. Verify the re-keyed copy: open it with the passphrase → run `PRAGMA integrity_check`.
8. If integrity check passes: move the verified copy to `destinationPath` with filename format `sreerajp_todo_backup_YYYYMMDD_HHMMSS.db`.
9. If integrity check fails: delete the temporary copy, throw `BackupCorruptedException`.
10. Reopen the original database connection.

#### Passphrase requirements:
- Minimum 8 characters.
- Confirmation field (enter twice).
- Clear warning displayed: "If you forget this passphrase, the backup cannot be recovered. Write it down."

### 3. Import Flow

1. Prompt user for the backup passphrase.
2. Open the source file **read-only** using the entered passphrase.
3. If decryption fails (wrong passphrase): show error "Incorrect passphrase or corrupted backup file." Allow retry.
4. Read `PRAGMA user_version` — compare with current schema version.
5. If older: run incremental migrations (`migration_v2.dart`, etc.) on the source file.
6. If newer: throw `BackupVersionTooNewException` — "This backup was created by a newer version of the app. Please update the app first."
7. Run `PRAGMA integrity_check` on the source file.
8. If integrity check fails: throw `BackupCorruptedException`.
9. Show confirmation dialog: "This will replace ALL current data. This action cannot be undone. Continue?"
10. Close the current database connection.
11. Create a backup of the current DB before replacing (safety net).
12. Re-key the imported file from the user passphrase to the current **device-derived key**.
13. Replace the current DB file with the re-keyed file.
14. Reopen the database.
15. Run startup sequence (orphan repair, recurring task generation).

### 4. Backup Screen (`/backup`) — `lib/presentation/screens/backup/`

#### `backup_screen.dart`
- **"Export Backup" button** → triggers export flow:
  1. Show passphrase entry dialog (with confirmation field).
  2. Use `file_picker` to let user choose destination directory (or default to Downloads).
  3. Show progress indicator during export.
  4. On success: SnackBar with "Backup saved to [path]".
  5. On error: error SnackBar with retry option.

- **"Restore from Backup" button** → triggers import flow:
  1. Use `file_picker` to select a `.db` file.
  2. Show passphrase entry dialog.
  3. Show confirmation dialog ("This will replace ALL current data...").
  4. Show progress indicator during import.
  5. On success: restart app or navigate to home.
  6. On error: appropriate error message.

- **Backup list** — shows recent backups in the default backup directory:
  - Each tile: file name, date, file size.
  - Delete button (with confirmation dialog).
  - Sorted newest first.

#### `widgets/backup_list_tile.dart`
- Displays backup file info.
- Delete action with confirmation.

#### Navigation:
- Accessible from the main app bar overflow menu on the daily list screen.

### 5. Exceptions (`lib/core/errors/exceptions.dart`)

Add (if not already present):
```dart
class BackupVersionTooNewException implements Exception {
  final int backupVersion;
  final int appVersion;
  BackupVersionTooNewException(this.backupVersion, this.appVersion);
}

class BackupCorruptedException implements Exception {
  final String? details;
  BackupCorruptedException([this.details]);
}
```

### 6. String Constants (`lib/core/constants/app_strings.dart`)

Add under `AppStrings.backup` namespace:
- `exportTitle` = "Export Backup"
- `importTitle` = "Restore from Backup"
- `passphraseLabel` = "Backup Passphrase"
- `passphraseConfirmLabel` = "Confirm Passphrase"
- `passphraseMinLength` = "Passphrase must be at least 8 characters"
- `passphraseMismatch` = "Passphrases do not match"
- `passphraseWarning` = "If you forget this passphrase, the backup cannot be recovered. Write it down."
- `exportSuccess` = "Backup saved to"
- `importConfirmTitle` = "Replace All Data?"
- `importConfirmMessage` = "This will replace ALL current data. This action cannot be undone."
- `importSuccess` = "Data restored successfully"
- `importWrongPassphrase` = "Incorrect passphrase or corrupted backup file"
- `importVersionTooNew` = "This backup was created by a newer version of the app. Please update."
- `importCorrupted` = "The backup file is corrupted and cannot be restored"
- `deleteBackupConfirm` = "Delete this backup?"
- `noBackupsFound` = "No backups found"

### 7. Provider Registration

In `providers.dart`:
```dart
final backupServiceProvider = Provider<BackupService>((ref) {
  return BackupService(ref.read(databaseServiceProvider));
});
```

---

## Tests to Write During This Phase

### Unit Tests — `test/data/backup_service_test.dart`
- Export creates a valid copy at the specified path.
- Export: original DB is unaffected after export.
- Export: exported file can be opened with the passphrase.
- Export: exported file fails to open with wrong passphrase.
- Import with correct passphrase: data restored correctly.
- Import with older schema version: triggers migration.
- Import with newer schema version: throws `BackupVersionTooNewException`.
- Import with corrupted file: throws `BackupCorruptedException`.
- Import with wrong passphrase: throws appropriate error.
- `listBackups`: returns files sorted newest first.
- `deleteBackup`: removes the file.

### Integration Test (Phase 8)
- Round-trip: create todos → export → delete all data → import → verify all data restored.

---

## Constraints
- No data leaves the device — all file operations are local.
- No networking packages.
- Passphrase never stored on disk.
- All strings in `app_strings.dart`.
- `file_picker` must pass offline dep audit (if it fails, use default directory via `path_provider`).

## Deliverables
- [ ] Export produces a valid, passphrase-encrypted `.db` file
- [ ] Import restores the full app state from a backup
- [ ] Wrong passphrase shows clear error message
- [ ] Schema version mismatch handled (older: migrate; newer: reject)
- [ ] Corrupted file detected and rejected
- [ ] Backup list screen with delete functionality
- [ ] Confirmation dialog before destructive import
- [ ] All tests passing
