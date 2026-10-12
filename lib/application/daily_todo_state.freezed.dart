// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'daily_todo_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DailyTodoState {

 List<TodoEntity> get todos; bool get isLoading; String? get error; List<UndoEntry> get undoStack; Set<String> get selectedIds; bool get isMultiSelectMode;
/// Create a copy of DailyTodoState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DailyTodoStateCopyWith<DailyTodoState> get copyWith => _$DailyTodoStateCopyWithImpl<DailyTodoState>(this as DailyTodoState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as DailyTodoState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DailyTodoState&&const DeepCollectionEquality().equals(other.todos, _this.todos)&&(identical(other.isLoading, _this.isLoading) || other.isLoading == _this.isLoading)&&(identical(other.error, _this.error) || other.error == _this.error)&&const DeepCollectionEquality().equals(other.undoStack, _this.undoStack)&&const DeepCollectionEquality().equals(other.selectedIds, _this.selectedIds)&&(identical(other.isMultiSelectMode, _this.isMultiSelectMode) || other.isMultiSelectMode == _this.isMultiSelectMode));
}


@override
int get hashCode {
  final _this = this as DailyTodoState;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.todos),_this.isLoading,_this.error,const DeepCollectionEquality().hash(_this.undoStack),const DeepCollectionEquality().hash(_this.selectedIds),_this.isMultiSelectMode);
}

@override
String toString() {
  final _this = this as DailyTodoState;
  return 'DailyTodoState(todos: ${_this.todos}, isLoading: ${_this.isLoading}, error: ${_this.error}, undoStack: ${_this.undoStack}, selectedIds: ${_this.selectedIds}, isMultiSelectMode: ${_this.isMultiSelectMode})';
}


}

/// @nodoc
abstract mixin class $DailyTodoStateCopyWith<$Res>  {
  factory $DailyTodoStateCopyWith(DailyTodoState value, $Res Function(DailyTodoState) _then) = _$DailyTodoStateCopyWithImpl;
@useResult
$Res call({
 List<TodoEntity> todos, bool isLoading, String? error, List<UndoEntry> undoStack, Set<String> selectedIds, bool isMultiSelectMode
});




}
/// @nodoc
class _$DailyTodoStateCopyWithImpl<$Res>
    implements $DailyTodoStateCopyWith<$Res> {
  _$DailyTodoStateCopyWithImpl(this._self, this._then);

  final DailyTodoState _self;
  final $Res Function(DailyTodoState) _then;

/// Create a copy of DailyTodoState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? todos = null,Object? isLoading = null,Object? error = freezed,Object? undoStack = null,Object? selectedIds = null,Object? isMultiSelectMode = null,}) {
  return _then(DailyTodoState(
todos: null == todos ? _self.todos : todos // ignore: cast_nullable_to_non_nullable
as List<TodoEntity>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,undoStack: null == undoStack ? _self.undoStack : undoStack // ignore: cast_nullable_to_non_nullable
as List<UndoEntry>,selectedIds: null == selectedIds ? _self.selectedIds : selectedIds // ignore: cast_nullable_to_non_nullable
as Set<String>,isMultiSelectMode: null == isMultiSelectMode ? _self.isMultiSelectMode : isMultiSelectMode // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [DailyTodoState].
extension DailyTodoStatePatterns on DailyTodoState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DailyTodoState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DailyTodoState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DailyTodoState value)  $default,){
final _that = this;
switch (_that) {
case _DailyTodoState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DailyTodoState value)?  $default,){
final _that = this;
switch (_that) {
case _DailyTodoState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<TodoEntity> todos,  bool isLoading,  String? error,  List<UndoEntry> undoStack,  Set<String> selectedIds,  bool isMultiSelectMode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DailyTodoState() when $default != null:
return $default(_that.todos,_that.isLoading,_that.error,_that.undoStack,_that.selectedIds,_that.isMultiSelectMode);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<TodoEntity> todos,  bool isLoading,  String? error,  List<UndoEntry> undoStack,  Set<String> selectedIds,  bool isMultiSelectMode)  $default,) {final _that = this;
switch (_that) {
case _DailyTodoState():
return $default(_that.todos,_that.isLoading,_that.error,_that.undoStack,_that.selectedIds,_that.isMultiSelectMode);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<TodoEntity> todos,  bool isLoading,  String? error,  List<UndoEntry> undoStack,  Set<String> selectedIds,  bool isMultiSelectMode)?  $default,) {final _that = this;
switch (_that) {
case _DailyTodoState() when $default != null:
return $default(_that.todos,_that.isLoading,_that.error,_that.undoStack,_that.selectedIds,_that.isMultiSelectMode);case _:
  return null;

}
}

}

