# Remove the "App Color" feature

**Status:** completed

## The issue

Settings → Appearance has an entry called **App Color** ("ആപ്പിന്റെ നിറം" —
"പേജിന്റെ പശ്ചാത്തലവും കാർഡിന്റെ നിറവും"). It lets the user pick a base colour
from which the page background, card colour, outline colour and text colour are
derived, stored separately for light and dark mode.

This feature is not needed. It should be removed completely: the settings entry,
the screen, the route, the saved preference, the theme plumbing, the strings,
the tests and the docs.

The **Accent Color** feature is a different feature and stays untouched.

## The plan

Remove the feature end to end. After the change the app always uses the built-in
default backgrounds (`_lightBackground` / `_darkBackground`), which are exactly
what a user sees today when they never touched App Color.

### 1. Presentation

- Delete `lib/presentation/screens/settings/app_color_screen.dart`.
- `lib/presentation/screens/settings/appearance_screen.dart` — remove the
  "App Color" `SettingsNavCard` and the `SizedBox` above it.

### 2. Routing

- `lib/core/constants/app_routes.dart` — remove `appColor`.
- `lib/app.dart` — remove the `AppColorScreen` import and its `GoRoute`;
  remove `base:` from the `AppTheme.light(...)` / `AppTheme.dark(...)` calls.

### 3. Application state

- `lib/application/appearance_notifier.dart`:
  - remove the `kBaseLightPreferenceKey` / `kBaseDarkPreferenceKey` constants,
  - remove the `lightBase` / `darkBase` fields, the `baseFor()` helper, and the
    `clearLightBase` / `clearDarkBase` flags in `copyWith`,
  - remove `setBaseFor()` and `resetBaseFor()`,
  - stop reading the two keys in `_loadInitialState`.
  - Note: old saved values stay in SharedPreferences but are simply ignored.
    No migration is needed, and the app looks the same as the default.

### 4. Theme

- `lib/presentation/shared/theme/app_theme.dart`:
  - drop the `base` parameter from `light()`, `dark()` and `_buildTheme()`,
  - remove `defaultLightBase`, `defaultDarkBase`, `presetLightBases`,
    `presetDarkBases`, `defaultBaseFor()`, `presetBasesFor()`, `normalizeBase()`,
  - collapse every `usesCustomBase ? A : B` branch to `B` (the default side),
    which makes `raisedColor` always `null`, so `raisedColor ?? X` becomes `X`,
  - remove the now-unused `panel()` local helper and the `_tone()` helper
    (`_withLightness` stays — the accent colour still uses it),
  - keep `contrastOn()` (used by the accent code).

### 5. Strings (l10n)

Remove these keys from `lib/l10n/app_en.arb` and `lib/l10n/app_ml.arb`
(and regenerate `lib/l10n/app_localizations*.dart` with `flutter gen-l10n`):
`appearanceAppColor`, `appearanceAppColorSubtitle`, `appColorLivePreview`,
`appColorPresets`, `appColorCustom`, `appColorHue`, `appColorTint`,
`appColorShade`, `appColorSampleTitle`, `appColorSampleBody`,
`appColorSampleButton`, `appColorAppliesToLight`, `appColorAppliesToDark`,
`appColorResetLight`, `appColorResetDark`, `appColorNote`.

### 6. Tests

- `test/presentation/app_theme_test.dart` — remove the
  `AppTheme app colour (base)` group.
- `test/application/appearance_notifier_test.dart` — remove the base-colour
  expectations and the `setBaseFor` / `resetBaseFor` tests.

### 7. Docs

- `docs/features.md` — delete the **App Color** row and drop "App Color" from
  the Appearance hub description.

## Files to change

| File | Change |
|------|--------|
| `lib/presentation/screens/settings/app_color_screen.dart` | delete |
| `lib/presentation/screens/settings/appearance_screen.dart` | remove nav card |
| `lib/core/constants/app_routes.dart` | remove route constant |
| `lib/app.dart` | remove import, route, `base:` args |
| `lib/application/appearance_notifier.dart` | remove base state + prefs keys |
| `lib/presentation/shared/theme/app_theme.dart` | remove base plumbing |
| `lib/l10n/app_en.arb` | remove keys |
| `lib/l10n/app_ml.arb` | remove keys |
| `lib/l10n/app_localizations.dart` (+ `_en`, `_ml`) | regenerated |
| `test/presentation/app_theme_test.dart` | remove base tests |
| `test/application/appearance_notifier_test.dart` | remove base tests |
| `docs/features.md` | remove feature row |

## Checks after the change

- `flutter analyze` → 0 issues
- `flutter test` → all pass
- `dart format lib/ test/`

## Risk

Only the app background / card / outline colours are touched, and only to force
the built-in defaults. Accent colour, theme mode, font and text size are not
affected.
