# Fix false live-database-encryption claim in features.md

**Status:** completed

## Files to be changed

- `docs/features.md`

## What the issue is

I asked a background agent to check `docs/features.md` against the real code. Almost
everything in the doc is correct (routes, sort modes, statistics screen, recurrence
engine, undo constants, backup details, exceptions list, localization — all confirmed
accurate against the code).

One claim is wrong. The doc says the **live app database** is transparently encrypted
using a device-derived key:

- Line 19 (Technical Profile): "AES-256 SQLCipher encryption ... with AES-256 SQLCipher
  encryption"
- Line 42 (section 2.2): "**Live Database:** Transparently encrypted on device storage
  (Android Keystore hardware security on Android, Windows DPAPI on Windows). No password
  entry required for normal daily usage."

Checking the actual code (`lib/data/database/database_service.dart`):
- The live database is opened with **no password at all** — no key is generated,
  stored, or passed in.
- On Windows/desktop (the FFI code path), passing a password is not even supported —
  the code throws an error if one is ever given.
- The only place a passphrase and real encryption are used is for **backup export
  files** (ZIP archive encrypted with a user-typed passphrase at export time). That
  part of the doc is accurate and stays as-is.

So the doc currently states, as a finished fact, a security feature (encrypted live
database) that has not been built yet. This is misleading — it overclaims what the app
actually protects on-device today.

## The plan for the fix

Edit `docs/features.md` in two places to describe the live database honestly:

1. **Technical Profile (around line 19)** — change the database bullet so it says the
   live database uses plain SQLite (via `sqflite_sqlcipher` / `sqflite_common_ffi`, no
   password currently applied), and encryption is only applied to exported backup
   files.

2. **Section 2.2 "AES-256 Database Encryption & Passphrase Backups" (around lines 41-43)**
   — replace the "Live Database: Transparently encrypted... Android Keystore... Windows
   DPAPI" bullet with an accurate statement: the live, on-device database is **not**
   currently encrypted with a device key (this is a planned/future item, not yet
   implemented); only backup archives are passphrase-encrypted today. Keep the "Backup
   Archives" bullet as-is, since it's correct.

No other section of the doc needs a change — the rest was verified correct.

I will not touch the project's `CLAUDE.md` file, since it repeats a similar claim and
has its own separate route-table drift (`/recurring*` routes that don't exist,
missing `/settings` `/about` `/permissions` that do) — that's a different file outside
the scope of this task; I'll just flag it to you separately.

After you approve, I will make the edit and then write the change log.
