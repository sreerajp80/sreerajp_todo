# Plan: Fix Bottom Navigation Bar Label Clipping

**Status:** Planned

## Goal
Fix the bottom navigation bar so the leftmost destination label (e.g., "എന്റെ ടാസ്കുകൾ" in Malayalam) is fully visible and not clipped by the rounded corner curve of the floating bottom bar pill.

## Issue
In `lib/presentation/shared/widgets/responsive_scaffold.dart`, the `NavigationBar` is wrapped in `ClipRRect(borderRadius: BorderRadius.circular(28))`. Because the `NavigationBar` spans from `x = 0` to full width without internal horizontal edge padding, the leftmost destination (index 0) starts flush at `x = 0`.
When the destination label text (such as "എന്റെ ടാസ്കുകൾ" in Malayalam) extends towards the left edge, the 28px outer rounded corner of `ClipRRect` clips off the left side of the text (causing "എന്റെ" to appear truncated as "ന്റെ").

## Proposed Changes

### 1. Responsive Scaffold (`lib/presentation/shared/widgets/responsive_scaffold.dart`)
- Wrap the floating bottom navigation bar in a `DecoratedBox` with `BorderRadius.circular(28)` using the theme's navigation bar surface background color.
- Add internal horizontal padding (`EdgeInsets.symmetric(horizontal: 12)`) inside the rounded pill box before rendering `NavigationBar`.
- Set `backgroundColor: Colors.transparent` and `elevation: 0` on the `NavigationBar` so that destination 0 is inset 12px away from the curved corners of the pill box, preventing text clipping.

### 2. App Theme (`lib/presentation/shared/theme/app_theme.dart`)
- Update `navigationBarTheme.labelTextStyle` in `appTheme`:
  - Set `fontSize: 11` (or 11.5) with `fontWeight: FontWeight.w600`.
  - Add `overflow: TextOverflow.ellipsis` and clean text height to ensure multilingual labels (Malayalam, English) fit neatly without awkward wrapping or line spilling.

## Verification Plan
- Run `flutter analyze` to ensure zero static analysis warnings/errors.
- Run `flutter test` to ensure all existing widget tests pass.
- Verify visually that destination labels (including Malayalam "എന്റെ ടാസ്കുകൾ") have clean horizontal clearance from the curved pill edges and are 100% visible.
