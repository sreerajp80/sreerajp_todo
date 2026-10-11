// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'daily_reflection_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$DailyReflectionEntity {
  String get date => throw _privateConstructorUsedError;
  String get reflectionNote => throw _privateConstructorUsedError;
  int get completedSeconds => throw _privateConstructorUsedError;
  int get droppedSeconds => throw _privateConstructorUsedError;
  String get createdAt => throw _privateConstructorUsedError;
  String get updatedAt => throw _privateConstructorUsedError;

  /// Create a copy of DailyReflectionEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DailyReflectionEntityCopyWith<DailyReflectionEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DailyReflectionEntityCopyWith<$Res> {
  factory $DailyReflectionEntityCopyWith(
    DailyReflectionEntity value,
    $Res Function(DailyReflectionEntity) then,
  ) = _$DailyReflectionEntityCopyWithImpl<$Res, DailyReflectionEntity>;
  @useResult
  $Res call({
    String date,
    String reflectionNote,
    int completedSeconds,
    int droppedSeconds,
    String createdAt,
    String updatedAt,
  });
}

/// @nodoc
class _$DailyReflectionEntityCopyWithImpl<
  $Res,
  $Val extends DailyReflectionEntity
>
    implements $DailyReflectionEntityCopyWith<$Res> {
  _$DailyReflectionEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DailyReflectionEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? reflectionNote = null,
    Object? completedSeconds = null,
    Object? droppedSeconds = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as String,
            reflectionNote: null == reflectionNote
                ? _value.reflectionNote
                : reflectionNote // ignore: cast_nullable_to_non_nullable
                      as String,
            completedSeconds: null == completedSeconds
                ? _value.completedSeconds
                : completedSeconds // ignore: cast_nullable_to_non_nullable
                      as int,
            droppedSeconds: null == droppedSeconds
                ? _value.droppedSeconds
                : droppedSeconds // ignore: cast_nullable_to_non_nullable
                      as int,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as String,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DailyReflectionEntityImplCopyWith<$Res>
    implements $DailyReflectionEntityCopyWith<$Res> {
  factory _$$DailyReflectionEntityImplCopyWith(
    _$DailyReflectionEntityImpl value,
    $Res Function(_$DailyReflectionEntityImpl) then,
  ) = __$$DailyReflectionEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String date,
    String reflectionNote,
    int completedSeconds,
    int droppedSeconds,
    String createdAt,
    String updatedAt,
  });
}

/// @nodoc
class __$$DailyReflectionEntityImplCopyWithImpl<$Res>
    extends
        _$DailyReflectionEntityCopyWithImpl<$Res, _$DailyReflectionEntityImpl>
    implements _$$DailyReflectionEntityImplCopyWith<$Res> {
  __$$DailyReflectionEntityImplCopyWithImpl(
    _$DailyReflectionEntityImpl _value,
    $Res Function(_$DailyReflectionEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DailyReflectionEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? reflectionNote = null,
    Object? completedSeconds = null,
    Object? droppedSeconds = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$DailyReflectionEntityImpl(
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as String,
        reflectionNote: null == reflectionNote
            ? _value.reflectionNote
            : reflectionNote // ignore: cast_nullable_to_non_nullable
                  as String,
        completedSeconds: null == completedSeconds
            ? _value.completedSeconds
            : completedSeconds // ignore: cast_nullable_to_non_nullable
                  as int,
        droppedSeconds: null == droppedSeconds
            ? _value.droppedSeconds
            : droppedSeconds // ignore: cast_nullable_to_non_nullable
                  as int,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as String,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$DailyReflectionEntityImpl extends _DailyReflectionEntity {
  const _$DailyReflectionEntityImpl({
    required this.date,
    required this.reflectionNote,
    this.completedSeconds = 0,
    this.droppedSeconds = 0,
    required this.createdAt,
    required this.updatedAt,
  }) : super._();

  @override
  final String date;
  @override
  final String reflectionNote;
  @override
  @JsonKey()
  final int completedSeconds;
  @override
  @JsonKey()
  final int droppedSeconds;
  @override
  final String createdAt;
  @override
  final String updatedAt;

  @override
  String toString() {
    return 'DailyReflectionEntity(date: $date, reflectionNote: $reflectionNote, completedSeconds: $completedSeconds, droppedSeconds: $droppedSeconds, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DailyReflectionEntityImpl &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.reflectionNote, reflectionNote) ||
                other.reflectionNote == reflectionNote) &&
            (identical(other.completedSeconds, completedSeconds) ||
                other.completedSeconds == completedSeconds) &&
            (identical(other.droppedSeconds, droppedSeconds) ||
                other.droppedSeconds == droppedSeconds) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    date,
    reflectionNote,
    completedSeconds,
    droppedSeconds,
    createdAt,
    updatedAt,
  );

  /// Create a copy of DailyReflectionEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DailyReflectionEntityImplCopyWith<_$DailyReflectionEntityImpl>
  get copyWith =>
      __$$DailyReflectionEntityImplCopyWithImpl<_$DailyReflectionEntityImpl>(
        this,
        _$identity,
      );
}

abstract class _DailyReflectionEntity extends DailyReflectionEntity {
  const factory _DailyReflectionEntity({
    required final String date,
    required final String reflectionNote,
    final int completedSeconds,
    final int droppedSeconds,
    required final String createdAt,
    required final String updatedAt,
  }) = _$DailyReflectionEntityImpl;
  const _DailyReflectionEntity._() : super._();

  @override
  String get date;
  @override
  String get reflectionNote;
  @override
  int get completedSeconds;
  @override
  int get droppedSeconds;
  @override
  String get createdAt;
  @override
  String get updatedAt;

  /// Create a copy of DailyReflectionEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DailyReflectionEntityImplCopyWith<_$DailyReflectionEntityImpl>
  get copyWith => throw _privateConstructorUsedError;
}
