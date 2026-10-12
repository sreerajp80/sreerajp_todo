// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'time_segment_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TimeSegmentEntity {

 String get id; String get todoId; String get startTime; String? get endTime; int? get durationSeconds; bool get interrupted; bool get manual; String? get notes;/// Set once the start/end times were changed while the parent todo was
/// already completed or dropped. Sticky: it is never cleared again.
 bool get editedAfterCompletion;/// ISO 8601 UTC timestamp of the last start/end time edit, if any.
 String? get timesEditedAt; String get createdAt;
/// Create a copy of TimeSegmentEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TimeSegmentEntityCopyWith<TimeSegmentEntity> get copyWith => _$TimeSegmentEntityCopyWithImpl<TimeSegmentEntity>(this as TimeSegmentEntity, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TimeSegmentEntity;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TimeSegmentEntity&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.todoId, _this.todoId) || other.todoId == _this.todoId)&&(identical(other.startTime, _this.startTime) || other.startTime == _this.startTime)&&(identical(other.endTime, _this.endTime) || other.endTime == _this.endTime)&&(identical(other.durationSeconds, _this.durationSeconds) || other.durationSeconds == _this.durationSeconds)&&(identical(other.interrupted, _this.interrupted) || other.interrupted == _this.interrupted)&&(identical(other.manual, _this.manual) || other.manual == _this.manual)&&(identical(other.notes, _this.notes) || other.notes == _this.notes)&&(identical(other.editedAfterCompletion, _this.editedAfterCompletion) || other.editedAfterCompletion == _this.editedAfterCompletion)&&(identical(other.timesEditedAt, _this.timesEditedAt) || other.timesEditedAt == _this.timesEditedAt)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}


@override
int get hashCode {
  final _this = this as TimeSegmentEntity;
  return Object.hash(runtimeType,_this.id,_this.todoId,_this.startTime,_this.endTime,_this.durationSeconds,_this.interrupted,_this.manual,_this.notes,_this.editedAfterCompletion,_this.timesEditedAt,_this.createdAt);
}

