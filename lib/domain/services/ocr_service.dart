/// Contract for optical character recognition (OCR) text extraction.
///
/// Implementations must run 100% offline on-device to respect the app's zero
/// network and privacy architecture.
abstract class OcrService {
  /// Extracts plain text from the image located at [imagePath].
  ///
  /// The [language] can be `'eng+mal'` (bilingual, default), `'mal'`
  /// (Malayalam), or `'eng'` (English).
  ///
  /// Returns an empty string if no text was found.
  ///
  /// [requestId] labels the call so it can later be dropped with
  /// [cancelRequests]. Callers that never cancel can leave it out.
  Future<String> extractTextFromImage(
    String imagePath, {
    String language = 'eng+mal',
    int? requestId,
  });

  /// Asks the platform to drop recognition work started with these ids.
  ///
  /// Recognition runs one job at a time, so a request can still be waiting in
  /// the queue after the screen that asked for it has closed. Cancelling frees
  /// the processor for whatever the user is doing now.
  Future<void> cancelRequests(List<int> requestIds) async {}
}
