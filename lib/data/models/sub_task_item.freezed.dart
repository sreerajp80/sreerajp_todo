// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sub_task_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$SubTaskItem {
  String get id => throw _privateConstructorUsedError;
  String get todoId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  bool get isCompleted => throw _privateConstructorUsedError;
  int get sortOrder => throw _privateConstructorUsedError;
  String get createdAt => throw _privateConstructorUsedError;
  String get updatedAt => throw _privateConstructorUsedError;

  /// Create a copy of SubTaskItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SubTaskItemCopyWith<SubTaskItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SubTaskItemCopyWith<$Res> {
  factory $SubTaskItemCopyWith(
    SubTaskItem value,
    $Res Function(SubTaskItem) then,
  ) = _$SubTaskItemCopyWithImpl<$Res, SubTaskItem>;
  @useResult
  $Res call({
    String id,
    String todoId,
    String title,
    bool isCompleted,
    int sortOrder,
    String createdAt,
    String updatedAt,
  });
}

/// @nodoc
class _$SubTaskItemCopyWithImpl<$Res, $Val extends SubTaskItem>
    implements $SubTaskItemCopyWith<$Res> {
  _$SubTaskItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SubTaskItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? todoId = null,
    Object? title = null,
    Object? isCompleted = null,
    Object? sortOrder = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            todoId: null == todoId
                ? _value.todoId
                : todoId // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            isCompleted: null == isCompleted
                ? _value.isCompleted
                : isCompleted // ignore: cast_nullable_to_non_nullable
                      as bool,
            sortOrder: null == sortOrder
                ? _value.sortOrder
                : sortOrder // ignore: cast_nullable_to_non_nullable
                      as int,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as String,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SubTaskItemImplCopyWith<$Res>
    implements $SubTaskItemCopyWith<$Res> {
  factory _$$SubTaskItemImplCopyWith(
    _$SubTaskItemImpl value,
    $Res Function(_$SubTaskItemImpl) then,
  ) = __$$SubTaskItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String todoId,
    String title,
    bool isCompleted,
    int sortOrder,
    String createdAt,
    String updatedAt,
  });
}

/// @nodoc
class __$$SubTaskItemImplCopyWithImpl<$Res>
    extends _$SubTaskItemCopyWithImpl<$Res, _$SubTaskItemImpl>
    implements _$$SubTaskItemImplCopyWith<$Res> {
  __$$SubTaskItemImplCopyWithImpl(
    _$SubTaskItemImpl _value,
    $Res Function(_$SubTaskItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SubTaskItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? todoId = null,
    Object? title = null,
    Object? isCompleted = null,
    Object? sortOrder = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$SubTaskItemImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        todoId: null == todoId
            ? _value.todoId
            : todoId // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        isCompleted: null == isCompleted
            ? _value.isCompleted
            : isCompleted // ignore: cast_nullable_to_non_nullable
                  as bool,
        sortOrder: null == sortOrder
            ? _value.sortOrder
            : sortOrder // ignore: cast_nullable_to_non_nullable
                  as int,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as String,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$SubTaskItemImpl extends _SubTaskItem {
  const _$SubTaskItemImpl({
    required this.id,
    required this.todoId,
    required this.title,
    this.isCompleted = false,
    this.sortOrder = 0,
    required this.createdAt,
    required this.updatedAt,
  }) : super._();

  @override
  final String id;
  @override
  final String todoId;
  @override
  final String title;
  @override
  @JsonKey()
  final bool isCompleted;
  @override
  @JsonKey()
  final int sortOrder;
  @override
  final String createdAt;
  @override
  final String updatedAt;

  @override
  String toString() {
    return 'SubTaskItem(id: $id, todoId: $todoId, title: $title, isCompleted: $isCompleted, sortOrder: $sortOrder, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubTaskItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.todoId, todoId) || other.todoId == todoId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.isCompleted, isCompleted) ||
                other.isCompleted == isCompleted) &&
            (identical(other.sortOrder, sortOrder) ||
                other.sortOrder == sortOrder) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    todoId,
    title,
    isCompleted,
    sortOrder,
    createdAt,
    updatedAt,
  );

  /// Create a copy of SubTaskItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SubTaskItemImplCopyWith<_$SubTaskItemImpl> get copyWith =>
      __$$SubTaskItemImplCopyWithImpl<_$SubTaskItemImpl>(this, _$identity);
}

abstract class _SubTaskItem extends SubTaskItem {
  const factory _SubTaskItem({
    required final String id,
    required final String todoId,
    required final String title,
    final bool isCompleted,
    final int sortOrder,
    required final String createdAt,
    required final String updatedAt,
  }) = _$SubTaskItemImpl;
  const _SubTaskItem._() : super._();

  @override
  String get id;
  @override
  String get todoId;
  @override
  String get title;
  @override
  bool get isCompleted;
  @override
  int get sortOrder;
  @override
  String get createdAt;
  @override
  String get updatedAt;

  /// Create a copy of SubTaskItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SubTaskItemImplCopyWith<_$SubTaskItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
