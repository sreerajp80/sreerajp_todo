// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recurrence_rule_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RecurrenceRuleEntity {

 String get id; String get title; String? get description; String get rrule; String get startDate; String? get endDate; bool get active; TodoPriority? get priority; int? get targetSeconds; List<String>? get subTaskTitles; String get createdAt; String get updatedAt;
/// Create a copy of RecurrenceRuleEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecurrenceRuleEntityCopyWith<RecurrenceRuleEntity> get copyWith => _$RecurrenceRuleEntityCopyWithImpl<RecurrenceRuleEntity>(this as RecurrenceRuleEntity, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as RecurrenceRuleEntity;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecurrenceRuleEntity&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.rrule, _this.rrule) || other.rrule == _this.rrule)&&(identical(other.startDate, _this.startDate) || other.startDate == _this.startDate)&&(identical(other.endDate, _this.endDate) || other.endDate == _this.endDate)&&(identical(other.active, _this.active) || other.active == _this.active)&&(identical(other.priority, _this.priority) || other.priority == _this.priority)&&(identical(other.targetSeconds, _this.targetSeconds) || other.targetSeconds == _this.targetSeconds)&&const DeepCollectionEquality().equals(other.subTaskTitles, _this.subTaskTitles)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt));
}


@override
int get hashCode {
  final _this = this as RecurrenceRuleEntity;
  return Object.hash(runtimeType,_this.id,_this.title,_this.description,_this.rrule,_this.startDate,_this.endDate,_this.active,_this.priority,_this.targetSeconds,const DeepCollectionEquality().hash(_this.subTaskTitles),_this.createdAt,_this.updatedAt);
}

@override
String toString() {
  final _this = this as RecurrenceRuleEntity;
  return 'RecurrenceRuleEntity(id: ${_this.id}, title: ${_this.title}, description: ${_this.description}, rrule: ${_this.rrule}, startDate: ${_this.startDate}, endDate: ${_this.endDate}, active: ${_this.active}, priority: ${_this.priority}, targetSeconds: ${_this.targetSeconds}, subTaskTitles: ${_this.subTaskTitles}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt})';
}


}

