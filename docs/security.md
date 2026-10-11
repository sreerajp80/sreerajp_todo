# Security — SreerajP ToDo

This document defines the security architecture, threat model, cryptographic design, sensitive data inventory, and offline boundary rules for SreerajP ToDo. Read this before modifying any security, crypto, database storage, backup, or permission logic.

Read [AGENTS.md](../AGENTS.md), [CLAUDE.md](../CLAUDE.md), and [architecture.md](architecture.md) first. For shared reference standards, see [guidelines/security.md](guidelines/security.md).

---

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

---

## 2. Security Objectives

- Protect locally stored task data and time-tracking records from casual extraction on a lost or stolen device.
- Prevent accidental disclosure of user data through logs, unencrypted backups, screenshots, or exports.
- Preserve recoverability and cross-device migration through portable encrypted backups with user-set passphrases.
- Ensure zero data leaves the device involuntarily — no network access, no telemetry, no cloud sync.

---

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

---

## 4. Sensitive Data Inventory

| Data Type | Example | Where It Exists | Protection Required |
|-----------|---------|-----------------|---------------------|
| Task titles | "Doctor appointment" | SQLite DB (encrypted), backup files (encrypted) | AES-256 encryption at rest |
| Task descriptions | "Bring insurance card" | SQLite DB (encrypted), backup files (encrypted) | AES-256 encryption at rest |
| Time segments | Start/end timestamps | SQLite DB (encrypted), backup files (encrypted) | AES-256 encryption at rest |
| Device encryption key | Android Keystore / DPAPI key reference | Platform secure key store | Never exposed to Dart code as plaintext; accessed via platform API |
| Backup passphrase | User-entered string | Memory only (during export/import) | Never stored on disk; cleared after operation |

---

## 5. Storage Model

### At Rest

- Primary local storage: SQLite database file encrypted with AES-256 via `sqflite_sqlcipher` (mobile) / SQLCipher FFI (desktop).
- Secure key storage: Android Keystore (Android) / Windows DPAPI (Windows) for the device-derived database encryption key.
- Backup behavior: Encrypted only. Backup files are re-encrypted from the device key to a user-set passphrase at export time. Plaintext export is not supported.

### In Memory

- Sensitive values are kept in memory: briefly (during database operations and backup passphrase entry).
- Memory clearing strategy: Passphrase strings are used only within the export/import flow scope and are not cached. The database handle holds the decryption context in native memory managed by SQLCipher.

### In Transit

- Internet use: None. The app never sends data over the internet. It has zero networking dependencies, zero cloud SDKs and zero telemetry.
- Local network use: Wi-Fi sync only, and only when the user starts it. `P2pWifiSyncService` opens a TCP socket between the user's own devices on the same Wi-Fi or hotspot. It refuses to connect to, or accept a connection from, any address that fails `isLocalNetworkAddress()` (`lib/core/network/network_address_utils.dart`). Only private (`10/8`, `172.16/12`, `192.168/16`), link-local (`169.254/16`) and loopback (`127/8`) IPv4 addresses pass. Host names are never resolved.
- Transport protections: The sync payload is encrypted with a session key derived from the pairing PIN and a random salt.

---

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

---

## 7. Authentication And Access Control

- App-lock strategy: Optional PIN and biometric device lock supported via the native `in.sreerajp.todo/app_lock` channel (Android). When enabled in Settings, the app requires device authentication before displaying task content.
- Fallback behavior: System device credentials (PIN/pattern/password) serve as fallback when biometrics fail.
- Session-expiry rule: Immediate on app backgrounding when lock is active.
- Background lock rule: Window shielding via `FLAG_SECURE` obscures recent task snapshots.
- Protected-route strategy: Day lock (past dates are read-only) enforced at the repository layer.

---

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

