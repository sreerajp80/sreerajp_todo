// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'time_tracking_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$TimeTrackingState {
  List<TimeSegmentEntity> get segments => throw _privateConstructorUsedError;
  TimeSegmentEntity? get runningSegment => throw _privateConstructorUsedError;
  int get totalDurationSeconds => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;

  /// Create a copy of TimeTrackingState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TimeTrackingStateCopyWith<TimeTrackingState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TimeTrackingStateCopyWith<$Res> {
  factory $TimeTrackingStateCopyWith(
    TimeTrackingState value,
    $Res Function(TimeTrackingState) then,
  ) = _$TimeTrackingStateCopyWithImpl<$Res, TimeTrackingState>;
  @useResult
  $Res call({
    List<TimeSegmentEntity> segments,
    TimeSegmentEntity? runningSegment,
    int totalDurationSeconds,
    bool isLoading,
    String? error,
  });

  $TimeSegmentEntityCopyWith<$Res>? get runningSegment;
}

/// @nodoc
class _$TimeTrackingStateCopyWithImpl<$Res, $Val extends TimeTrackingState>
    implements $TimeTrackingStateCopyWith<$Res> {
  _$TimeTrackingStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TimeTrackingState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? segments = null,
    Object? runningSegment = freezed,
    Object? totalDurationSeconds = null,
    Object? isLoading = null,
    Object? error = freezed,
  }) {
    return _then(
      _value.copyWith(
            segments: null == segments
                ? _value.segments
                : segments // ignore: cast_nullable_to_non_nullable
                      as List<TimeSegmentEntity>,
            runningSegment: freezed == runningSegment
                ? _value.runningSegment
                : runningSegment // ignore: cast_nullable_to_non_nullable
                      as TimeSegmentEntity?,
            totalDurationSeconds: null == totalDurationSeconds
                ? _value.totalDurationSeconds
                : totalDurationSeconds // ignore: cast_nullable_to_non_nullable
                      as int,
            isLoading: null == isLoading
                ? _value.isLoading
                : isLoading // ignore: cast_nullable_to_non_nullable
                      as bool,
            error: freezed == error
                ? _value.error
                : error // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }

  /// Create a copy of TimeTrackingState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TimeSegmentEntityCopyWith<$Res>? get runningSegment {
    if (_value.runningSegment == null) {
      return null;
    }

    return $TimeSegmentEntityCopyWith<$Res>(_value.runningSegment!, (value) {
      return _then(_value.copyWith(runningSegment: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$TimeTrackingStateImplCopyWith<$Res>
    implements $TimeTrackingStateCopyWith<$Res> {
  factory _$$TimeTrackingStateImplCopyWith(
    _$TimeTrackingStateImpl value,
    $Res Function(_$TimeTrackingStateImpl) then,
  ) = __$$TimeTrackingStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<TimeSegmentEntity> segments,
    TimeSegmentEntity? runningSegment,
    int totalDurationSeconds,
    bool isLoading,
    String? error,
  });

  @override
  $TimeSegmentEntityCopyWith<$Res>? get runningSegment;
}

/// @nodoc
class __$$TimeTrackingStateImplCopyWithImpl<$Res>
    extends _$TimeTrackingStateCopyWithImpl<$Res, _$TimeTrackingStateImpl>
    implements _$$TimeTrackingStateImplCopyWith<$Res> {
  __$$TimeTrackingStateImplCopyWithImpl(
    _$TimeTrackingStateImpl _value,
    $Res Function(_$TimeTrackingStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TimeTrackingState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? segments = null,
    Object? runningSegment = freezed,
    Object? totalDurationSeconds = null,
    Object? isLoading = null,
    Object? error = freezed,
  }) {
    return _then(
      _$TimeTrackingStateImpl(
        segments: null == segments
            ? _value._segments
            : segments // ignore: cast_nullable_to_non_nullable
                  as List<TimeSegmentEntity>,
        runningSegment: freezed == runningSegment
            ? _value.runningSegment
            : runningSegment // ignore: cast_nullable_to_non_nullable
                  as TimeSegmentEntity?,
        totalDurationSeconds: null == totalDurationSeconds
            ? _value.totalDurationSeconds
            : totalDurationSeconds // ignore: cast_nullable_to_non_nullable
                  as int,
        isLoading: null == isLoading
            ? _value.isLoading
            : isLoading // ignore: cast_nullable_to_non_nullable
                  as bool,
        error: freezed == error
            ? _value.error
            : error // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$TimeTrackingStateImpl implements _TimeTrackingState {
  const _$TimeTrackingStateImpl({
    final List<TimeSegmentEntity> segments = const [],
    this.runningSegment,
    this.totalDurationSeconds = 0,
    this.isLoading = false,
    this.error,
  }) : _segments = segments;

  final List<TimeSegmentEntity> _segments;
  @override
  @JsonKey()
  List<TimeSegmentEntity> get segments {
    if (_segments is EqualUnmodifiableListView) return _segments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_segments);
  }

  @override
  final TimeSegmentEntity? runningSegment;
  @override
  @JsonKey()
  final int totalDurationSeconds;
  @override
  @JsonKey()
  final bool isLoading;
  @override
  final String? error;

  @override
  String toString() {
    return 'TimeTrackingState(segments: $segments, runningSegment: $runningSegment, totalDurationSeconds: $totalDurationSeconds, isLoading: $isLoading, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TimeTrackingStateImpl &&
            const DeepCollectionEquality().equals(other._segments, _segments) &&
            (identical(other.runningSegment, runningSegment) ||
                other.runningSegment == runningSegment) &&
            (identical(other.totalDurationSeconds, totalDurationSeconds) ||
                other.totalDurationSeconds == totalDurationSeconds) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_segments),
    runningSegment,
    totalDurationSeconds,
    isLoading,
    error,
  );

  /// Create a copy of TimeTrackingState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TimeTrackingStateImplCopyWith<_$TimeTrackingStateImpl> get copyWith =>
      __$$TimeTrackingStateImplCopyWithImpl<_$TimeTrackingStateImpl>(
        this,
        _$identity,
      );
}

abstract class _TimeTrackingState implements TimeTrackingState {
  const factory _TimeTrackingState({
    final List<TimeSegmentEntity> segments,
    final TimeSegmentEntity? runningSegment,
    final int totalDurationSeconds,
    final bool isLoading,
    final String? error,
  }) = _$TimeTrackingStateImpl;

  @override
  List<TimeSegmentEntity> get segments;
  @override
  TimeSegmentEntity? get runningSegment;
  @override
  int get totalDurationSeconds;
  @override
  bool get isLoading;
  @override
  String? get error;

  /// Create a copy of TimeTrackingState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TimeTrackingStateImplCopyWith<_$TimeTrackingStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
