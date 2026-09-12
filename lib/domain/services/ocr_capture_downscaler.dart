/// The longest edge a working copy of a captured photo may have.
///
/// The camera captures at full sensor resolution, which on a modern phone is
/// 50 MP or more. Decoding that in Dart costs roughly 200 MB per copy, and the
/// enhance pipeline makes several copies, so the full-size image can never be
/// handed to the `image` package directly.
///
/// 4000 px on the long edge puts a full A4 page at about 340 dpi, comfortably
/// above the 300 dpi that text recognition wants, at about 48 MB per copy.
/// Shrinking a 50 MP capture to this size also averages several sensor pixels
/// into each output pixel, which removes noise — the result is sharper than
/// capturing at this size in the first place.
const int kOcrCaptureMaxLongEdge = 4000;

/// Prepares a full-resolution camera capture for the Dart image pipeline.
///
/// Implementations must run fully offline on-device.
abstract class OcrCaptureDownscaler {
  /// Returns the path of a working copy of [imagePath] whose longest edge is at
  /// most [kOcrCaptureMaxLongEdge], with any EXIF orientation already applied.
  ///
  /// Returns [imagePath] unchanged when the photo is already small enough, or
  /// when preparation fails. Callers must not assume the result is a new file,
  /// and must not delete it without first checking it differs from the source.
  Future<String> downscale(String imagePath);
}
