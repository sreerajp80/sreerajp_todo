import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:sreerajp_todo/domain/services/image_edit_service.dart';
import 'package:sreerajp_todo/domain/services/ocr_capture_downscaler.dart';
import 'package:sreerajp_todo/domain/services/ocr_enhancer.dart';
import 'package:sreerajp_todo/domain/services/ocr_service.dart';
import 'package:sreerajp_todo/l10n/app_localizations.dart';
import 'package:sreerajp_todo/presentation/screens/ocr/ocr_enhance_screen.dart';

/// Hands back a fixed prepared path, standing in for the native downscale of a
/// full-resolution capture.
class _FakeDownscaler implements OcrCaptureDownscaler {
  _FakeDownscaler(this.preparedPath);

  final String preparedPath;

  @override
  Future<String> downscale(String imagePath) async => preparedPath;
}

/// Records every source path it is asked to enhance and writes a real file, so
/// the screen has something to show.
class _FakeEnhancer implements OcrEnhancer {
  final List<String> sourcePaths = [];
  final List<OcrEnhanceParams> params = [];

  @override
  Future<OcrEnhanceResult> enhance(OcrEnhanceParams params) async {
    sourcePaths.add(params.sourcePath);
    this.params.add(params);

    final image = img.Image(width: 20, height: 10);
    img.fill(image, color: img.ColorRgb8(255, 255, 255));
    final bytes = img.encodePng(image);
    File(params.targetPath).writeAsBytesSync(bytes);

    return OcrEnhanceResult(
      targetPath: params.targetPath,
      width: 20,
      height: 10,
      previewBytes: bytes,
    );
  }
}

/// Counts how many times recognition was asked for.
class _FakeOcrService implements OcrService {
  int callCount = 0;

  @override
  Future<String> extractTextFromImage(
    String imagePath, {
    String language = 'eng',
    int? requestId,
  }) async {
    callCount++;
    return 'hello world';
  }

  @override
  Future<void> cancelRequests(List<int> requestIds) async {}
}

/// Records the path handed to the cropper — the whole point of this test.
class _RecordingImageEditService implements ImageEditService {
  String? receivedSourcePath;
  String? resultPath;

