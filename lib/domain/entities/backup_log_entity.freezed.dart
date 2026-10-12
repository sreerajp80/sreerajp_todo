// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'backup_log_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BackupLogEntity {

 String get id; String get timestamp; String get status; String get filePath; int get fileSizeBytes; String get triggerType; String get diagnosticMessage; String get createdAt;
/// Create a copy of BackupLogEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BackupLogEntityCopyWith<BackupLogEntity> get copyWith => _$BackupLogEntityCopyWithImpl<BackupLogEntity>(this as BackupLogEntity, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as BackupLogEntity;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BackupLogEntity&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.timestamp, _this.timestamp) || other.timestamp == _this.timestamp)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.filePath, _this.filePath) || other.filePath == _this.filePath)&&(identical(other.fileSizeBytes, _this.fileSizeBytes) || other.fileSizeBytes == _this.fileSizeBytes)&&(identical(other.triggerType, _this.triggerType) || other.triggerType == _this.triggerType)&&(identical(other.diagnosticMessage, _this.diagnosticMessage) || other.diagnosticMessage == _this.diagnosticMessage)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}


@override
int get hashCode {
  final _this = this as BackupLogEntity;
  return Object.hash(runtimeType,_this.id,_this.timestamp,_this.status,_this.filePath,_this.fileSizeBytes,_this.triggerType,_this.diagnosticMessage,_this.createdAt);
}

@override
String toString() {
  final _this = this as BackupLogEntity;
  return 'BackupLogEntity(id: ${_this.id}, timestamp: ${_this.timestamp}, status: ${_this.status}, filePath: ${_this.filePath}, fileSizeBytes: ${_this.fileSizeBytes}, triggerType: ${_this.triggerType}, diagnosticMessage: ${_this.diagnosticMessage}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $BackupLogEntityCopyWith<$Res>  {
  factory $BackupLogEntityCopyWith(BackupLogEntity value, $Res Function(BackupLogEntity) _then) = _$BackupLogEntityCopyWithImpl;
@useResult
$Res call({
 String id, String timestamp, String status, String filePath, int fileSizeBytes, String triggerType, String diagnosticMessage, String createdAt
});




}
/// @nodoc
class _$BackupLogEntityCopyWithImpl<$Res>
    implements $BackupLogEntityCopyWith<$Res> {
  _$BackupLogEntityCopyWithImpl(this._self, this._then);

  final BackupLogEntity _self;
  final $Res Function(BackupLogEntity) _then;

/// Create a copy of BackupLogEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? timestamp = null,Object? status = null,Object? filePath = null,Object? fileSizeBytes = null,Object? triggerType = null,Object? diagnosticMessage = null,Object? createdAt = null,}) {
  return _then(BackupLogEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,filePath: null == filePath ? _self.filePath : filePath // ignore: cast_nullable_to_non_nullable
as String,fileSizeBytes: null == fileSizeBytes ? _self.fileSizeBytes : fileSizeBytes // ignore: cast_nullable_to_non_nullable
as int,triggerType: null == triggerType ? _self.triggerType : triggerType // ignore: cast_nullable_to_non_nullable
as String,diagnosticMessage: null == diagnosticMessage ? _self.diagnosticMessage : diagnosticMessage // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [BackupLogEntity].
extension BackupLogEntityPatterns on BackupLogEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BackupLogEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BackupLogEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BackupLogEntity value)  $default,){
final _that = this;
switch (_that) {
case _BackupLogEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BackupLogEntity value)?  $default,){
final _that = this;
switch (_that) {
case _BackupLogEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String timestamp,  String status,  String filePath,  int fileSizeBytes,  String triggerType,  String diagnosticMessage,  String createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BackupLogEntity() when $default != null:
return $default(_that.id,_that.timestamp,_that.status,_that.filePath,_that.fileSizeBytes,_that.triggerType,_that.diagnosticMessage,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String timestamp,  String status,  String filePath,  int fileSizeBytes,  String triggerType,  String diagnosticMessage,  String createdAt)  $default,) {final _that = this;
switch (_that) {
case _BackupLogEntity():
return $default(_that.id,_that.timestamp,_that.status,_that.filePath,_that.fileSizeBytes,_that.triggerType,_that.diagnosticMessage,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String timestamp,  String status,  String filePath,  int fileSizeBytes,  String triggerType,  String diagnosticMessage,  String createdAt)?  $default,) {final _that = this;
switch (_that) {
case _BackupLogEntity() when $default != null:
return $default(_that.id,_that.timestamp,_that.status,_that.filePath,_that.fileSizeBytes,_that.triggerType,_that.diagnosticMessage,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc


class _BackupLogEntity extends BackupLogEntity {
  const _BackupLogEntity({required this.id, required this.timestamp, required this.status, required this.filePath, this.fileSizeBytes = 0, required this.triggerType, this.diagnosticMessage = '', required this.createdAt}): super._();
  

@override final  String id;
@override final  String timestamp;
@override final  String status;
@override final  String filePath;
@override@JsonKey() final  int fileSizeBytes;
@override final  String triggerType;
@override@JsonKey() final  String diagnosticMessage;
@override final  String createdAt;

/// Create a copy of BackupLogEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BackupLogEntityCopyWith<_BackupLogEntity> get copyWith => __$BackupLogEntityCopyWithImpl<_BackupLogEntity>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _BackupLogEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.status, status) || other.status == status)&&(identical(other.filePath, filePath) || other.filePath == filePath)&&(identical(other.fileSizeBytes, fileSizeBytes) || other.fileSizeBytes == fileSizeBytes)&&(identical(other.triggerType, triggerType) || other.triggerType == triggerType)&&(identical(other.diagnosticMessage, diagnosticMessage) || other.diagnosticMessage == diagnosticMessage)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,timestamp,status,filePath,fileSizeBytes,triggerType,diagnosticMessage,createdAt);
}

@override
String toString() {
    return 'BackupLogEntity(id: $id, timestamp: $timestamp, status: $status, filePath: $filePath, fileSizeBytes: $fileSizeBytes, triggerType: $triggerType, diagnosticMessage: $diagnosticMessage, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$BackupLogEntityCopyWith<$Res> implements $BackupLogEntityCopyWith<$Res> {
  factory _$BackupLogEntityCopyWith(_BackupLogEntity value, $Res Function(_BackupLogEntity) _then) = __$BackupLogEntityCopyWithImpl;
@override @useResult
$Res call({
 String id, String timestamp, String status, String filePath, int fileSizeBytes, String triggerType, String diagnosticMessage, String createdAt
});




}
/// @nodoc
class __$BackupLogEntityCopyWithImpl<$Res>
    implements _$BackupLogEntityCopyWith<$Res> {
  __$BackupLogEntityCopyWithImpl(this._self, this._then);

  final _BackupLogEntity _self;
  final $Res Function(_BackupLogEntity) _then;

/// Create a copy of BackupLogEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? timestamp = null,Object? status = null,Object? filePath = null,Object? fileSizeBytes = null,Object? triggerType = null,Object? diagnosticMessage = null,Object? createdAt = null,}) {
  return _then(_BackupLogEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,filePath: null == filePath ? _self.filePath : filePath // ignore: cast_nullable_to_non_nullable
as String,fileSizeBytes: null == fileSizeBytes ? _self.fileSizeBytes : fileSizeBytes // ignore: cast_nullable_to_non_nullable
as int,triggerType: null == triggerType ? _self.triggerType : triggerType // ignore: cast_nullable_to_non_nullable
as String,diagnosticMessage: null == diagnosticMessage ? _self.diagnosticMessage : diagnosticMessage // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
