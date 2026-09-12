import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:sreerajp_todo/domain/services/ocr_enhancer.dart';

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

  // 4. Apply filter preset.
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
      break;
    case OcrEnhanceFilter.enhance:
      // Mild contrast boost + grayscale for crisp legibility.
      image = img.grayscale(image);
      image = img.contrast(image, contrast: 118);
      break;
  }

  // 5. Apply brightness adjustment (-100 to 100).
  if (params.brightness != 0) {
    final factor = 1.0 + (params.brightness / 100.0);
    image = img.adjustColor(image, brightness: factor);
  }

  // 6. Apply contrast adjustment (-100 to 100).
  if (params.contrast != 0) {
    final factor = 1.0 + (params.contrast / 100.0);
    image = img.adjustColor(image, contrast: factor);
  }

  // 7. Optimal dimension scaling for OCR accuracy and memory safety.
  const int maxOcrDimension = 1800;
  final longestDimension = math.max(image.width, image.height);
  if (longestDimension > maxOcrDimension) {
    final scale = maxOcrDimension / longestDimension;
    image = img.copyResize(
      image,
      width: (image.width * scale).round(),
      height: (image.height * scale).round(),
      interpolation: img.Interpolation.linear,
    );
  } else if (image.height < 220 && longestDimension * 2 <= maxOcrDimension) {
    // If a crop is short in height (e.g. a 1 or 2 line snippet), scale it up so
    // individual characters have enough pixel resolution (x-height >= 28px) for
    // Tesseract's neural network to detect complex vowel marks, numbers, and
    // ligatures.
    final scale = math.min(2.0, maxOcrDimension / longestDimension);
    if (scale > 1.2) {
      image = img.copyResize(
        image,
        width: (image.width * scale).round(),
        height: (image.height * scale).round(),
        interpolation: img.Interpolation.linear,
      );
    }
  }

  // 8. Fast lossless PNG output for OCR recognition (compression level 1 for
  // max speed).
  final pngBytes = Uint8List.fromList(img.encodePng(image, level: 1));
  File(params.targetPath).writeAsBytesSync(pngBytes);

  // 9. Generate fast UI preview thumbnail if requested.
  Uint8List? previewBytes;
  if (params.generatePreview) {
    final longestEdge = math.max(image.width, image.height);
    if (longestEdge > params.previewMaxDimension) {
      final scale = params.previewMaxDimension / longestEdge;
      final previewImg = img.copyResize(
        image,
        width: (image.width * scale).round(),
        height: (image.height * scale).round(),
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
    } catch (e) {
      debugPrint('IsolateOcrEnhancer: image enhancement failed ($e)');
      rethrow;
    }
  }
}
