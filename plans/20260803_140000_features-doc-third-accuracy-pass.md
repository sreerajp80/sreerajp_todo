# Fix two small inaccuracies in docs/features.md (third accuracy pass)

**Status:** completed

## Files to be changed

- `docs/features.md`

## What is wrong

I checked `docs/features.md` against the real code again (this is the third check —
two earlier ones already found and fixed other problems). Two small things are
still wrong or missing:

1. **Wrong debounce number.** Section 3.5 says title autocomplete uses "250ms
   debouncing." The real code
   (`lib/core/constants/app_constants.dart` — `kAutocompleteDebounceMills = 300`,
   used in `title_autocomplete_field.dart` and `create_edit_todo_screen.dart`)
   uses **300ms**, not 250ms.

2. **Missing route.** `lib/core/constants/app_routes.dart` defines a root route
   `/` that redirects to today's daily list (`lib/app.dart`). Section 12's route
   table does not mention this route at all. It should be listed as a redirect
   row so the route table is complete.

Everything else checked in this pass (screens, providers, entities, use-cases,
exceptions, constants, settings/about/permissions screens, migrations) already
matches the code correctly — no other changes needed.

## Plan for the fix

1. In Section 3.5 ("History-Wide Title Autocomplete"), change "250ms" to "300ms."
2. In Section 12's route table, add a row for `/` → redirects to `/day/<today>`
   (no dedicated screen class — it is a `GoRouter` redirect defined in
   `lib/app.dart`).

No other wording changes. This is a documentation-only fix; no app code is touched.
