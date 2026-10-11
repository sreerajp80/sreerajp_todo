import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:sreerajp_todo/domain/entities/speech_event.dart';
import 'package:sreerajp_todo/core/logging/app_logger.dart';

export 'package:sreerajp_todo/domain/entities/speech_event.dart';

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
      AppLogger.warning('SpeechChannel: check failed (${e.code})');
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
      AppLogger.warning('SpeechChannel: permission request failed (${e.code})');
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
      AppLogger.warning('SpeechChannel: start failed (${e.code})');
    } on MissingPluginException {
      AppLogger.debug('SpeechChannel: host does not handle speech');
    }
  }

  /// Stops listening and asks for whatever was heard so far.
  Future<void> stop() async {
    if (!_isSupported) return;
    try {
      await _method.invokeMethod<void>('stop');
    } on PlatformException catch (e) {
      AppLogger.warning('SpeechChannel: stop failed (${e.code})');
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
