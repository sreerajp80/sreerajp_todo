/// Contract for image editing operations (crop, rotate) before OCR.
///
/// Colours arrive as plain 32-bit ARGB values rather than Flutter `Color`
/// objects, so this contract stays free of the Flutter framework. The caller
/// passes `theme.colorScheme.surface.toARGB32()` and the like.
///
/// Implementations must run 100% offline on-device to respect the app's zero
/// network and privacy architecture.
abstract class ImageEditService {
  /// Opens a crop-and-rotate editor for the image at [sourcePath].
  ///
  /// [toolbarTitle] is shown in the editor's app bar. [toolbarColorArgb],
  /// [toolbarWidgetColorArgb], [activeControlColorArgb] and [isLightStatusBar]
  /// style the native editor UI to match the app's current theme.
  ///
  /// Returns the path to the edited image, or `null` if the user cancelled.
  Future<String?> cropAndRotate({
    required String sourcePath,
    required String toolbarTitle,
    required int toolbarColorArgb,
    required int toolbarWidgetColorArgb,
    required int activeControlColorArgb,
    required bool isLightStatusBar,
  });
}
