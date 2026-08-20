# App bar "more options" menu overflows in Malayalam

**Status:** completed

## Issue

In the daily list screen, the app bar popup menu shows a yellow/black
"RIGHT OVERFLOWED BY 8.3 PIXELS" stripe on the "ലോക്കൽ P2P വൈഫൈ സിങ്ക്" row
when the app language is Malayalam.

Reason: each menu row is a `Row` with an icon, a gap and a plain `Text`.
The `Text` is not flexible, so it asks for its full one-line width. The popup
menu has a maximum width, so any label longer than that width overflows
instead of wrapping or shortening. English labels are short enough, Malayalam
labels are not.

A second, smaller issue: `dataHandoffTitle` has no Malayalam translation, so
that row still shows English text.

## Files to change

- `lib/presentation/screens/daily_list/daily_list_screen.dart`
- `lib/l10n/app_ml.arb`
- `lib/l10n/app_localizations_ml.dart` (regenerated, not hand edited)

## Plan for the fix

1. In `daily_list_screen.dart`, wrap the label `Text` of all five popup menu
   rows in `Expanded`, so the label uses the space left over after the icon
   and gap. This lets long text wrap to a second line instead of overflowing.
2. Add the missing `dataHandoffTitle` Malayalam string to `app_ml.arb`.
3. Regenerate localizations with `flutter gen-l10n`.
4. Run `flutter analyze` and `flutter test`.

No behaviour change, only layout and translation.