- Logger implementation: `AppLogger` (`lib/core/logging/app_logger.dart`), console only through `dart:developer`. `print()` and `debugPrint()` are not used.
- Verbose logging gate: `trace` and `debug` are silent in release builds. `info` and above still reach the console.
- Error objects: `AppLogger` records only the error type, never the error message, because a message can hold a task title.
- Redaction strategy: Never pass user content to any logging function. Log operation names and error categories only.
- `print()` is banned via `avoid_print` lint rule.

---

## 9. Platform Security Controls

### Android

- `android:allowBackup`: `false` (prevents Android's auto-backup from copying the encrypted DB to Google Drive in plaintext-accessible form).
- `android:fullBackupContent`: Not used (allowBackup is false).
- Screenshot protection: Enabled via `FLAG_SECURE` through the `in.sreerajp.todo/app_lock` channel, shielding screen content against screen captures and recent task previews.
- Root or tamper detection: Not implemented (out-of-scope threat model).
- `INTERNET` permission: Declared **only** for Wi-Fi sync on the local network. Android asks for it for any socket, even one that never leaves the Wi-Fi. The Dart address guard above is what keeps traffic local.
- `ACCESS_NETWORK_STATE`: Not needed. Removed from the final manifest with `tools:node="remove"` in case a plugin adds it.
- `ACCESS_WIFI_STATE`: Absent.
- No Google ML Kit, Play Services or Firebase code. OCR uses on-device Tesseract, and the AirQR scanner decodes camera frames with ZXing core (pure Java, no network code). Google ML Kit was removed because it shipped `com.google.android.datatransport`, which uploads usage events to Google.
- `CAMERA`: Declared, for QR code scanning between the user's own devices. No photo is stored.
- `RECORD_AUDIO`: Declared, for the offline voice task sheet only. See section 10.

### Windows

- No firewall rules registered.
- No internet connections. Wi-Fi sync, when the user starts it, talks only to local-network addresses (same guard as Android).
- No WinRT network capabilities (`internetClient`, `internetClientServer`, `privateNetworkClientServer`) declared.
- Database encryption key stored via Windows DPAPI, tied to the Windows user account.

---

## 10. Permissions

| Permission | Why It Is Needed | Requested When | Denial Handling |
|------------|------------------|----------------|-----------------|
| Local file storage (implicit) | SQLite database in app's private directory | Automatic (OS grants to all apps for their own data directory) | Not applicable |
| External storage / file access | Backup export/import to user-accessible location | When the user taps Export or Import on the Backup screen | Show error explaining file access is required for backup |
| `CAMERA` | Scanning an AirQR code to move data between the user's own devices | When the user opens the QR scanner | The scanner screen explains that the camera is required; every other feature keeps working |
| `INTERNET` | Wi-Fi sync between the user's own devices on the local network. No internet traffic | Granted at install (normal permission) | Not applicable |
| `RECORD_AUDIO` | The offline voice task sheet | Only after the user turns **Voice input** on in Settings → Task defaults → Day list, and then taps the microphone | The sheet shows its text box instead, and the sentence is parsed exactly the same way |

Permissions the app explicitly does NOT request: `ACCESS_NETWORK_STATE`, `ACCESS_WIFI_STATE`, `LOCATION`, `CONTACTS`, `PHONE`, `NOTIFICATIONS`.

### Why `RECORD_AUDIO` does not break the offline guarantee

Flutter cannot read a microphone by itself, so speech-to-text has to come from
somewhere. The choice made here keeps the offline promise in three ways:

1. **The app itself sends nothing over the internet.** The only socket code is
   Wi-Fi sync, which is limited to local-network addresses. The voice feature
   adds no network code, and the manifest audit in section 12 still applies.
2. **The recogniser is always asked for its on-device engine.** From API 33 the
   host calls `SpeechRecognizer.createOnDeviceSpeechRecognizer`; below that it
   sets `RecognizerIntent.EXTRA_PREFER_OFFLINE`. A device that cannot offer an
   on-device engine is reported back as `no_offline` and listening is
   **refused**, rather than being allowed to fall back to a server.
3. **A network error is treated as a missing language pack.** If the recogniser
   still reaches for the network, the host maps that error to
   `no_offline_language`, the attempt fails, and the user is told to install an
   offline pack or type instead.

The honest limit, recorded here so it is never overstated: the recogniser is a
separate app on the device (usually the system speech service). Its behaviour
can be constrained as above and its failures can be surfaced, but its code
cannot be audited from here. Users who do not accept that limit simply leave
**Voice input** off, which is the default, and type the sentence — the parser
itself is pure Dart and reaches nothing at all.

No audio is recorded, buffered to disk, or kept. The recogniser hands back text,
the text is parsed on the device, and the recogniser is destroyed as soon as the
sentence ends or the sheet closes.

---

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

---

## 12. Security Testing Strategy

| Area | Test Type | Notes |
|------|-----------|-------|
| Database encryption | Integration | Verify DB file is not readable without the correct key |
| Backup export/import | Unit + Integration | Round-trip: create data -> export with passphrase -> delete all -> import -> verify |
| Wrong passphrase rejection | Unit | Import with incorrect passphrase returns clear error |
| Schema version validation | Unit | Backup with newer version throws `BackupVersionTooNewException` |
| Integrity check | Unit | Corrupted backup file throws `BackupCorruptedException` |
| No internet traffic | Integration | Verify the merged Android manifest has `INTERNET` as its only network permission, and no `com.google.mlkit`, `com.google.android.gms` or `datatransport` entries |
| Local-only Wi-Fi sync | Unit | `isLocalNetworkAddress()` accepts only local ranges; `connectAndSyncAsPeer` throws `NonLocalAddressException` for other addresses |
| Offline operation | Integration | Disable all network interfaces -> launch app -> full CRUD -> verify zero errors |

### Required Test Vectors Or Regression Areas

- Backup round-trip with known passphrase (deterministic test).
- Import of a file encrypted with the wrong passphrase (must fail gracefully).
- Import of a file with a future schema version (must reject).
- Merged manifest audit: `ACCESS_NETWORK_STATE`, `ACCESS_WIFI_STATE`, `com.google.mlkit`, `com.google.android.gms` and `datatransport` must have zero matches. `INTERNET` is expected.

---

## 13. Incident Response Notes

- Triage owner: Single developer (SreerajP).
- Severity model: Any issue that could expose user data in plaintext is critical.
- Immediate containment actions:
  - If a transitive dependency introduces networking: remove the dependency, run dep audit, rebuild.
  - If encryption is found to be bypassable: patch the key derivation or SQLCipher configuration, release update.
- User communication trigger: Not applicable (personal-use app, single user).
- Patch release process reference: [release_process.md](release_process.md)

---

## 14. Open Risks And Future Hardening

- Risk: User forgets backup passphrase — backup is permanently unrecoverable.
  Hardening option: Show a prominent, non-dismissible warning at export time. Consider passphrase hint storage in a future version (stored locally, never in the backup).
- Risk: Device key loss after factory reset — live database is unrecoverable without a backup.
  Hardening option: Encourage regular backups with clear in-app guidance. Consider periodic backup reminders in a future version.
- Risk: Casual local access if app lock is disabled by user.
  Hardening option: Offer prominent, opt-in device authentication lock in app settings.
- Risk: A new plugin adds its own telemetry or network permission through manifest merge.
  Hardening option: Run the merged-manifest audit in `docs/release_process.md` on every release build.
- Risk: SQLCipher library vulnerability.
  Hardening option: Monitor SQLCipher releases and update promptly. The `sqflite_sqlcipher` package tracks upstream SQLCipher versions.

---

## 15. Security Review Checklist

- [ ] Threat model reviewed.
- [ ] Sensitive data inventory updated.
- [ ] Logging policy reviewed.
- [ ] Storage and backup behavior reviewed.
- [ ] Permission usage reviewed.
- [ ] Recovery, import, export, and migration paths reviewed.
- [ ] Tests cover the highest-risk failure modes.
