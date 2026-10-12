// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'time_tracking_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TimeTrackingState {

 List<TimeSegmentEntity> get segments; TimeSegmentEntity? get runningSegment; int get totalDurationSeconds; bool get isLoading; String? get error;
/// Create a copy of TimeTrackingState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TimeTrackingStateCopyWith<TimeTrackingState> get copyWith => _$TimeTrackingStateCopyWithImpl<TimeTrackingState>(this as TimeTrackingState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TimeTrackingState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TimeTrackingState&&const DeepCollectionEquality().equals(other.segments, _this.segments)&&(identical(other.runningSegment, _this.runningSegment) || other.runningSegment == _this.runningSegment)&&(identical(other.totalDurationSeconds, _this.totalDurationSeconds) || other.totalDurationSeconds == _this.totalDurationSeconds)&&(identical(other.isLoading, _this.isLoading) || other.isLoading == _this.isLoading)&&(identical(other.error, _this.error) || other.error == _this.error));
}


@override
int get hashCode {
  final _this = this as TimeTrackingState;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.segments),_this.runningSegment,_this.totalDurationSeconds,_this.isLoading,_this.error);
}

@override
String toString() {
  final _this = this as TimeTrackingState;
  return 'TimeTrackingState(segments: ${_this.segments}, runningSegment: ${_this.runningSegment}, totalDurationSeconds: ${_this.totalDurationSeconds}, isLoading: ${_this.isLoading}, error: ${_this.error})';
}


}