  @override
  Future<String?> cropAndRotate({
    required String sourcePath,
    required String toolbarTitle,
    required int toolbarColorArgb,
    required int toolbarWidgetColorArgb,
    required int activeControlColorArgb,
    required bool isLightStatusBar,
  }) async {
    receivedSourcePath = sourcePath;
    return resultPath;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  const pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('ocr_enhance_test');
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

  String writeCapture(String name) {
    final image = img.Image(width: 40, height: 20);
    img.fill(image, color: img.ColorRgb8(255, 255, 255));
    final path = '${tempDir.path}/$name.jpg';
    File(path).writeAsBytesSync(img.encodeJpg(image));
    return path;
  }

  String writeScreenshot(String name) {
    final image = img.Image(width: 40, height: 20);
    img.fill(image, color: img.ColorRgb8(255, 255, 255));
    final path = '${tempDir.path}/$name.png';
    File(path).writeAsBytesSync(img.encodePng(image));
    return path;
  }

  Future<void> pumpScreen(
    WidgetTester tester, {
    required String capturePath,
    required String masterPath,
    required OcrEnhancer enhancer,
    required ImageEditService editService,
    OcrService? ocrService,
  }) async {
    // A roomy surface. Widget tests draw text in a fixed-width placeholder
    // font, so every button label measures far wider than it does on a device
    // and the tool bars report an overflow that does not exist in the app.
    // Give the test window enough room that the overflow cannot fire and mask
    // what is actually being checked.
    tester.view.physicalSize = const Size(3200, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: OcrEnhanceScreen(
            imagePath: capturePath,
            ocrService: ocrService ?? _FakeOcrService(),
            ocrEnhancer: enhancer,
            imageEditService: editService,
            captureDownscaler: _FakeDownscaler(masterPath),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('crops the master image, not the filtered output', (
    tester,
  ) async {
    final capturePath = writeCapture('capture');
    final masterPath = writeCapture('master');
    final enhancer = _FakeEnhancer();
    final editService = _RecordingImageEditService();

    await pumpScreen(
      tester,
      capturePath: capturePath,
      masterPath: masterPath,
      enhancer: enhancer,
      editService: editService,
    );

    // The first enhancement has run, so an enhanced output now exists. That is
    // the file the old code would have handed to the cropper.
    expect(enhancer.sourcePaths, isNotEmpty);
    final enhancedOutput = enhancer.sourcePaths.length;
    expect(enhancedOutput, greaterThan(0));

    await tester.tap(find.byKey(const Key('ocr-crop-btn')));
    await tester.pumpAndSettle();

    // Cropping the enhanced copy would bake grayscale and contrast into the
    // source, so the next adjustment would apply them a second time and erode
    // the thin strokes OCR depends on.
    expect(editService.receivedSourcePath, masterPath);
  });

  testWidgets('a crop result becomes the new master for later enhancement', (
    tester,
  ) async {
    final capturePath = writeCapture('capture');
    final masterPath = writeCapture('master');
    final croppedPath = writeCapture('cropped');
    final enhancer = _FakeEnhancer();
    final editService = _RecordingImageEditService()..resultPath = croppedPath;

    await pumpScreen(
      tester,
      capturePath: capturePath,
      masterPath: masterPath,
      enhancer: enhancer,
      editService: editService,
    );

    await tester.tap(find.byKey(const Key('ocr-crop-btn')));
    await tester.pumpAndSettle();

    // Everything after the crop works from the cropped master.
    expect(enhancer.sourcePaths.last, croppedPath);
  });

  testWidgets('enhancement always reads the master, never its own output', (
    tester,
  ) async {
    final capturePath = writeCapture('capture');
    final masterPath = writeCapture('master');
    final enhancer = _FakeEnhancer();
    final editService = _RecordingImageEditService();

    await pumpScreen(
      tester,
      capturePath: capturePath,
      masterPath: masterPath,
      enhancer: enhancer,
      editService: editService,
    );

    await tester.tap(find.byKey(const Key('ocr-rotate-right-btn')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('ocr-rotate-right-btn')));
    await tester.pumpAndSettle();

    // Rotating twice must not stack filters: every run starts from the master.
    expect(enhancer.sourcePaths.length, greaterThanOrEqualTo(3));
    expect(enhancer.sourcePaths.toSet(), {masterPath});
  });
  ButtonStyleButton useTextButton(WidgetTester tester) =>
      tester.widget<ButtonStyleButton>(
        find.byKey(const Key('ocr-enhance-use-text-btn')),
      );

  testWidgets('does not read text on open or after edits', (tester) async {
    final ocr = _FakeOcrService();

    await pumpScreen(
      tester,
      capturePath: writeCapture('capture'),
      masterPath: writeCapture('master'),
      enhancer: _FakeEnhancer(),
      editService: _RecordingImageEditService(),
      ocrService: ocr,
    );

    await tester.tap(find.byKey(const Key('ocr-rotate-right-btn')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('ocr-invert-btn')));
    await tester.pumpAndSettle();

    expect(ocr.callCount, 0);
    expect(useTextButton(tester).onPressed, isNull);
  });

  testWidgets('extract button reads the text and enables Use Text', (
    tester,
  ) async {
    final ocr = _FakeOcrService();

    await pumpScreen(
      tester,
      capturePath: writeCapture('capture'),
      masterPath: writeCapture('master'),
      enhancer: _FakeEnhancer(),
      editService: _RecordingImageEditService(),
      ocrService: ocr,
    );

    final extractButton = tester.widget<IconButton>(
      find.byKey(const Key('ocr-enhance-extract-btn')),
    );
    expect(extractButton.tooltip, isNotEmpty);

    await tester.tap(find.byKey(const Key('ocr-enhance-extract-btn')));
    await tester.pumpAndSettle();

    expect(ocr.callCount, 1);
    expect(find.byKey(const Key('ocr-live-text-content')), findsOneWidget);
    expect(useTextButton(tester).onPressed, isNotNull);
  });

  testWidgets('an edit after extracting clears the text', (tester) async {
    final ocr = _FakeOcrService();

    await pumpScreen(
      tester,
      capturePath: writeCapture('capture'),
      masterPath: writeCapture('master'),
      enhancer: _FakeEnhancer(),
      editService: _RecordingImageEditService(),
      ocrService: ocr,
    );

    await tester.tap(find.byKey(const Key('ocr-enhance-extract-btn')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('ocr-live-text-content')), findsOneWidget);

    await tester.tap(find.byKey(const Key('ocr-rotate-left-btn')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('ocr-live-text-content')), findsNothing);
    expect(useTextButton(tester).onPressed, isNull);
    expect(ocr.callCount, 1);
  });

  testWidgets('a PNG screenshot starts on the Screenshot filter', (
    tester,
  ) async {
    final enhancer = _FakeEnhancer();

    await pumpScreen(
      tester,
      capturePath: writeScreenshot('screenshot'),
      masterPath: writeCapture('master'),
      enhancer: enhancer,
      editService: _RecordingImageEditService(),
    );

    expect(enhancer.params.first.filter, OcrEnhanceFilter.screen);
  });

  testWidgets('a JPEG camera capture starts on the Original filter', (
    tester,
  ) async {
    final enhancer = _FakeEnhancer();

    await pumpScreen(
      tester,
      capturePath: writeCapture('capture'),
      masterPath: writeCapture('master'),
      enhancer: enhancer,
      editService: _RecordingImageEditService(),
    );

    expect(enhancer.params.first.filter, OcrEnhanceFilter.original);
  });

  testWidgets('the new filter chips pass their filter to the enhancer', (
    tester,
  ) async {
    final enhancer = _FakeEnhancer();

    await pumpScreen(
      tester,
      capturePath: writeCapture('capture'),
      masterPath: writeCapture('master'),
      enhancer: enhancer,
      editService: _RecordingImageEditService(),
    );

    await tester.tap(find.byKey(const Key('ocr-filter-tab-btn')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('ocr-filter-adaptive-chip')));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    expect(enhancer.params.last.filter, OcrEnhanceFilter.adaptiveBw);

    await tester.tap(find.byKey(const Key('ocr-filter-screen-chip')));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    expect(enhancer.params.last.filter, OcrEnhanceFilter.screen);
  });

  testWidgets('the sharpness slider is passed on and reset clears it', (
    tester,
  ) async {
    final enhancer = _FakeEnhancer();

    await pumpScreen(
      tester,
      capturePath: writeCapture('capture'),
      masterPath: writeCapture('master'),
      enhancer: enhancer,
      editService: _RecordingImageEditService(),
    );

    await tester.tap(find.byKey(const Key('ocr-adjust-tab-btn')));
    await tester.pumpAndSettle();

    final slider = tester.widget<Slider>(
      find.byKey(const Key('ocr-sharpness-slider')),
    );
    expect(slider.min, 0);
    slider.onChanged!(60);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    expect(enhancer.params.last.sharpness, 60);

    await tester.tap(find.byKey(const Key('ocr-adjust-reset-btn')));
    await tester.pumpAndSettle();
    expect(enhancer.params.last.sharpness, 0);
  });
}
