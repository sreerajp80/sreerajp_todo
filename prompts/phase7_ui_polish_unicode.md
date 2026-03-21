# Phase 7 — UI Polish & Unicode Support

## Objective
Ensure the app is visually cohesive across light/dark themes, handles all Unicode scenarios correctly, has responsive layouts for mobile and desktop, meets accessibility standards, and has proper app branding (icon + splash screen).

## Pre-Requisites
- Phases 1–6 complete (all features functional).
- Read `CLAUDE.md` — Unicode rules, asset rules, measurement rules.
- Read `docs/security.md` — logging policy (§8 — never log task titles, descriptions, timestamps, file paths), platform security controls (§9).
- Read `docs/architecture.md` — UI system (§12), accessibility expectations.
- Read `docs/flutter_project_engineering_standard.md` — UI/UX baseline (§6 — theme, accessibility, screen states), coding standards (§8 — lint rules, formatting), Definition of Done (§14).

---

## Tasks

### 1. Unicode Audit

Test ALL text input fields with the following scripts:

| Script | Test String | Specific Checks |
|--------|------------|-----------------|
| ASCII | "Buy groceries" | Baseline |
| Extended Latin | "Ärzte Überweisungen café résumé" | Diacritics preserved |
| CJK (Chinese) | "购买杂货" | Full-width characters render |
| CJK (Japanese) | "日本語テスト" | Kanji + Katakana |
| CJK (Korean) | "한국어 테스트" | Hangul |
| Arabic | "العربية مهمة" | RTL text direction |
| Hebrew | "עברית משימה" | RTL text direction |
| Devanagari | "हिन्दी कार्य" | Complex script shaping |
| Emoji | "🎉✅🔥📝" | Emoji render correctly |
| Mixed LTR+RTL | "Task: المهمة" | BiDi handled |
| Zero-width | "test\u200Btest" | Zero-width space preserved |
| Composed/Decomposed | "é" (U+00E9) vs "é" (U+0065 U+0301) | NFC normalisation makes them equal |

#### Verification points:
- [ ] Text fields display all scripts correctly.
- [ ] `textDirection` auto-detected by `detectTextDirection()` — Arabic/Hebrew fields become RTL.
- [ ] NFC normalisation: `nfcNormalize("é")` (composed) == `nfcNormalize("é")` (decomposed).
- [ ] Hangul Jamo composition works.
- [ ] Title uniqueness treats composed/decomposed as same.
- [ ] Search finds results regardless of composed/decomposed input.
- [ ] Data survives round-trip: write → read → display unchanged.
- [ ] `Directionality` widget wraps screens that may contain RTL text.
- [ ] Never hardcode `TextDirection.ltr` on text input fields.

### 2. Responsive Layout

#### Mobile (< 600 dp):
- Single-column layout.
- Bottom navigation bar with tabs: Daily List, Statistics, Recurring, Backup.
- Full-width cards and list tiles.
- Charts scale to screen width.

#### Desktop/Tablet (≥ 600 dp):
- Navigation rail on the left side.
- Wider content area.
- Two-column layout on statistics screen (chart + table side by side).
- Larger tap targets not needed (mouse input).
- Min window size enforced if possible.

#### Implementation:
- Use `LayoutBuilder` or `MediaQuery` to detect width.
- Create a responsive scaffold wrapper:
  ```dart
  class ResponsiveScaffold extends StatelessWidget {
    // Mobile: Scaffold with bottomNavigationBar
    // Desktop: Scaffold with NavigationRail on left
  }
  ```

### 3. Light / Dark Theme Polish

In `lib/presentation/shared/theme/app_theme.dart`:

#### Status colours (both themes):
| Status | Light Theme | Dark Theme | Contrast ≥ 4.5:1 |
|--------|------------|------------|-------------------|
| Pending | Grey 600 | Grey 400 | ✓ |
| Completed | Green 700 | Green 400 | ✓ |
| Dropped | Red 700 | Red 400 | ✓ |
| Ported | Amber 700 | Amber 400 | ✓ |

#### Theme elements to audit:
- [ ] AppBar colour/elevation consistent.
- [ ] Card colours in both themes.
- [ ] Text contrast ratios ≥ 4.5:1.
- [ ] Input field borders and fill colours.
- [ ] SnackBar colours.
- [ ] Dialog colours.
- [ ] Chart colours visible in both themes.
- [ ] Status badges readable in both themes.
- [ ] Disabled/locked state visually distinct.
- [ ] FAB colour appropriate.
- [ ] Navigation rail/bottom nav consistent.

#### Theme switching:
- Follow system theme by default.
- Optional: add a theme toggle in settings (overflow menu or dedicated settings route).

### 4. Accessibility

- [ ] All interactive elements have `Semantics` labels.
- [ ] Minimum tap target size: **48 × 48 dp** on mobile.
- [ ] Screen reader support: meaningful labels for status badges, timer buttons, chart data points.
- [ ] Focus traversal works logically with keyboard (desktop).
- [ ] Sufficient colour contrast (WCAG AA: 4.5:1 for normal text, 3:1 for large text).
- [ ] Don't rely on colour alone to convey information (add text/icon alongside colour).

