# Plan: Fix OCR Orientation, Text Reading Order, Safe Area, Image Rotation, and Navigate to Creation Screen

**Status:** Complete

## Overview
This plan addresses all issues and requirements from real-world OCR camera testing:
1. **Navigate to Task Creation Screen (No Silent Save):** Instead of silently saving the task directly from the OCR bottom sheet, confirming the scanned task will navigate to the full Create/Edit Task screen (`CreateEditTodoScreen`) with the scanned title and description prefilled via `AppRoutes.createTodoPath(date: _effectiveDate, title: title, description: description)`. This lets the user see the task immediately, edit details, set priority or target time, and save normally.
2. **Natural Text Reading Order:** Text blocks detected by Google ML Kit were returned out of visual order (for example, the bottom sentence was recognized as the title, and the top text "Battery Soul" as description). We will sort lines and blocks by visual geometric coordinates (top-to-bottom, left-to-right) and detect vertical gaps between lines so the title and description are correctly extracted.
3. **Field Swap Button:** Add a 1-tap "Swap Title & Description" button (⇅) in the review sheet in case the user wants to flip them before proceeding.
4. **Bottom Button Visibility (Safe Area):** The action buttons were partially hidden behind Android's 3-button navigation bar. We will add safe area padding and configure `useSafeArea: true` so buttons are always fully visible and clickable.
5. **Image Rotation (Portrait & Landscape):** Users capture photos in portrait, landscape, or at various angles. We will add a 90° clockwise rotation button in the crop and preview screen so photos can be oriented properly before running OCR.

---

## Scenarios Considered for OCR Photo Capture

1. **Orientation variations:**
   - Phone in portrait, paper in portrait.
   - Phone in portrait, paper/screen in landscape (user needs 90° rotation).
   - Phone in landscape, taking wide notes or whiteboard photos.
   - Device held at angles where camera sensor EXIF rotation is not what the user intended.

2. **Visual layout variations:**
   - Title at top, description at bottom separated by space or newline.
   - Short title, long multi-line description.
   - Title followed by separator (`---`, `###`).
   - Single-line task with no description.
   - ML Kit detecting larger or high-contrast bottom blocks before the top block.

3. **Android navigation bar & screen variations:**
   - Devices with 3-button navigation (`<`, `O`, `|||`).
   - Devices with gesture navigation pill.
   - Devices in landscape orientation with side or bottom system insets.
   - Soft keyboard open vs soft keyboard closed.

4. **Task creation flow:**
   - Review sheet primary button navigates directly to the Create Task screen prefilled with scanned title and description.
   - If OCR was initiated from an existing Create Task screen, it returns the scanned title and description back to that screen.

---

## Files to Change

1. `lib/presentation/screens/ocr/ocr_scan_screen.dart` [MODIFY]
   - Change the primary flow to navigate to the Create Task screen using `AppRoutes.createTodoPath(date: _effectiveDate, title: title, description: description)` instead of silently saving.
   - Pass `recognizedText` through `OcrTextSorter.sort(recognizedText)` before parsing.

2. `lib/presentation/screens/ocr/utils/ocr_text_sorter.dart` [NEW]
   - Sorts ML Kit `RecognizedText` lines and blocks geometrically from top to bottom, left to right.
   - Preserves vertical gaps between blocks so paragraph separation is recognized by `OcrTaskParser`.

3. `lib/presentation/screens/ocr/ocr_crop_screen.dart` [MODIFY]
   - Add a 90° clockwise rotation button in the AppBar.
   - Losslessly rotate the source image in memory and reset the crop box.
   - When confirmed or "Use full image" is pressed, save the rotated image so ML Kit processes the properly oriented picture.

4. `lib/presentation/screens/ocr/widgets/ocr_result_bottom_sheet.dart` [MODIFY]
   - Update primary action button to "Continue to Task Creation" / "ടാസ്ക് സൃഷ്ടിക്കലിലേക്ക് തുടരുക" (or "Apply to Form" when called from form).
   - Add safe area handling: include `MediaQuery.paddingOf(context).bottom` alongside `bottomInset` and set `useSafeArea: true`.
   - Add a "Swap" button (`Icons.swap_vert`) between Title and Description fields.

5. `lib/l10n/app_en.arb` and `lib/l10n/app_ml.arb` [MODIFY]
   - Add strings for `ocrRotateImage` ("Rotate 90°" / "ചിത്രം തിരിക്കുക") and `ocrSwapFields` ("Swap Title and Description" / "ശീർഷകവും വിവരണവും മാറ്റുക").
   - Update `ocrContinueToCreate` ("Continue to Task Creation" / "ടാസ്ക് നിർമ്മാണത്തിലേക്ക് പോകുക").
   - Run `flutter gen-l10n`.

6. `test/presentation/screens/ocr/ocr_text_sorter_test.dart` [NEW]
   - Unit tests to verify that text with different bounding box positions is sorted top-to-bottom and gaps are preserved.

---

## Verification Plan

### Automated Tests
- Run unit tests: `flutter test test/presentation/screens/ocr/ocr_text_sorter_test.dart`
- Run all project tests: `flutter test`
- Run static analysis: `flutter analyze`

### Manual Verification
- Verify that confirming the scanned task opens the Create Task screen with Title and Description pre-filled.
- Verify that taking a photo with "Battery Soul" at the top and "An android app..." below places "Battery Soul" as Title and the sentence as Description.
- Verify the "Rotate 90°" button rotates the photo cleanly in crop mode.
- Verify the action button is fully visible above Android navigation buttons.
- Verify the Swap button swaps Title and Description when tapped.
