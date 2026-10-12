// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'voice_capture_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$VoiceCaptureState {

 VoiceCaptureStage get stage;/// The words heard or typed so far.
 String get text;/// What those words were understood to mean. Null while the box is empty.
 VoiceParseResult? get result;/// Why listening failed, if it did.
 SpeechErrorCode? get error;/// Why the microphone cannot be used, if it cannot.
///
/// Set once when the sheet opens. It is never an error on its own: the
/// sheet simply shows its text box instead of its microphone.
 SpeechUnavailableReason? get unavailable;
/// Create a copy of VoiceCaptureState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VoiceCaptureStateCopyWith<VoiceCaptureState> get copyWith => _$VoiceCaptureStateCopyWithImpl<VoiceCaptureState>(this as VoiceCaptureState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as VoiceCaptureState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VoiceCaptureState&&(identical(other.stage, _this.stage) || other.stage == _this.stage)&&(identical(other.text, _this.text) || other.text == _this.text)&&(identical(other.result, _this.result) || other.result == _this.result)&&(identical(other.error, _this.error) || other.error == _this.error)&&(identical(other.unavailable, _this.unavailable) || other.unavailable == _this.unavailable));
}


@override
int get hashCode {
  final _this = this as VoiceCaptureState;
  return Object.hash(runtimeType,_this.stage,_this.text,_this.result,_this.error,_this.unavailable);
}

@override
String toString() {
  final _this = this as VoiceCaptureState;
  return 'VoiceCaptureState(stage: ${_this.stage}, text: ${_this.text}, result: ${_this.result}, error: ${_this.error}, unavailable: ${_this.unavailable})';
}


}

/// @nodoc
abstract mixin class $VoiceCaptureStateCopyWith<$Res>  {
  factory $VoiceCaptureStateCopyWith(VoiceCaptureState value, $Res Function(VoiceCaptureState) _then) = _$VoiceCaptureStateCopyWithImpl;
@useResult
$Res call({
 VoiceCaptureStage stage, String text, VoiceParseResult? result, SpeechErrorCode? error, SpeechUnavailableReason? unavailable
});




}
/// @nodoc
class _$VoiceCaptureStateCopyWithImpl<$Res>
    implements $VoiceCaptureStateCopyWith<$Res> {
  _$VoiceCaptureStateCopyWithImpl(this._self, this._then);

  final VoiceCaptureState _self;
  final $Res Function(VoiceCaptureState) _then;

/// Create a copy of VoiceCaptureState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? stage = null,Object? text = null,Object? result = freezed,Object? error = freezed,Object? unavailable = freezed,}) {
  return _then(VoiceCaptureState(
stage: null == stage ? _self.stage : stage // ignore: cast_nullable_to_non_nullable
as VoiceCaptureStage,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,result: freezed == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as VoiceParseResult?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as SpeechErrorCode?,unavailable: freezed == unavailable ? _self.unavailable : unavailable // ignore: cast_nullable_to_non_nullable
as SpeechUnavailableReason?,
  ));
}

}


/// Adds pattern-matching-related methods to [VoiceCaptureState].
extension VoiceCaptureStatePatterns on VoiceCaptureState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VoiceCaptureState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VoiceCaptureState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VoiceCaptureState value)  $default,){
final _that = this;
switch (_that) {
case _VoiceCaptureState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VoiceCaptureState value)?  $default,){
final _that = this;
switch (_that) {
case _VoiceCaptureState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( VoiceCaptureStage stage,  String text,  VoiceParseResult? result,  SpeechErrorCode? error,  SpeechUnavailableReason? unavailable)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VoiceCaptureState() when $default != null:
return $default(_that.stage,_that.text,_that.result,_that.error,_that.unavailable);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( VoiceCaptureStage stage,  String text,  VoiceParseResult? result,  SpeechErrorCode? error,  SpeechUnavailableReason? unavailable)  $default,) {final _that = this;
switch (_that) {
case _VoiceCaptureState():
return $default(_that.stage,_that.text,_that.result,_that.error,_that.unavailable);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( VoiceCaptureStage stage,  String text,  VoiceParseResult? result,  SpeechErrorCode? error,  SpeechUnavailableReason? unavailable)?  $default,) {final _that = this;
switch (_that) {
case _VoiceCaptureState() when $default != null:
return $default(_that.stage,_that.text,_that.result,_that.error,_that.unavailable);case _:
  return null;

}
}

}

/// @nodoc


class _VoiceCaptureState extends VoiceCaptureState {
  const _VoiceCaptureState({this.stage = VoiceCaptureStage.idle, this.text = '', this.result, this.error, this.unavailable}): super._();
  

@override@JsonKey() final  VoiceCaptureStage stage;
/// The words heard or typed so far.
@override@JsonKey() final  String text;
/// What those words were understood to mean. Null while the box is empty.
@override final  VoiceParseResult? result;
/// Why listening failed, if it did.
@override final  SpeechErrorCode? error;
/// Why the microphone cannot be used, if it cannot.
///
/// Set once when the sheet opens. It is never an error on its own: the
/// sheet simply shows its text box instead of its microphone.
@override final  SpeechUnavailableReason? unavailable;

/// Create a copy of VoiceCaptureState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VoiceCaptureStateCopyWith<_VoiceCaptureState> get copyWith => __$VoiceCaptureStateCopyWithImpl<_VoiceCaptureState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _VoiceCaptureState&&(identical(other.stage, stage) || other.stage == stage)&&(identical(other.text, text) || other.text == text)&&(identical(other.result, result) || other.result == result)&&(identical(other.error, error) || other.error == error)&&(identical(other.unavailable, unavailable) || other.unavailable == unavailable));
}


@override
int get hashCode {
    return Object.hash(runtimeType,stage,text,result,error,unavailable);
}

@override
String toString() {
    return 'VoiceCaptureState(stage: $stage, text: $text, result: $result, error: $error, unavailable: $unavailable)';
}


}

/// @nodoc
abstract mixin class _$VoiceCaptureStateCopyWith<$Res> implements $VoiceCaptureStateCopyWith<$Res> {
  factory _$VoiceCaptureStateCopyWith(_VoiceCaptureState value, $Res Function(_VoiceCaptureState) _then) = __$VoiceCaptureStateCopyWithImpl;
@override @useResult
$Res call({
 VoiceCaptureStage stage, String text, VoiceParseResult? result, SpeechErrorCode? error, SpeechUnavailableReason? unavailable
});




}
/// @nodoc
class __$VoiceCaptureStateCopyWithImpl<$Res>
    implements _$VoiceCaptureStateCopyWith<$Res> {
  __$VoiceCaptureStateCopyWithImpl(this._self, this._then);

  final _VoiceCaptureState _self;
  final $Res Function(_VoiceCaptureState) _then;

/// Create a copy of VoiceCaptureState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? stage = null,Object? text = null,Object? result = freezed,Object? error = freezed,Object? unavailable = freezed,}) {
  return _then(_VoiceCaptureState(
stage: null == stage ? _self.stage : stage // ignore: cast_nullable_to_non_nullable
as VoiceCaptureStage,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,result: freezed == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as VoiceParseResult?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as SpeechErrorCode?,unavailable: freezed == unavailable ? _self.unavailable : unavailable // ignore: cast_nullable_to_non_nullable
as SpeechUnavailableReason?,
  ));
}


}

// dart format on