### 5. Error States and Empty States

#### Empty states:
- **No todos today**: friendly illustration or icon + "Add your first task" CTA button.
- **No search results**: "No tasks found matching '[query]'".
- **No statistics data**: "Start tracking tasks to see your statistics".
- **No backups**: "No backups found. Export your first backup to keep your data safe."
- **No recurrence rules**: "No recurring tasks. Create one to automate task creation."

#### Error states:
- **Database error**: error SnackBar with "Something went wrong. Tap to retry." + retry action.
- **Backup import error**: specific error message based on exception type.
- **Validation errors**: inline field errors (red text below the field).

All empty/error state strings in `app_strings.dart`.

### 6. Performance Audit

- [ ] `ListView.builder` used everywhere (daily list, search results, backup list, stats tables).
- [ ] No unnecessary rebuilds — use `const` constructors where possible.
- [ ] `StreamProvider` used only for live timer — nothing else.
- [ ] Charts don't cause jank on low-end devices.
- [ ] Statistics pagination loads incrementally.
- [ ] Autocomplete response < 100 ms per keystroke.

### 7. App Icon

#### Android:
- Adaptive icon (`mipmap-anydpi-v26`) with foreground and background layers.
- Place icon files in:
  - `android/app/src/main/res/mipmap-hdpi/`
  - `android/app/src/main/res/mipmap-mdpi/`
  - `android/app/src/main/res/mipmap-xhdpi/`
  - `android/app/src/main/res/mipmap-xxhdpi/`
  - `android/app/src/main/res/mipmap-xxxhdpi/`
  - `android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml`
- Design: simple, recognisable journal/vault icon. Use the app's primary colour.

#### Windows:
- `.ico` file in `windows/runner/resources/app_icon.ico`.
- Multiple sizes in the ICO: 16, 32, 48, 256.

### 8. Splash Screen

Using `flutter_native_splash` (if it passed dep audit):
```yaml
# pubspec.yaml
flutter_native_splash:
  color: "#1976D2"  # or your primary colour
  image: assets/splash/splash_logo.png
  android: true
  ios: false  # deferred
  web: false
```

Run:
```powershell
dart run flutter_native_splash:create
```

If `flutter_native_splash` failed the dep audit:
- Android: configure manually in `android/app/src/main/res/drawable/launch_background.xml`.
- Windows: configure in `windows/runner/main.cpp` (background colour).

Splash assets must be **bundled** in `assets/splash/` — no network loading.

### 9. Animation and Transitions

Subtle polish:
- Status change animation (colour transition on badge).
- List tile slide-in animation on load.
- Page transition animations via `go_router` `CustomTransitionPage`.
- Timer pulse animation on running segment indicator.
- Keep animations lightweight — no heavy Lottie or Rive.

### 10. Final String Audit

Scan all widget files for hardcoded strings. Every user-visible string must be in `app_strings.dart`:
```powershell
# Find potential hardcoded strings in presentation layer
Select-String -Path "lib\presentation\**\*.dart" -Pattern "'[A-Z][a-z]" -Recurse
```
Move any found strings to `app_strings.dart`.

---

## Tests

### Unicode Tests — `test/core/unicode_utils_test.dart` (extend)
- NFC: composed `é` (U+00E9) == decomposed (U+0065 U+0301)
- NFC: Hangul Jamo sequence → precomposed syllable
- NFC: already-NFC string passes through unchanged
- `detectTextDirection`: Arabic → RTL, English → LTR, mixed → LTR (default)
- Empty string handling

### Widget Tests
- StatisticsScreen renders in both light and dark themes without exceptions.
- Empty state widgets render correctly.
- Responsive layout: mobile width renders bottom nav, desktop width renders nav rail.

---

## Constraints
- All fonts **bundled** — no Google Fonts, no network font loading.
- `AssetImage`, `Image.asset()`, `Image.file()` only — never `Image.network()`.
- All strings in `app_strings.dart`.
- No imperial measurements in code, comments, or documentation.
- Metric units only (dp for sizing).
- Contrast ratio ≥ 4.5:1 for all text.

## Deliverables
- [ ] All Unicode test cases pass (all scripts listed above)
- [ ] NFC normalisation unit tests pass
- [ ] App visually consistent across light and dark themes
- [ ] Responsive layout: mobile (bottom nav) and desktop (nav rail)
- [ ] All empty states and error states implemented
- [ ] Accessibility: Semantics labels, 48dp tap targets, contrast ratios
- [ ] App icon configured for Android and Windows
- [ ] Splash screen configured
- [ ] No layout overflow errors on 5-inch phone or 27-inch desktop
- [ ] No hardcoded strings in widget files
- [ ] Performance: no jank, lazy loading everywhere
