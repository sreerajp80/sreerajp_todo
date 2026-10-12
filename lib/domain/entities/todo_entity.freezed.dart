// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'todo_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TodoEntity {

 String get id; String get date; String get title; String? get description; TodoStatus get status; TodoPriority get priority; int? get targetSeconds; String? get portedTo; String? get sourceDate; String? get recurrenceRuleId; String? get spacedRepetitionItemId; int get sortOrder; List<SubTaskItem> get subTasks; List<String> get prerequisiteTodoIds; String get createdAt; String get updatedAt;
/// Create a copy of TodoEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TodoEntityCopyWith<TodoEntity> get copyWith => _$TodoEntityCopyWithImpl<TodoEntity>(this as TodoEntity, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TodoEntity;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TodoEntity&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.date, _this.date) || other.date == _this.date)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.priority, _this.priority) || other.priority == _this.priority)&&(identical(other.targetSeconds, _this.targetSeconds) || other.targetSeconds == _this.targetSeconds)&&(identical(other.portedTo, _this.portedTo) || other.portedTo == _this.portedTo)&&(identical(other.sourceDate, _this.sourceDate) || other.sourceDate == _this.sourceDate)&&(identical(other.recurrenceRuleId, _this.recurrenceRuleId) || other.recurrenceRuleId == _this.recurrenceRuleId)&&(identical(other.spacedRepetitionItemId, _this.spacedRepetitionItemId) || other.spacedRepetitionItemId == _this.spacedRepetitionItemId)&&(identical(other.sortOrder, _this.sortOrder) || other.sortOrder == _this.sortOrder)&&const DeepCollectionEquality().equals(other.subTasks, _this.subTasks)&&const DeepCollectionEquality().equals(other.prerequisiteTodoIds, _this.prerequisiteTodoIds)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt));
}


@override
int get hashCode {
  final _this = this as TodoEntity;
  return Object.hash(runtimeType,_this.id,_this.date,_this.title,_this.description,_this.status,_this.priority,_this.targetSeconds,_this.portedTo,_this.sourceDate,_this.recurrenceRuleId,_this.spacedRepetitionItemId,_this.sortOrder,const DeepCollectionEquality().hash(_this.subTasks),const DeepCollectionEquality().hash(_this.prerequisiteTodoIds),_this.createdAt,_this.updatedAt);
}

@override
String toString() {
  final _this = this as TodoEntity;
  return 'TodoEntity(id: ${_this.id}, date: ${_this.date}, title: ${_this.title}, description: ${_this.description}, status: ${_this.status}, priority: ${_this.priority}, targetSeconds: ${_this.targetSeconds}, portedTo: ${_this.portedTo}, sourceDate: ${_this.sourceDate}, recurrenceRuleId: ${_this.recurrenceRuleId}, spacedRepetitionItemId: ${_this.spacedRepetitionItemId}, sortOrder: ${_this.sortOrder}, subTasks: ${_this.subTasks}, prerequisiteTodoIds: ${_this.prerequisiteTodoIds}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt})';
}


}

