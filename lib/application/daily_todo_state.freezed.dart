// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'daily_todo_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$DailyTodoState {
  List<TodoEntity> get todos => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  List<UndoEntry> get undoStack => throw _privateConstructorUsedError;
  Set<String> get selectedIds => throw _privateConstructorUsedError;
  bool get isMultiSelectMode => throw _privateConstructorUsedError;

  /// Create a copy of DailyTodoState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DailyTodoStateCopyWith<DailyTodoState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DailyTodoStateCopyWith<$Res> {
  factory $DailyTodoStateCopyWith(
    DailyTodoState value,
    $Res Function(DailyTodoState) then,
  ) = _$DailyTodoStateCopyWithImpl<$Res, DailyTodoState>;
  @useResult
  $Res call({
    List<TodoEntity> todos,
    bool isLoading,
    String? error,
    List<UndoEntry> undoStack,
    Set<String> selectedIds,
    bool isMultiSelectMode,
  });
}

/// @nodoc
class _$DailyTodoStateCopyWithImpl<$Res, $Val extends DailyTodoState>
    implements $DailyTodoStateCopyWith<$Res> {
  _$DailyTodoStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DailyTodoState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? todos = null,
    Object? isLoading = null,
    Object? error = freezed,
    Object? undoStack = null,
    Object? selectedIds = null,
    Object? isMultiSelectMode = null,
  }) {
    return _then(
      _value.copyWith(
            todos: null == todos
                ? _value.todos
                : todos // ignore: cast_nullable_to_non_nullable
                      as List<TodoEntity>,
            isLoading: null == isLoading
                ? _value.isLoading
                : isLoading // ignore: cast_nullable_to_non_nullable
                      as bool,
            error: freezed == error
                ? _value.error
                : error // ignore: cast_nullable_to_non_nullable
                      as String?,
            undoStack: null == undoStack
                ? _value.undoStack
                : undoStack // ignore: cast_nullable_to_non_nullable
                      as List<UndoEntry>,
            selectedIds: null == selectedIds
                ? _value.selectedIds
                : selectedIds // ignore: cast_nullable_to_non_nullable
                      as Set<String>,
            isMultiSelectMode: null == isMultiSelectMode
                ? _value.isMultiSelectMode
                : isMultiSelectMode // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DailyTodoStateImplCopyWith<$Res>
    implements $DailyTodoStateCopyWith<$Res> {
  factory _$$DailyTodoStateImplCopyWith(
    _$DailyTodoStateImpl value,
    $Res Function(_$DailyTodoStateImpl) then,
  ) = __$$DailyTodoStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<TodoEntity> todos,
    bool isLoading,
    String? error,
    List<UndoEntry> undoStack,
    Set<String> selectedIds,
    bool isMultiSelectMode,
  });
}

/// @nodoc
class __$$DailyTodoStateImplCopyWithImpl<$Res>
    extends _$DailyTodoStateCopyWithImpl<$Res, _$DailyTodoStateImpl>
    implements _$$DailyTodoStateImplCopyWith<$Res> {
  __$$DailyTodoStateImplCopyWithImpl(
    _$DailyTodoStateImpl _value,
    $Res Function(_$DailyTodoStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DailyTodoState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? todos = null,
    Object? isLoading = null,
    Object? error = freezed,
    Object? undoStack = null,
    Object? selectedIds = null,
    Object? isMultiSelectMode = null,
  }) {
    return _then(
      _$DailyTodoStateImpl(
        todos: null == todos
            ? _value._todos
            : todos // ignore: cast_nullable_to_non_nullable
                  as List<TodoEntity>,
        isLoading: null == isLoading
            ? _value.isLoading
            : isLoading // ignore: cast_nullable_to_non_nullable
                  as bool,
        error: freezed == error
            ? _value.error
            : error // ignore: cast_nullable_to_non_nullable
                  as String?,
        undoStack: null == undoStack
            ? _value._undoStack
            : undoStack // ignore: cast_nullable_to_non_nullable
                  as List<UndoEntry>,
        selectedIds: null == selectedIds
            ? _value._selectedIds
            : selectedIds // ignore: cast_nullable_to_non_nullable
                  as Set<String>,
        isMultiSelectMode: null == isMultiSelectMode
            ? _value.isMultiSelectMode
            : isMultiSelectMode // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$DailyTodoStateImpl implements _DailyTodoState {
  const _$DailyTodoStateImpl({
    final List<TodoEntity> todos = const [],
    this.isLoading = false,
    this.error,
    final List<UndoEntry> undoStack = const [],
    final Set<String> selectedIds = const {},
    this.isMultiSelectMode = false,
  }) : _todos = todos,
       _undoStack = undoStack,
       _selectedIds = selectedIds;

  final List<TodoEntity> _todos;
  @override
  @JsonKey()
  List<TodoEntity> get todos {
    if (_todos is EqualUnmodifiableListView) return _todos;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_todos);
  }

  @override
  @JsonKey()
  final bool isLoading;
  @override
  final String? error;
  final List<UndoEntry> _undoStack;
  @override
  @JsonKey()
  List<UndoEntry> get undoStack {
    if (_undoStack is EqualUnmodifiableListView) return _undoStack;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_undoStack);
  }

  final Set<String> _selectedIds;
  @override
  @JsonKey()
  Set<String> get selectedIds {
    if (_selectedIds is EqualUnmodifiableSetView) return _selectedIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_selectedIds);
  }

  @override
  @JsonKey()
  final bool isMultiSelectMode;

  @override
  String toString() {
    return 'DailyTodoState(todos: $todos, isLoading: $isLoading, error: $error, undoStack: $undoStack, selectedIds: $selectedIds, isMultiSelectMode: $isMultiSelectMode)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DailyTodoStateImpl &&
            const DeepCollectionEquality().equals(other._todos, _todos) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error) &&
            const DeepCollectionEquality().equals(
              other._undoStack,
              _undoStack,
            ) &&
            const DeepCollectionEquality().equals(
              other._selectedIds,
              _selectedIds,
            ) &&
            (identical(other.isMultiSelectMode, isMultiSelectMode) ||
                other.isMultiSelectMode == isMultiSelectMode));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_todos),
    isLoading,
    error,
    const DeepCollectionEquality().hash(_undoStack),
    const DeepCollectionEquality().hash(_selectedIds),
    isMultiSelectMode,
  );

  /// Create a copy of DailyTodoState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DailyTodoStateImplCopyWith<_$DailyTodoStateImpl> get copyWith =>
      __$$DailyTodoStateImplCopyWithImpl<_$DailyTodoStateImpl>(
        this,
        _$identity,
      );
}

