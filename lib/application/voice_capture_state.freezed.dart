// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'voice_capture_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$VoiceCaptureState {
  VoiceCaptureStage get stage => throw _privateConstructorUsedError;

  /// The words heard or typed so far.
  String get text => throw _privateConstructorUsedError;

  /// What those words were understood to mean. Null while the box is empty.
  VoiceParseResult? get result => throw _privateConstructorUsedError;

  /// Why listening failed, if it did.
  SpeechErrorCode? get error => throw _privateConstructorUsedError;

  /// Why the microphone cannot be used, if it cannot.
  ///
  /// Set once when the sheet opens. It is never an error on its own: the
  /// sheet simply shows its text box instead of its microphone.
  SpeechUnavailableReason? get unavailable =>
      throw _privateConstructorUsedError;

  /// Create a copy of VoiceCaptureState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VoiceCaptureStateCopyWith<VoiceCaptureState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VoiceCaptureStateCopyWith<$Res> {
  factory $VoiceCaptureStateCopyWith(
    VoiceCaptureState value,
    $Res Function(VoiceCaptureState) then,
  ) = _$VoiceCaptureStateCopyWithImpl<$Res, VoiceCaptureState>;
  @useResult
  $Res call({
    VoiceCaptureStage stage,
    String text,
    VoiceParseResult? result,
    SpeechErrorCode? error,
    SpeechUnavailableReason? unavailable,
  });
}

/// @nodoc
class _$VoiceCaptureStateCopyWithImpl<$Res, $Val extends VoiceCaptureState>
    implements $VoiceCaptureStateCopyWith<$Res> {
  _$VoiceCaptureStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VoiceCaptureState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? stage = null,
    Object? text = null,
    Object? result = freezed,
    Object? error = freezed,
    Object? unavailable = freezed,
  }) {
    return _then(
      _value.copyWith(
            stage: null == stage
                ? _value.stage
                : stage // ignore: cast_nullable_to_non_nullable
                      as VoiceCaptureStage,
            text: null == text
                ? _value.text
                : text // ignore: cast_nullable_to_non_nullable
                      as String,
            result: freezed == result
                ? _value.result
                : result // ignore: cast_nullable_to_non_nullable
                      as VoiceParseResult?,
            error: freezed == error
                ? _value.error
                : error // ignore: cast_nullable_to_non_nullable
                      as SpeechErrorCode?,
            unavailable: freezed == unavailable
                ? _value.unavailable
                : unavailable // ignore: cast_nullable_to_non_nullable
                      as SpeechUnavailableReason?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$VoiceCaptureStateImplCopyWith<$Res>
    implements $VoiceCaptureStateCopyWith<$Res> {
  factory _$$VoiceCaptureStateImplCopyWith(
    _$VoiceCaptureStateImpl value,
    $Res Function(_$VoiceCaptureStateImpl) then,
  ) = __$$VoiceCaptureStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    VoiceCaptureStage stage,
    String text,
    VoiceParseResult? result,
    SpeechErrorCode? error,
    SpeechUnavailableReason? unavailable,
  });
}

/// @nodoc
class __$$VoiceCaptureStateImplCopyWithImpl<$Res>
    extends _$VoiceCaptureStateCopyWithImpl<$Res, _$VoiceCaptureStateImpl>
    implements _$$VoiceCaptureStateImplCopyWith<$Res> {
  __$$VoiceCaptureStateImplCopyWithImpl(
    _$VoiceCaptureStateImpl _value,
    $Res Function(_$VoiceCaptureStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VoiceCaptureState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? stage = null,
    Object? text = null,
    Object? result = freezed,
    Object? error = freezed,
    Object? unavailable = freezed,
  }) {
    return _then(
      _$VoiceCaptureStateImpl(
        stage: null == stage
            ? _value.stage
            : stage // ignore: cast_nullable_to_non_nullable
                  as VoiceCaptureStage,
        text: null == text
            ? _value.text
            : text // ignore: cast_nullable_to_non_nullable
                  as String,
        result: freezed == result
            ? _value.result
            : result // ignore: cast_nullable_to_non_nullable
                  as VoiceParseResult?,
        error: freezed == error
            ? _value.error
            : error // ignore: cast_nullable_to_non_nullable
                  as SpeechErrorCode?,
        unavailable: freezed == unavailable
            ? _value.unavailable
            : unavailable // ignore: cast_nullable_to_non_nullable
                  as SpeechUnavailableReason?,
      ),
    );
  }
}

/// @nodoc

class _$VoiceCaptureStateImpl extends _VoiceCaptureState {
  const _$VoiceCaptureStateImpl({
    this.stage = VoiceCaptureStage.idle,
    this.text = '',
    this.result,
    this.error,
    this.unavailable,
  }) : super._();

  @override
  @JsonKey()
  final VoiceCaptureStage stage;

  /// The words heard or typed so far.
  @override
  @JsonKey()
  final String text;

  /// What those words were understood to mean. Null while the box is empty.
  @override
  final VoiceParseResult? result;

  /// Why listening failed, if it did.
  @override
  final SpeechErrorCode? error;

  /// Why the microphone cannot be used, if it cannot.
  ///
  /// Set once when the sheet opens. It is never an error on its own: the
  /// sheet simply shows its text box instead of its microphone.
  @override
  final SpeechUnavailableReason? unavailable;

  @override
  String toString() {
    return 'VoiceCaptureState(stage: $stage, text: $text, result: $result, error: $error, unavailable: $unavailable)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VoiceCaptureStateImpl &&
            (identical(other.stage, stage) || other.stage == stage) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.result, result) || other.result == result) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.unavailable, unavailable) ||
                other.unavailable == unavailable));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, stage, text, result, error, unavailable);

  /// Create a copy of VoiceCaptureState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VoiceCaptureStateImplCopyWith<_$VoiceCaptureStateImpl> get copyWith =>
      __$$VoiceCaptureStateImplCopyWithImpl<_$VoiceCaptureStateImpl>(
        this,
        _$identity,
      );
}

abstract class _VoiceCaptureState extends VoiceCaptureState {
  const factory _VoiceCaptureState({
    final VoiceCaptureStage stage,
    final String text,
    final VoiceParseResult? result,
    final SpeechErrorCode? error,
    final SpeechUnavailableReason? unavailable,
  }) = _$VoiceCaptureStateImpl;
  const _VoiceCaptureState._() : super._();

  @override
  VoiceCaptureStage get stage;

  /// The words heard or typed so far.
  @override
  String get text;

  /// What those words were understood to mean. Null while the box is empty.
  @override
  VoiceParseResult? get result;

  /// Why listening failed, if it did.
  @override
  SpeechErrorCode? get error;

  /// Why the microphone cannot be used, if it cannot.
  ///
  /// Set once when the sheet opens. It is never an error on its own: the
  /// sheet simply shows its text box instead of its microphone.
  @override
  SpeechUnavailableReason? get unavailable;

  /// Create a copy of VoiceCaptureState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VoiceCaptureStateImplCopyWith<_$VoiceCaptureStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
