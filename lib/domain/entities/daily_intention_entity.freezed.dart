// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'daily_intention_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DailyIntentionEntity {

 String get date; String get intentionText; String get createdAt;
/// Create a copy of DailyIntentionEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DailyIntentionEntityCopyWith<DailyIntentionEntity> get copyWith => _$DailyIntentionEntityCopyWithImpl<DailyIntentionEntity>(this as DailyIntentionEntity, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as DailyIntentionEntity;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DailyIntentionEntity&&(identical(other.date, _this.date) || other.date == _this.date)&&(identical(other.intentionText, _this.intentionText) || other.intentionText == _this.intentionText)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}


@override
int get hashCode {
  final _this = this as DailyIntentionEntity;
  return Object.hash(runtimeType,_this.date,_this.intentionText,_this.createdAt);
}

@override
String toString() {
  final _this = this as DailyIntentionEntity;
  return 'DailyIntentionEntity(date: ${_this.date}, intentionText: ${_this.intentionText}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $DailyIntentionEntityCopyWith<$Res>  {
  factory $DailyIntentionEntityCopyWith(DailyIntentionEntity value, $Res Function(DailyIntentionEntity) _then) = _$DailyIntentionEntityCopyWithImpl;
@useResult
$Res call({
 String date, String intentionText, String createdAt
});




}
/// @nodoc
class _$DailyIntentionEntityCopyWithImpl<$Res>
    implements $DailyIntentionEntityCopyWith<$Res> {
  _$DailyIntentionEntityCopyWithImpl(this._self, this._then);

  final DailyIntentionEntity _self;
  final $Res Function(DailyIntentionEntity) _then;

/// Create a copy of DailyIntentionEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? intentionText = null,Object? createdAt = null,}) {
  return _then(DailyIntentionEntity(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,intentionText: null == intentionText ? _self.intentionText : intentionText // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [DailyIntentionEntity].
extension DailyIntentionEntityPatterns on DailyIntentionEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DailyIntentionEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DailyIntentionEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DailyIntentionEntity value)  $default,){
final _that = this;
switch (_that) {
case _DailyIntentionEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DailyIntentionEntity value)?  $default,){
final _that = this;
switch (_that) {
case _DailyIntentionEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String date,  String intentionText,  String createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DailyIntentionEntity() when $default != null:
return $default(_that.date,_that.intentionText,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String date,  String intentionText,  String createdAt)  $default,) {final _that = this;
switch (_that) {
case _DailyIntentionEntity():
return $default(_that.date,_that.intentionText,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String date,  String intentionText,  String createdAt)?  $default,) {final _that = this;
switch (_that) {
case _DailyIntentionEntity() when $default != null:
return $default(_that.date,_that.intentionText,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc


class _DailyIntentionEntity extends DailyIntentionEntity {
  const _DailyIntentionEntity({required this.date, required this.intentionText, required this.createdAt}): super._();
  

@override final  String date;
@override final  String intentionText;
@override final  String createdAt;

/// Create a copy of DailyIntentionEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DailyIntentionEntityCopyWith<_DailyIntentionEntity> get copyWith => __$DailyIntentionEntityCopyWithImpl<_DailyIntentionEntity>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DailyIntentionEntity&&(identical(other.date, date) || other.date == date)&&(identical(other.intentionText, intentionText) || other.intentionText == intentionText)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode {
    return Object.hash(runtimeType,date,intentionText,createdAt);
}

@override
String toString() {
    return 'DailyIntentionEntity(date: $date, intentionText: $intentionText, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$DailyIntentionEntityCopyWith<$Res> implements $DailyIntentionEntityCopyWith<$Res> {
  factory _$DailyIntentionEntityCopyWith(_DailyIntentionEntity value, $Res Function(_DailyIntentionEntity) _then) = __$DailyIntentionEntityCopyWithImpl;
@override @useResult
$Res call({
 String date, String intentionText, String createdAt
});




}
/// @nodoc
class __$DailyIntentionEntityCopyWithImpl<$Res>
    implements _$DailyIntentionEntityCopyWith<$Res> {
  __$DailyIntentionEntityCopyWithImpl(this._self, this._then);

  final _DailyIntentionEntity _self;
  final $Res Function(_DailyIntentionEntity) _then;

/// Create a copy of DailyIntentionEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? intentionText = null,Object? createdAt = null,}) {
  return _then(_DailyIntentionEntity(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,intentionText: null == intentionText ? _self.intentionText : intentionText // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
