// ignore_for_file: prefer_initializing_formals
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sreerajp_todo/application/voice_capture_state.dart';
import 'package:sreerajp_todo/core/platform/speech_channel.dart';
import 'package:sreerajp_todo/core/utils/date_utils.dart';
import 'package:sreerajp_todo/core/voice/voice_command_parser.dart';

/// Runs the voice sheet: opens the microphone, collects the words, and keeps
/// the reading of them up to date.
///
/// It talks to [SpeechChannel] and [VoiceCommandParser] only. It never touches
/// a DAO or the database, and it never saves anything: the sheet hands its
/// result to the normal create screen, which is where every rule about
/// Day-Lock, duplicate titles and NFC normalisation is already enforced.
class VoiceCaptureNotifier extends StateNotifier<VoiceCaptureState> {
  VoiceCaptureNotifier({
    required SpeechChannel channel,
    VoiceCommandParser parser = const VoiceCommandParser(),
    DateTime Function()? today,
  }) : _channel = channel,
       _parser = parser,
       _today = today ?? nowInAppDay,
       super(const VoiceCaptureState());

  final SpeechChannel _channel;
  final VoiceCommandParser _parser;

  /// Where "today" comes from. Passed in so the app day-start setting is
  /// honoured, and so tests are not tied to the wall clock.
  final DateTime Function() _today;

  StreamSubscription<SpeechEvent>? _subscription;

  /// Works out whether the microphone can be offered, before the sheet draws.
  Future<void> prepare() async {
    final reason = await _channel.check();
    if (!mounted) return;
    state = state.copyWith(unavailable: reason);
  }

  /// Replaces the words, whether they were typed or heard, and reads them.
  void setText(String text) {
    final trimmed = text.trim();
    state = state.copyWith(
      text: text,
      stage: state.stage == VoiceCaptureStage.listening
          ? VoiceCaptureStage.listening
          : (trimmed.isEmpty
                ? VoiceCaptureStage.idle
                : VoiceCaptureStage.ready),
      result: trimmed.isEmpty ? null : _parser.parse(text, today: _today()),
      error: null,
    );
  }

  /// Opens the microphone in [localeTag], asking for permission if needed.
  Future<void> startListening(String localeTag) async {
    if (state.stage == VoiceCaptureStage.listening) return;

    if (state.unavailable == SpeechUnavailableReason.missingPermission) {
      final granted = await _channel.requestPermission();
      if (!mounted) return;
      if (!granted) {
        state = state.copyWith(error: SpeechErrorCode.permissionDenied);
        return;
      }
      // Ask the host again rather than assuming: the permission may be in
      // place now, but the recogniser could still be missing.
      final reason = await _channel.check();
      if (!mounted) return;
      state = state.copyWith(unavailable: reason);
      if (reason != null) return;
    }

    if (!state.canListen) return;

    await _subscription?.cancel();
    _subscription = _channel.events.listen(_onEvent);

    state = state.copyWith(
      stage: VoiceCaptureStage.listening,
      text: '',
      result: null,
      error: null,
    );
    await _channel.start(localeTag);
  }

  /// Closes the microphone and keeps whatever was heard.
  Future<void> stopListening() async {
    if (state.stage != VoiceCaptureStage.listening) return;
    await _channel.stop();
    if (!mounted) return;
    state = state.copyWith(
      stage: state.text.trim().isEmpty
          ? VoiceCaptureStage.idle
          : VoiceCaptureStage.ready,
    );
  }

  /// Clears the sheet back to how it opened.
  void reset() {
    state = VoiceCaptureState(unavailable: state.unavailable);
  }

  void _onEvent(SpeechEvent event) {
    if (!mounted) return;
    switch (event.type) {
      case SpeechEventType.partial:
        // Partial words are shown as they arrive but not parsed yet: the
        // reading would jump about while the sentence is still changing.
        state = state.copyWith(text: event.text);
      case SpeechEventType.result:
        setText(event.text);
        state = state.copyWith(
          stage: event.text.trim().isEmpty
              ? VoiceCaptureStage.idle
              : VoiceCaptureStage.ready,
        );
      case SpeechEventType.error:
        state = state.copyWith(
          stage: state.text.trim().isEmpty
              ? VoiceCaptureStage.idle
              : VoiceCaptureStage.ready,
          error: event.error ?? SpeechErrorCode.unknown,
        );
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    // Never leave the microphone open behind a closed sheet.
    unawaited(_channel.stop());
    super.dispose();
  }
}
