# Settings restructure: Appearance hub, Language page, separate cards

**Status:** completed

## Goal

Rebuild the Settings screen of SreerajP ToDo so it matches the layout used in the
SreerajP ContactSphere app.

New Settings screen layout (one tappable card per row):

1. **Appearance** card -> opens an Appearance page that holds three tappable cards:
   - **Theme Mode** -> Theme Mode page (System / Light / Dark)
   - **Typography & Text Size** -> Typography page (font family + text size)
   - **Accent Color** -> Accent Color page (presets + colour wheel + reset)
2. **Language** card -> opens a Language page that lists the languages to pick
   (System default, English, Malayalam)
3. **Backup** card (own card) -> existing Backup screen
4. **About** card (own card) -> existing About screen
5. **Permissions** card (own card) -> existing Permissions screen
6. The existing "Offline and private" information card stays at the bottom.

## What is missing today

- Settings puts theme mode and language inline as segmented buttons, and groups
  Backup / Permissions / About inside one "Shortcuts" card.
- The app has **no** font-family setting, **no** text-size setting and **no**
  accent-colour setting at all. These have to be built from scratch.
- Theme mode is **not saved**. `themeModeProvider` is a plain `StateProvider`
  that resets to `ThemeMode.system` on every app start.
- `assets/fonts/` is empty, so no alternate font is bundled.

## Plan

### 1. Bundle fonts (local copy, no network)

Copy the three open-licence (OFL) font families already used by the
ContactSphere project into `assets/fonts/`, together with their OFL licence
files: Manjari, Anek Malayalam, Noto Sans Malayalam (Regular + Bold each).
Declare them under `flutter: fonts:` in `pubspec.yaml`.
These are plain local files. No package and no network access is added, so the
offline rule is not broken.

### 2. New appearance state (saved with SharedPreferences)

Add `lib/application/appearance_notifier.dart`:

- `enum AppFont { system, manjari, anekMalayalam, notoSansMalayalam }` with
  label key + pubspec family name.
- `enum AppTextScale { small, normal, large, larger }` = 0.85 / 1.0 / 1.15 / 1.30.
- `AppearanceState` (immutable class with `copyWith`): `themeMode`, `font`,
  `textScale`, `lightAccent` (nullable), `darkAccent` (nullable).
- `AppearanceNotifier extends StateNotifier<AppearanceState>`: loads from
  `SharedPreferences` in the constructor and saves on every setter
  (`setThemeMode`, `setFont`, `setTextScale`, `setAccentFor(brightness, color)`,
  `resetAccentFor(brightness)`).
- Preference keys: `appearance_theme_mode`, `appearance_font`,
  `appearance_text_scale`, `appearance_accent_light`, `appearance_accent_dark`.

This mirrors `lib/application/locale_notifier.dart`, which already lives in the
application layer and already reads `SharedPreferences`.

### 3. Providers

In `lib/application/providers.dart`:

- Add `appearanceProvider = StateNotifierProvider<AppearanceNotifier, AppearanceState>`
  built from `sharedPreferencesProvider`.
- Replace the old `themeModeProvider` `StateProvider` with a small derived
  provider (`ref.watch(appearanceProvider).themeMode`) so nothing else breaks,
  and update the two places that write to it.

### 4. Theme takes accent + font

In `lib/presentation/shared/theme/app_theme.dart`:

- Change `static final light` / `static final dark` into
  `static ThemeData light({Color? accent, String? fontFamily})` and
  `static ThemeData dark({Color? accent, String? fontFamily})`.
- `_buildTheme` accepts the optional accent (used for `primary`,
  `primaryContainer`, `onPrimary` via a readable-contrast helper) and the font
  family (passed to `ThemeData.fontFamily`). When accent is null the current
  blue palette is kept exactly as it is today, so the default look does not change.
- Add `static const defaultLightAccent` / `defaultDarkAccent`,
  `static const presetAccents` (8 colours) and `static Color contrastOn(Color)`.

In `lib/app.dart`:

- Watch `appearanceProvider`, pass accent + font into the two themes.
- Add a `builder:` to `MaterialApp.router` that wraps the child in a
  `MediaQuery` with the chosen text scale multiplied on top of the system
  scale, so the text size choice applies app-wide.

