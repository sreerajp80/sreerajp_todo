# Change Log — App Colour (page background) setting

Implements: `plans/20260818_213801_app-background-colour.md`

## What was added

A new **App Colour** page under Settings → Appearance. The user picks one base
colour and the app derives the page background, the card colour, the outline
colour and the text colour from it. The choice is saved separately for light
mode and dark mode, the same way the accent colour already was.

The accent colour setting is untouched. It still controls the highlight colour
(buttons, chips, switches, selected labels) and still wins over the app colour.

If the user picks nothing, the app looks exactly as before.

## How it works

- One picked colour is passed to the theme as `base`.
- `AppTheme.normalizeBase` pulls the pick into a safe range first:
  - light mode: lightness kept at 0.86 or above, saturation at 0.45 or below,
  - dark mode: lightness kept at 0.20 or below, saturation at 0.55 or below.
  So a light theme stays light, a dark theme stays dark, and the tint never
  gets loud. The picker previews the corrected colour, so what the user sees is
  what the app uses.
- From that colour the theme derives:
  - page background — the picked colour itself,
  - card / dialog / popup / navigation bar colour — a step away from the
    background (lighter, or slightly darker when the page is nearly white),
  - input, chip, raised button and unselected segment colour — a further step,
  - outline colour and text colours (`onSurface`, `onSurfaceVariant`) — same
    hue, fixed readable lightness, saturation capped.

## Files changed

| File | Change |
|------|--------|
| `lib/presentation/shared/theme/app_theme.dart` | new `base` parameter on `light()` / `dark()` / `_buildTheme`; `defaultLightBase`, `defaultDarkBase`, `presetLightBases`, `presetDarkBases`, `defaultBaseFor`, `presetBasesFor`, `normalizeBase`, `_tone`; background, surface, card, dialog, popup, navigation bar, input, chip, raised button, outline and text colours now derive from the base when one is set |
| `lib/application/appearance_notifier.dart` | `lightBase` / `darkBase` state, `baseFor`, `setBaseFor`, `resetBaseFor`, and the `appearance_base_light` / `appearance_base_dark` preference keys |
| `lib/presentation/screens/settings/app_color_screen.dart` | new picker screen: live preview built from the real theme, preset swatches per brightness, hue / tint / shade sliders, reset button |
| `lib/presentation/screens/settings/appearance_screen.dart` | new "App Color" card |
| `lib/core/constants/app_routes.dart` | new `appColor` route path |
| `lib/app.dart` | new route, and `base:` passed into the light and dark themes |
| `lib/l10n/app_en.arb`, `lib/l10n/app_ml.arb` | 16 new strings in English and Malayalam |
| `lib/l10n/app_localizations*.dart` | regenerated with `flutter gen-l10n` |
| `test/application/appearance_notifier_test.dart` | saves / reloads / resets the app colour per brightness, and keeps it apart from the accent |
| `test/presentation/app_theme_test.dart` | new file: default look unchanged, background follows the pick, cards stay apart from the background, text contrast above 4.5:1 on every preset, clamps for out-of-range and loud picks, accent still wins |
| `test/presentation/settings_screen_test.dart` | Appearance hub now has four cards |
| `docs/features.md` | Appearance, Accent Color and App Color rows in the screen map |

## Checks

- `flutter analyze` — no issues found.
- `flutter test` — 337 tests, all passed.
- `dart format` run on every changed file.

## Notes

- No database change, no migration, no new package. Still fully offline.
- The 17 "untranslated" messages reported by `flutter gen-l10n` are pre-existing
  data-handoff strings and are not related to this change. All 16 new strings
  are translated in Malayalam.
