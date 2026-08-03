# Change log: Third accuracy pass on docs/features.md

Implements plan `plans/20260803_140000_features-doc-third-accuracy-pass.md`.

## What changed

Both changes are in `docs/features.md` only. No app code was touched.

1. **Fixed a wrong number.** Section 3.5 said title autocomplete used "250ms
   debouncing." The real constant is `kAutocompleteDebounceMills = 300` in
   `lib/core/constants/app_constants.dart`. Changed the doc to say "300ms."

2. **Added a missing route.** The Section 12 route table did not mention the
   root route `/`, which redirects to today's Daily List. Added a row for it,
   noting it is a `GoRouter` redirect defined in `lib/app.dart`, not a screen
   of its own.

## Why

This was a third critical review of the doc (two earlier passes already fixed
other issues: a made-up heatmap feature, wrong sort-option count, a wrong
language-switch claim, and a wrong content-width number). A fresh audit of
screens, routes, entities, use-cases, exceptions, constants, and migrations
against the real code found only these two small gaps. Everything else in the
doc was confirmed accurate.
