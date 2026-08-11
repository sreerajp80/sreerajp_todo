# Change Log — Live Database Encryption at Rest (Android Keystore / Windows DPAPI Integration)

**Date:** 2026-08-10 13:13
**Plan reference:** `plans/20260810_130943_live_database_encryption.md`

## Summary of Changes
Implemented transparent AES-256 live database encryption at rest across Android and Windows desktop platforms:

1. **Android Hardware Keystore Integration (`MainActivity.kt`):**
   - Registered MethodChannel `in.sreerajp.todo/database_key`.
   - Created Android Hardware KeyStore AES-256 Master Key (`AndroidKeyStore`).
   - Encrypted 32-byte (256-bit) database passphrase with AES/GCM/NoPadding and saved IV + Ciphertext in private `SharedPreferences`.
   - Returns 64-character hex key string on demand.

2. **Windows DPAPI Integration (`win32_dpapi.dart`):**
   - Implemented native bindings for `CryptProtectData` and `CryptUnprotectData` via `dart:ffi` calling `crypt32.dll`.
   - Securely protects 256-bit database encryption key saved in `sreerajp_todo_db.key` under app documents directory using Windows user credentials.

3. **Database Key Service (`database_key_service.dart`):**
   - Created `DatabaseKeyService` resolving the 256-bit database key dynamically based on platform (Android KeyStore MethodChannel, Windows DPAPI FFI, or test key in `FLUTTER_TEST`).

4. **Transparent Database Encryption (`database_service.dart`):**
   - Updated `DatabaseService` to retrieve the key from `DatabaseKeyService` and pass it to `sqflite_sqlcipher` (mobile) / FFI runtime (desktop).
   - Added transparent automatic in-place migration for existing unencrypted databases via `PRAGMA rekey`.

5. **Riverpod Providers & Documentation (`providers.dart`, `architecture.md`):**
   - Provided `databaseKeyServiceProvider` and injected into `databaseServiceProvider`.
   - Updated architecture documentation.

6. **Unit Tests (`database_key_service_test.dart`):**
   - Added unit tests for key generation and test environment fallback logic.

## Verification
- `flutter analyze` completed with 0 errors / 0 warnings.
- `flutter test` passed all 235 unit and widget tests successfully.
