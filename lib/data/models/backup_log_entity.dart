import 'package:freezed_annotation/freezed_annotation.dart';

part 'backup_log_entity.freezed.dart';

@freezed
class BackupLogEntity with _$BackupLogEntity {
  const BackupLogEntity._();

  const factory BackupLogEntity({
    required String id,
    required String timestamp,
    required String status,
    required String filePath,
    @Default(0) int fileSizeBytes,
    required String triggerType,
    @Default('') String diagnosticMessage,
    required String createdAt,
  }) = _BackupLogEntity;

  Map<String, dynamic> toMap() => {
    'id': id,
    'timestamp': timestamp,
    'status': status,
    'file_path': filePath,
    'file_size_bytes': fileSizeBytes,
    'trigger_type': triggerType,
    'diagnostic_message': diagnosticMessage,
    'created_at': createdAt,
  };

  factory BackupLogEntity.fromMap(Map<String, dynamic> map) => BackupLogEntity(
    id: map['id'] as String,
    timestamp: map['timestamp'] as String,
    status: map['status'] as String,
    filePath: map['file_path'] as String,
    fileSizeBytes: map['file_size_bytes'] as int? ?? 0,
    triggerType: map['trigger_type'] as String,
    diagnosticMessage: map['diagnostic_message'] as String? ?? '',
    createdAt: map['created_at'] as String,
  );
}