/// @nodoc
abstract mixin class $TodoEntityCopyWith<$Res>  {
  factory $TodoEntityCopyWith(TodoEntity value, $Res Function(TodoEntity) _then) = _$TodoEntityCopyWithImpl;
@useResult
$Res call({
 String id, String date, String title, String? description, TodoStatus status, TodoPriority priority, int? targetSeconds, String? portedTo, String? sourceDate, String? recurrenceRuleId, String? spacedRepetitionItemId, int sortOrder, List<SubTaskItem> subTasks, List<String> prerequisiteTodoIds, String createdAt, String updatedAt
});




}
/// @nodoc
class _$TodoEntityCopyWithImpl<$Res>
    implements $TodoEntityCopyWith<$Res> {
  _$TodoEntityCopyWithImpl(this._self, this._then);

  final TodoEntity _self;
  final $Res Function(TodoEntity) _then;

/// Create a copy of TodoEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? date = null,Object? title = null,Object? description = freezed,Object? status = null,Object? priority = null,Object? targetSeconds = freezed,Object? portedTo = freezed,Object? sourceDate = freezed,Object? recurrenceRuleId = freezed,Object? spacedRepetitionItemId = freezed,Object? sortOrder = null,Object? subTasks = null,Object? prerequisiteTodoIds = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(TodoEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TodoStatus,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as TodoPriority,targetSeconds: freezed == targetSeconds ? _self.targetSeconds : targetSeconds // ignore: cast_nullable_to_non_nullable
as int?,portedTo: freezed == portedTo ? _self.portedTo : portedTo // ignore: cast_nullable_to_non_nullable
as String?,sourceDate: freezed == sourceDate ? _self.sourceDate : sourceDate // ignore: cast_nullable_to_non_nullable
as String?,recurrenceRuleId: freezed == recurrenceRuleId ? _self.recurrenceRuleId : recurrenceRuleId // ignore: cast_nullable_to_non_nullable
as String?,spacedRepetitionItemId: freezed == spacedRepetitionItemId ? _self.spacedRepetitionItemId : spacedRepetitionItemId // ignore: cast_nullable_to_non_nullable
as String?,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,subTasks: null == subTasks ? _self.subTasks : subTasks // ignore: cast_nullable_to_non_nullable
as List<SubTaskItem>,prerequisiteTodoIds: null == prerequisiteTodoIds ? _self.prerequisiteTodoIds : prerequisiteTodoIds // ignore: cast_nullable_to_non_nullable
as List<String>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [TodoEntity].
extension TodoEntityPatterns on TodoEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TodoEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TodoEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TodoEntity value)  $default,){
final _that = this;
switch (_that) {
case _TodoEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TodoEntity value)?  $default,){
final _that = this;
switch (_that) {
case _TodoEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String date,  String title,  String? description,  TodoStatus status,  TodoPriority priority,  int? targetSeconds,  String? portedTo,  String? sourceDate,  String? recurrenceRuleId,  String? spacedRepetitionItemId,  int sortOrder,  List<SubTaskItem> subTasks,  List<String> prerequisiteTodoIds,  String createdAt,  String updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TodoEntity() when $default != null:
return $default(_that.id,_that.date,_that.title,_that.description,_that.status,_that.priority,_that.targetSeconds,_that.portedTo,_that.sourceDate,_that.recurrenceRuleId,_that.spacedRepetitionItemId,_that.sortOrder,_that.subTasks,_that.prerequisiteTodoIds,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String date,  String title,  String? description,  TodoStatus status,  TodoPriority priority,  int? targetSeconds,  String? portedTo,  String? sourceDate,  String? recurrenceRuleId,  String? spacedRepetitionItemId,  int sortOrder,  List<SubTaskItem> subTasks,  List<String> prerequisiteTodoIds,  String createdAt,  String updatedAt)  $default,) {final _that = this;
switch (_that) {
case _TodoEntity():
return $default(_that.id,_that.date,_that.title,_that.description,_that.status,_that.priority,_that.targetSeconds,_that.portedTo,_that.sourceDate,_that.recurrenceRuleId,_that.spacedRepetitionItemId,_that.sortOrder,_that.subTasks,_that.prerequisiteTodoIds,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String date,  String title,  String? description,  TodoStatus status,  TodoPriority priority,  int? targetSeconds,  String? portedTo,  String? sourceDate,  String? recurrenceRuleId,  String? spacedRepetitionItemId,  int sortOrder,  List<SubTaskItem> subTasks,  List<String> prerequisiteTodoIds,  String createdAt,  String updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _TodoEntity() when $default != null:
return $default(_that.id,_that.date,_that.title,_that.description,_that.status,_that.priority,_that.targetSeconds,_that.portedTo,_that.sourceDate,_that.recurrenceRuleId,_that.spacedRepetitionItemId,_that.sortOrder,_that.subTasks,_that.prerequisiteTodoIds,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc


class _TodoEntity extends TodoEntity {
  const _TodoEntity({required this.id, required this.date, required this.title, this.description, this.status = TodoStatus.pending, this.priority = TodoPriority.normal, this.targetSeconds, this.portedTo, this.sourceDate, this.recurrenceRuleId, this.spacedRepetitionItemId, this.sortOrder = 0,  List<SubTaskItem> subTasks = const [],  List<String> prerequisiteTodoIds = const [], required this.createdAt, required this.updatedAt}): _subTasks = subTasks,_prerequisiteTodoIds = prerequisiteTodoIds,super._();
  

@override final  String id;
@override final  String date;
@override final  String title;
@override final  String? description;
@override@JsonKey() final  TodoStatus status;
@override@JsonKey() final  TodoPriority priority;
@override final  int? targetSeconds;
@override final  String? portedTo;
@override final  String? sourceDate;
@override final  String? recurrenceRuleId;
@override final  String? spacedRepetitionItemId;
@override@JsonKey() final  int sortOrder;
 final  List<SubTaskItem> _subTasks;
@override@JsonKey() List<SubTaskItem> get subTasks {
  if (_subTasks is EqualUnmodifiableListView) return _subTasks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_subTasks);
}

 final  List<String> _prerequisiteTodoIds;
@override@JsonKey() List<String> get prerequisiteTodoIds {
  if (_prerequisiteTodoIds is EqualUnmodifiableListView) return _prerequisiteTodoIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_prerequisiteTodoIds);
}

@override final  String createdAt;
@override final  String updatedAt;

/// Create a copy of TodoEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TodoEntityCopyWith<_TodoEntity> get copyWith => __$TodoEntityCopyWithImpl<_TodoEntity>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TodoEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.date, date) || other.date == date)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.status, status) || other.status == status)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.targetSeconds, targetSeconds) || other.targetSeconds == targetSeconds)&&(identical(other.portedTo, portedTo) || other.portedTo == portedTo)&&(identical(other.sourceDate, sourceDate) || other.sourceDate == sourceDate)&&(identical(other.recurrenceRuleId, recurrenceRuleId) || other.recurrenceRuleId == recurrenceRuleId)&&(identical(other.spacedRepetitionItemId, spacedRepetitionItemId) || other.spacedRepetitionItemId == spacedRepetitionItemId)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&const DeepCollectionEquality().equals(other.subTasks, _subTasks)&&const DeepCollectionEquality().equals(other.prerequisiteTodoIds, _prerequisiteTodoIds)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,date,title,description,status,priority,targetSeconds,portedTo,sourceDate,recurrenceRuleId,spacedRepetitionItemId,sortOrder,const DeepCollectionEquality().hash(_subTasks),const DeepCollectionEquality().hash(_prerequisiteTodoIds),createdAt,updatedAt);
}

@override
String toString() {
    return 'TodoEntity(id: $id, date: $date, title: $title, description: $description, status: $status, priority: $priority, targetSeconds: $targetSeconds, portedTo: $portedTo, sourceDate: $sourceDate, recurrenceRuleId: $recurrenceRuleId, spacedRepetitionItemId: $spacedRepetitionItemId, sortOrder: $sortOrder, subTasks: $subTasks, prerequisiteTodoIds: $prerequisiteTodoIds, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$TodoEntityCopyWith<$Res> implements $TodoEntityCopyWith<$Res> {
  factory _$TodoEntityCopyWith(_TodoEntity value, $Res Function(_TodoEntity) _then) = __$TodoEntityCopyWithImpl;
@override @useResult
$Res call({
 String id, String date, String title, String? description, TodoStatus status, TodoPriority priority, int? targetSeconds, String? portedTo, String? sourceDate, String? recurrenceRuleId, String? spacedRepetitionItemId, int sortOrder, List<SubTaskItem> subTasks, List<String> prerequisiteTodoIds, String createdAt, String updatedAt
});




}
/// @nodoc
class __$TodoEntityCopyWithImpl<$Res>
    implements _$TodoEntityCopyWith<$Res> {
  __$TodoEntityCopyWithImpl(this._self, this._then);

  final _TodoEntity _self;
  final $Res Function(_TodoEntity) _then;

/// Create a copy of TodoEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? date = null,Object? title = null,Object? description = freezed,Object? status = null,Object? priority = null,Object? targetSeconds = freezed,Object? portedTo = freezed,Object? sourceDate = freezed,Object? recurrenceRuleId = freezed,Object? spacedRepetitionItemId = freezed,Object? sortOrder = null,Object? subTasks = null,Object? prerequisiteTodoIds = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_TodoEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TodoStatus,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as TodoPriority,targetSeconds: freezed == targetSeconds ? _self.targetSeconds : targetSeconds // ignore: cast_nullable_to_non_nullable
as int?,portedTo: freezed == portedTo ? _self.portedTo : portedTo // ignore: cast_nullable_to_non_nullable
as String?,sourceDate: freezed == sourceDate ? _self.sourceDate : sourceDate // ignore: cast_nullable_to_non_nullable
as String?,recurrenceRuleId: freezed == recurrenceRuleId ? _self.recurrenceRuleId : recurrenceRuleId // ignore: cast_nullable_to_non_nullable
as String?,spacedRepetitionItemId: freezed == spacedRepetitionItemId ? _self.spacedRepetitionItemId : spacedRepetitionItemId // ignore: cast_nullable_to_non_nullable
as String?,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,subTasks: null == subTasks ? _self._subTasks : subTasks // ignore: cast_nullable_to_non_nullable
as List<SubTaskItem>,prerequisiteTodoIds: null == prerequisiteTodoIds ? _self._prerequisiteTodoIds : prerequisiteTodoIds // ignore: cast_nullable_to_non_nullable
as List<String>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
