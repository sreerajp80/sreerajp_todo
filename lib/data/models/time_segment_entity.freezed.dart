// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'time_segment_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$TimeSegmentEntity {
  String get id => throw _privateConstructorUsedError;
  String get todoId => throw _privateConstructorUsedError;
  String get startTime => throw _privateConstructorUsedError;
  String? get endTime => throw _privateConstructorUsedError;
  int? get durationSeconds => throw _privateConstructorUsedError;
  bool get interrupted => throw _privateConstructorUsedError;
  bool get manual => throw _privateConstructorUsedError;
  String get createdAt => throw _privateConstructorUsedError;

  /// Create a copy of TimeSegmentEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TimeSegmentEntityCopyWith<TimeSegmentEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TimeSegmentEntityCopyWith<$Res> {
  factory $TimeSegmentEntityCopyWith(
    TimeSegmentEntity value,
    $Res Function(TimeSegmentEntity) then,
  ) = _$TimeSegmentEntityCopyWithImpl<$Res, TimeSegmentEntity>;
  @useResult
  $Res call({
    String id,
    String todoId,
    String startTime,
    String? endTime,
    int? durationSeconds,
    bool interrupted,
    bool manual,
    String createdAt,
  });
}

/// @nodoc
class _$TimeSegmentEntityCopyWithImpl<$Res, $Val extends TimeSegmentEntity>
    implements $TimeSegmentEntityCopyWith<$Res> {
  _$TimeSegmentEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TimeSegmentEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? todoId = null,
    Object? startTime = null,
    Object? endTime = freezed,
    Object? durationSeconds = freezed,
    Object? interrupted = null,
    Object? manual = null,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            todoId: null == todoId
                ? _value.todoId
                : todoId // ignore: cast_nullable_to_non_nullable
                      as String,
            startTime: null == startTime
                ? _value.startTime
                : startTime // ignore: cast_nullable_to_non_nullable
                      as String,
            endTime: freezed == endTime
                ? _value.endTime
                : endTime // ignore: cast_nullable_to_non_nullable
                      as String?,
            durationSeconds: freezed == durationSeconds
                ? _value.durationSeconds
                : durationSeconds // ignore: cast_nullable_to_non_nullable
                      as int?,
            interrupted: null == interrupted
                ? _value.interrupted
                : interrupted // ignore: cast_nullable_to_non_nullable
                      as bool,
            manual: null == manual
                ? _value.manual
                : manual // ignore: cast_nullable_to_non_nullable
                      as bool,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TimeSegmentEntityImplCopyWith<$Res>
    implements $TimeSegmentEntityCopyWith<$Res> {
  factory _$$TimeSegmentEntityImplCopyWith(
    _$TimeSegmentEntityImpl value,
    $Res Function(_$TimeSegmentEntityImpl) then,
  ) = __$$TimeSegmentEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String todoId,
    String startTime,
    String? endTime,
    int? durationSeconds,
    bool interrupted,
    bool manual,
    String createdAt,
  });
}

/// @nodoc
class __$$TimeSegmentEntityImplCopyWithImpl<$Res>
    extends _$TimeSegmentEntityCopyWithImpl<$Res, _$TimeSegmentEntityImpl>
    implements _$$TimeSegmentEntityImplCopyWith<$Res> {
  __$$TimeSegmentEntityImplCopyWithImpl(
    _$TimeSegmentEntityImpl _value,
    $Res Function(_$TimeSegmentEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TimeSegmentEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? todoId = null,
    Object? startTime = null,
    Object? endTime = freezed,
    Object? durationSeconds = freezed,
    Object? interrupted = null,
    Object? manual = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$TimeSegmentEntityImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        todoId: null == todoId
            ? _value.todoId
            : todoId // ignore: cast_nullable_to_non_nullable
                  as String,
        startTime: null == startTime
            ? _value.startTime
            : startTime // ignore: cast_nullable_to_non_nullable
                  as String,
        endTime: freezed == endTime
            ? _value.endTime
            : endTime // ignore: cast_nullable_to_non_nullable
                  as String?,
        durationSeconds: freezed == durationSeconds
            ? _value.durationSeconds
            : durationSeconds // ignore: cast_nullable_to_non_nullable
                  as int?,
        interrupted: null == interrupted
            ? _value.interrupted
            : interrupted // ignore: cast_nullable_to_non_nullable
                  as bool,
        manual: null == manual
            ? _value.manual
            : manual // ignore: cast_nullable_to_non_nullable
                  as bool,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$TimeSegmentEntityImpl extends _TimeSegmentEntity {
  const _$TimeSegmentEntityImpl({
    required this.id,
    required this.todoId,
    required this.startTime,
    this.endTime,
    this.durationSeconds,
    this.interrupted = false,
    this.manual = false,
    required this.createdAt,
  }) : super._();

  @override
  final String id;
  @override
  final String todoId;
  @override
  final String startTime;
  @override
  final String? endTime;
  @override
  final int? durationSeconds;
  @override
  @JsonKey()
  final bool interrupted;
  @override
  @JsonKey()
  final bool manual;
  @override
  final String createdAt;

  @override
  String toString() {
    return 'TimeSegmentEntity(id: $id, todoId: $todoId, startTime: $startTime, endTime: $endTime, durationSeconds: $durationSeconds, interrupted: $interrupted, manual: $manual, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TimeSegmentEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.todoId, todoId) || other.todoId == todoId) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            (identical(other.durationSeconds, durationSeconds) ||
                other.durationSeconds == durationSeconds) &&
            (identical(other.interrupted, interrupted) ||
                other.interrupted == interrupted) &&
            (identical(other.manual, manual) || other.manual == manual) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    todoId,
    startTime,
    endTime,
    durationSeconds,
    interrupted,
    manual,
    createdAt,
  );

  /// Create a copy of TimeSegmentEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TimeSegmentEntityImplCopyWith<_$TimeSegmentEntityImpl> get copyWith =>
      __$$TimeSegmentEntityImplCopyWithImpl<_$TimeSegmentEntityImpl>(
        this,
        _$identity,
      );
}

abstract class _TimeSegmentEntity extends TimeSegmentEntity {
  const factory _TimeSegmentEntity({
    required final String id,
    required final String todoId,
    required final String startTime,
    final String? endTime,
    final int? durationSeconds,
    final bool interrupted,
    final bool manual,
    required final String createdAt,
  }) = _$TimeSegmentEntityImpl;
  const _TimeSegmentEntity._() : super._();

  @override
  String get id;
  @override
  String get todoId;
  @override
  String get startTime;
  @override
  String? get endTime;
  @override
  int? get durationSeconds;
  @override
  bool get interrupted;
  @override
  bool get manual;
  @override
  String get createdAt;

  /// Create a copy of TimeSegmentEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TimeSegmentEntityImplCopyWith<_$TimeSegmentEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
