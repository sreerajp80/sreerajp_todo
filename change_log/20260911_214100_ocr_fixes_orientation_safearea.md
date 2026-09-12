# Change Log: Fix OCR Orientation, Text Reading Order, Safe Area, Image Rotation, and Navigate to Creation Screen

**Date:** 2026-09-11 21:41:00  
**Plan:** `plans/20260911_212800_ocr_fixes_orientation_safearea.md`

## Problem Solved
Real-world camera testing on physical Android devices revealed several critical OCR UX issues:
1. **Inverted Reading Order:** ML Kit returned text blocks in recognition order instead of top-to-bottom layout, causing the bottom sentence to be parsed as the Title and the top header "Battery Soul" as the Description.
2. **Action Buttons Obscured:** On Android devices with 3-button navigation, the review bottom sheet's primary button was partially hidden under the system navigation bar (`< O |||`).
3. **No Photo Rotation:** Photos taken in landscape or tilted on desks needed rotation to be read properly by OCR.
4. **No Direct Navigation to Creation Screen:** Tasks were either silently inserted into the database or required manual navigation, rather than showing the full task creation form with pre-filled title and description.
5. **No Field Swap Option:** When text was swapped or needed adjustment, users had to re-type the fields manually.

## Changes Made
1. **Geometric Text Sorter (`lib/presentation/screens/ocr/utils/ocr_text_sorter.dart`):**
   - Created `OcrTextSorter` which sorts ML Kit `RecognizedText` lines geometrically (top-to-bottom, left-to-right).
   - Preserves vertical line gaps as empty lines (`\n\n`), triggering `OcrTaskParser`'s paragraph separator detection so top titles and lower descriptions are correctly separated.

2. **90° Image Rotation in Cropper (`lib/presentation/screens/ocr/ocr_crop_screen.dart`):**
   - Added a 90° clockwise rotation button (`Icons.rotate_90_degrees_cw_outlined`) to the top AppBar.
   - Rotates the image in-memory using `ui.PictureRecorder` and `Canvas.rotate(math.pi / 2)` and resets the crop rectangle.
   - When confirmed or when "Use Full Image" is tapped, saves the rotated image to a temporary PNG file so ML Kit runs OCR on the correctly oriented image.

3. **Safe Area & Review Sheet Redesign (`lib/presentation/screens/ocr/widgets/ocr_result_bottom_sheet.dart`):**
   - Added `useSafeArea: true` to `showModalBottomSheet`.
   - Included `MediaQuery.paddingOf(context).bottom` in the bottom padding calculation so action buttons stay comfortably above system navigation bars (3-button navigation and gesture pills).
   - Added a compact "Swap Title and Description" button (⇅) between the Task Name and Description fields.
   - Streamlined the action buttons into a single horizontal row: `[ Retake ]` and `[ Continue to Task Details ➔ ]` (or `[ Apply to Task ✓ ]`).

4. **Navigate to Creation Screen (`lib/presentation/screens/ocr/ocr_scan_screen.dart`):**
   - Updated `_navigateToFullEditor` to pop the scanner screen and navigate to `CreateEditTodoScreen` via route query parameters (`AppRoutes.createTodoPath(date: ..., title: ..., description: ...)`).
   - Removed silent background saving so the user is always taken directly to the task creation screen to inspect details, choose priority, set target time, and save.

5. **Localization (`lib/l10n/app_en.arb`, `lib/l10n/app_ml.arb`):**
   - Added `ocrRotateImage`, `ocrSwapFields`, and `ocrContinueToCreate` keys in English and Malayalam.

6. **Automated Tests:**
   - Added unit tests in `test/presentation/screens/ocr/ocr_text_sorter_test.dart` for geometric sorting, column alignment, and gap detection.
   - Updated widget tests in `test/presentation/ocr/ocr_result_bottom_sheet_test.dart` to verify swapping, navigation, and validation.

## Verification
- `flutter analyze` completed with 0 issues.
- `flutter test test/presentation/screens/ocr/ocr_text_sorter_test.dart` passed (4/4).
- `flutter test test/presentation/ocr/ocr_result_bottom_sheet_test.dart` passed (5/5).
- Full test suite passed (702/702 tests passed).
- All code formatted with `dart format`.
