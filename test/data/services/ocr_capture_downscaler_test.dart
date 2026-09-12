import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:sreerajp_todo/data/services/ocr_capture_downscaler.dart';
import 'package:sreerajp_todo/domain/services/ocr_capture_downscaler.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  const downscaler = NativeOcrCaptureDownscaler();
  const pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('ocr_capture_test');
    NativeOcrCaptureDownscaler.resetExifProbeForTest();

    // getTemporaryDirectory has no platform behind it in a unit test.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, (call) async {
          if (call.method == 'getTemporaryDirectory') return tempDir.path;
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, null);
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  /// Writes a JPEG with a dark block in the top-left corner, so the corner can
  /// be found again after a rotation.
  String writeJpeg({
    required String name,
    required int width,
    required int height,
    int? exifOrientation,
  }) {
    final image = img.Image(width: width, height: height);
    img.fill(image, color: img.ColorRgb8(255, 255, 255));
    img.fillRect(
      image,
      x1: 0,
      y1: 0,
      x2: (width ~/ 8).clamp(1, width - 1),
      y2: (height ~/ 8).clamp(1, height - 1),
      color: img.ColorRgb8(10, 10, 10),
    );
    if (exifOrientation != null) {
      image.exif.imageIfd.orientation = exifOrientation;
    }
    final path = '${tempDir.path}/$name.jpg';
    File(path).writeAsBytesSync(img.encodeJpg(image, quality: 100));
    return path;
  }

  group('NativeOcrCaptureDownscaler', () {
    test('caps an oversized capture at the long-edge limit', () async {
      // Stands in for a full-sensor capture, which is far larger than the
      // Dart image pipeline can decode without being killed.
      final source = writeJpeg(name: 'big', width: 6000, height: 4500);

      final result = await downscaler.downscale(source);

      expect(result, isNot(source));
      final decoded = img.decodeImage(File(result).readAsBytesSync())!;
      expect(decoded.width, kOcrCaptureMaxLongEdge);
      // Aspect ratio survives the shrink.
      expect(decoded.width / decoded.height, closeTo(6000 / 4500, 0.01));
    });

    test('leaves an already-small upright photo alone', () async {
      final source = writeJpeg(name: 'small', width: 800, height: 600);

      final result = await downscaler.downscale(source);

      // Rewriting it would only cost time; the original is the sharpest copy.
      expect(result, source);
    });

    test(
      'falls back to the original path when the file cannot be read',
      () async {
        final source = '${tempDir.path}/not_an_image.jpg';
        File(source).writeAsStringSync('this is not an image');

        final result = await downscaler.downscale(source);

        expect(result, source);
      },
    );

    test('falls back to the original path when the file is missing', () async {
      final source = '${tempDir.path}/missing.jpg';

      final result = await downscaler.downscale(source);

      expect(result, source);
    });

    test('applies EXIF rotation exactly once', () async {
      // Orientation 6 means "turn a quarter turn clockwise", so a 400x200
      // photo must come back 200x400. Rotating it twice would give 400x200
      // again, which is exactly the bug this guards.
      final source = writeJpeg(
        name: 'sideways',
        width: 400,
        height: 200,
        exifOrientation: 6,
      );

      final result = await downscaler.downscale(source);

      expect(result, isNot(source));
      final decoded = img.decodeImage(File(result).readAsBytesSync())!;
      expect(decoded.width, 200);
      expect(decoded.height, 400);
    });

    test(
      'caps and rotates together for an oversized sideways capture',
      () async {
        final source = writeJpeg(
          name: 'big_sideways',
          width: 6000,
          height: 4500,
          exifOrientation: 6,
        );

        final result = await downscaler.downscale(source);

        final decoded = img.decodeImage(File(result).readAsBytesSync())!;
        // Turned a quarter turn, so the tall side is now the long one.
        expect(decoded.height, greaterThan(decoded.width));
        expect(decoded.height, kOcrCaptureMaxLongEdge);
      },
    );
  });
}
