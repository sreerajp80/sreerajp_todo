// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'todo_search_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TodoSearchResult {

 TodoEntity get todo; String? get matchedNote;
/// Create a copy of TodoSearchResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TodoSearchResultCopyWith<TodoSearchResult> get copyWith => _$TodoSearchResultCopyWithImpl<TodoSearchResult>(this as TodoSearchResult, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TodoSearchResult;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TodoSearchResult&&(identical(other.todo, _this.todo) || other.todo == _this.todo)&&(identical(other.matchedNote, _this.matchedNote) || other.matchedNote == _this.matchedNote));
}


@override
int get hashCode {
  final _this = this as TodoSearchResult;
  return Object.hash(runtimeType,_this.todo,_this.matchedNote);
}

@override
String toString() {
  final _this = this as TodoSearchResult;
  return 'TodoSearchResult(todo: ${_this.todo}, matchedNote: ${_this.matchedNote})';
}


}

/// @nodoc
abstract mixin class $TodoSearchResultCopyWith<$Res>  {
  factory $TodoSearchResultCopyWith(TodoSearchResult value, $Res Function(TodoSearchResult) _then) = _$TodoSearchResultCopyWithImpl;
@useResult
$Res call({
 TodoEntity todo, String? matchedNote
});


$TodoEntityCopyWith<$Res> get todo;

}
/// @nodoc
class _$TodoSearchResultCopyWithImpl<$Res>
    implements $TodoSearchResultCopyWith<$Res> {
  _$TodoSearchResultCopyWithImpl(this._self, this._then);

  final TodoSearchResult _self;
  final $Res Function(TodoSearchResult) _then;

/// Create a copy of TodoSearchResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? todo = null,Object? matchedNote = freezed,}) {
  return _then(TodoSearchResult(
todo: null == todo ? _self.todo : todo // ignore: cast_nullable_to_non_nullable
as TodoEntity,matchedNote: freezed == matchedNote ? _self.matchedNote : matchedNote // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of TodoSearchResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TodoEntityCopyWith<$Res> get todo {
  
  return $TodoEntityCopyWith<$Res>(_self.todo, (value) {
    return _then(_self.copyWith(todo: value));
  });
}
}


/// Adds pattern-matching-related methods to [TodoSearchResult].
extension TodoSearchResultPatterns on TodoSearchResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TodoSearchResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TodoSearchResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TodoSearchResult value)  $default,){
final _that = this;
switch (_that) {
case _TodoSearchResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TodoSearchResult value)?  $default,){
final _that = this;
switch (_that) {
case _TodoSearchResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( TodoEntity todo,  String? matchedNote)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TodoSearchResult() when $default != null:
return $default(_that.todo,_that.matchedNote);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( TodoEntity todo,  String? matchedNote)  $default,) {final _that = this;
switch (_that) {
case _TodoSearchResult():
return $default(_that.todo,_that.matchedNote);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( TodoEntity todo,  String? matchedNote)?  $default,) {final _that = this;
switch (_that) {
case _TodoSearchResult() when $default != null:
return $default(_that.todo,_that.matchedNote);case _:
  return null;

}
}

}

/// @nodoc


class _TodoSearchResult implements TodoSearchResult {
  const _TodoSearchResult({required this.todo, this.matchedNote});
  

@override final  TodoEntity todo;
@override final  String? matchedNote;

/// Create a copy of TodoSearchResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TodoSearchResultCopyWith<_TodoSearchResult> get copyWith => __$TodoSearchResultCopyWithImpl<_TodoSearchResult>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TodoSearchResult&&(identical(other.todo, todo) || other.todo == todo)&&(identical(other.matchedNote, matchedNote) || other.matchedNote == matchedNote));
}


@override
int get hashCode {
    return Object.hash(runtimeType,todo,matchedNote);
}

@override
String toString() {
    return 'TodoSearchResult(todo: $todo, matchedNote: $matchedNote)';
}


}

/// @nodoc
abstract mixin class _$TodoSearchResultCopyWith<$Res> implements $TodoSearchResultCopyWith<$Res> {
  factory _$TodoSearchResultCopyWith(_TodoSearchResult value, $Res Function(_TodoSearchResult) _then) = __$TodoSearchResultCopyWithImpl;
@override @useResult
$Res call({
 TodoEntity todo, String? matchedNote
});


@override $TodoEntityCopyWith<$Res> get todo;

}
/// @nodoc
class __$TodoSearchResultCopyWithImpl<$Res>
    implements _$TodoSearchResultCopyWith<$Res> {
  __$TodoSearchResultCopyWithImpl(this._self, this._then);

  final _TodoSearchResult _self;
  final $Res Function(_TodoSearchResult) _then;

/// Create a copy of TodoSearchResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? todo = null,Object? matchedNote = freezed,}) {
  return _then(_TodoSearchResult(
todo: null == todo ? _self.todo : todo // ignore: cast_nullable_to_non_nullable
as TodoEntity,matchedNote: freezed == matchedNote ? _self.matchedNote : matchedNote // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of TodoSearchResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TodoEntityCopyWith<$Res> get todo {
  
  return $TodoEntityCopyWith<$Res>(_self.todo, (value) {
    return _then(_self.copyWith(todo: value));
  });
}
}

// dart format on