/// @nodoc


class _DailyTodoState implements DailyTodoState {
  const _DailyTodoState({ List<TodoEntity> todos = const [], this.isLoading = false, this.error,  List<UndoEntry> undoStack = const [],  Set<String> selectedIds = const {}, this.isMultiSelectMode = false}): _todos = todos,_undoStack = undoStack,_selectedIds = selectedIds;
  

 final  List<TodoEntity> _todos;
@override@JsonKey() List<TodoEntity> get todos {
  if (_todos is EqualUnmodifiableListView) return _todos;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_todos);
}

@override@JsonKey() final  bool isLoading;
@override final  String? error;
 final  List<UndoEntry> _undoStack;
@override@JsonKey() List<UndoEntry> get undoStack {
  if (_undoStack is EqualUnmodifiableListView) return _undoStack;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_undoStack);
}

 final  Set<String> _selectedIds;
@override@JsonKey() Set<String> get selectedIds {
  if (_selectedIds is EqualUnmodifiableSetView) return _selectedIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_selectedIds);
}

@override@JsonKey() final  bool isMultiSelectMode;

/// Create a copy of DailyTodoState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DailyTodoStateCopyWith<_DailyTodoState> get copyWith => __$DailyTodoStateCopyWithImpl<_DailyTodoState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DailyTodoState&&const DeepCollectionEquality().equals(other.todos, _todos)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.error, error) || other.error == error)&&const DeepCollectionEquality().equals(other.undoStack, _undoStack)&&const DeepCollectionEquality().equals(other.selectedIds, _selectedIds)&&(identical(other.isMultiSelectMode, isMultiSelectMode) || other.isMultiSelectMode == isMultiSelectMode));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_todos),isLoading,error,const DeepCollectionEquality().hash(_undoStack),const DeepCollectionEquality().hash(_selectedIds),isMultiSelectMode);
}

@override
String toString() {
    return 'DailyTodoState(todos: $todos, isLoading: $isLoading, error: $error, undoStack: $undoStack, selectedIds: $selectedIds, isMultiSelectMode: $isMultiSelectMode)';
}


}

