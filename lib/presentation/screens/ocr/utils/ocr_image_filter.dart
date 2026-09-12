import 'dart:ui';

/// Supported visual enhancement modes for optimizing OCR accuracy.
enum OcrFilterMode {
  /// Unaltered original colors.
  original,

  /// High-contrast black and white document mode.
  ///
  /// Converts to perceptual grayscale and increases contrast, turning paper
  /// background clean white and text deep black. Dramatically improves OCR
  /// accuracy on low-contrast paper, shadows, or faint pencil/ink.
  documentBw,

  /// Clean grayscale without harsh threshold clipping.
  grayscale,

  /// Brightened exposure mode.
  ///
  /// Lifts dark shadows and underexposed areas without washing out text.
  brighten,
}

/// Utility providing high-performance 4x5 color matrices for image enhancement.
class OcrImageFilter {
  OcrImageFilter._();

  /// ITU-R BT.709 luma coefficients for human perceptual brightness.
  static const double lumaR = 0.2126;
  static const double lumaG = 0.7152;
  static const double lumaB = 0.0722;

  /// Generates a customized 4x5 color matrix for combined brightness,
  /// contrast, and optional grayscale conversion.
  ///
  /// - [brightness]: additive pixel offset (e.g. -50.0 to +50.0).
  /// - [contrast]: contrast multiplier centered around 128 (e.g. 0.5 to 2.5).
  /// - [isGrayscale]: whether to reduce color channels to perceptual luma.
  static List<double> generateMatrix({
    double brightness = 0.0,
    double contrast = 1.0,
    bool isGrayscale = false,
  }) {
    final offset = 128.0 * (1.0 - contrast) + brightness;

    if (isGrayscale) {
      final r = lumaR * contrast;
      final g = lumaG * contrast;
      final b = lumaB * contrast;

      return <double>[
        r, g, b, 0, offset, // R
        r, g, b, 0, offset, // G
        r, g, b, 0, offset, // B
        0, 0, 0, 1, 0, // A
      ];
    } else {
      return <double>[
        contrast, 0, 0, 0, offset, // R
        0, contrast, 0, 0, offset, // G
        0, 0, contrast, 0, offset, // B
        0, 0, 0, 1, 0, // A
      ];
    }
  }

  /// 4x5 Matrix for high-contrast B&W document enhancement.
  static final List<double> documentBwMatrix = generateMatrix(
    brightness: 10.0,
    contrast: 1.8,
    isGrayscale: true,
  );

  /// 4x5 Matrix for natural grayscale enhancement.
  static final List<double> grayscaleMatrix = generateMatrix(
    isGrayscale: true,
  );

  /// 4x5 Matrix for brightening underexposed or shadowed captures.
  static final List<double> brightenMatrix = generateMatrix(
    brightness: 35.0,
    contrast: 1.15,
  );

  /// 4x5 Identity matrix for unmodified rendering.
  static final List<double> identityMatrix = generateMatrix();

  /// Returns the color matrix corresponding to the specified [mode].
  static List<double> matrixForMode(OcrFilterMode mode) {
    return switch (mode) {
      OcrFilterMode.original => identityMatrix,
      OcrFilterMode.documentBw => documentBwMatrix,
      OcrFilterMode.grayscale => grayscaleMatrix,
      OcrFilterMode.brighten => brightenMatrix,
    };
  }

  /// Returns a [ColorFilter] corresponding to the specified [mode], or null
  /// if [mode] is [OcrFilterMode.original].
  static ColorFilter? colorFilterForMode(OcrFilterMode mode) {
    if (mode == OcrFilterMode.original) return null;
    return ColorFilter.matrix(matrixForMode(mode));
  }
}
