// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'daily_reflection_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DailyReflectionEntity {

 String get date; String get reflectionNote; int get completedSeconds; int get droppedSeconds; String get createdAt; String get updatedAt;
/// Create a copy of DailyReflectionEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DailyReflectionEntityCopyWith<DailyReflectionEntity> get copyWith => _$DailyReflectionEntityCopyWithImpl<DailyReflectionEntity>(this as DailyReflectionEntity, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as DailyReflectionEntity;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DailyReflectionEntity&&(identical(other.date, _this.date) || other.date == _this.date)&&(identical(other.reflectionNote, _this.reflectionNote) || other.reflectionNote == _this.reflectionNote)&&(identical(other.completedSeconds, _this.completedSeconds) || other.completedSeconds == _this.completedSeconds)&&(identical(other.droppedSeconds, _this.droppedSeconds) || other.droppedSeconds == _this.droppedSeconds)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt));
}


@override
int get hashCode {
  final _this = this as DailyReflectionEntity;
  return Object.hash(runtimeType,_this.date,_this.reflectionNote,_this.completedSeconds,_this.droppedSeconds,_this.createdAt,_this.updatedAt);
}

@override
String toString() {
  final _this = this as DailyReflectionEntity;
  return 'DailyReflectionEntity(date: ${_this.date}, reflectionNote: ${_this.reflectionNote}, completedSeconds: ${_this.completedSeconds}, droppedSeconds: ${_this.droppedSeconds}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt})';
}


}

/// @nodoc
abstract mixin class $DailyReflectionEntityCopyWith<$Res>  {
  factory $DailyReflectionEntityCopyWith(DailyReflectionEntity value, $Res Function(DailyReflectionEntity) _then) = _$DailyReflectionEntityCopyWithImpl;
@useResult
$Res call({
 String date, String reflectionNote, int completedSeconds, int droppedSeconds, String createdAt, String updatedAt
});




}
/// @nodoc
class _$DailyReflectionEntityCopyWithImpl<$Res>
    implements $DailyReflectionEntityCopyWith<$Res> {
  _$DailyReflectionEntityCopyWithImpl(this._self, this._then);

  final DailyReflectionEntity _self;
  final $Res Function(DailyReflectionEntity) _then;

/// Create a copy of DailyReflectionEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? reflectionNote = null,Object? completedSeconds = null,Object? droppedSeconds = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(DailyReflectionEntity(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,reflectionNote: null == reflectionNote ? _self.reflectionNote : reflectionNote // ignore: cast_nullable_to_non_nullable
as String,completedSeconds: null == completedSeconds ? _self.completedSeconds : completedSeconds // ignore: cast_nullable_to_non_nullable
as int,droppedSeconds: null == droppedSeconds ? _self.droppedSeconds : droppedSeconds // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [DailyReflectionEntity].
extension DailyReflectionEntityPatterns on DailyReflectionEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DailyReflectionEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DailyReflectionEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DailyReflectionEntity value)  $default,){
final _that = this;
switch (_that) {
case _DailyReflectionEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DailyReflectionEntity value)?  $default,){
final _that = this;
switch (_that) {
case _DailyReflectionEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String date,  String reflectionNote,  int completedSeconds,  int droppedSeconds,  String createdAt,  String updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DailyReflectionEntity() when $default != null:
return $default(_that.date,_that.reflectionNote,_that.completedSeconds,_that.droppedSeconds,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String date,  String reflectionNote,  int completedSeconds,  int droppedSeconds,  String createdAt,  String updatedAt)  $default,) {final _that = this;
switch (_that) {
case _DailyReflectionEntity():
return $default(_that.date,_that.reflectionNote,_that.completedSeconds,_that.droppedSeconds,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String date,  String reflectionNote,  int completedSeconds,  int droppedSeconds,  String createdAt,  String updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _DailyReflectionEntity() when $default != null:
return $default(_that.date,_that.reflectionNote,_that.completedSeconds,_that.droppedSeconds,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc


class _DailyReflectionEntity extends DailyReflectionEntity {
  const _DailyReflectionEntity({required this.date, required this.reflectionNote, this.completedSeconds = 0, this.droppedSeconds = 0, required this.createdAt, required this.updatedAt}): super._();
  

@override final  String date;
@override final  String reflectionNote;
@override@JsonKey() final  int completedSeconds;
@override@JsonKey() final  int droppedSeconds;
@override final  String createdAt;
@override final  String updatedAt;

/// Create a copy of DailyReflectionEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DailyReflectionEntityCopyWith<_DailyReflectionEntity> get copyWith => __$DailyReflectionEntityCopyWithImpl<_DailyReflectionEntity>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DailyReflectionEntity&&(identical(other.date, date) || other.date == date)&&(identical(other.reflectionNote, reflectionNote) || other.reflectionNote == reflectionNote)&&(identical(other.completedSeconds, completedSeconds) || other.completedSeconds == completedSeconds)&&(identical(other.droppedSeconds, droppedSeconds) || other.droppedSeconds == droppedSeconds)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode {
    return Object.hash(runtimeType,date,reflectionNote,completedSeconds,droppedSeconds,createdAt,updatedAt);
}

@override
String toString() {
    return 'DailyReflectionEntity(date: $date, reflectionNote: $reflectionNote, completedSeconds: $completedSeconds, droppedSeconds: $droppedSeconds, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$DailyReflectionEntityCopyWith<$Res> implements $DailyReflectionEntityCopyWith<$Res> {
  factory _$DailyReflectionEntityCopyWith(_DailyReflectionEntity value, $Res Function(_DailyReflectionEntity) _then) = __$DailyReflectionEntityCopyWithImpl;
@override @useResult
$Res call({
 String date, String reflectionNote, int completedSeconds, int droppedSeconds, String createdAt, String updatedAt
});




}
/// @nodoc
class __$DailyReflectionEntityCopyWithImpl<$Res>
    implements _$DailyReflectionEntityCopyWith<$Res> {
  __$DailyReflectionEntityCopyWithImpl(this._self, this._then);

  final _DailyReflectionEntity _self;
  final $Res Function(_DailyReflectionEntity) _then;

/// Create a copy of DailyReflectionEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? reflectionNote = null,Object? completedSeconds = null,Object? droppedSeconds = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_DailyReflectionEntity(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,reflectionNote: null == reflectionNote ? _self.reflectionNote : reflectionNote // ignore: cast_nullable_to_non_nullable
as String,completedSeconds: null == completedSeconds ? _self.completedSeconds : completedSeconds // ignore: cast_nullable_to_non_nullable
as int,droppedSeconds: null == droppedSeconds ? _self.droppedSeconds : droppedSeconds // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