/// @nodoc
abstract mixin class _$DailyTodoStateCopyWith<$Res> implements $DailyTodoStateCopyWith<$Res> {
  factory _$DailyTodoStateCopyWith(_DailyTodoState value, $Res Function(_DailyTodoState) _then) = __$DailyTodoStateCopyWithImpl;
@override @useResult
$Res call({
 List<TodoEntity> todos, bool isLoading, String? error, List<UndoEntry> undoStack, Set<String> selectedIds, bool isMultiSelectMode
});




}
/// @nodoc
class __$DailyTodoStateCopyWithImpl<$Res>
    implements _$DailyTodoStateCopyWith<$Res> {
  __$DailyTodoStateCopyWithImpl(this._self, this._then);

  final _DailyTodoState _self;
  final $Res Function(_DailyTodoState) _then;

/// Create a copy of DailyTodoState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? todos = null,Object? isLoading = null,Object? error = freezed,Object? undoStack = null,Object? selectedIds = null,Object? isMultiSelectMode = null,}) {
  return _then(_DailyTodoState(
todos: null == todos ? _self._todos : todos // ignore: cast_nullable_to_non_nullable
as List<TodoEntity>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,undoStack: null == undoStack ? _self._undoStack : undoStack // ignore: cast_nullable_to_non_nullable
as List<UndoEntry>,selectedIds: null == selectedIds ? _self._selectedIds : selectedIds // ignore: cast_nullable_to_non_nullable
as Set<String>,isMultiSelectMode: null == isMultiSelectMode ? _self.isMultiSelectMode : isMultiSelectMode // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$UndoEntry {

 String get todoId; TodoStatus get oldStatus; TodoStatus get newStatus; String? get copiedTodoId; String? get sourceDate; String? get targetDate; bool get isMove; String? get previousSourceDate; DateTime get timestamp;
/// Create a copy of UndoEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UndoEntryCopyWith<UndoEntry> get copyWith => _$UndoEntryCopyWithImpl<UndoEntry>(this as UndoEntry, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as UndoEntry;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UndoEntry&&(identical(other.todoId, _this.todoId) || other.todoId == _this.todoId)&&(identical(other.oldStatus, _this.oldStatus) || other.oldStatus == _this.oldStatus)&&(identical(other.newStatus, _this.newStatus) || other.newStatus == _this.newStatus)&&(identical(other.copiedTodoId, _this.copiedTodoId) || other.copiedTodoId == _this.copiedTodoId)&&(identical(other.sourceDate, _this.sourceDate) || other.sourceDate == _this.sourceDate)&&(identical(other.targetDate, _this.targetDate) || other.targetDate == _this.targetDate)&&(identical(other.isMove, _this.isMove) || other.isMove == _this.isMove)&&(identical(other.previousSourceDate, _this.previousSourceDate) || other.previousSourceDate == _this.previousSourceDate)&&(identical(other.timestamp, _this.timestamp) || other.timestamp == _this.timestamp));
}


@override
int get hashCode {
  final _this = this as UndoEntry;
  return Object.hash(runtimeType,_this.todoId,_this.oldStatus,_this.newStatus,_this.copiedTodoId,_this.sourceDate,_this.targetDate,_this.isMove,_this.previousSourceDate,_this.timestamp);
}

@override
String toString() {
  final _this = this as UndoEntry;
  return 'UndoEntry(todoId: ${_this.todoId}, oldStatus: ${_this.oldStatus}, newStatus: ${_this.newStatus}, copiedTodoId: ${_this.copiedTodoId}, sourceDate: ${_this.sourceDate}, targetDate: ${_this.targetDate}, isMove: ${_this.isMove}, previousSourceDate: ${_this.previousSourceDate}, timestamp: ${_this.timestamp})';
}


}

/// @nodoc
abstract mixin class $UndoEntryCopyWith<$Res>  {
  factory $UndoEntryCopyWith(UndoEntry value, $Res Function(UndoEntry) _then) = _$UndoEntryCopyWithImpl;
@useResult
$Res call({
 String todoId, TodoStatus oldStatus, TodoStatus newStatus, String? copiedTodoId, String? sourceDate, String? targetDate, bool isMove, String? previousSourceDate, DateTime timestamp
});




}
/// @nodoc
class _$UndoEntryCopyWithImpl<$Res>
    implements $UndoEntryCopyWith<$Res> {
  _$UndoEntryCopyWithImpl(this._self, this._then);

  final UndoEntry _self;
  final $Res Function(UndoEntry) _then;

/// Create a copy of UndoEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? todoId = null,Object? oldStatus = null,Object? newStatus = null,Object? copiedTodoId = freezed,Object? sourceDate = freezed,Object? targetDate = freezed,Object? isMove = null,Object? previousSourceDate = freezed,Object? timestamp = null,}) {
  return _then(UndoEntry(
todoId: null == todoId ? _self.todoId : todoId // ignore: cast_nullable_to_non_nullable
as String,oldStatus: null == oldStatus ? _self.oldStatus : oldStatus // ignore: cast_nullable_to_non_nullable
as TodoStatus,newStatus: null == newStatus ? _self.newStatus : newStatus // ignore: cast_nullable_to_non_nullable
as TodoStatus,copiedTodoId: freezed == copiedTodoId ? _self.copiedTodoId : copiedTodoId // ignore: cast_nullable_to_non_nullable
as String?,sourceDate: freezed == sourceDate ? _self.sourceDate : sourceDate // ignore: cast_nullable_to_non_nullable
as String?,targetDate: freezed == targetDate ? _self.targetDate : targetDate // ignore: cast_nullable_to_non_nullable
as String?,isMove: null == isMove ? _self.isMove : isMove // ignore: cast_nullable_to_non_nullable
as bool,previousSourceDate: freezed == previousSourceDate ? _self.previousSourceDate : previousSourceDate // ignore: cast_nullable_to_non_nullable
as String?,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [UndoEntry].
extension UndoEntryPatterns on UndoEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UndoEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UndoEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UndoEntry value)  $default,){
final _that = this;
switch (_that) {
case _UndoEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UndoEntry value)?  $default,){
final _that = this;
switch (_that) {
case _UndoEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String todoId,  TodoStatus oldStatus,  TodoStatus newStatus,  String? copiedTodoId,  String? sourceDate,  String? targetDate,  bool isMove,  String? previousSourceDate,  DateTime timestamp)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UndoEntry() when $default != null:
return $default(_that.todoId,_that.oldStatus,_that.newStatus,_that.copiedTodoId,_that.sourceDate,_that.targetDate,_that.isMove,_that.previousSourceDate,_that.timestamp);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String todoId,  TodoStatus oldStatus,  TodoStatus newStatus,  String? copiedTodoId,  String? sourceDate,  String? targetDate,  bool isMove,  String? previousSourceDate,  DateTime timestamp)  $default,) {final _that = this;
switch (_that) {
case _UndoEntry():
return $default(_that.todoId,_that.oldStatus,_that.newStatus,_that.copiedTodoId,_that.sourceDate,_that.targetDate,_that.isMove,_that.previousSourceDate,_that.timestamp);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String todoId,  TodoStatus oldStatus,  TodoStatus newStatus,  String? copiedTodoId,  String? sourceDate,  String? targetDate,  bool isMove,  String? previousSourceDate,  DateTime timestamp)?  $default,) {final _that = this;
switch (_that) {
case _UndoEntry() when $default != null:
return $default(_that.todoId,_that.oldStatus,_that.newStatus,_that.copiedTodoId,_that.sourceDate,_that.targetDate,_that.isMove,_that.previousSourceDate,_that.timestamp);case _:
  return null;

}
}

}

