# Plan: fifth accuracy pass on docs/features.md

**Status:** completed

## Files to be changed

- `docs/features.md`

## What is wrong

I re-checked `docs/features.md` against the code after four earlier accuracy passes today.
I found three remaining problems:

1. **Contradicts its own earlier fix.** Section 13 ("Summary Matrix of App Capabilities"),
   row "Security & Backup", still says:
   > AES-256 SQLCipher DB encryption, passphrase-protected portable backups, ...

   This directly contradicts Section 2, point 2 (already fixed in the last pass), which
   correctly says the **live** database is currently unencrypted — only backup files are
   passphrase-encrypted. I checked `lib/data/database/database_service.dart` line 28: the
   live database is opened with no `password` argument, confirming the live DB is plain
   SQLite today. The Summary Matrix row was missed when the earlier fix was made.

2. **About screen description is incomplete.** Section 12's table entry for the About
   screen says it shows "app version, build date, author metadata, AI pair-programming
   attribution, and offline guarantees." I checked
   `lib/presentation/screens/about/about_screen.dart` and it also shows two more info
   tiles that aren't mentioned: a Unicode-first input tile and a "built for daily
   navigation flow" tile.

3. **Permissions screen description is too narrow.** Section 12's table entry for the
   Permissions screen says it lists "required local storage permissions." I checked
   `lib/presentation/screens/settings/permissions_screen.dart` and it actually lists four
   implicit permission categories — storage, file picker access, system clock, and text
   processing — plus a separate section confirming no explicit permissions are required.
   The doc's wording undersells this by naming only "storage."

## Plan for the fix

Edit `docs/features.md` in three places:

1. In Section 13's Summary Matrix, "Security & Backup" row: replace
   "AES-256 SQLCipher DB encryption" with wording that matches Section 2's corrected
   claim — e.g. "Passphrase-protected AES-256 backup encryption (live DB not yet
   encrypted), backup integrity check, zero network/telemetry."

2. In Section 12's table, About App row: extend the description to also mention the
   Unicode-first input tile and the daily-navigation-flow tile.

3. In Section 12's table, Permissions Info row: extend the description to name all four
   implicit permission categories (storage, file picker, system clock, text processing)
   instead of just "storage permissions."

No code changes — this is a documentation-only fix.

## Do you approve this plan?
