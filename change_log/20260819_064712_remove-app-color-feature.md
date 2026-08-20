# Removed the "App Color" feature

Implements plan `plans/20260819_063425_remove-app-color-feature.md`.

## Why

The App Color screen (Settings → Appearance → App Color) let the user pick a
base colour for the page background and cards. The feature is not needed, so it
was removed completely.

The app now always uses the built-in default backgrounds. This is exactly what
a user saw when they never touched App Color. The **Accent Color** feature is
untouched.

## What changed

### Presentation

- Deleted `lib/presentation/screens/settings/app_color_screen.dart`.
- `lib/presentation/screens/settings/appearance_screen.dart` — removed the
  "App Color" nav card. The Appearance hub now shows three cards: Theme Mode,
  Typography, Accent Color.

### Routing

- `lib/core/constants/app_routes.dart` — removed the `appColor` route constant.
- `lib/app.dart` — removed the `AppColorScreen` import and its `GoRoute`, and
  removed the `base:` argument from the `AppTheme.light()` / `AppTheme.dark()`
  calls.

### Application state

- `lib/application/appearance_notifier.dart` — removed the
  `kBaseLightPreferenceKey` / `kBaseDarkPreferenceKey` constants, the
  `lightBase` / `darkBase` fields, `baseFor()`, the `clearLightBase` /
  `clearDarkBase` flags in `copyWith`, and `setBaseFor()` / `resetBaseFor()`.
  Old saved values may still sit in SharedPreferences; they are now ignored, so
  no migration was needed.

### Theme

- `lib/presentation/shared/theme/app_theme.dart` — dropped the `base` parameter
  from `light()`, `dark()` and `_buildTheme()`. Removed `defaultLightBase`,
  `defaultDarkBase`, `presetLightBases`, `presetDarkBases`, `defaultBaseFor()`,
  `presetBasesFor()` and `normalizeBase()`. Every `usesCustomBase ? A : B`
  branch was collapsed to the default side, so `raisedColor` is gone and each
  `raisedColor ?? X` became `X`. The unused `panel()` local helper and the
  `_tone()` helper were removed. `_withLightness()` and `contrastOn()` stay —
  the accent colour still uses them.

### Strings (l10n)

- Removed 16 keys from `lib/l10n/app_en.arb` and `lib/l10n/app_ml.arb`:
  `appearanceAppColor`, `appearanceAppColorSubtitle`, `appColorLivePreview`,
  `appColorPresets`, `appColorCustom`, `appColorHue`, `appColorTint`,
  `appColorShade`, `appColorSampleTitle`, `appColorSampleBody`,
  `appColorSampleButton`, `appColorAppliesToLight`, `appColorAppliesToDark`,
  `appColorResetLight`, `appColorResetDark`, `appColorNote`.
- Regenerated `lib/l10n/app_localizations*.dart` with `flutter gen-l10n`.

### Tests

- `test/presentation/app_theme_test.dart` — the whole file was about the base
  colour. It was rewritten as a smaller theme test that checks the default
  backgrounds, card/background separation, text contrast, and the accent
  override.
- `test/application/appearance_notifier_test.dart` — removed the base-colour
  expectations and the `setBaseFor` / `resetBaseFor` tests.
- `test/presentation/settings_screen_test.dart` — the Appearance hub now
  expects three nav cards, and the App Color title check was removed.

### Docs

- `docs/features.md` — removed the **App Color** row and dropped "App Color"
  from the Appearance hub description.

## Checks

- `dart format lib/ test/` — done.
- `flutter analyze` — no issues left from this change. Seven errors remain in
  `lib/presentation/screens/settings/security/app_lock_screen.dart` and
  `lib/presentation/screens/settings/security_screen.dart` about an undefined
  `securitySettingsProvider` / `appLockProvider`. These are pre-existing, come
  from separate in-progress work, and were not touched here.
- `flutter test` — 463 tests, all pass.
