import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sreerajp_todo/core/constants/app_strings.dart';
import 'package:sreerajp_todo/data/backup/backup_file_info.dart';

class BackupListTile extends StatelessWidget {
  const BackupListTile({super.key, required this.info, this.onDelete});

  final BackupFileInfo info;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat.yMMMd().add_jm();

    return Card(
      child: ListTile(
        leading: const Icon(Icons.insert_drive_file_outlined),
        title: Text(
          info.fileName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${formatter.format(info.createdAt)} • ${_formatBytes(info.fileSizeBytes)}',
        ),
        trailing: IconButton(
          onPressed: onDelete,
          icon: const Icon(Icons.delete_outline),
          tooltip: AppStrings.delete,
        ),
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    }
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
