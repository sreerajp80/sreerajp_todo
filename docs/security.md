# Security

## 1. Security Scope

- App: `SreerajP ToDo`
- Data sensitivity level: `high`
- Engineering standard profiles in force:
  - `Core Baseline`
  - `Production App Extension`
  - `Sensitive Data Extension`
- Platforms in scope:
  - `Android`
  - `Windows`

## 2. Security Objectives

- Protect locally stored task data and time-tracking records from casual extraction on a lost or stolen device.
- Prevent accidental disclosure of user data through logs, unencrypted backups, screenshots, or exports.
- Preserve recoverability and cross-device migration through portable encrypted backups with user-set passphrases.
- Ensure zero data leaves the device involuntarily — no network access, no telemetry, no cloud sync.

## 3. Threat Model Summary

### In Scope Threats

- Lost or stolen device with the app installed (data at rest must be encrypted).
- Casual local access by someone who picks up an unlocked device.
- Accidental plaintext export (backup files must always be encrypted).
- Log leakage of task titles, descriptions, or time data.

### Out Of Scope Threats

- Fully compromised or rooted device with attacker access to Android Keystore / Windows DPAPI.
- Physical hardware attacks (cold boot, JTAG, chip-off).
- Attacks requiring OS-level compromise (kernel exploits, custom ROMs with backdoors).
- Side-channel attacks on the SQLCipher encryption.

## 4. Sensitive Data Inventory

| Data Type | Example | Where It Exists | Protection Required |
|-----------|---------|-----------------|---------------------|
| Task titles | "Doctor appointment" | SQLite DB (encrypted), backup files (encrypted) | AES-256 encryption at rest |
| Task descriptions | "Bring insurance card" | SQLite DB (encrypted), backup files (encrypted) | AES-256 encryption at rest |
| Time segments | Start/end timestamps | SQLite DB (encrypted), backup files (encrypted) | AES-256 encryption at rest |
| Device encryption key | Android Keystore / DPAPI key reference | Platform secure key store | Never exposed to Dart code as plaintext; accessed via platform API |
| Backup passphrase | User-entered string | Memory only (during export/import) | Never stored on disk; cleared after operation |

## 5. Storage Model

### At Rest

- Primary local storage: SQLite database file encrypted with AES-256 via `sqflite_sqlcipher` (mobile) / SQLCipher FFI (desktop).
- Secure key storage: Android Keystore (Android) / Windows DPAPI (Windows) for the device-derived database encryption key.
- Backup behavior: Encrypted only. Backup files are re-encrypted from the device key to a user-set passphrase at export time. Plaintext export is not supported.

### In Memory

- Sensitive values are kept in memory: briefly (during database operations and backup passphrase entry).
- Memory clearing strategy: Passphrase strings are used only within the export/import flow scope and are not cached. The database handle holds the decryption context in native memory managed by SQLCipher.

### In Transit

- Network use: None. The app has zero networking code, zero networking permissions, and zero networking dependencies.
- Transport protections: Not applicable.

## 6. Cryptography Design

- Encryption algorithm: AES-256-CBC (SQLCipher default page-level encryption).
- Key derivation: PBKDF2-HMAC-SHA512 (SQLCipher default for passphrase-based keys).
- Nonce or IV strategy: SQLCipher manages per-page IVs internally.
- Format versioning: SQLCipher 4.x format. Database schema version tracked via `PRAGMA user_version`.
- Legacy format support: No. The app ships with SQLCipher 4.x only.

### Dual-Key Architecture

| Context | Key Source | User Interaction |
|---------|-----------|-----------------|
| Live database (daily use) | Device-derived key via Android Keystore / Windows DPAPI | None — transparent, auto-generated on first launch |
| Backup files (export) | User-set passphrase (min 8 characters) | Entered at export time, confirmed by typing twice |
| Backup files (import) | Same user passphrase | Entered at import time |

Re-keying between the device key and user passphrase is performed via `PRAGMA rekey` during export and import.

### Rules

- Keys, IVs, salts, and passwords must never be hardcoded.
- The device-derived key is generated using the platform's cryptographically secure key generation facility.
- The backup passphrase is never stored on disk — if forgotten, the backup is unrecoverable.

## 7. Authentication And Access Control

