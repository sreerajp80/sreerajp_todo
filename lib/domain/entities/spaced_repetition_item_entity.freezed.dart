// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'spaced_repetition_item_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SpacedRepetitionItemEntity {

 String get id; String get title; String? get description; int get level; double get easeFactor; int get intervalDays; String get nextReviewDate; String? get lastReviewedAt; bool get active; String get createdAt; String get updatedAt;
/// Create a copy of SpacedRepetitionItemEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SpacedRepetitionItemEntityCopyWith<SpacedRepetitionItemEntity> get copyWith => _$SpacedRepetitionItemEntityCopyWithImpl<SpacedRepetitionItemEntity>(this as SpacedRepetitionItemEntity, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SpacedRepetitionItemEntity;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SpacedRepetitionItemEntity&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.level, _this.level) || other.level == _this.level)&&(identical(other.easeFactor, _this.easeFactor) || other.easeFactor == _this.easeFactor)&&(identical(other.intervalDays, _this.intervalDays) || other.intervalDays == _this.intervalDays)&&(identical(other.nextReviewDate, _this.nextReviewDate) || other.nextReviewDate == _this.nextReviewDate)&&(identical(other.lastReviewedAt, _this.lastReviewedAt) || other.lastReviewedAt == _this.lastReviewedAt)&&(identical(other.active, _this.active) || other.active == _this.active)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt));
}


@override
int get hashCode {
  final _this = this as SpacedRepetitionItemEntity;
  return Object.hash(runtimeType,_this.id,_this.title,_this.description,_this.level,_this.easeFactor,_this.intervalDays,_this.nextReviewDate,_this.lastReviewedAt,_this.active,_this.createdAt,_this.updatedAt);
}

@override
String toString() {
  final _this = this as SpacedRepetitionItemEntity;
  return 'SpacedRepetitionItemEntity(id: ${_this.id}, title: ${_this.title}, description: ${_this.description}, level: ${_this.level}, easeFactor: ${_this.easeFactor}, intervalDays: ${_this.intervalDays}, nextReviewDate: ${_this.nextReviewDate}, lastReviewedAt: ${_this.lastReviewedAt}, active: ${_this.active}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt})';
}


}