### 5. New screens

- `lib/presentation/screens/settings/appearance_screen.dart` - hub page with the
  three cards.
- `lib/presentation/screens/settings/theme_mode_screen.dart` - System / Light /
  Dark choice plus a short explanation.
- `lib/presentation/screens/settings/typography_screen.dart` - font list with a
  live English + Malayalam preview per font, and a text-size segmented control.
- `lib/presentation/screens/settings/accent_color_screen.dart` - live preview,
  8 preset swatches, an HSV colour wheel with a brightness slider, and a
  "reset to default" button. The accent is stored separately for light and dark
  mode, matching ContactSphere.
- `lib/presentation/screens/settings/language_screen.dart` - radio list of
  System default / English / Malayalam.

All new screens use the existing `AppSectionCard` / `SettingsLinkTile` widgets
so they look like the rest of this app (not a copy of ContactSphere styling).

### 6. Rewrite the Settings screen

`lib/presentation/screens/settings/settings_screen.dart` becomes a list of
tappable cards: Appearance, Language, Backup, About, Permissions, then the
offline information card. A new small widget
`lib/presentation/screens/settings/widgets/settings_nav_card.dart` renders one
tappable card (icon tile, title, subtitle, chevron).

### 7. Routes

Add to `lib/core/constants/app_routes.dart` and register in `lib/app.dart`
(all as `go_router` routes, nested under `/settings`):

- `/settings/appearance`
- `/settings/appearance/theme-mode`
- `/settings/appearance/typography`
- `/settings/appearance/accent-color`
- `/settings/language`

### 8. Strings

Add new keys to `lib/l10n/app_en.arb` and `lib/l10n/app_ml.arb`
(titles, subtitles, font names, text-size labels, accent-colour labels,
reset button, helper texts), then regenerate the localisation files with
`flutter gen-l10n`. No user-visible literal strings in the new widgets.

### 9. Tests

- `test/application/appearance_notifier_test.dart` - defaults, save + reload of
  theme mode, font, text scale and per-mode accent, and accent reset.
- `test/presentation/settings_screen_test.dart` - the six cards are shown and
  tapping Appearance opens the Appearance page with its three cards.
- Update `test/presentation/statistics/widgets/per_item_line_chart_test.dart`
  and `test/presentation/statistics_screen_test.dart` for the
  `AppTheme.light` -> `AppTheme.light()` change.

### 10. Checks

Run `dart format`, `flutter analyze` (must be 0 issues) and `flutter test`.

## Files to change

**New**
- `lib/application/appearance_notifier.dart`
- `lib/presentation/screens/settings/appearance_screen.dart`
- `lib/presentation/screens/settings/theme_mode_screen.dart`
- `lib/presentation/screens/settings/typography_screen.dart`
- `lib/presentation/screens/settings/accent_color_screen.dart`
- `lib/presentation/screens/settings/language_screen.dart`
- `lib/presentation/screens/settings/widgets/settings_nav_card.dart`
- `test/application/appearance_notifier_test.dart`
- `test/presentation/settings_screen_test.dart`
- `assets/fonts/*.ttf` + `assets/fonts/OFL-*.txt` (copied local files)

**Changed**
- `pubspec.yaml` (font declarations)
- `lib/app.dart` (routes, theme wiring, text scaler)
- `lib/application/providers.dart` (appearance provider)
- `lib/core/constants/app_routes.dart` (new routes)
- `lib/presentation/shared/theme/app_theme.dart` (accent + font + presets)
- `lib/presentation/screens/settings/settings_screen.dart` (rewrite)
- `lib/l10n/app_en.arb`, `lib/l10n/app_ml.arb` (+ regenerated files)
- `test/presentation/statistics/widgets/per_item_line_chart_test.dart`
- `test/presentation/statistics_screen_test.dart`

**Docs (after implementation)**
- `change_log/20260818_<time>_settings-appearance-restructure.md`

## Points to confirm

1. Bundling the three Malayalam/Latin fonts from the ContactSphere project is OK
   (they are OFL licensed, so redistribution is allowed with the licence file).
2. Accent colour is stored **per theme mode** (a separate colour for light and
   dark), same as ContactSphere. Say if you want one shared colour instead.
3. Default look stays exactly as it is now unless the user changes something.