@override
String toString() {
  final _this = this as TimeSegmentEntity;
  return 'TimeSegmentEntity(id: ${_this.id}, todoId: ${_this.todoId}, startTime: ${_this.startTime}, endTime: ${_this.endTime}, durationSeconds: ${_this.durationSeconds}, interrupted: ${_this.interrupted}, manual: ${_this.manual}, notes: ${_this.notes}, editedAfterCompletion: ${_this.editedAfterCompletion}, timesEditedAt: ${_this.timesEditedAt}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $TimeSegmentEntityCopyWith<$Res>  {
  factory $TimeSegmentEntityCopyWith(TimeSegmentEntity value, $Res Function(TimeSegmentEntity) _then) = _$TimeSegmentEntityCopyWithImpl;
@useResult
$Res call({
 String id, String todoId, String startTime, String? endTime, int? durationSeconds, bool interrupted, bool manual, String? notes, bool editedAfterCompletion, String? timesEditedAt, String createdAt
});




}
/// @nodoc
class _$TimeSegmentEntityCopyWithImpl<$Res>
    implements $TimeSegmentEntityCopyWith<$Res> {
  _$TimeSegmentEntityCopyWithImpl(this._self, this._then);

  final TimeSegmentEntity _self;
  final $Res Function(TimeSegmentEntity) _then;

/// Create a copy of TimeSegmentEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? todoId = null,Object? startTime = null,Object? endTime = freezed,Object? durationSeconds = freezed,Object? interrupted = null,Object? manual = null,Object? notes = freezed,Object? editedAfterCompletion = null,Object? timesEditedAt = freezed,Object? createdAt = null,}) {
  return _then(TimeSegmentEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,todoId: null == todoId ? _self.todoId : todoId // ignore: cast_nullable_to_non_nullable
as String,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as String,endTime: freezed == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as String?,durationSeconds: freezed == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as int?,interrupted: null == interrupted ? _self.interrupted : interrupted // ignore: cast_nullable_to_non_nullable
as bool,manual: null == manual ? _self.manual : manual // ignore: cast_nullable_to_non_nullable
as bool,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,editedAfterCompletion: null == editedAfterCompletion ? _self.editedAfterCompletion : editedAfterCompletion // ignore: cast_nullable_to_non_nullable
as bool,timesEditedAt: freezed == timesEditedAt ? _self.timesEditedAt : timesEditedAt // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [TimeSegmentEntity].
extension TimeSegmentEntityPatterns on TimeSegmentEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TimeSegmentEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TimeSegmentEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TimeSegmentEntity value)  $default,){
final _that = this;
switch (_that) {
case _TimeSegmentEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TimeSegmentEntity value)?  $default,){
final _that = this;
switch (_that) {
case _TimeSegmentEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String todoId,  String startTime,  String? endTime,  int? durationSeconds,  bool interrupted,  bool manual,  String? notes,  bool editedAfterCompletion,  String? timesEditedAt,  String createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TimeSegmentEntity() when $default != null:
return $default(_that.id,_that.todoId,_that.startTime,_that.endTime,_that.durationSeconds,_that.interrupted,_that.manual,_that.notes,_that.editedAfterCompletion,_that.timesEditedAt,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String todoId,  String startTime,  String? endTime,  int? durationSeconds,  bool interrupted,  bool manual,  String? notes,  bool editedAfterCompletion,  String? timesEditedAt,  String createdAt)  $default,) {final _that = this;
switch (_that) {
case _TimeSegmentEntity():
return $default(_that.id,_that.todoId,_that.startTime,_that.endTime,_that.durationSeconds,_that.interrupted,_that.manual,_that.notes,_that.editedAfterCompletion,_that.timesEditedAt,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String todoId,  String startTime,  String? endTime,  int? durationSeconds,  bool interrupted,  bool manual,  String? notes,  bool editedAfterCompletion,  String? timesEditedAt,  String createdAt)?  $default,) {final _that = this;
switch (_that) {
case _TimeSegmentEntity() when $default != null:
return $default(_that.id,_that.todoId,_that.startTime,_that.endTime,_that.durationSeconds,_that.interrupted,_that.manual,_that.notes,_that.editedAfterCompletion,_that.timesEditedAt,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc


class _TimeSegmentEntity extends TimeSegmentEntity {
  const _TimeSegmentEntity({required this.id, required this.todoId, required this.startTime, this.endTime, this.durationSeconds, this.interrupted = false, this.manual = false, this.notes, this.editedAfterCompletion = false, this.timesEditedAt, required this.createdAt}): super._();
  

@override final  String id;
@override final  String todoId;
@override final  String startTime;
@override final  String? endTime;
@override final  int? durationSeconds;
@override@JsonKey() final  bool interrupted;
@override@JsonKey() final  bool manual;
@override final  String? notes;
/// Set once the start/end times were changed while the parent todo was
/// already completed or dropped. Sticky: it is never cleared again.
@override@JsonKey() final  bool editedAfterCompletion;
/// ISO 8601 UTC timestamp of the last start/end time edit, if any.
@override final  String? timesEditedAt;
@override final  String createdAt;

/// Create a copy of TimeSegmentEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TimeSegmentEntityCopyWith<_TimeSegmentEntity> get copyWith => __$TimeSegmentEntityCopyWithImpl<_TimeSegmentEntity>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TimeSegmentEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.todoId, todoId) || other.todoId == todoId)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.durationSeconds, durationSeconds) || other.durationSeconds == durationSeconds)&&(identical(other.interrupted, interrupted) || other.interrupted == interrupted)&&(identical(other.manual, manual) || other.manual == manual)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.editedAfterCompletion, editedAfterCompletion) || other.editedAfterCompletion == editedAfterCompletion)&&(identical(other.timesEditedAt, timesEditedAt) || other.timesEditedAt == timesEditedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,todoId,startTime,endTime,durationSeconds,interrupted,manual,notes,editedAfterCompletion,timesEditedAt,createdAt);
}

@override
String toString() {
    return 'TimeSegmentEntity(id: $id, todoId: $todoId, startTime: $startTime, endTime: $endTime, durationSeconds: $durationSeconds, interrupted: $interrupted, manual: $manual, notes: $notes, editedAfterCompletion: $editedAfterCompletion, timesEditedAt: $timesEditedAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$TimeSegmentEntityCopyWith<$Res> implements $TimeSegmentEntityCopyWith<$Res> {
  factory _$TimeSegmentEntityCopyWith(_TimeSegmentEntity value, $Res Function(_TimeSegmentEntity) _then) = __$TimeSegmentEntityCopyWithImpl;
@override @useResult
$Res call({
 String id, String todoId, String startTime, String? endTime, int? durationSeconds, bool interrupted, bool manual, String? notes, bool editedAfterCompletion, String? timesEditedAt, String createdAt
});




}
/// @nodoc
class __$TimeSegmentEntityCopyWithImpl<$Res>
    implements _$TimeSegmentEntityCopyWith<$Res> {
  __$TimeSegmentEntityCopyWithImpl(this._self, this._then);

  final _TimeSegmentEntity _self;
  final $Res Function(_TimeSegmentEntity) _then;

/// Create a copy of TimeSegmentEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? todoId = null,Object? startTime = null,Object? endTime = freezed,Object? durationSeconds = freezed,Object? interrupted = null,Object? manual = null,Object? notes = freezed,Object? editedAfterCompletion = null,Object? timesEditedAt = freezed,Object? createdAt = null,}) {
  return _then(_TimeSegmentEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,todoId: null == todoId ? _self.todoId : todoId // ignore: cast_nullable_to_non_nullable
as String,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as String,endTime: freezed == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as String?,durationSeconds: freezed == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as int?,interrupted: null == interrupted ? _self.interrupted : interrupted // ignore: cast_nullable_to_non_nullable
as bool,manual: null == manual ? _self.manual : manual // ignore: cast_nullable_to_non_nullable
as bool,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,editedAfterCompletion: null == editedAfterCompletion ? _self.editedAfterCompletion : editedAfterCompletion // ignore: cast_nullable_to_non_nullable
as bool,timesEditedAt: freezed == timesEditedAt ? _self.timesEditedAt : timesEditedAt // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
