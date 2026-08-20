# App Background Colour (App Colour) Setting

**Status:** completed

## Issue

Settings -> Appearance today lets the user change only the **accent** colour
(the highlight colour used on buttons, chips, switches and selected text).
The page background, the card/surface colour and the outline colour are fixed
constants in `lib/presentation/shared/theme/app_theme.dart`
(`_lightBackground`, `_lightSurface`, `_darkBackground`, `_darkSurface`,
`_lightOutline`, `_darkOutline`).

The user wants to change the overall app colour too, not just the accent.

## Decision (agreed with the user)

Add a new **App Colour** screen that works like the Accent Colour screen:
the user picks **one base colour**, and the app derives the page background,
the card/surface colour and the outline colour from it. Text colours stay
automatic so the app cannot become unreadable. The choice is stored
separately for light mode and dark mode, exactly like the accent.

Not in scope: separate pickers for text colour, or full theme presets.

## Plan for the fix

### 1. Store the new preference
`lib/application/appearance_notifier.dart`
- Add preference keys `appearance_base_light` and `appearance_base_dark`.
- Add `lightBase` / `darkBase` (`Color?`) to `AppearanceState`, with
  `baseFor(Brightness)`, plus `clearLightBase` / `clearDarkBase` flags in
  `copyWith` (same shape as the existing accent fields).
- Load them in `_loadInitialState`.
- Add `setBaseFor(Brightness, Color)` and `resetBaseFor(Brightness)`.

### 2. Derive the theme colours
`lib/presentation/shared/theme/app_theme.dart`
- Add `defaultLightBase` / `defaultDarkBase` constants holding today's values
  (`0xFFF0F4FB` and `0xFF0E1724`), so nothing changes when no colour is picked.
- Add a `presetBases` list of quick-pick base colours (neutral greys plus a few
  soft tints for light mode, and deep tints for dark mode).
- Give `light()`, `dark()` and `_buildTheme()` a new optional `base` parameter.
- When `base` is given, derive with the existing `_withLightness` helper:
  - background = the picked colour,
  - surface = slightly lighter in light mode / slightly lighter in dark mode,
    so cards still stand apart from the page,
  - outline = a mid-lightness version of the same hue,
  - `onSurface` / `onSurfaceVariant` = auto-contrasted via `contrastOn`, so
    text stays readable on any picked colour.
- Keep every existing hard-coded value as the fallback when `base` is null.

### 3. Guard readability
- Clamp the derived lightness so a light-mode pick can never go too dark and a
  dark-mode pick can never go too light (the picker screen shows the clamped
  result live, so what is shown is what is applied).

### 4. New picker screen
`lib/presentation/screens/settings/app_color_screen.dart` (new)
- Copy the structure of `accent_color_screen.dart`: live preview card,
  preset swatches, hue/saturation/value wheel and sliders, Reset button.
- The preview shows a sample page with a card, body text and an accent button,
  so the user sees the background/card/text combination together.
- Edits the colour of whichever theme (light or dark) is showing right now.

### 5. Wiring
- `lib/core/constants/app_routes.dart` - add
  `appColor = '/settings/appearance/app-color'`.
- `lib/app.dart` - add the route, and pass
  `base: appearance.baseFor(...)` into `AppTheme.light()` / `AppTheme.dark()`.
- `lib/presentation/screens/settings/appearance_screen.dart` - add the
  "App Colour" tile below "Accent Colour".

### 6. Strings (both languages)
- `lib/l10n/app_en.arb`, `lib/l10n/app_ml.arb` - add
  `appearanceAppColor`, `appearanceAppColorSubtitle`, `appColorLivePreview`,
  `appColorPresets`, `appColorAppliesToLight`, `appColorAppliesToDark`,
  `appColorSampleText`, `appColorReset`.
- Regenerate `app_localizations*.dart` with `flutter gen-l10n`.

### 7. Tests
`test/` - add:
- `AppearanceNotifier` saves, reloads and clears the base colour per brightness.
- `AppTheme.light(base: ...)` / `dark(base: ...)` return the picked background,
  a surface that differs from the background, and an `onSurface` that meets a
  minimum contrast against the background.

### 8. Docs
- `docs/features.md` - describe the new Appearance option.
- `change_log/` - write the change log after implementation.

## Files to be changed

| File | Change |
|------|--------|
| `lib/application/appearance_notifier.dart` | new base-colour state, keys, setters |
| `lib/presentation/shared/theme/app_theme.dart` | `base` parameter, derived background/surface/outline/text |
| `lib/presentation/screens/settings/app_color_screen.dart` | new picker screen |
| `lib/presentation/screens/settings/appearance_screen.dart` | new "App Colour" tile |
| `lib/core/constants/app_routes.dart` | new route path |
| `lib/app.dart` | new route + pass `base` into the themes |
| `lib/l10n/app_en.arb`, `lib/l10n/app_ml.arb` | new strings |
| `lib/l10n/app_localizations*.dart` | regenerated |
| `test/application/appearance_notifier_test.dart` | new/updated tests |
| `test/presentation/app_theme_test.dart` | new/updated tests |
| `docs/features.md` | document the option |

## Checks before done

- `flutter analyze` - 0 issues.
- `flutter test` - all pass.
- `dart format lib/ test/`.
- Manual check in light and dark mode: text stays readable, cards stay visible
  against the background, Reset returns the old look.

## Risks

- A very saturated pick can look loud. The lightness clamp and the live preview
  keep it usable, and Reset always restores the default.
- No database or migration change. No new package. Fully offline.
