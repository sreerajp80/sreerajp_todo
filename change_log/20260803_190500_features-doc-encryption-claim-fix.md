# Change log: fixed false live-database-encryption claim in features.md

Implements plan: `plans/20260803_190000_features-doc-encryption-claim-fix.md`

## What was wrong

`docs/features.md` said the live app database is transparently encrypted on the device
using a hardware key (Android Keystore / Windows DPAPI). A code check showed this is
not true: `lib/data/database/database_service.dart` opens the live database with no
password at all, and the desktop (FFI) code path does not even support a password —
it throws an error if one is passed. Only backup export files are actually encrypted
(with a user-typed passphrase).

## What changed

Edited `docs/features.md` in two places:

1. **Technical Profile** (Database Storage bullet) — now says the live database is
   opened without a password today, device-key encryption is a planned feature not yet
   built, and only backup files are encrypted right now.

2. **Section 2.2** (previously "AES-256 Database Encryption & Passphrase Backups") —
   renamed to "Database Encryption Status (Live DB Not Yet Encrypted; Passphrase
   Backups Are)". The "Live Database" bullet now states plainly that it is
   unencrypted today, and the "Backup Archives" bullet is kept as-is since it was
   already accurate.

## What was checked and left unchanged

A background audit compared the whole doc against the code before this fix. Everything
else was confirmed accurate: all routes in section 12, the 8 sort modes, statistics
screen filters/cards/table columns/charts, the recurrence engine (file names, 7-day
look-ahead window), undo system constants (5s toast, 5-item stack, 2-min clear), backup
filename pattern and 8-character passphrase minimum, the 8 domain exceptions, and the
English/Malayalam-only localization with no in-app switcher.

## Note not acted on

The project's own `CLAUDE.md` repeats the same false live-DB-encryption claim, and
separately has a route table that is out of date (lists `/recurring*` routes/screens
that don't exist in code, and is missing `/settings`, `/about`, `/permissions` which do
exist). This was flagged to the user but not fixed, since it's outside the scope of the
features.md task.
