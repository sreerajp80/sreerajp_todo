import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sreerajp_todo/domain/services/ocr_capture_downscaler.dart';

/// Arguments for [bakeAndEncodeCaptureIsolate].
@immutable
class OcrDownscaleArgs {
  const OcrDownscaleArgs({
    required this.rgbaBytes,
    required this.width,
    required this.height,
    required this.exifOrientation,
    required this.targetPath,
  });

  /// Straight RGBA pixels, four bytes per pixel.
  final Uint8List rgbaBytes;
  final int width;
  final int height;

  /// EXIF orientation still to be applied, or 1 when there is nothing to do.
  final int exifOrientation;

  final String targetPath;
}

/// Applies any remaining EXIF rotation and writes the working copy as PNG.
///
/// Top-level on purpose: it is run through [compute] in a background isolate,
/// because encoding a 12 MP PNG blocks a frame for far too long.
bool bakeAndEncodeCaptureIsolate(OcrDownscaleArgs args) {
  var image = img.Image.fromBytes(
    width: args.width,
    height: args.height,
    bytes: args.rgbaBytes.buffer,
    numChannels: 4,
  );

  if (args.exifOrientation > 1) {
    // bakeOrientation reads the tag off the image, so put it there first.
    image.exif.imageIfd.orientation = args.exifOrientation;
    image = img.bakeOrientation(image);
  }

  // Lossless. JPEG blur at this stage eats the one-pixel strokes of `.`, `=`,
  // `,` and `:` before OCR ever sees them. Level 1 keeps the encode fast.
  File(args.targetPath).writeAsBytesSync(img.encodePng(image, level: 1));
  return true;
}

/// Shrinks a full-resolution camera capture to a size the Dart image pipeline
/// can afford, using the platform's native image codec.
///
/// The codec subsamples while decoding rather than decoding first and shrinking
/// after, so a 50 MP photo never materialises as a 200 MB pixel buffer.
class NativeOcrCaptureDownscaler implements OcrCaptureDownscaler {
  const NativeOcrCaptureDownscaler();

  /// Whether the platform codec applies EXIF orientation on its own.
  ///
  /// Decided once by [_probeCodecExifBehaviour] rather than assumed, because
  /// guessing wrong rotates the photo twice and the user then has to undo it
  /// by hand.
  static bool? _codecAppliesExif;

  @visibleForTesting
  static void resetExifProbeForTest() => _codecAppliesExif = null;

  /// Decodes a tiny image whose EXIF says "rotate 90°" and checks whether the
  /// codec swapped its sides. A codec that honours one orientation honours all
  /// of them, so this settles the 180° and mirrored cases too, which cannot be
  /// told apart from the output dimensions alone.
  static Future<bool> _probeCodecExifBehaviour() async {
    final cached = _codecAppliesExif;
    if (cached != null) return cached;

    var applies = false;
    try {
      // 16x8, so JPEG's 8-pixel blocks divide it evenly and the decoded size is
      // exactly what was encoded.
      final probe = img.Image(width: 16, height: 8);
      probe.exif.imageIfd.orientation = 6; // 90° clockwise: 16x8 becomes 8x16.

      final codec = await ui.instantiateImageCodec(
        Uint8List.fromList(img.encodeJpg(probe)),
      );
      final frame = await codec.getNextFrame();
      applies = frame.image.width == 8 && frame.image.height == 16;
      frame.image.dispose();
      codec.dispose();
    } catch (e) {
      // Fall back to applying the rotation ourselves. An unrotated photo is a
      // recoverable annoyance; a double-rotated one is a bug the user sees.
      debugPrint('OcrCaptureDownscaler: EXIF probe failed ($e)');
      applies = false;
    }

    _codecAppliesExif = applies;
    return applies;
  }

  @override
  Future<String> downscale(String imagePath) async {
    try {
      final bytes = await File(imagePath).readAsBytes();

      // Header only. This reads the stored pixel size without decoding a
      // single pixel, so it costs nothing even on a 50 MP file.
      final info = img.findDecoderForData(bytes)?.startDecode(bytes);
      if (info == null || info.width <= 0 || info.height <= 0) {
        debugPrint('OcrCaptureDownscaler: unreadable header, using original');
        return imagePath;
      }

      final storedWidth = info.width;
      final storedHeight = info.height;
      final exifOrientation =
          img.decodeJpgExif(bytes)?.imageIfd.orientation ?? 1;

      // Orientations 5 to 8 turn the image a quarter turn, swapping its sides.
      final swapsSides = exifOrientation >= 5 && exifOrientation <= 8;
      final longEdge = storedWidth > storedHeight ? storedWidth : storedHeight;

      // Already small enough and already upright: nothing to gain by rewriting
      // it, and the original stays the sharpest thing we have.
      if (longEdge <= kOcrCaptureMaxLongEdge && exifOrientation <= 1) {
        return imagePath;
      }

      final codecAppliesExif = await _probeCodecExifBehaviour();

      final scale = longEdge > kOcrCaptureMaxLongEdge
          ? kOcrCaptureMaxLongEdge / longEdge
          : 1.0;

      // targetWidth applies to what the codec hands back, which is already
      // turned when the codec honours EXIF itself.
      final codecOutputWidth = codecAppliesExif && swapsSides
          ? storedHeight
          : storedWidth;
      final targetWidth = (codecOutputWidth * scale).round().clamp(1, 1 << 20);

      final codec = await ui.instantiateImageCodec(
        bytes,
        targetWidth: targetWidth,
      );
      final frame = await codec.getNextFrame();
      final uiImage = frame.image;

      final rgba = await uiImage.toByteData(format: ui.ImageByteFormat.rawRgba);
      final decodedWidth = uiImage.width;
      final decodedHeight = uiImage.height;
      uiImage.dispose();
      codec.dispose();

      if (rgba == null) {
        debugPrint('OcrCaptureDownscaler: pixel read failed, using original');
        return imagePath;
      }

      final tempDir = await getTemporaryDirectory();
      final targetPath = p.join(
        tempDir.path,
        'ocr_cap_${DateTime.now().microsecondsSinceEpoch}.png',
      );

      final written = await compute(
        bakeAndEncodeCaptureIsolate,
        OcrDownscaleArgs(
          rgbaBytes: rgba.buffer.asUint8List(),
          width: decodedWidth,
          height: decodedHeight,
          // Only ours to do when the codec left it alone.
          exifOrientation: codecAppliesExif ? 1 : exifOrientation,
          targetPath: targetPath,
        ),
      );

      if (!written) return imagePath;
      return targetPath;
    } catch (e) {
      // Preparation is an optimisation, never a hard requirement. A slower
      // correct path beats a crash on the one photo the user wanted.
      debugPrint('OcrCaptureDownscaler: downscale failed ($e)');
      return imagePath;
    }
  }
}
