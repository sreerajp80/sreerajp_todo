import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:sreerajp_todo/domain/services/ocr_enhancer.dart';
import 'package:sreerajp_todo/core/logging/app_logger.dart';

/// Fraction of the darkest and lightest pixels ignored when choosing the black
/// and white points, so a few specks of dust or a glare highlight cannot decide
/// the whole page's levels.
const double kOcrLevelClipFraction = 0.05;

/// Stretches a grayscale image's tones so the darkest 5% of pixels become black
/// and the lightest 5% become white.
///
/// A photographed page is never true black on true white — it comes back as
/// dark grey ink on light grey paper. Recognition binarizes the image, and the
/// closer the ink and paper already are to black and white, the less the
/// binarizer has to guess. Call this before any contrast lift.
img.Image normalizeOcrLevels(img.Image image) {
  final histogram = List<int>.filled(256, 0);
  for (final pixel in image) {
    histogram[pixel.r.round().clamp(0, 255)]++;
  }

  final total = image.width * image.height;
  if (total == 0) return image;

  final clip = (total * kOcrLevelClipFraction).round();

  var low = 0;
  var counted = 0;
  for (var value = 0; value < 256; value++) {
    counted += histogram[value];
    if (counted > clip) {
      low = value;
      break;
    }
  }

  var high = 255;
  counted = 0;
  for (var value = 255; value >= 0; value--) {
    counted += histogram[value];
    if (counted > clip) {
      high = value;
      break;
    }
  }

  // Too flat to stretch safely — a nearly blank or single-tone image. Leave it
  // alone rather than amplifying its noise into fake ink.
  if (high - low < 16) return image;

  final span = (high - low).toDouble();
  final lookup = List<int>.generate(
    256,
    (value) => (((value - low) / span) * 255).round().clamp(0, 255),
  );

  for (final pixel in image) {
    final value = lookup[pixel.r.round().clamp(0, 255)];
    pixel.setRgb(value, value, value);
  }
  return image;
}

/// Most pixels a photo may keep for recognition, about 3260 x 2450.
///
/// That keeps a full A4 page near 280 dpi, so small print still has letters
/// tall enough for Tesseract, while one RGBA copy stays near 32 MB.
const int kOcrPhotoPixelBudget = 8000000;

/// Most pixels a screen capture may keep after it is enlarged. Higher than
/// the photo budget because screen text starts out small and must be
/// enlarged, and a scrolling screenshot can be very tall.
const int kOcrScreenPixelBudget = 12000000;

/// How much a screen capture is enlarged. Phone UI text is often only 10 to
/// 15 px tall; Tesseract reads best at about 20 to 35 px.
const double kOcrScreenUpscale = 2.0;

/// Crops shorter than this (one or two lines of text) are enlarged too.
const int kOcrShortCropHeight = 220;

/// Mean brightness (0..255) below which an image counts as mostly dark — a
/// dark-mode screen with light text. Matches the native side.
const int kOcrDarkMeanLuminance = 110;

/// Sharpening applied by the filters that ask for it, before the user's own
/// sharpness setting. Light, so thin vowel signs do not grow halos.
const double kOcrFilterSharpenAmount = 0.5;

/// Returns the factor the image should be resized by before recognition.
///
/// Values below 1 shrink an image that is over its pixel budget. Values above
/// 1 enlarge screen captures and short crops so their letters are tall enough.
/// Tiny enlargements (under 1.2x) are skipped; they cost time and gain nothing.
double ocrScaleFactor({
  required int width,
  required int height,
  required OcrEnhanceFilter filter,
}) {
  final pixels = width * height;
  if (pixels <= 0) return 1.0;

  final isScreen = filter == OcrEnhanceFilter.screen;
  final budget = isScreen ? kOcrScreenPixelBudget : kOcrPhotoPixelBudget;
  final budgetScale = math.sqrt(budget / pixels);

  var wanted = 1.0;
  if (isScreen) {
    wanted = kOcrScreenUpscale;
  } else if (height < kOcrShortCropHeight) {
    wanted = 2.0;
  }

  final scale = math.min(wanted, budgetScale);
  if (scale > 1.0 && scale < 1.2) return 1.0;
  return scale;
}

/// True when the average brightness of [image] is below
/// [kOcrDarkMeanLuminance]. Samples a grid, so a big image is cheap.
bool isMostlyDark(img.Image image) {
  if (image.width == 0 || image.height == 0) return false;
  final stepX = math.max(1, image.width ~/ 64);
  final stepY = math.max(1, image.height ~/ 64);
  var total = 0.0;
  var count = 0;
  for (var y = 0; y < image.height; y += stepY) {
    for (var x = 0; x < image.width; x += stepX) {
      final pixel = image.getPixel(x, y);
      total += pixel.r * 0.299 + pixel.g * 0.587 + pixel.b * 0.114;
      count++;
    }
  }
  return total / count < kOcrDarkMeanLuminance;
}

