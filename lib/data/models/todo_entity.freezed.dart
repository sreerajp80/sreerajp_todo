// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'todo_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$TodoEntity {
  String get id => throw _privateConstructorUsedError;
  String get date => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  TodoStatus get status => throw _privateConstructorUsedError;
  String? get portedTo => throw _privateConstructorUsedError;
  String? get sourceDate => throw _privateConstructorUsedError;
  String? get recurrenceRuleId => throw _privateConstructorUsedError;
  int get sortOrder => throw _privateConstructorUsedError;
  String get createdAt => throw _privateConstructorUsedError;
  String get updatedAt => throw _privateConstructorUsedError;

  /// Create a copy of TodoEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TodoEntityCopyWith<TodoEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TodoEntityCopyWith<$Res> {
  factory $TodoEntityCopyWith(
    TodoEntity value,
    $Res Function(TodoEntity) then,
  ) = _$TodoEntityCopyWithImpl<$Res, TodoEntity>;
  @useResult
  $Res call({
    String id,
    String date,
    String title,
    String? description,
    TodoStatus status,
    String? portedTo,
    String? sourceDate,
    String? recurrenceRuleId,
    int sortOrder,
    String createdAt,
    String updatedAt,
  });
}

/// @nodoc
class _$TodoEntityCopyWithImpl<$Res, $Val extends TodoEntity>
    implements $TodoEntityCopyWith<$Res> {
  _$TodoEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TodoEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? date = null,
    Object? title = null,
    Object? description = freezed,
    Object? status = null,
    Object? portedTo = freezed,
    Object? sourceDate = freezed,
    Object? recurrenceRuleId = freezed,
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
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as TodoStatus,
            portedTo: freezed == portedTo
                ? _value.portedTo
                : portedTo // ignore: cast_nullable_to_non_nullable
                      as String?,
            sourceDate: freezed == sourceDate
                ? _value.sourceDate
                : sourceDate // ignore: cast_nullable_to_non_nullable
                      as String?,
            recurrenceRuleId: freezed == recurrenceRuleId
                ? _value.recurrenceRuleId
                : recurrenceRuleId // ignore: cast_nullable_to_non_nullable
                      as String?,
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
abstract class _$$TodoEntityImplCopyWith<$Res>
    implements $TodoEntityCopyWith<$Res> {
  factory _$$TodoEntityImplCopyWith(
    _$TodoEntityImpl value,
    $Res Function(_$TodoEntityImpl) then,
  ) = __$$TodoEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String date,
    String title,
    String? description,
    TodoStatus status,
    String? portedTo,
    String? sourceDate,
    String? recurrenceRuleId,
    int sortOrder,
    String createdAt,
    String updatedAt,
  });
}

/// @nodoc
class __$$TodoEntityImplCopyWithImpl<$Res>
    extends _$TodoEntityCopyWithImpl<$Res, _$TodoEntityImpl>
    implements _$$TodoEntityImplCopyWith<$Res> {
  __$$TodoEntityImplCopyWithImpl(
    _$TodoEntityImpl _value,
    $Res Function(_$TodoEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TodoEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? date = null,
    Object? title = null,
    Object? description = freezed,
    Object? status = null,
    Object? portedTo = freezed,
    Object? sourceDate = freezed,
    Object? recurrenceRuleId = freezed,
    Object? sortOrder = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$TodoEntityImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as TodoStatus,
        portedTo: freezed == portedTo
            ? _value.portedTo
            : portedTo // ignore: cast_nullable_to_non_nullable
                  as String?,
        sourceDate: freezed == sourceDate
            ? _value.sourceDate
            : sourceDate // ignore: cast_nullable_to_non_nullable
                  as String?,
        recurrenceRuleId: freezed == recurrenceRuleId
            ? _value.recurrenceRuleId
            : recurrenceRuleId // ignore: cast_nullable_to_non_nullable
                  as String?,
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

class _$TodoEntityImpl extends _TodoEntity {
  const _$TodoEntityImpl({
    required this.id,
    required this.date,
    required this.title,
    this.description,
    this.status = TodoStatus.pending,
    this.portedTo,
    this.sourceDate,
    this.recurrenceRuleId,
    this.sortOrder = 0,
    required this.createdAt,
    required this.updatedAt,
  }) : super._();

  @override
  final String id;
  @override
  final String date;
  @override
  final String title;
  @override
  final String? description;
  @override
  @JsonKey()
  final TodoStatus status;
  @override
  final String? portedTo;
  @override
  final String? sourceDate;
  @override
  final String? recurrenceRuleId;
  @override
  @JsonKey()
  final int sortOrder;
  @override
  final String createdAt;
  @override
  final String updatedAt;

  @override
  String toString() {
    return 'TodoEntity(id: $id, date: $date, title: $title, description: $description, status: $status, portedTo: $portedTo, sourceDate: $sourceDate, recurrenceRuleId: $recurrenceRuleId, sortOrder: $sortOrder, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TodoEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.portedTo, portedTo) ||
                other.portedTo == portedTo) &&
            (identical(other.sourceDate, sourceDate) ||
                other.sourceDate == sourceDate) &&
            (identical(other.recurrenceRuleId, recurrenceRuleId) ||
                other.recurrenceRuleId == recurrenceRuleId) &&
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
    date,
    title,
    description,
    status,
    portedTo,
    sourceDate,
    recurrenceRuleId,
    sortOrder,
    createdAt,
    updatedAt,
  );

  /// Create a copy of TodoEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TodoEntityImplCopyWith<_$TodoEntityImpl> get copyWith =>
      __$$TodoEntityImplCopyWithImpl<_$TodoEntityImpl>(this, _$identity);
}

abstract class _TodoEntity extends TodoEntity {
  const factory _TodoEntity({
    required final String id,
    required final String date,
    required final String title,
    final String? description,
    final TodoStatus status,
    final String? portedTo,
    final String? sourceDate,
    final String? recurrenceRuleId,
    final int sortOrder,
    required final String createdAt,
    required final String updatedAt,
  }) = _$TodoEntityImpl;
  const _TodoEntity._() : super._();

  @override
  String get id;
  @override
  String get date;
  @override
  String get title;
  @override
  String? get description;
  @override
  TodoStatus get status;
  @override
  String? get portedTo;
  @override
  String? get sourceDate;
  @override
  String? get recurrenceRuleId;
  @override
  int get sortOrder;
  @override
  String get createdAt;
  @override
  String get updatedAt;

  /// Create a copy of TodoEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TodoEntityImplCopyWith<_$TodoEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