abstract class _DailyTodoState implements DailyTodoState {
  const factory _DailyTodoState({
    final List<TodoEntity> todos,
    final bool isLoading,
    final String? error,
    final List<UndoEntry> undoStack,
    final Set<String> selectedIds,
    final bool isMultiSelectMode,
  }) = _$DailyTodoStateImpl;

  @override
  List<TodoEntity> get todos;
  @override
  bool get isLoading;
  @override
  String? get error;
  @override
  List<UndoEntry> get undoStack;
  @override
  Set<String> get selectedIds;
  @override
  bool get isMultiSelectMode;

  /// Create a copy of DailyTodoState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DailyTodoStateImplCopyWith<_$DailyTodoStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$UndoEntry {
  String get todoId => throw _privateConstructorUsedError;
  TodoStatus get oldStatus => throw _privateConstructorUsedError;
  TodoStatus get newStatus => throw _privateConstructorUsedError;
  String? get copiedTodoId => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;

  /// Create a copy of UndoEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UndoEntryCopyWith<UndoEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UndoEntryCopyWith<$Res> {
  factory $UndoEntryCopyWith(UndoEntry value, $Res Function(UndoEntry) then) =
      _$UndoEntryCopyWithImpl<$Res, UndoEntry>;
  @useResult
  $Res call({
    String todoId,
    TodoStatus oldStatus,
    TodoStatus newStatus,
    String? copiedTodoId,
    DateTime timestamp,
  });
}