/// @nodoc
abstract mixin class $TimeTrackingStateCopyWith<$Res>  {
  factory $TimeTrackingStateCopyWith(TimeTrackingState value, $Res Function(TimeTrackingState) _then) = _$TimeTrackingStateCopyWithImpl;
@useResult
$Res call({
 List<TimeSegmentEntity> segments, TimeSegmentEntity? runningSegment, int totalDurationSeconds, bool isLoading, String? error
});


$TimeSegmentEntityCopyWith<$Res>? get runningSegment;

}
/// @nodoc
class _$TimeTrackingStateCopyWithImpl<$Res>
    implements $TimeTrackingStateCopyWith<$Res> {
  _$TimeTrackingStateCopyWithImpl(this._self, this._then);

  final TimeTrackingState _self;
  final $Res Function(TimeTrackingState) _then;

/// Create a copy of TimeTrackingState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? segments = null,Object? runningSegment = freezed,Object? totalDurationSeconds = null,Object? isLoading = null,Object? error = freezed,}) {
  return _then(TimeTrackingState(
segments: null == segments ? _self.segments : segments // ignore: cast_nullable_to_non_nullable
as List<TimeSegmentEntity>,runningSegment: freezed == runningSegment ? _self.runningSegment : runningSegment // ignore: cast_nullable_to_non_nullable
as TimeSegmentEntity?,totalDurationSeconds: null == totalDurationSeconds ? _self.totalDurationSeconds : totalDurationSeconds // ignore: cast_nullable_to_non_nullable
as int,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of TimeTrackingState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TimeSegmentEntityCopyWith<$Res>? get runningSegment {
    if (_self.runningSegment == null) {
    return null;
  }

  return $TimeSegmentEntityCopyWith<$Res>(_self.runningSegment!, (value) {
    return _then(_self.copyWith(runningSegment: value));
  });
}
}


/// Adds pattern-matching-related methods to [TimeTrackingState].
extension TimeTrackingStatePatterns on TimeTrackingState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TimeTrackingState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TimeTrackingState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TimeTrackingState value)  $default,){
final _that = this;
switch (_that) {
case _TimeTrackingState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TimeTrackingState value)?  $default,){
final _that = this;
switch (_that) {
case _TimeTrackingState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<TimeSegmentEntity> segments,  TimeSegmentEntity? runningSegment,  int totalDurationSeconds,  bool isLoading,  String? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TimeTrackingState() when $default != null:
return $default(_that.segments,_that.runningSegment,_that.totalDurationSeconds,_that.isLoading,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<TimeSegmentEntity> segments,  TimeSegmentEntity? runningSegment,  int totalDurationSeconds,  bool isLoading,  String? error)  $default,) {final _that = this;
switch (_that) {
case _TimeTrackingState():
return $default(_that.segments,_that.runningSegment,_that.totalDurationSeconds,_that.isLoading,_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<TimeSegmentEntity> segments,  TimeSegmentEntity? runningSegment,  int totalDurationSeconds,  bool isLoading,  String? error)?  $default,) {final _that = this;
switch (_that) {
case _TimeTrackingState() when $default != null:
return $default(_that.segments,_that.runningSegment,_that.totalDurationSeconds,_that.isLoading,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _TimeTrackingState implements TimeTrackingState {
  const _TimeTrackingState({ List<TimeSegmentEntity> segments = const [], this.runningSegment, this.totalDurationSeconds = 0, this.isLoading = false, this.error}): _segments = segments;
  

 final  List<TimeSegmentEntity> _segments;
@override@JsonKey() List<TimeSegmentEntity> get segments {
  if (_segments is EqualUnmodifiableListView) return _segments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_segments);
}

@override final  TimeSegmentEntity? runningSegment;
@override@JsonKey() final  int totalDurationSeconds;
@override@JsonKey() final  bool isLoading;
@override final  String? error;

/// Create a copy of TimeTrackingState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TimeTrackingStateCopyWith<_TimeTrackingState> get copyWith => __$TimeTrackingStateCopyWithImpl<_TimeTrackingState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TimeTrackingState&&const DeepCollectionEquality().equals(other.segments, _segments)&&(identical(other.runningSegment, runningSegment) || other.runningSegment == runningSegment)&&(identical(other.totalDurationSeconds, totalDurationSeconds) || other.totalDurationSeconds == totalDurationSeconds)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_segments),runningSegment,totalDurationSeconds,isLoading,error);
}

@override
String toString() {
    return 'TimeTrackingState(segments: $segments, runningSegment: $runningSegment, totalDurationSeconds: $totalDurationSeconds, isLoading: $isLoading, error: $error)';
}


}

/// @nodoc
abstract mixin class _$TimeTrackingStateCopyWith<$Res> implements $TimeTrackingStateCopyWith<$Res> {
  factory _$TimeTrackingStateCopyWith(_TimeTrackingState value, $Res Function(_TimeTrackingState) _then) = __$TimeTrackingStateCopyWithImpl;
@override @useResult
$Res call({
 List<TimeSegmentEntity> segments, TimeSegmentEntity? runningSegment, int totalDurationSeconds, bool isLoading, String? error
});


@override $TimeSegmentEntityCopyWith<$Res>? get runningSegment;

}
/// @nodoc
class __$TimeTrackingStateCopyWithImpl<$Res>
    implements _$TimeTrackingStateCopyWith<$Res> {
  __$TimeTrackingStateCopyWithImpl(this._self, this._then);

  final _TimeTrackingState _self;
  final $Res Function(_TimeTrackingState) _then;

/// Create a copy of TimeTrackingState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? segments = null,Object? runningSegment = freezed,Object? totalDurationSeconds = null,Object? isLoading = null,Object? error = freezed,}) {
  return _then(_TimeTrackingState(
segments: null == segments ? _self._segments : segments // ignore: cast_nullable_to_non_nullable
as List<TimeSegmentEntity>,runningSegment: freezed == runningSegment ? _self.runningSegment : runningSegment // ignore: cast_nullable_to_non_nullable
as TimeSegmentEntity?,totalDurationSeconds: null == totalDurationSeconds ? _self.totalDurationSeconds : totalDurationSeconds // ignore: cast_nullable_to_non_nullable
as int,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of TimeTrackingState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TimeSegmentEntityCopyWith<$Res>? get runningSegment {
    if (_self.runningSegment == null) {
    return null;
  }

  return $TimeSegmentEntityCopyWith<$Res>(_self.runningSegment!, (value) {
    return _then(_self.copyWith(runningSegment: value));
  });
}
}

// dart format on
