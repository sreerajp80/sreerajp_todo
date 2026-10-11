// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'daily_intention_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$DailyIntentionEntity {
  String get date => throw _privateConstructorUsedError;
  String get intentionText => throw _privateConstructorUsedError;
  String get createdAt => throw _privateConstructorUsedError;

  /// Create a copy of DailyIntentionEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DailyIntentionEntityCopyWith<DailyIntentionEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DailyIntentionEntityCopyWith<$Res> {
  factory $DailyIntentionEntityCopyWith(
    DailyIntentionEntity value,
    $Res Function(DailyIntentionEntity) then,
  ) = _$DailyIntentionEntityCopyWithImpl<$Res, DailyIntentionEntity>;
  @useResult
  $Res call({String date, String intentionText, String createdAt});
}

/// @nodoc
class _$DailyIntentionEntityCopyWithImpl<
  $Res,
  $Val extends DailyIntentionEntity
>
    implements $DailyIntentionEntityCopyWith<$Res> {
  _$DailyIntentionEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DailyIntentionEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? intentionText = null,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as String,
            intentionText: null == intentionText
                ? _value.intentionText
                : intentionText // ignore: cast_nullable_to_non_nullable
                      as String,
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
abstract class _$$DailyIntentionEntityImplCopyWith<$Res>
    implements $DailyIntentionEntityCopyWith<$Res> {
  factory _$$DailyIntentionEntityImplCopyWith(
    _$DailyIntentionEntityImpl value,
    $Res Function(_$DailyIntentionEntityImpl) then,
  ) = __$$DailyIntentionEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String date, String intentionText, String createdAt});
}

/// @nodoc
class __$$DailyIntentionEntityImplCopyWithImpl<$Res>
    extends _$DailyIntentionEntityCopyWithImpl<$Res, _$DailyIntentionEntityImpl>
    implements _$$DailyIntentionEntityImplCopyWith<$Res> {
  __$$DailyIntentionEntityImplCopyWithImpl(
    _$DailyIntentionEntityImpl _value,
    $Res Function(_$DailyIntentionEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DailyIntentionEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? intentionText = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$DailyIntentionEntityImpl(
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as String,
        intentionText: null == intentionText
            ? _value.intentionText
            : intentionText // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$DailyIntentionEntityImpl extends _DailyIntentionEntity {
  const _$DailyIntentionEntityImpl({
    required this.date,
    required this.intentionText,
    required this.createdAt,
  }) : super._();

  @override
  final String date;
  @override
  final String intentionText;
  @override
  final String createdAt;

  @override
  String toString() {
    return 'DailyIntentionEntity(date: $date, intentionText: $intentionText, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DailyIntentionEntityImpl &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.intentionText, intentionText) ||
                other.intentionText == intentionText) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @override
  int get hashCode => Object.hash(runtimeType, date, intentionText, createdAt);

  /// Create a copy of DailyIntentionEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DailyIntentionEntityImplCopyWith<_$DailyIntentionEntityImpl>
  get copyWith =>
      __$$DailyIntentionEntityImplCopyWithImpl<_$DailyIntentionEntityImpl>(
        this,
        _$identity,
      );
}

abstract class _DailyIntentionEntity extends DailyIntentionEntity {
  const factory _DailyIntentionEntity({
    required final String date,
    required final String intentionText,
    required final String createdAt,
  }) = _$DailyIntentionEntityImpl;
  const _DailyIntentionEntity._() : super._();

  @override
  String get date;
  @override
  String get intentionText;
  @override
  String get createdAt;

  /// Create a copy of DailyIntentionEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DailyIntentionEntityImplCopyWith<_$DailyIntentionEntityImpl>
  get copyWith => throw _privateConstructorUsedError;
}
