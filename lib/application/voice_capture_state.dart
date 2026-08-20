import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sreerajp_todo/core/platform/speech_channel.dart';
import 'package:sreerajp_todo/core/voice/voice_parse_result.dart';

part 'voice_capture_state.freezed.dart';

/// Where the voice sheet is in its short life.
enum VoiceCaptureStage {
  /// Waiting for the user to speak or type.
  idle,

  /// The microphone is open.
  listening,

  /// Words are in, and [VoiceCaptureState.result] holds what they mean.
  ready,
}

/// Everything the voice sheet needs to draw itself.
@freezed
class VoiceCaptureState with _$VoiceCaptureState {
  const factory VoiceCaptureState({
    @Default(VoiceCaptureStage.idle) VoiceCaptureStage stage,

    /// The words heard or typed so far.
    @Default('') String text,

    /// What those words were understood to mean. Null while the box is empty.
    VoiceParseResult? result,

    /// Why listening failed, if it did.
    SpeechErrorCode? error,

    /// Why the microphone cannot be used, if it cannot.
    ///
    /// Set once when the sheet opens. It is never an error on its own: the
    /// sheet simply shows its text box instead of its microphone.
    SpeechUnavailableReason? unavailable,
  }) = _VoiceCaptureState;

  const VoiceCaptureState._();

  /// True when the microphone can be offered at all.
  bool get canListen => unavailable == null;

  /// True when there is something worth creating a task from.
  bool get canCreate => (result?.title.trim().isNotEmpty) ?? false;
}
