// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'backup_log_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$BackupLogEntity {
  String get id => throw _privateConstructorUsedError;
  String get timestamp => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String get filePath => throw _privateConstructorUsedError;
  int get fileSizeBytes => throw _privateConstructorUsedError;
  String get triggerType => throw _privateConstructorUsedError;
  String get diagnosticMessage => throw _privateConstructorUsedError;
  String get createdAt => throw _privateConstructorUsedError;

  /// Create a copy of BackupLogEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BackupLogEntityCopyWith<BackupLogEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BackupLogEntityCopyWith<$Res> {
  factory $BackupLogEntityCopyWith(
    BackupLogEntity value,
    $Res Function(BackupLogEntity) then,
  ) = _$BackupLogEntityCopyWithImpl<$Res, BackupLogEntity>;
  @useResult
  $Res call({
    String id,
    String timestamp,
    String status,
    String filePath,
    int fileSizeBytes,
    String triggerType,
    String diagnosticMessage,
    String createdAt,
  });
}

/// @nodoc
class _$BackupLogEntityCopyWithImpl<$Res, $Val extends BackupLogEntity>
    implements $BackupLogEntityCopyWith<$Res> {
  _$BackupLogEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BackupLogEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? timestamp = null,
    Object? status = null,
    Object? filePath = null,
    Object? fileSizeBytes = null,
    Object? triggerType = null,
    Object? diagnosticMessage = null,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            timestamp: null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            filePath: null == filePath
                ? _value.filePath
                : filePath // ignore: cast_nullable_to_non_nullable
                      as String,
            fileSizeBytes: null == fileSizeBytes
                ? _value.fileSizeBytes
                : fileSizeBytes // ignore: cast_nullable_to_non_nullable
                      as int,
            triggerType: null == triggerType
                ? _value.triggerType
                : triggerType // ignore: cast_nullable_to_non_nullable
                      as String,
            diagnosticMessage: null == diagnosticMessage
                ? _value.diagnosticMessage
                : diagnosticMessage // ignore: cast_nullable_to_non_nullable
                      as String,
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
abstract class _$$BackupLogEntityImplCopyWith<$Res>
    implements $BackupLogEntityCopyWith<$Res> {
  factory _$$BackupLogEntityImplCopyWith(
    _$BackupLogEntityImpl value,
    $Res Function(_$BackupLogEntityImpl) then,
  ) = __$$BackupLogEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String timestamp,
    String status,
    String filePath,
    int fileSizeBytes,
    String triggerType,
    String diagnosticMessage,
    String createdAt,
  });
}

/// @nodoc
class __$$BackupLogEntityImplCopyWithImpl<$Res>
    extends _$BackupLogEntityCopyWithImpl<$Res, _$BackupLogEntityImpl>
    implements _$$BackupLogEntityImplCopyWith<$Res> {
  __$$BackupLogEntityImplCopyWithImpl(
    _$BackupLogEntityImpl _value,
    $Res Function(_$BackupLogEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BackupLogEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? timestamp = null,
    Object? status = null,
    Object? filePath = null,
    Object? fileSizeBytes = null,
    Object? triggerType = null,
    Object? diagnosticMessage = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$BackupLogEntityImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        timestamp: null == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        filePath: null == filePath
            ? _value.filePath
            : filePath // ignore: cast_nullable_to_non_nullable
                  as String,
        fileSizeBytes: null == fileSizeBytes
            ? _value.fileSizeBytes
            : fileSizeBytes // ignore: cast_nullable_to_non_nullable
                  as int,
        triggerType: null == triggerType
            ? _value.triggerType
            : triggerType // ignore: cast_nullable_to_non_nullable
                  as String,
        diagnosticMessage: null == diagnosticMessage
            ? _value.diagnosticMessage
            : diagnosticMessage // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$BackupLogEntityImpl extends _BackupLogEntity {
  const _$BackupLogEntityImpl({
    required this.id,
    required this.timestamp,
    required this.status,
    required this.filePath,
    this.fileSizeBytes = 0,
    required this.triggerType,
    this.diagnosticMessage = '',
    required this.createdAt,
  }) : super._();

  @override
  final String id;
  @override
  final String timestamp;
  @override
  final String status;
  @override
  final String filePath;
  @override
  @JsonKey()
  final int fileSizeBytes;
  @override
  final String triggerType;
  @override
  @JsonKey()
  final String diagnosticMessage;
  @override
  final String createdAt;

  @override
  String toString() {
    return 'BackupLogEntity(id: $id, timestamp: $timestamp, status: $status, filePath: $filePath, fileSizeBytes: $fileSizeBytes, triggerType: $triggerType, diagnosticMessage: $diagnosticMessage, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BackupLogEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.filePath, filePath) ||
                other.filePath == filePath) &&
            (identical(other.fileSizeBytes, fileSizeBytes) ||
                other.fileSizeBytes == fileSizeBytes) &&
            (identical(other.triggerType, triggerType) ||
                other.triggerType == triggerType) &&
            (identical(other.diagnosticMessage, diagnosticMessage) ||
                other.diagnosticMessage == diagnosticMessage) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    timestamp,
    status,
    filePath,
    fileSizeBytes,
    triggerType,
    diagnosticMessage,
    createdAt,
  );

  /// Create a copy of BackupLogEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BackupLogEntityImplCopyWith<_$BackupLogEntityImpl> get copyWith =>
      __$$BackupLogEntityImplCopyWithImpl<_$BackupLogEntityImpl>(
        this,
        _$identity,
      );
}

abstract class _BackupLogEntity extends BackupLogEntity {
  const factory _BackupLogEntity({
    required final String id,
    required final String timestamp,
    required final String status,
    required final String filePath,
    final int fileSizeBytes,
    required final String triggerType,
    final String diagnosticMessage,
    required final String createdAt,
  }) = _$BackupLogEntityImpl;
  const _BackupLogEntity._() : super._();

  @override
  String get id;
  @override
  String get timestamp;
  @override
  String get status;
  @override
  String get filePath;
  @override
  int get fileSizeBytes;
  @override
  String get triggerType;
  @override
  String get diagnosticMessage;
  @override
  String get createdAt;

  /// Create a copy of BackupLogEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BackupLogEntityImplCopyWith<_$BackupLogEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
