import 'dart:typed_data';

/// Available document filter presets for image enhancement.
enum OcrEnhanceFilter {
  /// Unmodified original colors.
  original,

  /// High-contrast document mode that separates ink from paper background.
  documentBw,

  /// Clean monochrome grayscale.
  grayscale,

  /// Enhanced contrast and clarity for faint or washed-out documents.
  enhance,

  /// Tuned for screen captures: grayscale, dark mode flipped to dark text on
  /// light, and the image enlarged so small UI text is tall enough to read.
  screen,

  /// Local black-and-white threshold for photos with shadows or uneven light.
  /// Each pixel is judged against its own surroundings, not the whole page.
  adaptiveBw,
}

/// Parameters for document image enhancement.
class OcrEnhanceParams {
  const OcrEnhanceParams({
    required this.sourcePath,
    required this.targetPath,
    this.rotationAngle = 0,
    this.brightness = 0,
    this.contrast = 0,
    this.filter = OcrEnhanceFilter.original,
    this.invert = false,
    this.sharpness = 0,
    this.generatePreview = true,
    this.previewMaxDimension = 1200,
  });

  /// Path to the source image file.
  final String sourcePath;

  /// Path where the lossless full-resolution processed image will be written.
  final String targetPath;

  /// Rotation in degrees (0, 90, 180, 270).
  final int rotationAngle;

  /// Brightness adjustment from -100 to 100 (0 = default).
  final int brightness;

  /// Contrast adjustment from -100 to 100 (0 = default).
  final int contrast;

  /// Active filter preset.
  final OcrEnhanceFilter filter;

  /// Whether to flip the image's light and dark values.
  ///
  /// Text recognition reads dark ink on light paper. Light lettering on a dark
  /// ground — a masthead, a titled banner, a slide — is treated as background
  /// and dropped. Inverting such an image is what makes that text readable.
  final bool invert;

  /// Extra sharpening from 0 to 100 (0 = none). Firms up soft letter edges
  /// from a slightly blurred photo or anti-aliased screen text.
  final int sharpness;

  /// Whether to generate fast preview thumbnail bytes for the UI.
  final bool generatePreview;

  /// Maximum edge dimension for the preview thumbnail.
  final int previewMaxDimension;

  OcrEnhanceParams copyWith({
    String? sourcePath,
    String? targetPath,
    int? rotationAngle,
    int? brightness,
    int? contrast,
    OcrEnhanceFilter? filter,
    bool? invert,
    int? sharpness,
    bool? generatePreview,
    int? previewMaxDimension,
  }) {
    return OcrEnhanceParams(
      sourcePath: sourcePath ?? this.sourcePath,
      targetPath: targetPath ?? this.targetPath,
      rotationAngle: rotationAngle ?? this.rotationAngle,
      brightness: brightness ?? this.brightness,
      contrast: contrast ?? this.contrast,
      filter: filter ?? this.filter,
      invert: invert ?? this.invert,
      sharpness: sharpness ?? this.sharpness,
      generatePreview: generatePreview ?? this.generatePreview,
      previewMaxDimension: previewMaxDimension ?? this.previewMaxDimension,
    );
  }
}

/// Result of document image enhancement.
class OcrEnhanceResult {
  const OcrEnhanceResult({
    required this.targetPath,
    required this.width,
    required this.height,
    this.previewBytes,
  });

  /// Path to the full-resolution lossless PNG file on disk.
  final String targetPath;

  /// Width of the processed image in pixels.
  final int width;

  /// Height of the processed image in pixels.
  final int height;

  /// Fast display preview bytes (PNG encoded).
  final Uint8List? previewBytes;
}

/// Contract for rotating, filtering and adjusting a document photo before OCR.
///
/// Implementations must run 100% offline on-device to respect the app's zero
/// network and privacy architecture.
abstract class OcrEnhancer {
  /// Applies [params] to the source image and writes a lossless PNG.
  Future<OcrEnhanceResult> enhance(OcrEnhanceParams params);
}
