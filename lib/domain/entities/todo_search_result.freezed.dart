// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'todo_search_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$TodoSearchResult {
  TodoEntity get todo => throw _privateConstructorUsedError;
  String? get matchedNote => throw _privateConstructorUsedError;

  /// Create a copy of TodoSearchResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TodoSearchResultCopyWith<TodoSearchResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TodoSearchResultCopyWith<$Res> {
  factory $TodoSearchResultCopyWith(
    TodoSearchResult value,
    $Res Function(TodoSearchResult) then,
  ) = _$TodoSearchResultCopyWithImpl<$Res, TodoSearchResult>;
  @useResult
  $Res call({TodoEntity todo, String? matchedNote});

  $TodoEntityCopyWith<$Res> get todo;
}

/// @nodoc
class _$TodoSearchResultCopyWithImpl<$Res, $Val extends TodoSearchResult>
    implements $TodoSearchResultCopyWith<$Res> {
  _$TodoSearchResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TodoSearchResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? todo = null, Object? matchedNote = freezed}) {
    return _then(
      _value.copyWith(
            todo: null == todo
                ? _value.todo
                : todo // ignore: cast_nullable_to_non_nullable
                      as TodoEntity,
            matchedNote: freezed == matchedNote
                ? _value.matchedNote
                : matchedNote // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }

  /// Create a copy of TodoSearchResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TodoEntityCopyWith<$Res> get todo {
    return $TodoEntityCopyWith<$Res>(_value.todo, (value) {
      return _then(_value.copyWith(todo: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$TodoSearchResultImplCopyWith<$Res>
    implements $TodoSearchResultCopyWith<$Res> {
  factory _$$TodoSearchResultImplCopyWith(
    _$TodoSearchResultImpl value,
    $Res Function(_$TodoSearchResultImpl) then,
  ) = __$$TodoSearchResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({TodoEntity todo, String? matchedNote});

  @override
  $TodoEntityCopyWith<$Res> get todo;
}

/// @nodoc
class __$$TodoSearchResultImplCopyWithImpl<$Res>
    extends _$TodoSearchResultCopyWithImpl<$Res, _$TodoSearchResultImpl>
    implements _$$TodoSearchResultImplCopyWith<$Res> {
  __$$TodoSearchResultImplCopyWithImpl(
    _$TodoSearchResultImpl _value,
    $Res Function(_$TodoSearchResultImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TodoSearchResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? todo = null, Object? matchedNote = freezed}) {
    return _then(
      _$TodoSearchResultImpl(
        todo: null == todo
            ? _value.todo
            : todo // ignore: cast_nullable_to_non_nullable
                  as TodoEntity,
        matchedNote: freezed == matchedNote
            ? _value.matchedNote
            : matchedNote // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$TodoSearchResultImpl implements _TodoSearchResult {
  const _$TodoSearchResultImpl({required this.todo, this.matchedNote});

  @override
  final TodoEntity todo;
  @override
  final String? matchedNote;

  @override
  String toString() {
    return 'TodoSearchResult(todo: $todo, matchedNote: $matchedNote)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TodoSearchResultImpl &&
            (identical(other.todo, todo) || other.todo == todo) &&
            (identical(other.matchedNote, matchedNote) ||
                other.matchedNote == matchedNote));
  }

  @override
  int get hashCode => Object.hash(runtimeType, todo, matchedNote);

  /// Create a copy of TodoSearchResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TodoSearchResultImplCopyWith<_$TodoSearchResultImpl> get copyWith =>
      __$$TodoSearchResultImplCopyWithImpl<_$TodoSearchResultImpl>(
        this,
        _$identity,
      );
}

abstract class _TodoSearchResult implements TodoSearchResult {
  const factory _TodoSearchResult({
    required final TodoEntity todo,
    final String? matchedNote,
  }) = _$TodoSearchResultImpl;

  @override
  TodoEntity get todo;
  @override
  String? get matchedNote;

  /// Create a copy of TodoSearchResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TodoSearchResultImplCopyWith<_$TodoSearchResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
