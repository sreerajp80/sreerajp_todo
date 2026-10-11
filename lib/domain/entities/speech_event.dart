/// Pure-Dart types shared by the speech channel (data layer) and the
/// voice sheet (presentation layer).
library;

/// Why the microphone cannot be used right now.
enum SpeechUnavailableReason {
  /// This platform has no recogniser at all. Windows, for one.
  unsupported,

  /// The device has no speech recogniser app installed.
  noRecogniser,

  /// A recogniser exists, but this device cannot promise to keep it offline.
  ///
  /// Either the Android version is too old to ask for an offline engine, or
  /// the recogniser reports that it has no on-device engine at all. Listening
  /// is refused rather than risking a sentence being sent to a server.
  noOfflineEngine,

  /// The user has not granted the microphone permission yet.
  missingPermission,
}

/// What the host reported back while listening.
enum SpeechEventType {
  /// Words heard so far. More may still change.
  partial,

  /// The finished sentence. Listening has stopped.
  result,

  /// Listening stopped without a sentence.
  error,
}

/// Why listening failed, in terms the user interface can explain.
enum SpeechErrorCode {
  /// The microphone permission was refused.
  permissionDenied,

  /// Nothing recognisable was heard.
  noMatch,

  /// The recogniser has no offline language pack for the chosen language.
  ///
  /// This is the one that matters most here: it is also what a recogniser
  /// reports when it wanted to reach the internet and was not allowed to.
  noOfflineLanguage,

  /// The recogniser is already busy, usually with our own earlier request.
  busy,

  /// Anything else the host could not classify.
  unknown,
}

/// One message from the host while listening.
class SpeechEvent {
  const SpeechEvent({required this.type, this.text = '', this.error});

  final SpeechEventType type;

  /// The words heard. Empty on an error.
  final String text;

  /// Set only when [type] is [SpeechEventType.error].
  final SpeechErrorCode? error;
}
