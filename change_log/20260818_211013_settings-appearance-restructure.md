# Change log: Settings restructure with an Appearance hub

Implements plan `plans/20260818_205832_settings-appearance-restructure.md`.

## What changed for the user

The Settings screen is now a list of tappable cards, one per section:

1. **Appearance** - opens a hub page with three cards:
   - **Theme mode** - System / Light / Dark. The choice is now **saved**, so it
     no longer resets to System when the app restarts.
   - **Typography & Text Size** - pick the app font (System default, Manjari,
     Anek Malayalam, Noto Sans Malayalam) with a live English and Malayalam
     preview, and pick the text size (Small, Default, Large, Larger).
   - **Accent Color** - live preview, eight preset colours, a colour wheel with a
     brightness slider, and a reset button. Light mode and dark mode keep their
     own accent colour.
2. **Language** - opens a page to pick System default, English or Malayalam.
3. **Backup** - own card.
4. **About this app** - own card.
5. **Permissions** - own card.
6. The "Offline and private" note stays at the bottom.

Nothing changes visually until the user picks something: the default accent,
font and text size keep the current look.

## New files

- `lib/application/appearance_notifier.dart` - `AppFont` and `AppTextScale`
  enums, `AppearanceState`, and `AppearanceNotifier`. Every change is saved to
  `SharedPreferences` under the keys `appearance_theme_mode`,
  `appearance_font`, `appearance_text_scale`, `appearance_accent_light` and
  `appearance_accent_dark`.
- `lib/presentation/screens/settings/appearance_screen.dart`
- `lib/presentation/screens/settings/theme_mode_screen.dart`
- `lib/presentation/screens/settings/typography_screen.dart`
- `lib/presentation/screens/settings/accent_color_screen.dart`
- `lib/presentation/screens/settings/language_screen.dart`
- `lib/presentation/screens/settings/widgets/settings_nav_card.dart` - one
  tappable settings card (icon tile, title, subtitle, chevron).
- `test/application/appearance_notifier_test.dart`
- `test/presentation/settings_screen_test.dart`
- `assets/fonts/` - Manjari, Anek Malayalam and Noto Sans Malayalam
  (Regular + Bold) plus their OFL licence files. These are local font files
  only. No package and no network access was added.

## Changed files

- `pubspec.yaml` - declares the three font families.
- `lib/application/providers.dart` - added `appearanceProvider`.
  `themeModeProvider` is now a read-only view of the saved theme mode instead of
  a `StateProvider` that reset on every start.
- `lib/presentation/shared/theme/app_theme.dart` - `AppTheme.light` and
  `AppTheme.dark` are now methods that take an optional `accent` and
  `fontFamily`. Added `defaultLightAccent`, `defaultDarkAccent`,
  `presetAccents` and `contrastOn()`. With no accent given, the palette is
  byte-for-byte the same as before.
- `lib/app.dart` - watches `appearanceProvider`, passes the accent and font into
  both themes, registers the five new routes, and applies the chosen text size
  through a `MediaQuery` text scaler (combined with the device text scale and
  clamped to 0.8x - 1.8x).
- `lib/core/constants/app_routes.dart` - added `/settings/appearance`,
  `/settings/appearance/theme-mode`, `/settings/appearance/typography`,
  `/settings/appearance/accent-color` and `/settings/language`.
- `lib/presentation/screens/settings/settings_screen.dart` - rewritten as the
  six-card list described above.
- `lib/l10n/app_en.arb` and `lib/l10n/app_ml.arb` - 32 new strings (card titles,
  subtitles, font names, text size labels, accent colour labels and help texts),
  with the generated localisation files regenerated. No hard-coded user text in
  the new screens.
- `test/presentation/statistics_screen_test.dart` and
  `test/presentation/statistics/widgets/per_item_line_chart_test.dart` - updated
  for `AppTheme.light` -> `AppTheme.light()`.

## Removed

- `lib/presentation/screens/settings/widgets/settings_link_tile.dart` - the old
  "Shortcuts" row widget. Nothing used it after the rewrite.

## Checks run

- `flutter analyze` - 0 issues.
- `flutter test` - 293 tests, all pass (8 new appearance tests, 3 new settings
  screen tests).
- `flutter build bundle` - succeeds, and `FontManifest.json` lists all three
  bundled font families.
