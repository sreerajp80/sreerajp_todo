import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

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
@immutable
class SpeechEvent {
  const SpeechEvent({required this.type, this.text = '', this.error});

  final SpeechEventType type;

  /// The words heard. Empty on an error.
  final String text;

  /// Set only when [type] is [SpeechEventType.error].
  final SpeechErrorCode? error;
}

/// Dart side of the on-device speech recogniser channel.
///
/// Android only, and deliberately built as a small method channel rather than
/// a package, so the audited dependency list in `docs/dependencies.md` stays
/// unchanged. Everywhere else — Windows above all — every call is a safe no-op
/// that reports [SpeechUnavailableReason.unsupported], and the voice sheet
/// falls back to typing.
///
/// **On the offline promise.** This app holds no `INTERNET` permission, so
/// nothing here can reach the network itself. The recogniser, though, is a
/// separate app on the device (usually the system speech service). The host
/// side asks it for its **on-device** engine and refuses to fall back to an
/// online one. If the device has no offline language pack, the attempt fails
/// with [SpeechErrorCode.noOfflineLanguage] rather than quietly going online,
/// and the user is told to install the pack or type instead.
class SpeechChannel {
  SpeechChannel({
    MethodChannel? methodChannel,
    EventChannel? eventChannel,
    bool? isSupported,
  }) : _method = methodChannel ?? const MethodChannel(methodChannelName),
       _events = eventChannel ?? const EventChannel(eventChannelName),
       _isSupported = isSupported ?? _defaultIsSupported();

  /// The command channel, named beside the existing app channels.
  static const String methodChannelName = 'in.sreerajp.todo/speech';

  /// The channel the host pushes heard words back over.
  static const String eventChannelName = 'in.sreerajp.todo/speech_events';

  final MethodChannel _method;
  final EventChannel _events;
  final bool _isSupported;

  static bool _defaultIsSupported() {
    if (kIsWeb) return false;
    return Platform.isAndroid;
  }

  /// True when this platform could have a recogniser at all.
  bool get isSupported => _isSupported;

  /// Checks whether listening can start, and says why not when it cannot.
  ///
  /// Returns null when everything is ready.
  Future<SpeechUnavailableReason?> check() async {
    if (!_isSupported) return SpeechUnavailableReason.unsupported;
    try {
      final result = await _method.invokeMethod<String>('check');
      return switch (result) {
        'ready' => null,
        'no_recogniser' => SpeechUnavailableReason.noRecogniser,
        'no_offline' => SpeechUnavailableReason.noOfflineEngine,
        'no_permission' => SpeechUnavailableReason.missingPermission,
        _ => SpeechUnavailableReason.unsupported,
      };
    } on PlatformException catch (e) {
      debugPrint('SpeechChannel: check failed (${e.code})');
      return SpeechUnavailableReason.unsupported;
    } on MissingPluginException {
      return SpeechUnavailableReason.unsupported;
    }
  }

  /// Asks the user for the microphone, and reports whether they agreed.
  ///
  /// Nothing is asked until the user has already turned voice input on in
  /// Settings and tapped the microphone, so the prompt never arrives unasked.
  Future<bool> requestPermission() async {
    if (!_isSupported) return false;
    try {
      return await _method.invokeMethod<bool>('requestPermission') ?? false;
    } on PlatformException catch (e) {
      debugPrint('SpeechChannel: permission request failed (${e.code})');
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  /// Starts listening in [localeTag], for example `en-IN` or `ml-IN`.
  ///
  /// Listen to [events] for what comes back. Throws nothing: a host that
  /// refuses simply sends an error event.
  Future<void> start(String localeTag) async {
    if (!_isSupported) return;
    try {
      await _method.invokeMethod<void>('start', <String, dynamic>{
        'locale': localeTag,
      });
    } on PlatformException catch (e) {
      debugPrint('SpeechChannel: start failed (${e.code})');
    } on MissingPluginException {
      debugPrint('SpeechChannel: host does not handle speech');
    }
  }

  /// Stops listening and asks for whatever was heard so far.
  Future<void> stop() async {
    if (!_isSupported) return;
    try {
      await _method.invokeMethod<void>('stop');
    } on PlatformException catch (e) {
      debugPrint('SpeechChannel: stop failed (${e.code})');
    } on MissingPluginException {
      // Nothing was listening in the first place.
    }
  }

  /// Words and errors pushed up from the recogniser.
  Stream<SpeechEvent> get events {
    if (!_isSupported) return const Stream<SpeechEvent>.empty();
    return _events.receiveBroadcastStream().map(_toEvent);
  }

  SpeechEvent _toEvent(dynamic raw) {
    if (raw is! Map) {
      return const SpeechEvent(
        type: SpeechEventType.error,
        error: SpeechErrorCode.unknown,
      );
    }
    final type = raw['type'] as String? ?? 'error';
    final text = raw['text'] as String? ?? '';
    return switch (type) {
      'partial' => SpeechEvent(type: SpeechEventType.partial, text: text),
      'result' => SpeechEvent(type: SpeechEventType.result, text: text),
      _ => SpeechEvent(
        type: SpeechEventType.error,
        error: _toErrorCode(raw['code'] as String?),
      ),
    };
  }

  SpeechErrorCode _toErrorCode(String? code) => switch (code) {
    'permission' => SpeechErrorCode.permissionDenied,
    'no_match' => SpeechErrorCode.noMatch,
    'no_offline_language' => SpeechErrorCode.noOfflineLanguage,
    'busy' => SpeechErrorCode.busy,
    _ => SpeechErrorCode.unknown,
  };
}
