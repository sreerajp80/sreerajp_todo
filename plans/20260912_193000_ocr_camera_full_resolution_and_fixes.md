# OCR camera: full sensor resolution + camera control fixes

**Status:** Implemented (see change_log/20260912_201500_ocr_camera_full_resolution_and_fixes.md)

## Why

A review of the OCR capture path found four defects. The biggest one is that the
camera never uses the sensor the phone actually has, so every later filter is
trying to rescue detail that was thrown away at the moment of capture.

## The four problems

### 1. Capture resolution is 720p

`lib/presentation/screens/ocr/ocr_scan_screen.dart` builds its `CameraController`
with `ResolutionPreset.high`. On Android that asks CameraX for a bound size of
1280x720. A full page of text at 720p leaves body letters only a few pixels tall,
and a `.` or `:` lands below the size the recognizer can see at all.

`lib/data/services/ocr_image_preprocessor.dart` then enlarges the short edge to
1200 px. Enlarging cannot put back detail the sensor never recorded; it only makes
blurred letters bigger.

### 2. Disposed camera controller is still rendered

`didChangeAppLifecycleState` calls `controller.dispose()` on `inactive` but leaves
`_isCameraInitialized` at `true` and `_controller` non-null. The next `build`
renders `CameraPreview` on a dead controller. This path runs every single time the
user opens the gallery picker or the crop screen.

Two more faults in the same area:

- On `resumed` it reads `_cameras[_selectedCameraIndex]` with no guard. If the
  camera list is empty because permission was refused, this throws a range error.
- `_initializeCameraController` awaits disposal of the previous controller *before*
  the `setState` that clears `_isCameraInitialized`, so there is a second window
  where a disposed controller can be painted.

### 3. Crop feeds the filtered image back in as the new source

`_openCropper` passes `_enhancedOutputPath` to the cropper. That file is already
grayscaled, level-stretched and contrast-boosted. The crop result is then stored as
`_currentSourcePath`, so every later filter or brightness change re-processes an
already-processed image and applies contrast a second time. That is exactly the
thin-stroke damage the comment in `lib/data/services/cropper_image_edit_service.dart`
is written to avoid.

Cropping from the filtered copy also means a crop of one quarter of the page keeps
only a quarter of the *preview-sized* pixels, instead of a quarter of the full
capture.

### 4. Tap-to-focus aims at the wrong point

`_onTapToFocus` divides the tap position by the size of the whole screen
`RenderBox`. The preview sits letterboxed inside a `Center`, so whenever the preview
aspect ratio differs from the screen aspect ratio the normalised point is wrong by
the size of the letterbox bars. The focus lands off the text.

There is also no `setFocusMode`, so continuous autofocus is free to drift straight
back off the paper after the user has aimed it.

## How full resolution will actually work

`ResolutionPreset.max` maps, in `camera_android_camerax`, to
`ResolutionStrategy.highestAvailableStrategy` together with
`preferHigherResolutionOverCaptureRate`. That is the real full sensor output the
device reports, so on a 50 MP phone the JPEG is a 50 MP JPEG.

That capture cannot be fed to the existing Dart pipeline as it stands:

- The `image` package decodes 50 MP to roughly 150-200 MB of pixels, and
  `bakeOrientation`, `copyRotate` and `copyResize` each allocate another full copy.
  Peak use would be 400-600 MB and would be killed on most devices.
- A pure-Dart JPEG decode of 50 MP takes many seconds, and the enhance screen
  re-runs that decode on every slider move.

So the capture stays full resolution and the *decode* is made cheap: right after
capture the photo is downscaled once through Flutter's native Skia codec
(`instantiateImageCodec` with a `targetWidth`), which subsamples while decoding
instead of decoding first and shrinking after. Memory stays flat and the step is
fast.

This is not a compromise on OCR quality. Downscaling 50 MP to 12 MP averages several
sensor pixels into each output pixel, which removes noise and gives a visibly
sharper page than capturing at 12 MP directly. What OCR needs is dots per inch
across the page, and this plan raises that from about 255 DPI to about 340 DPI for a
full A4 sheet, with much cleaner pixels.

## Design: two images instead of one

The enhance screen will hold two paths instead of one.

- **Master** - geometry only. EXIF baked, user rotation applied, crop applied. No
  filter, no brightness, no contrast. Starts as the downscaled capture.
- **Enhanced** - the master with the current filter and adjustments applied. This is
  what the preview shows and what OCR reads. It is thrown away and rebuilt on every
  adjustment.

Crop reads the master and writes a new master. Filters therefore never compound, and
a crop keeps the full detail of the capture.

## Files to change

