# OCR camera: full sensor resolution + camera control fixes

**Plan:** `plans/20260912_193000_ocr_camera_full_resolution_and_fixes.md`

## What this changes

Four defects in the OCR capture path are fixed. The camera now shoots at the
phone's full sensor resolution instead of 720p, a disposed camera controller can
no longer be painted, cropping no longer applies the document filters a second
time, and tap-to-focus now aims where the user actually tapped.

## 1. Full sensor resolution capture

`lib/presentation/screens/ocr/ocr_scan_screen.dart` now builds its
`CameraController` with `ResolutionPreset.max` instead of `ResolutionPreset.high`.

`ResolutionPreset.high` asked CameraX for a bound size of 1280x720. A full page of
text at that size leaves body letters only a few pixels tall, and a `.` or `:`
lands below the size the recognizer can see at all. `ResolutionPreset.max` maps to
CameraX's highest-available strategy, so a 50 MP sensor now captures 50 MP.

The full-size photo is not handed to the Dart image pipeline. Decoding 50 MP with
the `image` package costs roughly 150-200 MB of pixels, and the enhance pipeline
makes several copies, so the peak would be 400-600 MB and the app would be killed.
A new service shrinks the photo once, natively, before any Dart pixel work starts.

### New service: `OcrCaptureDownscaler`

- Interface: `lib/domain/services/ocr_capture_downscaler.dart`
- Implementation: `lib/data/services/ocr_capture_downscaler.dart`
- Provider: `ocrCaptureDownscalerProvider` in `lib/application/providers.dart`

It reads the JPEG header only to learn the stored size, then decodes through the
platform's native codec with a `targetWidth`, which subsamples while decoding
instead of decoding first and shrinking after. The working copy is capped at
4000 px on the long edge and written as lossless PNG. Any failure returns the
original path unchanged, so a bad photo slows the flow down but never crashes it.

Shrinking 50 MP to this size averages several sensor pixels into each output
pixel. That removes noise, so the result is sharper than capturing at this size
directly. A full A4 page now reaches about 340 dpi, above the 300 dpi that text
recognition wants.

### EXIF orientation is applied exactly once

Whether the platform codec turns a sideways photo itself is not assumed. On first
use the service decodes a 16x8 test image whose EXIF says "rotate a quarter turn"
and checks whether the sides came back swapped. The answer is cached. Guessing
this wrong would rotate the photo twice and leave the user to undo it by hand.

`kOcrMaxLongEdge` in `lib/data/services/ocr_image_preprocessor.dart` was raised
from 3000 to 4000 to match.

## 2. The disposed camera controller can no longer be painted

In `didChangeAppLifecycleState`, the `inactive` branch disposed the controller but
left `_isCameraInitialized` at `true` and `_controller` non-null, so the next
`build` rendered `CameraPreview` on a dead controller. This ran every time the user
opened the gallery picker or the crop screen. The field is now cleared in a
`setState` before the controller is disposed.

Two related faults in the same area are fixed:

- The `resumed` branch read `_cameras[_selectedCameraIndex]` with no guard, which
  threw a range error when camera permission had been refused and the list was
  empty. It now restarts initialisation from the beginning in that case, and
  clamps the index otherwise.
- `_initializeCameraController` awaited disposal of the previous controller before
  clearing `_isCameraInitialized`, leaving a second window where a disposed
  controller could be painted. The flag is now cleared first. The new controller is
  also disposed if the screen closed while it was starting up.

## 3. Crop no longer applies the filters twice

`lib/presentation/screens/ocr/ocr_enhance_screen.dart` now keeps two images instead
of one.

- **Master** (`_masterPath`) - geometry only: EXIF baked, user rotation and crop
  applied, never a filter.
- **Enhanced** (`_enhancedOutputPath`) - the master with the current filter and
  adjustments applied. Shown in the preview, read by recognition, thrown away and
  rebuilt on every adjustment.

Before, `_openCropper` handed the *enhanced* file to the cropper and stored the
result as the new source. That file was already grayscaled, level-stretched and
contrast-boosted, so the next slider move applied all of that a second time and
eroded the thin strokes recognition depends on. Cropping the master also means a
crop of one quarter of the page keeps one quarter of the full capture, not one
quarter of a preview-sized copy.

The screen shows a "Preparing photo..." state while the first master is being made.

## 4. Tap-to-focus and focus lock

- The tap is now normalised against the preview's own box, found through a
  `GlobalKey`, instead of the whole screen. The preview is letterboxed inside a
  `Center`, so dividing by the screen size shifted the point by the height of the
  black bars and the focus landed off the page. A tap that falls on the bars is
  now ignored rather than clamped to an edge.
- After the focus and exposure points are set, focus is locked with
  `FocusMode.locked`, so continuous autofocus cannot hunt away from a flat page.
- A "Focus locked" chip appears while the lock is held; tapping it returns to
  automatic focus. Switching lenses clears the lock.

## Localization

Two new keys added to `lib/l10n/app_en.arb` and `lib/l10n/app_ml.arb`, each with an
`@key` description in the English file:

- `ocrPreparingImage` - overlay shown while the capture is being prepared.
- `ocrFocusLocked` - the viewfinder focus-lock chip.

## Tests

- `test/data/services/ocr_capture_downscaler_test.dart` (new, 6 tests): an
  oversized capture is capped at the long-edge limit with its aspect ratio kept; an
  already-small upright photo is returned untouched; an unreadable file and a
  missing file both fall back to the original path; EXIF rotation is applied
  exactly once; capping and rotation work together.
- `test/presentation/screens/ocr/ocr_enhance_screen_test.dart` (new, 3 tests): the
  cropper is handed the master and not the filtered output; a crop result becomes
  the new master; rotating twice always re-reads the master so filters cannot
  stack.
- `test/data/services/ocr_image_preprocessor_test.dart`: comment updated for the
  new 4000 px cap. The assertions already referenced the constant.

`flutter analyze` reports no issues. `flutter test` passes all 742 tests.
`dart format` run over `lib/`, `test/` and `integration_test/`.

## Not done

A widget test for the camera lifecycle fix was planned but not written. Driving
`CameraController` in a widget test needs a fake `CameraPlatform`, which requires
adding `camera_platform_interface` and `plugin_platform_interface` as dev
dependencies. The approved plan said no new package, so this was left out rather
than decided unilaterally. The fix itself is in place; only its automated test is
missing. Both packages are pure Dart, offline, and would not ship in the app, so
this can be revisited if the dependency list is widened.

## Notes for the next change

- `camera_android_camerax` hands the same `ResolutionSelector` to the preview, the
  still capture and the analysis use case, so `ResolutionPreset.max` raises the
  preview target too. CameraX still clamps the preview surface to the device
  maximum preview size, so the viewfinder should stay smooth. If any device shows
  a laggy preview, the fallback is `ResolutionPreset.ultraHigh`. Splitting the
  selectors per use case would need a plugin fork.
- No new runtime package was added, and no network permission or capability was
  introduced. Everything still runs fully offline on device.
