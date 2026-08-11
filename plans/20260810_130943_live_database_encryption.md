# Implementation Plan — Live Database Encryption at Rest (Android Keystore / Windows DPAPI Integration)

**Status:** Approved

## Issue
The live database (`sreerajp_todo.db`) is currently opened without encryption at rest (`password: null`). While exported backup archives are encrypted with AES-256 ZIP encryption, the live database file stored on the local device filesystem is unencrypted.

## Proposed Fix
Implement transparent 256-bit live database encryption at rest across Android and Windows platforms:
1. **Android Hardware Keystore Integration (`MainActivity.kt`):** Implement a MethodChannel (`in.sreerajp.todo/database_key`) in Kotlin. Generate an AES-256 master key in Android Hardware KeyStore (`AndroidKeyStore`), encrypt a 256-bit random database key via AES/GCM/NoPadding, and store the encrypted payload in private `SharedPreferences`. Decrypt and return the 64-character hex key string to Flutter on demand.
2. **Windows DPAPI Integration (`win32_dpapi.dart`):** Implement Windows Data Protection API (`CryptProtectData` / `CryptUnprotectData`) binding via `dart:ffi` calling `crypt32.dll`. Securely encrypt and store the 256-bit database key in `sreerajp_todo_db.key` under the app documents directory, protected by the Windows user credentials.
3. **Database Key Service (`database_key_service.dart`):** Create a unified key manager that retrieves/creates the key per platform (Android KeyStore channel, Windows DPAPI FFI, or mock key during test execution).
4. **Database Service Encryption (`database_service.dart`):** Pass the key to `sqflite_sqlcipher` (mobile) and SQLCipher / FFI configuration (desktop) when opening `sreerajp_todo.db`. Include transparent migration logic so existing unencrypted database files are encrypted in-place without data loss.
5. **Documentation & Tests:** Add unit tests for key management and update security documentation (`docs/security.md`, `docs/architecture.md`).

## Proposed File Changes
- **NEW** `lib/data/database/database_key_service.dart`
- **NEW** `lib/core/utils/win32_dpapi.dart`
- **NEW** `test/data/database_key_service_test.dart`
- **MODIFY** `android/app/src/main/kotlin/in/sreerajp/sreerajp_todo/MainActivity.kt`
- **MODIFY** `lib/data/database/database_service.dart`
- **MODIFY** `lib/application/providers.dart`
- **MODIFY** `docs/security.md`
- **MODIFY** `docs/architecture.md`
