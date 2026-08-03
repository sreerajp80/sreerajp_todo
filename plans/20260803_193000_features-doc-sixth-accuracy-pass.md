# Features doc — sixth accuracy pass (screen-reader accessibility gap)

**Status:** completed

## What I checked

I did a full fresh audit of `docs/features.md` against the current code: every route in
`lib/app.dart` / `app_routes.dart`, every provider in `providers.dart`, every use-case file,
the Statistics screen tabs, the Settings screen, the pubspec dependencies, and the Android
manifest. This confirms the previous five accuracy passes are still holding up — no
regressions, no reintroduced heatmap/encryption claims, all screens and routes are listed
correctly.

## The one gap found

The doc's "Inclusive Design & Accessibility Profile" (section 1) lists four accessibility
areas: multi-lingual/RTL, visual/colorblind, keyboard/motor, and offline/digital inclusion.
It does not mention screen-reader support.

The code actually has real `Semantics` labels on interactive controls, confirmed in
`lib/presentation/screens/daily_list/widgets/todo_list_tile.dart`:
- line 203-205: the whole tile is marked `button: true` with a tooltip label.
- line 345-347: the title text is exposed with `label: todo.title`.
- line 366-368: the selection-toggle checkbox has `button: true, label: toggleSelection`.
- line 487-489: the delete action has `button: true, label: delete`.
- line 506-507: the locked-day overlay has `label: lockedTask`.

The same `Semantics(...)` pattern also appears in `create_edit_todo_screen.dart`,
`time_segments_screen.dart`, and the shared `app_error_state.dart` / `status_badge.dart` /
`app_empty_state.dart` widgets — so this is a real, deliberate, app-wide pattern, not a
one-off.

## Files to change

- `docs/features.md` only.

## The fix

Add one bullet to the "Inclusive Design & Accessibility Profile" list in section 1, after the
existing "Keyboard & Motor Accessibility" bullet, describing screen-reader support: interactive
list tiles, action buttons (toggle-select, delete), status badges, and locked-day indicators
all expose `Semantics` labels/roles for screen readers (e.g. TalkBack, Narrator).

No other changes are needed — every other part of the document (screens, providers, use
cases, statistics tabs, settings, offline/manifest claims) was independently re-verified and
found accurate.

## Change log

After this edit is approved and made, I will write a change log entry to `change_log/`
describing the addition, referencing this plan.