| File | Change |
|------|--------|
| `lib/presentation/screens/ocr/ocr_scan_screen.dart` | `ResolutionPreset.max`; lifecycle fix; focus mapping and focus lock |
| `lib/domain/services/ocr_capture_downscaler.dart` | New. Interface for the capture downscaler |
| `lib/data/services/ocr_capture_downscaler.dart` | New. Native-codec downscale of the full-resolution capture |
| `lib/application/providers.dart` | Register the downscaler provider |
| `lib/presentation/screens/ocr/ocr_enhance_screen.dart` | Master/enhanced split; crop reads master; downscale on entry |
| `lib/data/services/ocr_image_preprocessor.dart` | Raise `kOcrMaxLongEdge` from 3000 to 4000 |
| `lib/l10n/app_en.arb`, `lib/l10n/app_ml.arb` | New strings for focus lock and the preparing-image state |
| `test/data/services/ocr_capture_downscaler_test.dart` | New tests |
| `test/data/services/ocr_image_preprocessor_test.dart` | Update for the new cap |
| `test/presentation/screens/ocr/ocr_enhance_screen_test.dart` | Crop reads master, not enhanced output |

## Step by step

### Step 1 - full resolution capture

In `_initializeCameraController`, use `ResolutionPreset.max`.

Known trade-off, recorded here on purpose: `camera_android_camerax` hands the same
`ResolutionSelector` to the preview, the still capture and the analysis use case.
CameraX still clamps the preview surface to the device maximum preview size, so the
viewfinder should stay smooth, but if any device shows a laggy preview the single
fallback is `ResolutionPreset.ultraHigh` (2160p). This cannot be split per use case
without forking the plugin, which is out of scope.

### Step 2 - lifecycle fix

- On `inactive`: clear `_isCameraInitialized` and null `_controller` in a `setState`
  first, then dispose the captured reference.
- On `resumed`: if `_cameras` is empty, re-run the whole `_initializeCamera`;
  otherwise clamp the index before using it.
- In `_initializeCameraController`, clear `_isCameraInitialized` before awaiting the
  old controller's disposal.

### Step 3 - downscale service

New `OcrCaptureDownscaler` with a single method that takes a captured photo path and
returns the path of a working copy whose long edge is at most 4000 px.

- Decode through `ui.instantiateImageCodec` with `targetWidth`, chosen from the
  header dimensions, so the full-size bitmap is never materialised.
- Read the JPEG EXIF orientation from the header only, with no pixel decode, and
  check whether the Skia codec has already applied it; apply the remaining rotation
  only if it has not. This must be verified on a real sideways photo during
  implementation, because double-rotating is the easy mistake here.
- Write the working copy as PNG so no JPEG blur is added before OCR.
- If anything fails, return the original path. A slow correct path beats a crash.

### Step 4 - master/enhanced split in the enhance screen

- Add `_masterPath`, seeded in `initState` by running the capture through the
  downscaler, with a "preparing image" state shown while it runs.
- `_applyEnhancements` reads `_masterPath` and writes the enhanced output.
- `_openCropper` passes `_masterPath`, and on success sets the crop result as the new
  `_masterPath`, resets `_rotationAngle` to 0, and rebuilds the enhanced output.
- Rotation still lives in the enhancer, applied master to enhanced, so the master
  stays untouched until a crop bakes the geometry in.

### Step 5 - focus fix

- Put a `GlobalKey` on the `CameraPreview` and normalise the tap against that box,
  not the screen box, so the letterbox bars no longer shift the point.
- After `setFocusPoint` and `setExposurePoint`, call `setFocusMode(FocusMode.locked)`
  so autofocus cannot wander off the paper.
- Show a small "AF locked" chip while locked; tapping it returns to
  `FocusMode.auto`. Unlock automatically when the lens is switched.

### Step 6 - preprocessor cap

Raise `kOcrMaxLongEdge` from 3000 to 4000. A full A4 page then reaches about 340 DPI,
above the 300 DPI that text recognition wants. Peak pixel buffer is about 48 MB per
copy, which is safe.

## Tests

- Downscaler: an oversized image is capped at 4000 px on the long edge; a small image
  is returned unchanged; an unreadable file falls back to the original path; a photo
  carrying EXIF orientation comes out upright exactly once.
- Preprocessor: existing tests updated for the 4000 px cap.
- Enhance screen widget test: after a filter is chosen and a crop is performed, the
  path handed to the mocked `ImageEditService` is the master, not the enhanced
  output.
- Scan screen widget test: an `inactive` lifecycle event does not leave a
  `CameraPreview` mounted.

## Rules this change must respect

- No new package, and no network of any kind. Everything stays on device.
- New UI strings go through the ARB files in both English and Malayalam, each with an
  `@key` description.
- Layers hold: the interface goes in `lib/domain/services/`, the implementation in
  `lib/data/services/`, the provider in `lib/application/providers.dart`, and the
  screens only read providers.
- `flutter analyze` at zero issues and `flutter test` green before this is called
  done.

## Out of scope

- Splitting the preview and capture resolution selectors, which needs a plugin fork.
- Vendor high-resolution modes reached only through camera extensions.
- Any change to the OCR engines themselves.