/// Sharpens [image] with an unsharp mask: each pixel is pushed away from the
/// blurred average of its neighbours by [amount] (0 = no change, 1 = strong).
///
/// Letter edges get firmer; flat areas stay as they are.
img.Image unsharpMask(
  img.Image image, {
  required double amount,
  int radius = 1,
}) {
  if (amount <= 0) return image;
  final blurred = img.gaussianBlur(img.Image.from(image), radius: radius);
  final blurredPixels = blurred.iterator;
  for (final pixel in image) {
    blurredPixels.moveNext();
    final soft = blurredPixels.current;
    pixel.setRgb(
      (pixel.r + amount * (pixel.r - soft.r)).round().clamp(0, 255),
      (pixel.g + amount * (pixel.g - soft.g)).round().clamp(0, 255),
      (pixel.b + amount * (pixel.b - soft.b)).round().clamp(0, 255),
    );
  }
  return image;
}

/// Sauvola sensitivity. Higher keeps less faint ink; 0.34 is the usual value
/// for printed pages.
const double kSauvolaK = 0.34;

/// Pixels the local statistics are measured on. Larger images are measured on
/// a smaller copy, so the memory used stays small on any photo.
const int kSauvolaStatsPixels = 400000;

/// Turns a grayscale [image] into pure black and white with Sauvola's local
/// threshold.
///
/// A single threshold for the whole page fails when a shadow covers part of
/// it: the shaded paper is darker than the ink in the light part. Sauvola
/// compares each pixel with the mean and spread of its own neighbourhood, so
/// ink is found in the shadow and in the light part alike.
///
/// The mean and spread are measured on a reduced copy using integral images
/// (running sums), so the cost does not grow with the window size.
img.Image sauvolaBinarize(img.Image image, {double k = kSauvolaK}) {
  final width = image.width;
  final height = image.height;
  if (width == 0 || height == 0) return image;

  final factor = math.max(
    1,
    math.sqrt(width * height / kSauvolaStatsPixels).ceil(),
  );
  final statsWidth = (width / factor).ceil();
  final statsHeight = (height / factor).ceil();
  final stats = factor == 1
      ? image
      : img.copyResize(
          image,
          width: statsWidth,
          height: statsHeight,
          interpolation: img.Interpolation.average,
        );

  // Integral images: entry (x, y) holds the sum of every value above and to
  // the left, so the sum over any window costs four lookups.
  final stride = statsWidth + 1;
  final sums = Float64List(stride * (statsHeight + 1));
  final squares = Float64List(stride * (statsHeight + 1));
  for (var y = 0; y < statsHeight; y++) {
    var rowSum = 0.0;
    var rowSquares = 0.0;
    for (var x = 0; x < statsWidth; x++) {
      final value = stats.getPixel(x, y).r.toDouble();
      rowSum += value;
      rowSquares += value * value;
      final index = (y + 1) * stride + x + 1;
      sums[index] = sums[index - stride] + rowSum;
      squares[index] = squares[index - stride] + rowSquares;
    }
  }

  // Window about 1/40 of the short side: two or three letter heights on a
  // typical page.
  final radius = math.max(3, (math.min(statsWidth, statsHeight) / 40).round());
  final thresholds = Float32List(statsWidth * statsHeight);
  for (var y = 0; y < statsHeight; y++) {
    final top = math.max(0, y - radius);
    final bottom = math.min(statsHeight, y + radius + 1);
    for (var x = 0; x < statsWidth; x++) {
      final left = math.max(0, x - radius);
      final right = math.min(statsWidth, x + radius + 1);
      final area = ((bottom - top) * (right - left)).toDouble();
      final a = top * stride + left;
      final b = top * stride + right;
      final c = bottom * stride + left;
      final d = bottom * stride + right;
      final mean = (sums[d] - sums[b] - sums[c] + sums[a]) / area;
      final meanSquares =
          (squares[d] - squares[b] - squares[c] + squares[a]) / area;
      final deviation = math.sqrt(math.max(0.0, meanSquares - mean * mean));
      thresholds[y * statsWidth + x] = mean * (1 + k * (deviation / 128 - 1));
    }
  }

  for (final pixel in image) {
    final statsX = math.min(statsWidth - 1, pixel.x ~/ factor);
    final statsY = math.min(statsHeight - 1, pixel.y ~/ factor);
    final value = pixel.r < thresholds[statsY * statsWidth + statsX] ? 0 : 255;
    pixel.setRgb(value, value, value);
  }
  return image;
}

