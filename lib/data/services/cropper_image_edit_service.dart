import 'dart:ui';

import 'package:image_cropper/image_cropper.dart';
import 'package:sreerajp_todo/domain/services/image_edit_service.dart';
import 'package:sreerajp_todo/core/logging/app_logger.dart';

/// On-device image editing backed by [ImageCropper] (uCrop on Android).
class CropperImageEditService implements ImageEditService {
  const CropperImageEditService({this.imageCropper});

  /// Allows injection for testing. When `null`, a fresh instance is created.
  final ImageCropper? imageCropper;

  @override
  Future<String?> cropAndRotate({
    required String sourcePath,
    required String toolbarTitle,
    required int toolbarColorArgb,
    required int toolbarWidgetColorArgb,
    required int activeControlColorArgb,
    required bool isLightStatusBar,
  }) async {
    final cropper = imageCropper ?? ImageCropper();

    try {
      final croppedFile = await cropper.cropImage(
        sourcePath: sourcePath,
        // Lossless PNG, not the default JPEG at quality 90. JPEG blur eats the
        // one-pixel strokes of `.`, `=`, `,` and `:`, so the crop step must not
        // degrade the image before OCR ever sees it.
        compressFormat: ImageCompressFormat.png,
        compressQuality: 100,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: toolbarTitle,
            toolbarColor: Color(toolbarColorArgb),
            toolbarWidgetColor: Color(toolbarWidgetColorArgb),
            // statusBarLight: true = light status bar (dark icons).
            statusBarLight: isLightStatusBar,
            activeControlsWidgetColor: Color(activeControlColorArgb),
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
          ),
        ],
      );

      if (croppedFile == null) return null;
      return croppedFile.path;
    } catch (e, st) {
      AppLogger.error(
        'CropperImageEditService: crop failed',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }
}
