// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sub_task_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SubTaskItem {

 String get id; String get todoId; String get title; bool get isCompleted; int get sortOrder; String get createdAt; String get updatedAt;
/// Create a copy of SubTaskItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SubTaskItemCopyWith<SubTaskItem> get copyWith => _$SubTaskItemCopyWithImpl<SubTaskItem>(this as SubTaskItem, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SubTaskItem;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SubTaskItem&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.todoId, _this.todoId) || other.todoId == _this.todoId)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.isCompleted, _this.isCompleted) || other.isCompleted == _this.isCompleted)&&(identical(other.sortOrder, _this.sortOrder) || other.sortOrder == _this.sortOrder)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt));
}


@override
int get hashCode {
  final _this = this as SubTaskItem;
  return Object.hash(runtimeType,_this.id,_this.todoId,_this.title,_this.isCompleted,_this.sortOrder,_this.createdAt,_this.updatedAt);
}

@override
String toString() {
  final _this = this as SubTaskItem;
  return 'SubTaskItem(id: ${_this.id}, todoId: ${_this.todoId}, title: ${_this.title}, isCompleted: ${_this.isCompleted}, sortOrder: ${_this.sortOrder}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt})';
}


}

/// @nodoc
abstract mixin class $SubTaskItemCopyWith<$Res>  {
  factory $SubTaskItemCopyWith(SubTaskItem value, $Res Function(SubTaskItem) _then) = _$SubTaskItemCopyWithImpl;
@useResult
$Res call({
 String id, String todoId, String title, bool isCompleted, int sortOrder, String createdAt, String updatedAt
});




}
/// @nodoc
class _$SubTaskItemCopyWithImpl<$Res>
    implements $SubTaskItemCopyWith<$Res> {
  _$SubTaskItemCopyWithImpl(this._self, this._then);

  final SubTaskItem _self;
  final $Res Function(SubTaskItem) _then;

/// Create a copy of SubTaskItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? todoId = null,Object? title = null,Object? isCompleted = null,Object? sortOrder = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(SubTaskItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,todoId: null == todoId ? _self.todoId : todoId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,isCompleted: null == isCompleted ? _self.isCompleted : isCompleted // ignore: cast_nullable_to_non_nullable
as bool,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SubTaskItem].
extension SubTaskItemPatterns on SubTaskItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SubTaskItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SubTaskItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SubTaskItem value)  $default,){
final _that = this;
switch (_that) {
case _SubTaskItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SubTaskItem value)?  $default,){
final _that = this;
switch (_that) {
case _SubTaskItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String todoId,  String title,  bool isCompleted,  int sortOrder,  String createdAt,  String updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SubTaskItem() when $default != null:
return $default(_that.id,_that.todoId,_that.title,_that.isCompleted,_that.sortOrder,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String todoId,  String title,  bool isCompleted,  int sortOrder,  String createdAt,  String updatedAt)  $default,) {final _that = this;
switch (_that) {
case _SubTaskItem():
return $default(_that.id,_that.todoId,_that.title,_that.isCompleted,_that.sortOrder,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String todoId,  String title,  bool isCompleted,  int sortOrder,  String createdAt,  String updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _SubTaskItem() when $default != null:
return $default(_that.id,_that.todoId,_that.title,_that.isCompleted,_that.sortOrder,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc


class _SubTaskItem extends SubTaskItem {
  const _SubTaskItem({required this.id, required this.todoId, required this.title, this.isCompleted = false, this.sortOrder = 0, required this.createdAt, required this.updatedAt}): super._();
  

@override final  String id;
@override final  String todoId;
@override final  String title;
@override@JsonKey() final  bool isCompleted;
@override@JsonKey() final  int sortOrder;
@override final  String createdAt;
@override final  String updatedAt;

/// Create a copy of SubTaskItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SubTaskItemCopyWith<_SubTaskItem> get copyWith => __$SubTaskItemCopyWithImpl<_SubTaskItem>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SubTaskItem&&(identical(other.id, id) || other.id == id)&&(identical(other.todoId, todoId) || other.todoId == todoId)&&(identical(other.title, title) || other.title == title)&&(identical(other.isCompleted, isCompleted) || other.isCompleted == isCompleted)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,todoId,title,isCompleted,sortOrder,createdAt,updatedAt);
}

@override
String toString() {
    return 'SubTaskItem(id: $id, todoId: $todoId, title: $title, isCompleted: $isCompleted, sortOrder: $sortOrder, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$SubTaskItemCopyWith<$Res> implements $SubTaskItemCopyWith<$Res> {
  factory _$SubTaskItemCopyWith(_SubTaskItem value, $Res Function(_SubTaskItem) _then) = __$SubTaskItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String todoId, String title, bool isCompleted, int sortOrder, String createdAt, String updatedAt
});




}
/// @nodoc
class __$SubTaskItemCopyWithImpl<$Res>
    implements _$SubTaskItemCopyWith<$Res> {
  __$SubTaskItemCopyWithImpl(this._self, this._then);

  final _SubTaskItem _self;
  final $Res Function(_SubTaskItem) _then;

/// Create a copy of SubTaskItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? todoId = null,Object? title = null,Object? isCompleted = null,Object? sortOrder = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_SubTaskItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,todoId: null == todoId ? _self.todoId : todoId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,isCompleted: null == isCompleted ? _self.isCompleted : isCompleted // ignore: cast_nullable_to_non_nullable
as bool,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
