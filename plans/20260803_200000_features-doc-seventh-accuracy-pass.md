# Features doc — seventh accuracy pass (fix leftover "re-encrypts to local device key" claim)

**Status:** completed

## Files to be changed

- `docs/features.md`

## What the issue is

I did a full critical review of `docs/features.md` against the actual code (screens, routes,
exceptions, use-cases, providers, settings screen, statistics screen, backup service, pubspec).

Almost everything already checks out correctly, after six earlier accuracy passes. I found
**one** leftover mistake:

- **Section 11.2 "Import Restore"**, line 253, says the restore flow:
  > "...executes `PRAGMA integrity_check` validation, **re-encrypts to local device key**,
  > replaces live database atomically..."

  This is wrong and it contradicts the doc's own Section 2.2, which already correctly says the
  live database is **not** encrypted today (only backup archives are, with a user passphrase).

  I checked the real code in `lib/data/backup/backup_service.dart`, method `importDatabase`
  (around lines 66–134). After the backup archive is decrypted and its integrity is checked,
  the code just copies the extracted database file straight on top of the live database path
  (`File(extractedDatabasePath).copy(liveDatabasePath)`). There is no re-encryption step
  anywhere in that method or elsewhere in the file. So the "re-encrypts to local device key"
  phrase is describing a step that does not exist in the code yet (device-key encryption is
  listed elsewhere in the doc as a planned, not-yet-built feature).

No other missing features, wrong routes, wrong exception names, or scope gaps were found in
the rest of the document — Section 1 (App Overview) and the Accessibility Profile already cover
the app's full actual scope.

## The plan for the fix

1. In `docs/features.md`, Section 11.2, replace:
   > "...executes `PRAGMA integrity_check` validation, re-encrypts to local device key,
   > replaces live database atomically, and triggers automatic recurring task generation."

   with wording that matches the real behaviour and stays consistent with Section 2.2, e.g.:
   > "...executes `PRAGMA integrity_check` validation, replaces the live database atomically
   > with the restored (currently unencrypted) database file, and triggers automatic recurring
   > task generation."

2. Re-read the full document once more after the edit to confirm no other sentence still
   references "re-encrypts" or implies the live DB gets encrypted on restore.

3. Write a change log entry in `change_log/` describing the fix, referencing this plan.

No code files are touched — this is a documentation-only correction.