/// @nodoc


class _UndoEntry implements UndoEntry {
  const _UndoEntry({required this.todoId, required this.oldStatus, required this.newStatus, this.copiedTodoId, this.sourceDate, this.targetDate, this.isMove = false, this.previousSourceDate, required this.timestamp});
  

@override final  String todoId;
@override final  TodoStatus oldStatus;
@override final  TodoStatus newStatus;
@override final  String? copiedTodoId;
@override final  String? sourceDate;
@override final  String? targetDate;
@override@JsonKey() final  bool isMove;
@override final  String? previousSourceDate;
@override final  DateTime timestamp;

/// Create a copy of UndoEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UndoEntryCopyWith<_UndoEntry> get copyWith => __$UndoEntryCopyWithImpl<_UndoEntry>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _UndoEntry&&(identical(other.todoId, todoId) || other.todoId == todoId)&&(identical(other.oldStatus, oldStatus) || other.oldStatus == oldStatus)&&(identical(other.newStatus, newStatus) || other.newStatus == newStatus)&&(identical(other.copiedTodoId, copiedTodoId) || other.copiedTodoId == copiedTodoId)&&(identical(other.sourceDate, sourceDate) || other.sourceDate == sourceDate)&&(identical(other.targetDate, targetDate) || other.targetDate == targetDate)&&(identical(other.isMove, isMove) || other.isMove == isMove)&&(identical(other.previousSourceDate, previousSourceDate) || other.previousSourceDate == previousSourceDate)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp));
}


@override
int get hashCode {
    return Object.hash(runtimeType,todoId,oldStatus,newStatus,copiedTodoId,sourceDate,targetDate,isMove,previousSourceDate,timestamp);
}

@override
String toString() {
    return 'UndoEntry(todoId: $todoId, oldStatus: $oldStatus, newStatus: $newStatus, copiedTodoId: $copiedTodoId, sourceDate: $sourceDate, targetDate: $targetDate, isMove: $isMove, previousSourceDate: $previousSourceDate, timestamp: $timestamp)';
}


}

/// @nodoc
abstract mixin class _$UndoEntryCopyWith<$Res> implements $UndoEntryCopyWith<$Res> {
  factory _$UndoEntryCopyWith(_UndoEntry value, $Res Function(_UndoEntry) _then) = __$UndoEntryCopyWithImpl;
@override @useResult
$Res call({
 String todoId, TodoStatus oldStatus, TodoStatus newStatus, String? copiedTodoId, String? sourceDate, String? targetDate, bool isMove, String? previousSourceDate, DateTime timestamp
});




}
/// @nodoc
class __$UndoEntryCopyWithImpl<$Res>
    implements _$UndoEntryCopyWith<$Res> {
  __$UndoEntryCopyWithImpl(this._self, this._then);

  final _UndoEntry _self;
  final $Res Function(_UndoEntry) _then;

/// Create a copy of UndoEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? todoId = null,Object? oldStatus = null,Object? newStatus = null,Object? copiedTodoId = freezed,Object? sourceDate = freezed,Object? targetDate = freezed,Object? isMove = null,Object? previousSourceDate = freezed,Object? timestamp = null,}) {
  return _then(_UndoEntry(
todoId: null == todoId ? _self.todoId : todoId // ignore: cast_nullable_to_non_nullable
as String,oldStatus: null == oldStatus ? _self.oldStatus : oldStatus // ignore: cast_nullable_to_non_nullable
as TodoStatus,newStatus: null == newStatus ? _self.newStatus : newStatus // ignore: cast_nullable_to_non_nullable
as TodoStatus,copiedTodoId: freezed == copiedTodoId ? _self.copiedTodoId : copiedTodoId // ignore: cast_nullable_to_non_nullable
as String?,sourceDate: freezed == sourceDate ? _self.sourceDate : sourceDate // ignore: cast_nullable_to_non_nullable
as String?,targetDate: freezed == targetDate ? _self.targetDate : targetDate // ignore: cast_nullable_to_non_nullable
as String?,isMove: null == isMove ? _self.isMove : isMove // ignore: cast_nullable_to_non_nullable
as bool,previousSourceDate: freezed == previousSourceDate ? _self.previousSourceDate : previousSourceDate // ignore: cast_nullable_to_non_nullable
as String?,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