/// Background isolate worker for lossless document image processing.
OcrEnhanceResult processOcrImageIsolate(OcrEnhanceParams params) {
  final file = File(params.sourcePath);
  if (!file.existsSync()) {
    throw FileSystemException('Source image does not exist', params.sourcePath);
  }

  final bytes = file.readAsBytesSync();
  final img.Image? raw = img.decodeImage(bytes);
  if (raw == null) {
    throw const FormatException('Failed to decode source image');
  }

  // 1. Normalize EXIF orientation first so coordinates are upright.
  var image = img.bakeOrientation(raw);

  // 2. Apply manual rotation in 90-degree steps.
  final normalizedAngle = (params.rotationAngle % 360 + 360) % 360;
  if (normalizedAngle != 0) {
    image = img.copyRotate(image, angle: normalizedAngle.toDouble());
  }

  // 3. Flip light and dark, before the filter runs, so the filter works on
  // dark-ink-on-light-paper the way it expects.
  if (params.invert) {
    image = img.invert(image);
  }

  // 4. Resize to the size recognition will read, before the filters. When
  // shrinking, the filters then work on fewer pixels; when enlarging,
  // sharpening acts on the final letter edges. Cubic keeps thin strokes
  // crisper than linear.
  final scale = ocrScaleFactor(
    width: image.width,
    height: image.height,
    filter: params.filter,
  );
  if (scale != 1.0) {
    image = img.copyResize(
      image,
      width: math.max(1, (image.width * scale).round()),
      height: math.max(1, (image.height * scale).round()),
      interpolation: img.Interpolation.cubic,
    );
  }

  // 5. Apply filter preset.
  switch (params.filter) {
    case OcrEnhanceFilter.original:
      break;
    case OcrEnhanceFilter.grayscale:
      image = img.grayscale(image);
      break;
    case OcrEnhanceFilter.documentBw:
      image = img.grayscale(image);
      // Stretch the levels first. Without this a photographed page keeps a grey
      // cast, so a plain contrast lift darkens the paper along with the ink and
      // the recognizer's binarizer still has to guess where the ink ends.
      image = normalizeOcrLevels(image);
      // Clean contrast boost to separate ink from paper without eroding thin
      // vowel signs.
      image = img.contrast(image, contrast: 130);
      image = unsharpMask(image, amount: kOcrFilterSharpenAmount);
      break;
    case OcrEnhanceFilter.enhance:
      // Level stretch, mild contrast boost and light sharpening for crisp
      // legibility.
      image = img.grayscale(image);
      image = normalizeOcrLevels(image);
      image = img.contrast(image, contrast: 118);
      image = unsharpMask(image, amount: kOcrFilterSharpenAmount);
      break;
    case OcrEnhanceFilter.screen:
      // Brightness-based grayscale turns coloured buttons and chips into plain
      // grey, so their text stands out the same way as body text.
      image = img.grayscale(image);
      // Dark mode: the recognizer drops light text on a dark ground as
      // background. Flip it to dark text on light.
      if (isMostlyDark(image)) image = img.invert(image);
      image = normalizeOcrLevels(image);
      image = unsharpMask(image, amount: kOcrFilterSharpenAmount);
      break;
    case OcrEnhanceFilter.adaptiveBw:
      image = img.grayscale(image);
      image = sauvolaBinarize(image);
      break;
  }

  // 6. Apply brightness adjustment (-100 to 100).
  if (params.brightness != 0) {
    final factor = 1.0 + (params.brightness / 100.0);
    image = img.adjustColor(image, brightness: factor);
  }

  // 7. Apply contrast adjustment (-100 to 100).
  if (params.contrast != 0) {
    final factor = 1.0 + (params.contrast / 100.0);
    image = img.adjustColor(image, contrast: factor);
  }

  // 8. Apply the user's extra sharpening (0 to 100 maps to 0 to 1.5).
  if (params.sharpness > 0) {
    image = unsharpMask(
      image,
      amount: params.sharpness.clamp(0, 100) / 100.0 * 1.5,
    );
  }

  // 9. Fast lossless PNG output for OCR recognition (compression level 1 for
  // max speed).
  final pngBytes = Uint8List.fromList(img.encodePng(image, level: 1));
  File(params.targetPath).writeAsBytesSync(pngBytes);

  // 10. Generate fast UI preview thumbnail if requested.
  Uint8List? previewBytes;
  if (params.generatePreview) {
    final longestEdge = math.max(image.width, image.height);
    if (longestEdge > params.previewMaxDimension) {
      final previewScale = params.previewMaxDimension / longestEdge;
      final previewImg = img.copyResize(
        image,
        width: (image.width * previewScale).round(),
        height: (image.height * previewScale).round(),
        interpolation: img.Interpolation.linear,
      );
      previewBytes = Uint8List.fromList(img.encodePng(previewImg, level: 1));
    } else {
      previewBytes = pngBytes;
    }
  }

  return OcrEnhanceResult(
    targetPath: params.targetPath,
    width: image.width,
    height: image.height,
    previewBytes: previewBytes,
  );
}

/// [OcrEnhancer] that does its pixel work in a background isolate, so the UI
/// stays smooth while a full-resolution photo is processed.
class IsolateOcrEnhancer implements OcrEnhancer {
  const IsolateOcrEnhancer();

  @override
  Future<OcrEnhanceResult> enhance(OcrEnhanceParams params) async {
    try {
      return await compute(processOcrImageIsolate, params);
    } catch (e, st) {
      AppLogger.error(
        'IsolateOcrEnhancer: image enhancement failed',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }
}