/// @nodoc
abstract mixin class $SpacedRepetitionItemEntityCopyWith<$Res>  {
  factory $SpacedRepetitionItemEntityCopyWith(SpacedRepetitionItemEntity value, $Res Function(SpacedRepetitionItemEntity) _then) = _$SpacedRepetitionItemEntityCopyWithImpl;
@useResult
$Res call({
 String id, String title, String? description, int level, double easeFactor, int intervalDays, String nextReviewDate, String? lastReviewedAt, bool active, String createdAt, String updatedAt
});




}
/// @nodoc
class _$SpacedRepetitionItemEntityCopyWithImpl<$Res>
    implements $SpacedRepetitionItemEntityCopyWith<$Res> {
  _$SpacedRepetitionItemEntityCopyWithImpl(this._self, this._then);

  final SpacedRepetitionItemEntity _self;
  final $Res Function(SpacedRepetitionItemEntity) _then;

/// Create a copy of SpacedRepetitionItemEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? description = freezed,Object? level = null,Object? easeFactor = null,Object? intervalDays = null,Object? nextReviewDate = null,Object? lastReviewedAt = freezed,Object? active = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(SpacedRepetitionItemEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int,easeFactor: null == easeFactor ? _self.easeFactor : easeFactor // ignore: cast_nullable_to_non_nullable
as double,intervalDays: null == intervalDays ? _self.intervalDays : intervalDays // ignore: cast_nullable_to_non_nullable
as int,nextReviewDate: null == nextReviewDate ? _self.nextReviewDate : nextReviewDate // ignore: cast_nullable_to_non_nullable
as String,lastReviewedAt: freezed == lastReviewedAt ? _self.lastReviewedAt : lastReviewedAt // ignore: cast_nullable_to_non_nullable
as String?,active: null == active ? _self.active : active // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SpacedRepetitionItemEntity].
extension SpacedRepetitionItemEntityPatterns on SpacedRepetitionItemEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SpacedRepetitionItemEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SpacedRepetitionItemEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SpacedRepetitionItemEntity value)  $default,){
final _that = this;
switch (_that) {
case _SpacedRepetitionItemEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SpacedRepetitionItemEntity value)?  $default,){
final _that = this;
switch (_that) {
case _SpacedRepetitionItemEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String? description,  int level,  double easeFactor,  int intervalDays,  String nextReviewDate,  String? lastReviewedAt,  bool active,  String createdAt,  String updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SpacedRepetitionItemEntity() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.level,_that.easeFactor,_that.intervalDays,_that.nextReviewDate,_that.lastReviewedAt,_that.active,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String? description,  int level,  double easeFactor,  int intervalDays,  String nextReviewDate,  String? lastReviewedAt,  bool active,  String createdAt,  String updatedAt)  $default,) {final _that = this;
switch (_that) {
case _SpacedRepetitionItemEntity():
return $default(_that.id,_that.title,_that.description,_that.level,_that.easeFactor,_that.intervalDays,_that.nextReviewDate,_that.lastReviewedAt,_that.active,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String? description,  int level,  double easeFactor,  int intervalDays,  String nextReviewDate,  String? lastReviewedAt,  bool active,  String createdAt,  String updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _SpacedRepetitionItemEntity() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.level,_that.easeFactor,_that.intervalDays,_that.nextReviewDate,_that.lastReviewedAt,_that.active,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc


class _SpacedRepetitionItemEntity extends SpacedRepetitionItemEntity {
  const _SpacedRepetitionItemEntity({required this.id, required this.title, this.description, this.level = 1, this.easeFactor = 2.5, this.intervalDays = 1, required this.nextReviewDate, this.lastReviewedAt, this.active = true, required this.createdAt, required this.updatedAt}): super._();
  

@override final  String id;
@override final  String title;
@override final  String? description;
@override@JsonKey() final  int level;
@override@JsonKey() final  double easeFactor;
@override@JsonKey() final  int intervalDays;
@override final  String nextReviewDate;
@override final  String? lastReviewedAt;
@override@JsonKey() final  bool active;
@override final  String createdAt;
@override final  String updatedAt;

/// Create a copy of SpacedRepetitionItemEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SpacedRepetitionItemEntityCopyWith<_SpacedRepetitionItemEntity> get copyWith => __$SpacedRepetitionItemEntityCopyWithImpl<_SpacedRepetitionItemEntity>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SpacedRepetitionItemEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.level, level) || other.level == level)&&(identical(other.easeFactor, easeFactor) || other.easeFactor == easeFactor)&&(identical(other.intervalDays, intervalDays) || other.intervalDays == intervalDays)&&(identical(other.nextReviewDate, nextReviewDate) || other.nextReviewDate == nextReviewDate)&&(identical(other.lastReviewedAt, lastReviewedAt) || other.lastReviewedAt == lastReviewedAt)&&(identical(other.active, active) || other.active == active)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,title,description,level,easeFactor,intervalDays,nextReviewDate,lastReviewedAt,active,createdAt,updatedAt);
}

@override
String toString() {
    return 'SpacedRepetitionItemEntity(id: $id, title: $title, description: $description, level: $level, easeFactor: $easeFactor, intervalDays: $intervalDays, nextReviewDate: $nextReviewDate, lastReviewedAt: $lastReviewedAt, active: $active, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$SpacedRepetitionItemEntityCopyWith<$Res> implements $SpacedRepetitionItemEntityCopyWith<$Res> {
  factory _$SpacedRepetitionItemEntityCopyWith(_SpacedRepetitionItemEntity value, $Res Function(_SpacedRepetitionItemEntity) _then) = __$SpacedRepetitionItemEntityCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String? description, int level, double easeFactor, int intervalDays, String nextReviewDate, String? lastReviewedAt, bool active, String createdAt, String updatedAt
});




}
/// @nodoc
class __$SpacedRepetitionItemEntityCopyWithImpl<$Res>
    implements _$SpacedRepetitionItemEntityCopyWith<$Res> {
  __$SpacedRepetitionItemEntityCopyWithImpl(this._self, this._then);

  final _SpacedRepetitionItemEntity _self;
  final $Res Function(_SpacedRepetitionItemEntity) _then;

/// Create a copy of SpacedRepetitionItemEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? description = freezed,Object? level = null,Object? easeFactor = null,Object? intervalDays = null,Object? nextReviewDate = null,Object? lastReviewedAt = freezed,Object? active = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_SpacedRepetitionItemEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int,easeFactor: null == easeFactor ? _self.easeFactor : easeFactor // ignore: cast_nullable_to_non_nullable
as double,intervalDays: null == intervalDays ? _self.intervalDays : intervalDays // ignore: cast_nullable_to_non_nullable
as int,nextReviewDate: null == nextReviewDate ? _self.nextReviewDate : nextReviewDate // ignore: cast_nullable_to_non_nullable
as String,lastReviewedAt: freezed == lastReviewedAt ? _self.lastReviewedAt : lastReviewedAt // ignore: cast_nullable_to_non_nullable
as String?,active: null == active ? _self.active : active // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