- App-lock strategy: None in v1.0 (the device's own screen lock is the primary access barrier).
- Fallback behavior: Not applicable.
- Session-expiry rule: Not applicable.
- Background lock rule: Not applicable.
- Protected-route strategy: Day lock (past dates are read-only) enforced at the repository layer.

## 8. Logging And Telemetry Policy

### Never Log

- Database encryption keys or key references
- Backup passphrases
- Task titles, descriptions, or any user-entered content
- Time segment start/end timestamps
- File paths containing user data

### Allowed Diagnostic Context

- Operation name (e.g., "backup export started", "orphan repair completed")
- Error category (e.g., "integrity check failed", "schema version mismatch")
- Non-sensitive counts (e.g., "repaired 3 orphaned segments", "generated 5 recurring tasks")

### Logging Controls

- Logger implementation: `debugPrint()` only (gated by debug mode).
- Verbose logging gate: Debug builds only. Release builds produce no diagnostic output.
- Redaction strategy: Never pass user content to any logging function. Log operation names and error categories only.
- `print()` is banned via `avoid_print` lint rule.

## 9. Platform Security Controls

### Android

- `android:allowBackup`: `false` (prevents Android's auto-backup from copying the encrypted DB to Google Drive in plaintext-accessible form).
- `android:fullBackupContent`: Not used (allowBackup is false).
- Screenshot protection: Not enabled in v1.0 (task lists are not considered high-sensitivity like passwords or financial data).
- Root or tamper detection: Not implemented (out-of-scope threat model).
- `INTERNET` permission: Deliberately absent. Android OS blocks all network access at the system level.
- `ACCESS_NETWORK_STATE` / `ACCESS_WIFI_STATE`: Absent.

### Windows

- No firewall rules registered.
- No outbound network connections.
- No WinRT network capabilities (`internetClient`, `internetClientServer`, `privateNetworkClientServer`) declared.
- Database encryption key stored via Windows DPAPI, tied to the Windows user account.

## 10. Permissions

| Permission | Why It Is Needed | Requested When | Denial Handling |
|------------|------------------|----------------|-----------------|
| Local file storage (implicit) | SQLite database in app's private directory | Automatic (OS grants to all apps for their own data directory) | Not applicable |
| External storage / file access | Backup export/import to user-accessible location | When the user taps Export or Import on the Backup screen | Show error explaining file access is required for backup |

Permissions the app explicitly does NOT request: `INTERNET`, `ACCESS_NETWORK_STATE`, `ACCESS_WIFI_STATE`, `CAMERA`, `MICROPHONE`, `LOCATION`, `CONTACTS`, `PHONE`, `NOTIFICATIONS`.

## 11. Backup, Import, Export, And Recovery

- Backup supported: Yes
- Backup format: Encrypted SQLite database (AES-256 via SQLCipher, keyed with user passphrase)
- Import supported: Yes
- Recovery flow:
  1. User selects a `.db` backup file.
  2. User enters the passphrase set during export.
  3. App validates: decryption succeeds, schema version compatible, integrity check passes.
  4. App re-keys from passphrase to device key, replaces current DB, and restarts.
- Plaintext export policy: Disallowed. All backups are encrypted with a user-set passphrase.

### Validation Requirements

- Import parsing rejects files that cannot be decrypted (wrong passphrase or not a SQLCipher database).
- Import rejects files with a schema version newer than the app (`BackupVersionTooNewException`).
- Import rejects files that fail `PRAGMA integrity_check` (`BackupCorruptedException`).
- Export verifies the re-keyed backup with `PRAGMA integrity_check` before finalising.
- Round-trip backup/restore is tested as a critical integration test.

## 12. Security Testing Strategy

| Area | Test Type | Notes |
|------|-----------|-------|
| Database encryption | Integration | Verify DB file is not readable without the correct key |
| Backup export/import | Unit + Integration | Round-trip: create data -> export with passphrase -> delete all -> import -> verify |
| Wrong passphrase rejection | Unit | Import with incorrect passphrase returns clear error |
| Schema version validation | Unit | Backup with newer version throws `BackupVersionTooNewException` |
| Integrity check | Unit | Corrupted backup file throws `BackupCorruptedException` |
| No network permissions | Integration | Verify merged Android manifest contains no INTERNET or network permissions |
| Offline operation | Integration | Disable all network interfaces -> launch app -> full CRUD -> verify zero errors |

### Required Test Vectors Or Regression Areas

- Backup round-trip with known passphrase (deterministic test).
- Import of a file encrypted with the wrong passphrase (must fail gracefully).
- Import of a file with a future schema version (must reject).
- Merged manifest audit for network permissions (must be zero matches).

## 13. Incident Response Notes

- Triage owner: Single developer (SreerajP).
- Severity model: Any issue that could expose user data in plaintext is critical.
- Immediate containment actions:
  - If a transitive dependency introduces networking: remove the dependency, run dep audit, rebuild.
  - If encryption is found to be bypassable: patch the key derivation or SQLCipher configuration, release update.
- User communication trigger: Not applicable (personal-use app, single user).
- Patch release process reference: `docs/release_process.md`

## 14. Open Risks And Future Hardening

- Risk: User forgets backup passphrase — backup is permanently unrecoverable.
  Hardening option: Show a prominent, non-dismissible warning at export time. Consider passphrase hint storage in a future version (stored locally, never in the backup).
- Risk: Device key loss after factory reset — live database is unrecoverable without a backup.
  Hardening option: Encourage regular backups with clear in-app guidance. Consider periodic backup reminders in a future version.
- Risk: No app lock means anyone with device access can read task data.
  Hardening option: Add biometric/PIN app lock in a future version (v2.0).
- Risk: SQLCipher library vulnerability.
  Hardening option: Monitor SQLCipher releases and update promptly. The `sqflite_sqlcipher` package tracks upstream SQLCipher versions.

## 15. Security Review Checklist

- [ ] Threat model reviewed.
- [ ] Sensitive data inventory updated.
- [ ] Logging policy reviewed.
- [ ] Storage and backup behavior reviewed.
- [ ] Permission usage reviewed.
- [ ] Recovery, import, export, and migration paths reviewed.
- [ ] Tests cover the highest-risk failure modes.
