# Fixed app bar menu overflow in Malayalam

Implements `plans/20260819_062249_appbar-menu-overflow.md`.

## What was wrong

The app bar "more options" popup menu on the daily list screen showed a
"RIGHT OVERFLOWED BY 8.3 PIXELS" stripe on the local P2P Wi-Fi sync row when
the app language was Malayalam. Each row placed a plain `Text` next to an icon
inside a `Row`, so the label asked for its full one-line width and spilled past
the popup menu's maximum width.

The Data Handoff row also had no Malayalam translation, so it showed English.

## What changed

- `lib/presentation/screens/daily_list/daily_list_screen.dart`
  - Wrapped the label `Text` of all five popup menu rows (settings, Wi-Fi sync,
    AirQR share, AirQR scan, data handoff) in `Expanded`. Long labels now wrap
    to a second line instead of overflowing.
- `lib/l10n/app_ml.arb`
  - Added the Malayalam string for `dataHandoffTitle`.
- `lib/l10n/app_localizations_ml.dart`
  - Regenerated with `flutter gen-l10n`.

## Checks

- `flutter analyze` — no issues found.
- `flutter test` — all 426 tests passed.
