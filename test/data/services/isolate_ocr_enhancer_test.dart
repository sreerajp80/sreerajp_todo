import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:sreerajp_todo/data/services/isolate_ocr_enhancer.dart';
import 'package:sreerajp_todo/domain/services/ocr_enhancer.dart';

void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('ocr_enhancer_test_');
  });

  tearDown(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  String writeTestImage({required int width, required int height}) {
    final image = img.Image(width: width, height: height);
    img.fill(image, color: img.ColorRgb8(240, 240, 240));
    img.fillRect(
      image,
      x1: 10,
      y1: 10,
      x2: width - 10,
      y2: height - 10,
      color: img.ColorRgb8(20, 20, 20),
    );
    final path = '${tempDir.path}/test_source.png';
    File(path).writeAsBytesSync(img.encodePng(image));
    return path;
  }

  group('OcrEnhancer isolate worker', () {
    test('rotates image 90 degrees and swaps dimensions', () {
      final sourcePath = writeTestImage(width: 400, height: 200);
      final targetPath = '${tempDir.path}/rotated.png';

      final result = processOcrImageIsolate(
        OcrEnhanceParams(
          sourcePath: sourcePath,
          targetPath: targetPath,
          rotationAngle: 90,
        ),
      );

      expect(result.width, 200);
      expect(result.height, 400);
      expect(File(targetPath).existsSync(), isTrue);
      expect(result.previewBytes, isNotNull);

      // Verify PNG file integrity
      final decoded = img.decodeImage(File(targetPath).readAsBytesSync())!;
      expect(decoded.width, 200);
      expect(decoded.height, 400);
    });

    test('applies document B&W and contrast enhancement', () {
      final sourcePath = writeTestImage(width: 300, height: 300);
      final targetPath = '${tempDir.path}/doc_bw.png';

      final result = processOcrImageIsolate(
        OcrEnhanceParams(
          sourcePath: sourcePath,
          targetPath: targetPath,
          filter: OcrEnhanceFilter.documentBw,
          contrast: 20,
          brightness: 10,
        ),
      );

      expect(result.width, 300);
      expect(result.height, 300);
      expect(File(targetPath).existsSync(), isTrue);

      final decoded = img.decodeImage(File(targetPath).readAsBytesSync())!;
      expect(decoded.numChannels, greaterThanOrEqualTo(1));
    });

    test('applies grayscale and high-contrast filters', () {
      final sourcePath = writeTestImage(width: 200, height: 200);
      final grayPath = '${tempDir.path}/gray.png';
      final sharpPath = '${tempDir.path}/sharp.png';

      final grayResult = processOcrImageIsolate(
        OcrEnhanceParams(
          sourcePath: sourcePath,
          targetPath: grayPath,
          filter: OcrEnhanceFilter.grayscale,
        ),
      );
      expect(File(grayResult.targetPath).existsSync(), isTrue);

      final sharpResult = processOcrImageIsolate(
        OcrEnhanceParams(
          sourcePath: sourcePath,
          targetPath: sharpPath,
          filter: OcrEnhanceFilter.enhance,
        ),
      );
      expect(File(sharpResult.targetPath).existsSync(), isTrue);
    });

    test('invert flips light and dark', () {
      final sourcePath = writeTestImage(width: 100, height: 100);
      final targetPath = '${tempDir.path}/inverted.png';

      final result = processOcrImageIsolate(
        OcrEnhanceParams(
          sourcePath: sourcePath,
          targetPath: targetPath,
          invert: true,
        ),
      );

      final decoded = img.decodeImage(
        File(result.targetPath).readAsBytesSync(),
      )!;
      // The source is a dark block (20) on a light border (240). After inverting,
      // the corner must be dark and the middle light.
      expect(decoded.getPixel(2, 2).r, lessThan(60));
      expect(decoded.getPixel(50, 50).r, greaterThan(200));
    });

    test('documentBw pushes a grey-cast page towards black and white', () {
      // A low-contrast page: mid-grey ink on light-grey paper, the way a photo
      // of a real page comes back.
      final image = img.Image(width: 100, height: 100);
      img.fill(image, color: img.ColorRgb8(200, 200, 200));
      img.fillRect(
        image,
        x1: 20,
        y1: 20,
        x2: 80,
        y2: 80,
        color: img.ColorRgb8(120, 120, 120),
      );
      final sourcePath = '${tempDir.path}/grey_page.png';
      File(sourcePath).writeAsBytesSync(img.encodePng(image));

      final result = processOcrImageIsolate(
        OcrEnhanceParams(
          sourcePath: sourcePath,
          targetPath: '${tempDir.path}/doc.png',
          filter: OcrEnhanceFilter.documentBw,
        ),
      );

      final decoded = img.decodeImage(
        File(result.targetPath).readAsBytesSync(),
      )!;
      final paper = decoded.getPixel(5, 5).r;
      final ink = decoded.getPixel(50, 50).r;
      // Both tones were within 80 levels of each other. They must now be far
      // apart, with paper near white and ink near black.
      expect(paper - ink, greaterThan(180));
      expect(paper, greaterThan(230));
      expect(ink, lessThan(40));
    });

    group('normalizeOcrLevels', () {
      test('stretches a narrow tone range to the full scale', () {
        final image = img.Image(width: 100, height: 100);
        img.fill(image, color: img.ColorRgb8(180, 180, 180));
        img.fillRect(
          image,
          x1: 0,
          y1: 0,
          x2: 99,
          y2: 49,
          color: img.ColorRgb8(100, 100, 100),
        );

        final result = normalizeOcrLevels(img.grayscale(image));

        expect(result.getPixel(50, 75).r, greaterThan(230));
        expect(result.getPixel(50, 25).r, lessThan(25));
      });

      test('leaves a nearly flat image untouched', () {
        final image = img.grayscale(
          img.Image(width: 50, height: 50)..clear(img.ColorRgb8(128, 128, 128)),
        );

        final result = normalizeOcrLevels(image);

        // Amplifying a blank page would turn sensor noise into fake ink.
        expect(result.getPixel(25, 25).r, closeTo(128, 2));
      });
    });

    String writeImage(String name, img.Image image) {
      final path = '${tempDir.path}/$name.png';
      File(path).writeAsBytesSync(img.encodePng(image));
      return path;
    }

    img.Image readResult(OcrEnhanceResult result) =>
        img.decodeImage(File(result.targetPath).readAsBytesSync())!;

    test('keeps a large photo far above the old 1800 px cap', () {
      final sourcePath = writeTestImage(width: 2400, height: 1800);

      final result = processOcrImageIsolate(
        OcrEnhanceParams(
          sourcePath: sourcePath,
          targetPath: '${tempDir.path}/large.png',
          generatePreview: false,
        ),
      );

      // 4.3 MP is inside the photo budget, so nothing is shrunk.
      expect(result.width, 2400);
      expect(result.height, 1800);
    });

    test('screen filter enlarges a screenshot and flips dark mode', () {
      // Dark mode: light text block on a dark ground.
      final image = img.Image(width: 300, height: 240);
      img.fill(image, color: img.ColorRgb8(30, 30, 30));
      img.fillRect(
        image,
        x1: 100,
        y1: 80,
        x2: 200,
        y2: 160,
        color: img.ColorRgb8(220, 220, 220),
      );

      final result = processOcrImageIsolate(
        OcrEnhanceParams(
          sourcePath: writeImage('dark_screen', image),
          targetPath: '${tempDir.path}/screen.png',
          filter: OcrEnhanceFilter.screen,
        ),
      );

      expect(result.width, 600);
      expect(result.height, 480);
      final decoded = readResult(result);
      // The ground is now light and the former light text is now dark.
      expect(decoded.getPixel(20, 20).r, greaterThan(200));
      expect(decoded.getPixel(300, 240).r, lessThan(60));
    });

    test('screen filter leaves a light screenshot the right way round', () {
      final image = img.Image(width: 300, height: 240);
      img.fill(image, color: img.ColorRgb8(250, 250, 250));
      img.fillRect(
        image,
        x1: 100,
        y1: 80,
        x2: 200,
        y2: 160,
        color: img.ColorRgb8(40, 40, 40),
      );

      final decoded = readResult(
        processOcrImageIsolate(
          OcrEnhanceParams(
            sourcePath: writeImage('light_screen', image),
            targetPath: '${tempDir.path}/screen_light.png',
            filter: OcrEnhanceFilter.screen,
          ),
        ),
      );

      expect(decoded.getPixel(20, 20).r, greaterThan(200));
      expect(decoded.getPixel(300, 240).r, lessThan(60));
    });

    test('adaptiveBw finds ink under a shadow', () {
      // Paper fades from bright on the left to shadowed on the right. Strokes
      // are 80 levels darker than the paper around them, so the ink on the
      // left (150) is lighter than the paper on the right (90): no single
      // threshold can split them.
      // Tall enough (240 px) that the short-crop enlargement does not apply.
      const width = 400;
      const height = 240;
      final image = img.Image(width: width, height: height);
      int paperAt(int x) => (230 - 140 * x / (width - 1)).round();
      for (final pixel in image) {
        final paper = paperAt(pixel.x);
        final isInk = pixel.x % 20 >= 9 && pixel.x % 20 <= 11;
        final value = isInk ? paper - 80 : paper;
        pixel.setRgb(value, value, value);
      }

      final decoded = readResult(
        processOcrImageIsolate(
          OcrEnhanceParams(
            sourcePath: writeImage('shadow', image),
            targetPath: '${tempDir.path}/adaptive.png',
            filter: OcrEnhanceFilter.adaptiveBw,
          ),
        ),
      );

      // Bright side: ink black, paper white.
      expect(decoded.getPixel(30, 100).r, 0);
      expect(decoded.getPixel(20, 100).r, 255);
      // Shadowed side: still ink black, paper white.
      expect(decoded.getPixel(370, 100).r, 0);
      expect(decoded.getPixel(360, 100).r, 255);
    });

    test('sharpness firms up a soft edge', () {
      final image = img.Image(width: 200, height: 300);
      for (final pixel in image) {
        final value = pixel.x < 100 ? 100 : 160;
        pixel.setRgb(value, value, value);
      }
      final sourcePath = writeImage('edge', image);

      final decoded = readResult(
        processOcrImageIsolate(
          OcrEnhanceParams(
            sourcePath: sourcePath,
            targetPath: '${tempDir.path}/sharp_edge.png',
            sharpness: 100,
          ),
        ),
      );

      // Pixels beside the edge are pushed apart; far from it nothing changes.
      expect(decoded.getPixel(99, 150).r, lessThan(100));
      expect(decoded.getPixel(100, 150).r, greaterThan(160));
      expect(decoded.getPixel(20, 150).r, 100);
    });

    group('ocrScaleFactor', () {
      test('shrinks a photo over the pixel budget', () {
        final scale = ocrScaleFactor(
          width: 4000,
          height: 3000,
          filter: OcrEnhanceFilter.documentBw,
        );
        expect(scale, lessThan(1));
        expect(4000 * 3000 * scale * scale, lessThanOrEqualTo(8000001));
      });

      test('doubles a normal phone screenshot', () {
        expect(
          ocrScaleFactor(
            width: 1080,
            height: 2400,
            filter: OcrEnhanceFilter.screen,
          ),
          2.0,
        );
      });

      test('keeps a long scrolling screenshot inside the budget', () {
        final scale = ocrScaleFactor(
          width: 1080,
          height: 9000,
          filter: OcrEnhanceFilter.screen,
        );
        expect(1080 * 9000 * scale * scale, lessThanOrEqualTo(12000001));
      });

      test('leaves a normal photo alone', () {
        expect(
          ocrScaleFactor(
            width: 1600,
            height: 1200,
            filter: OcrEnhanceFilter.original,
          ),
          1.0,
        );
      });
    });

    group('isMostlyDark', () {
      test('is true for a dark image', () {
        final image = img.Image(width: 50, height: 50)
          ..clear(img.ColorRgb8(20, 20, 20));
        expect(isMostlyDark(image), isTrue);
      });

      test('is false for a light image', () {
        final image = img.Image(width: 50, height: 50)
          ..clear(img.ColorRgb8(230, 230, 230));
        expect(isMostlyDark(image), isFalse);
      });
    });

    test('throws FileSystemException when source file is missing', () {
      expect(
        () => processOcrImageIsolate(
          OcrEnhanceParams(
            sourcePath: '${tempDir.path}/nonexistent.png',
            targetPath: '${tempDir.path}/out.png',
          ),
        ),
        throwsA(isA<FileSystemException>()),
      );
    });
  });
}
