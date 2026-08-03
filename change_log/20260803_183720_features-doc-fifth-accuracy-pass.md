# Change log: fifth accuracy pass on docs/features.md

Implements plan: `plans/20260803_183720_features-doc-fifth-accuracy-pass.md`

## What was wrong

Re-checked `docs/features.md` against the code and found three problems left over
from earlier accuracy passes:

1. The Summary Matrix table (Section 13, "Security & Backup" row) still said
   "AES-256 SQLCipher DB encryption," contradicting the earlier fix in Section 2
   which correctly states the live database is not yet encrypted (only backup
   files are passphrase-encrypted). Confirmed by reading
   `lib/data/database/database_service.dart` — the live database is opened with
   no password argument.
2. The About screen's row in the Section 12 screen table did not mention two
   info tiles the screen actually shows: a Unicode-first input note and a
   "built for daily navigation flow" note (`lib/presentation/screens/about/about_screen.dart`).
3. The Permissions screen's row in the Section 12 screen table said it lists
   "required local storage permissions," but the screen actually lists four
   implicit permission categories: storage, file picker access, system clock,
   and text processing (`lib/presentation/screens/settings/permissions_screen.dart`).

## What changed

Edited `docs/features.md` in three places:

1. Section 13 Summary Matrix, "Security & Backup" row — now says "Passphrase-protected
   AES-256 backup encryption (live database is not yet encrypted), backup integrity
   check, zero network/telemetry."
2. Section 12 table, About App row — now also mentions the Unicode-first input note
   and the daily-navigation-flow note.
3. Section 12 table, Permissions Info row — now names all four implicit permission
   categories instead of just "storage."

No code was changed — this was a documentation-only fix.

## What was checked and left unchanged

An Explore sub-agent independently verified the Settings screen description (accurate,
no changes needed) and the full route list in `lib/core/constants/app_routes.dart`
(matches Section 12 exactly — no discrepancy). It also confirmed there is no CSV/other
export, no notifications/reminders subsystem, no app-icon customization, and no
standalone "duplicate/clone task" action anywhere in the code, so the doc's silence on
those is correct rather than a gap.