/// @nodoc
class _$UndoEntryCopyWithImpl<$Res, $Val extends UndoEntry>
    implements $UndoEntryCopyWith<$Res> {
  _$UndoEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UndoEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? todoId = null,
    Object? oldStatus = null,
    Object? newStatus = null,
    Object? copiedTodoId = freezed,
    Object? timestamp = null,
  }) {
    return _then(
      _value.copyWith(
            todoId: null == todoId
                ? _value.todoId
                : todoId // ignore: cast_nullable_to_non_nullable
                      as String,
            oldStatus: null == oldStatus
                ? _value.oldStatus
                : oldStatus // ignore: cast_nullable_to_non_nullable
                      as TodoStatus,
            newStatus: null == newStatus
                ? _value.newStatus
                : newStatus // ignore: cast_nullable_to_non_nullable
                      as TodoStatus,
            copiedTodoId: freezed == copiedTodoId
                ? _value.copiedTodoId
                : copiedTodoId // ignore: cast_nullable_to_non_nullable
                      as String?,
            timestamp: null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UndoEntryImplCopyWith<$Res>
    implements $UndoEntryCopyWith<$Res> {
  factory _$$UndoEntryImplCopyWith(
    _$UndoEntryImpl value,
    $Res Function(_$UndoEntryImpl) then,
  ) = __$$UndoEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String todoId,
    TodoStatus oldStatus,
    TodoStatus newStatus,
    String? copiedTodoId,
    DateTime timestamp,
  });
}

/// @nodoc
class __$$UndoEntryImplCopyWithImpl<$Res>
    extends _$UndoEntryCopyWithImpl<$Res, _$UndoEntryImpl>
    implements _$$UndoEntryImplCopyWith<$Res> {
  __$$UndoEntryImplCopyWithImpl(
    _$UndoEntryImpl _value,
    $Res Function(_$UndoEntryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UndoEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? todoId = null,
    Object? oldStatus = null,
    Object? newStatus = null,
    Object? copiedTodoId = freezed,
    Object? timestamp = null,
  }) {
    return _then(
      _$UndoEntryImpl(
        todoId: null == todoId
            ? _value.todoId
            : todoId // ignore: cast_nullable_to_non_nullable
                  as String,
        oldStatus: null == oldStatus
            ? _value.oldStatus
            : oldStatus // ignore: cast_nullable_to_non_nullable
                  as TodoStatus,
        newStatus: null == newStatus
            ? _value.newStatus
            : newStatus // ignore: cast_nullable_to_non_nullable
                  as TodoStatus,
        copiedTodoId: freezed == copiedTodoId
            ? _value.copiedTodoId
            : copiedTodoId // ignore: cast_nullable_to_non_nullable
                  as String?,
        timestamp: null == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc

class _$UndoEntryImpl implements _UndoEntry {
  const _$UndoEntryImpl({
    required this.todoId,
    required this.oldStatus,
    required this.newStatus,
    this.copiedTodoId,
    required this.timestamp,
  });

  @override
  final String todoId;
  @override
  final TodoStatus oldStatus;
  @override
  final TodoStatus newStatus;
  @override
  final String? copiedTodoId;
  @override
  final DateTime timestamp;

  @override
  String toString() {
    return 'UndoEntry(todoId: $todoId, oldStatus: $oldStatus, newStatus: $newStatus, copiedTodoId: $copiedTodoId, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UndoEntryImpl &&
            (identical(other.todoId, todoId) || other.todoId == todoId) &&
            (identical(other.oldStatus, oldStatus) ||
                other.oldStatus == oldStatus) &&
            (identical(other.newStatus, newStatus) ||
                other.newStatus == newStatus) &&
            (identical(other.copiedTodoId, copiedTodoId) ||
                other.copiedTodoId == copiedTodoId) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    todoId,
    oldStatus,
    newStatus,
    copiedTodoId,
    timestamp,
  );

  /// Create a copy of UndoEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UndoEntryImplCopyWith<_$UndoEntryImpl> get copyWith =>
      __$$UndoEntryImplCopyWithImpl<_$UndoEntryImpl>(this, _$identity);
}

abstract class _UndoEntry implements UndoEntry {
  const factory _UndoEntry({
    required final String todoId,
    required final TodoStatus oldStatus,
    required final TodoStatus newStatus,
    final String? copiedTodoId,
    required final DateTime timestamp,
  }) = _$UndoEntryImpl;

  @override
  String get todoId;
  @override
  TodoStatus get oldStatus;
  @override
  TodoStatus get newStatus;
  @override
  String? get copiedTodoId;
  @override
  DateTime get timestamp;

  /// Create a copy of UndoEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UndoEntryImplCopyWith<_$UndoEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
