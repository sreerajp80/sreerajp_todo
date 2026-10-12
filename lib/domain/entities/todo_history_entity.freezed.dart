// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'todo_history_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TodoHistoryEntity {

 String get id; String get todoId; TodoHistoryEventType get eventType; String get eventTime; String get description; String? get metadata; String get createdAt;
/// Create a copy of TodoHistoryEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TodoHistoryEntityCopyWith<TodoHistoryEntity> get copyWith => _$TodoHistoryEntityCopyWithImpl<TodoHistoryEntity>(this as TodoHistoryEntity, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TodoHistoryEntity;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TodoHistoryEntity&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.todoId, _this.todoId) || other.todoId == _this.todoId)&&(identical(other.eventType, _this.eventType) || other.eventType == _this.eventType)&&(identical(other.eventTime, _this.eventTime) || other.eventTime == _this.eventTime)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.metadata, _this.metadata) || other.metadata == _this.metadata)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}


@override
int get hashCode {
  final _this = this as TodoHistoryEntity;
  return Object.hash(runtimeType,_this.id,_this.todoId,_this.eventType,_this.eventTime,_this.description,_this.metadata,_this.createdAt);
}

@override
String toString() {
  final _this = this as TodoHistoryEntity;
  return 'TodoHistoryEntity(id: ${_this.id}, todoId: ${_this.todoId}, eventType: ${_this.eventType}, eventTime: ${_this.eventTime}, description: ${_this.description}, metadata: ${_this.metadata}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $TodoHistoryEntityCopyWith<$Res>  {
  factory $TodoHistoryEntityCopyWith(TodoHistoryEntity value, $Res Function(TodoHistoryEntity) _then) = _$TodoHistoryEntityCopyWithImpl;
@useResult
$Res call({
 String id, String todoId, TodoHistoryEventType eventType, String eventTime, String description, String? metadata, String createdAt
});




}
/// @nodoc
class _$TodoHistoryEntityCopyWithImpl<$Res>
    implements $TodoHistoryEntityCopyWith<$Res> {
  _$TodoHistoryEntityCopyWithImpl(this._self, this._then);

  final TodoHistoryEntity _self;
  final $Res Function(TodoHistoryEntity) _then;

/// Create a copy of TodoHistoryEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? todoId = null,Object? eventType = null,Object? eventTime = null,Object? description = null,Object? metadata = freezed,Object? createdAt = null,}) {
  return _then(TodoHistoryEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,todoId: null == todoId ? _self.todoId : todoId // ignore: cast_nullable_to_non_nullable
as String,eventType: null == eventType ? _self.eventType : eventType // ignore: cast_nullable_to_non_nullable
as TodoHistoryEventType,eventTime: null == eventTime ? _self.eventTime : eventTime // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [TodoHistoryEntity].
extension TodoHistoryEntityPatterns on TodoHistoryEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TodoHistoryEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TodoHistoryEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TodoHistoryEntity value)  $default,){
final _that = this;
switch (_that) {
case _TodoHistoryEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TodoHistoryEntity value)?  $default,){
final _that = this;
switch (_that) {
case _TodoHistoryEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String todoId,  TodoHistoryEventType eventType,  String eventTime,  String description,  String? metadata,  String createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TodoHistoryEntity() when $default != null:
return $default(_that.id,_that.todoId,_that.eventType,_that.eventTime,_that.description,_that.metadata,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String todoId,  TodoHistoryEventType eventType,  String eventTime,  String description,  String? metadata,  String createdAt)  $default,) {final _that = this;
switch (_that) {
case _TodoHistoryEntity():
return $default(_that.id,_that.todoId,_that.eventType,_that.eventTime,_that.description,_that.metadata,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String todoId,  TodoHistoryEventType eventType,  String eventTime,  String description,  String? metadata,  String createdAt)?  $default,) {final _that = this;
switch (_that) {
case _TodoHistoryEntity() when $default != null:
return $default(_that.id,_that.todoId,_that.eventType,_that.eventTime,_that.description,_that.metadata,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc


class _TodoHistoryEntity extends TodoHistoryEntity {
  const _TodoHistoryEntity({required this.id, required this.todoId, required this.eventType, required this.eventTime, required this.description, this.metadata, required this.createdAt}): super._();
  

@override final  String id;
@override final  String todoId;
@override final  TodoHistoryEventType eventType;
@override final  String eventTime;
@override final  String description;
@override final  String? metadata;
@override final  String createdAt;

/// Create a copy of TodoHistoryEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TodoHistoryEntityCopyWith<_TodoHistoryEntity> get copyWith => __$TodoHistoryEntityCopyWithImpl<_TodoHistoryEntity>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TodoHistoryEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.todoId, todoId) || other.todoId == todoId)&&(identical(other.eventType, eventType) || other.eventType == eventType)&&(identical(other.eventTime, eventTime) || other.eventTime == eventTime)&&(identical(other.description, description) || other.description == description)&&(identical(other.metadata, metadata) || other.metadata == metadata)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,todoId,eventType,eventTime,description,metadata,createdAt);
}

@override
String toString() {
    return 'TodoHistoryEntity(id: $id, todoId: $todoId, eventType: $eventType, eventTime: $eventTime, description: $description, metadata: $metadata, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$TodoHistoryEntityCopyWith<$Res> implements $TodoHistoryEntityCopyWith<$Res> {
  factory _$TodoHistoryEntityCopyWith(_TodoHistoryEntity value, $Res Function(_TodoHistoryEntity) _then) = __$TodoHistoryEntityCopyWithImpl;
@override @useResult
$Res call({
 String id, String todoId, TodoHistoryEventType eventType, String eventTime, String description, String? metadata, String createdAt
});




}
/// @nodoc
class __$TodoHistoryEntityCopyWithImpl<$Res>
    implements _$TodoHistoryEntityCopyWith<$Res> {
  __$TodoHistoryEntityCopyWithImpl(this._self, this._then);

  final _TodoHistoryEntity _self;
  final $Res Function(_TodoHistoryEntity) _then;

/// Create a copy of TodoHistoryEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? todoId = null,Object? eventType = null,Object? eventTime = null,Object? description = null,Object? metadata = freezed,Object? createdAt = null,}) {
  return _then(_TodoHistoryEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,todoId: null == todoId ? _self.todoId : todoId // ignore: cast_nullable_to_non_nullable
as String,eventType: null == eventType ? _self.eventType : eventType // ignore: cast_nullable_to_non_nullable
as TodoHistoryEventType,eventTime: null == eventTime ? _self.eventTime : eventTime // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
