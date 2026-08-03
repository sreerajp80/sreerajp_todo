# Change log — Features doc, seventh accuracy pass

Implements: `plans/20260803_200000_features-doc-seventh-accuracy-pass.md`

## What changed

Did a full critical review of `docs/features.md` against the real code: all screens, routes
(`app_routes.dart`, `app.dart`), domain exceptions, use-cases, Riverpod providers, the Settings
screen, the Statistics screen, and the backup/restore logic in `lib/data/backup/backup_service.dart`.

The document was already accurate after six earlier passes, with one exception:

- **Section 11.2 "Import Restore"** said the restore flow "re-encrypts to local device key."
  This was wrong — it contradicted Section 2.2 of the same document, which already correctly
  states the live database is **not** encrypted today (only backup archives are, with a user
  passphrase). The real code in `importDatabase()` (`backup_service.dart`) just copies the
  decrypted backup file straight onto the live database path. There is no re-encryption step.

## Fix applied

Updated the sentence in Section 11.2 to say the restore flow "replaces the live database
atomically with the restored (currently unencrypted) database file," matching the actual code
and staying consistent with Section 2.2.

## What was checked and found correct (no changes needed)

- All 10 screens present in code are listed in the Section 12 route table and the Section 13
  summary matrix.
- Route paths match `app_routes.dart` / `app.dart` exactly, including query-param routes.
- All 8 exceptions in `lib/core/errors/exceptions.dart` match Section 2.6 verbatim.
- All use-cases in `lib/domain/usecases/` are represented in the doc.
- No calendar heatmap feature exists in code (already correctly removed from the doc in an
  earlier pass); no undocumented package or screen was found in `pubspec.yaml` or
  `lib/presentation/screens/`.
- The App Overview and Accessibility Profile in Section 1 already reflect the app's full scope.
