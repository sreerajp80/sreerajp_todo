// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'todo_history_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$TodoHistoryEntity {
  String get id => throw _privateConstructorUsedError;
  String get todoId => throw _privateConstructorUsedError;
  TodoHistoryEventType get eventType => throw _privateConstructorUsedError;
  String get eventTime => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String? get metadata => throw _privateConstructorUsedError;
  String get createdAt => throw _privateConstructorUsedError;

  /// Create a copy of TodoHistoryEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TodoHistoryEntityCopyWith<TodoHistoryEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TodoHistoryEntityCopyWith<$Res> {
  factory $TodoHistoryEntityCopyWith(
    TodoHistoryEntity value,
    $Res Function(TodoHistoryEntity) then,
  ) = _$TodoHistoryEntityCopyWithImpl<$Res, TodoHistoryEntity>;
  @useResult
  $Res call({
    String id,
    String todoId,
    TodoHistoryEventType eventType,
    String eventTime,
    String description,
    String? metadata,
    String createdAt,
  });
}

/// @nodoc
class _$TodoHistoryEntityCopyWithImpl<$Res, $Val extends TodoHistoryEntity>
    implements $TodoHistoryEntityCopyWith<$Res> {
  _$TodoHistoryEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TodoHistoryEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? todoId = null,
    Object? eventType = null,
    Object? eventTime = null,
    Object? description = null,
    Object? metadata = freezed,
    Object? createdAt = null,
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
            eventType: null == eventType
                ? _value.eventType
                : eventType // ignore: cast_nullable_to_non_nullable
                      as TodoHistoryEventType,
            eventTime: null == eventTime
                ? _value.eventTime
                : eventTime // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            metadata: freezed == metadata
                ? _value.metadata
                : metadata // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TodoHistoryEntityImplCopyWith<$Res>
    implements $TodoHistoryEntityCopyWith<$Res> {
  factory _$$TodoHistoryEntityImplCopyWith(
    _$TodoHistoryEntityImpl value,
    $Res Function(_$TodoHistoryEntityImpl) then,
  ) = __$$TodoHistoryEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String todoId,
    TodoHistoryEventType eventType,
    String eventTime,
    String description,
    String? metadata,
    String createdAt,
  });
}

/// @nodoc
class __$$TodoHistoryEntityImplCopyWithImpl<$Res>
    extends _$TodoHistoryEntityCopyWithImpl<$Res, _$TodoHistoryEntityImpl>
    implements _$$TodoHistoryEntityImplCopyWith<$Res> {
  __$$TodoHistoryEntityImplCopyWithImpl(
    _$TodoHistoryEntityImpl _value,
    $Res Function(_$TodoHistoryEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TodoHistoryEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? todoId = null,
    Object? eventType = null,
    Object? eventTime = null,
    Object? description = null,
    Object? metadata = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _$TodoHistoryEntityImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        todoId: null == todoId
            ? _value.todoId
            : todoId // ignore: cast_nullable_to_non_nullable
                  as String,
        eventType: null == eventType
            ? _value.eventType
            : eventType // ignore: cast_nullable_to_non_nullable
                  as TodoHistoryEventType,
        eventTime: null == eventTime
            ? _value.eventTime
            : eventTime // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        metadata: freezed == metadata
            ? _value.metadata
            : metadata // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$TodoHistoryEntityImpl extends _TodoHistoryEntity {
  const _$TodoHistoryEntityImpl({
    required this.id,
    required this.todoId,
    required this.eventType,
    required this.eventTime,
    required this.description,
    this.metadata,
    required this.createdAt,
  }) : super._();

  @override
  final String id;
  @override
  final String todoId;
  @override
  final TodoHistoryEventType eventType;
  @override
  final String eventTime;
  @override
  final String description;
  @override
  final String? metadata;
  @override
  final String createdAt;

  @override
  String toString() {
    return 'TodoHistoryEntity(id: $id, todoId: $todoId, eventType: $eventType, eventTime: $eventTime, description: $description, metadata: $metadata, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TodoHistoryEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.todoId, todoId) || other.todoId == todoId) &&
            (identical(other.eventType, eventType) ||
                other.eventType == eventType) &&
            (identical(other.eventTime, eventTime) ||
                other.eventTime == eventTime) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.metadata, metadata) ||
                other.metadata == metadata) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    todoId,
    eventType,
    eventTime,
    description,
    metadata,
    createdAt,
  );

  /// Create a copy of TodoHistoryEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TodoHistoryEntityImplCopyWith<_$TodoHistoryEntityImpl> get copyWith =>
      __$$TodoHistoryEntityImplCopyWithImpl<_$TodoHistoryEntityImpl>(
        this,
        _$identity,
      );
}

abstract class _TodoHistoryEntity extends TodoHistoryEntity {
  const factory _TodoHistoryEntity({
    required final String id,
    required final String todoId,
    required final TodoHistoryEventType eventType,
    required final String eventTime,
    required final String description,
    final String? metadata,
    required final String createdAt,
  }) = _$TodoHistoryEntityImpl;
  const _TodoHistoryEntity._() : super._();

  @override
  String get id;
  @override
  String get todoId;
  @override
  TodoHistoryEventType get eventType;
  @override
  String get eventTime;
  @override
  String get description;
  @override
  String? get metadata;
  @override
  String get createdAt;

  /// Create a copy of TodoHistoryEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TodoHistoryEntityImplCopyWith<_$TodoHistoryEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