/// @nodoc
abstract mixin class $RecurrenceRuleEntityCopyWith<$Res>  {
  factory $RecurrenceRuleEntityCopyWith(RecurrenceRuleEntity value, $Res Function(RecurrenceRuleEntity) _then) = _$RecurrenceRuleEntityCopyWithImpl;
@useResult
$Res call({
 String id, String title, String? description, String rrule, String startDate, String? endDate, bool active, TodoPriority? priority, int? targetSeconds, List<String>? subTaskTitles, String createdAt, String updatedAt
});




}
/// @nodoc
class _$RecurrenceRuleEntityCopyWithImpl<$Res>
    implements $RecurrenceRuleEntityCopyWith<$Res> {
  _$RecurrenceRuleEntityCopyWithImpl(this._self, this._then);

  final RecurrenceRuleEntity _self;
  final $Res Function(RecurrenceRuleEntity) _then;

/// Create a copy of RecurrenceRuleEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? description = freezed,Object? rrule = null,Object? startDate = null,Object? endDate = freezed,Object? active = null,Object? priority = freezed,Object? targetSeconds = freezed,Object? subTaskTitles = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(RecurrenceRuleEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,rrule: null == rrule ? _self.rrule : rrule // ignore: cast_nullable_to_non_nullable
as String,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as String,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as String?,active: null == active ? _self.active : active // ignore: cast_nullable_to_non_nullable
as bool,priority: freezed == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as TodoPriority?,targetSeconds: freezed == targetSeconds ? _self.targetSeconds : targetSeconds // ignore: cast_nullable_to_non_nullable
as int?,subTaskTitles: freezed == subTaskTitles ? _self.subTaskTitles : subTaskTitles // ignore: cast_nullable_to_non_nullable
as List<String>?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [RecurrenceRuleEntity].
extension RecurrenceRuleEntityPatterns on RecurrenceRuleEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecurrenceRuleEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecurrenceRuleEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecurrenceRuleEntity value)  $default,){
final _that = this;
switch (_that) {
case _RecurrenceRuleEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecurrenceRuleEntity value)?  $default,){
final _that = this;
switch (_that) {
case _RecurrenceRuleEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String? description,  String rrule,  String startDate,  String? endDate,  bool active,  TodoPriority? priority,  int? targetSeconds,  List<String>? subTaskTitles,  String createdAt,  String updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecurrenceRuleEntity() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.rrule,_that.startDate,_that.endDate,_that.active,_that.priority,_that.targetSeconds,_that.subTaskTitles,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String? description,  String rrule,  String startDate,  String? endDate,  bool active,  TodoPriority? priority,  int? targetSeconds,  List<String>? subTaskTitles,  String createdAt,  String updatedAt)  $default,) {final _that = this;
switch (_that) {
case _RecurrenceRuleEntity():
return $default(_that.id,_that.title,_that.description,_that.rrule,_that.startDate,_that.endDate,_that.active,_that.priority,_that.targetSeconds,_that.subTaskTitles,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String? description,  String rrule,  String startDate,  String? endDate,  bool active,  TodoPriority? priority,  int? targetSeconds,  List<String>? subTaskTitles,  String createdAt,  String updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _RecurrenceRuleEntity() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.rrule,_that.startDate,_that.endDate,_that.active,_that.priority,_that.targetSeconds,_that.subTaskTitles,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc


class _RecurrenceRuleEntity extends RecurrenceRuleEntity {
  const _RecurrenceRuleEntity({required this.id, required this.title, this.description, required this.rrule, required this.startDate, this.endDate, this.active = true, this.priority, this.targetSeconds,  List<String>? subTaskTitles, required this.createdAt, required this.updatedAt}): _subTaskTitles = subTaskTitles,super._();
  

@override final  String id;
@override final  String title;
@override final  String? description;
@override final  String rrule;
@override final  String startDate;
@override final  String? endDate;
@override@JsonKey() final  bool active;
@override final  TodoPriority? priority;
@override final  int? targetSeconds;
 final  List<String>? _subTaskTitles;
@override List<String>? get subTaskTitles {
  final value = _subTaskTitles;
  if (value == null) return null;
  if (_subTaskTitles is EqualUnmodifiableListView) return _subTaskTitles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  String createdAt;
@override final  String updatedAt;

/// Create a copy of RecurrenceRuleEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecurrenceRuleEntityCopyWith<_RecurrenceRuleEntity> get copyWith => __$RecurrenceRuleEntityCopyWithImpl<_RecurrenceRuleEntity>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecurrenceRuleEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.rrule, rrule) || other.rrule == rrule)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.active, active) || other.active == active)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.targetSeconds, targetSeconds) || other.targetSeconds == targetSeconds)&&const DeepCollectionEquality().equals(other.subTaskTitles, _subTaskTitles)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,title,description,rrule,startDate,endDate,active,priority,targetSeconds,const DeepCollectionEquality().hash(_subTaskTitles),createdAt,updatedAt);
}

@override
String toString() {
    return 'RecurrenceRuleEntity(id: $id, title: $title, description: $description, rrule: $rrule, startDate: $startDate, endDate: $endDate, active: $active, priority: $priority, targetSeconds: $targetSeconds, subTaskTitles: $subTaskTitles, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$RecurrenceRuleEntityCopyWith<$Res> implements $RecurrenceRuleEntityCopyWith<$Res> {
  factory _$RecurrenceRuleEntityCopyWith(_RecurrenceRuleEntity value, $Res Function(_RecurrenceRuleEntity) _then) = __$RecurrenceRuleEntityCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String? description, String rrule, String startDate, String? endDate, bool active, TodoPriority? priority, int? targetSeconds, List<String>? subTaskTitles, String createdAt, String updatedAt
});




}
/// @nodoc
class __$RecurrenceRuleEntityCopyWithImpl<$Res>
    implements _$RecurrenceRuleEntityCopyWith<$Res> {
  __$RecurrenceRuleEntityCopyWithImpl(this._self, this._then);

  final _RecurrenceRuleEntity _self;
  final $Res Function(_RecurrenceRuleEntity) _then;

/// Create a copy of RecurrenceRuleEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? description = freezed,Object? rrule = null,Object? startDate = null,Object? endDate = freezed,Object? active = null,Object? priority = freezed,Object? targetSeconds = freezed,Object? subTaskTitles = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_RecurrenceRuleEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,rrule: null == rrule ? _self.rrule : rrule // ignore: cast_nullable_to_non_nullable
as String,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as String,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as String?,active: null == active ? _self.active : active // ignore: cast_nullable_to_non_nullable
as bool,priority: freezed == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as TodoPriority?,targetSeconds: freezed == targetSeconds ? _self.targetSeconds : targetSeconds // ignore: cast_nullable_to_non_nullable
as int?,subTaskTitles: freezed == subTaskTitles ? _self._subTaskTitles : subTaskTitles // ignore: cast_nullable_to_non_nullable
as List<String>?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
