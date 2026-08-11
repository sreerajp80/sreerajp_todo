import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sreerajp_todo/application/providers.dart';
import 'package:sreerajp_todo/core/extensions/localization_extensions.dart';
import 'package:sreerajp_todo/presentation/shared/widgets/app_section_card.dart';

class BackupHealthDashboard extends ConsumerStatefulWidget {
  const BackupHealthDashboard({super.key});

  @override
  ConsumerState<BackupHealthDashboard> createState() =>
      _BackupHealthDashboardState();
}

class _BackupHealthDashboardState
    extends ConsumerState<BackupHealthDashboard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final healthLogsAsync = ref.watch(backupHealthLogsProvider);
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return healthLogsAsync.when(
      data: (logs) {
        final latestLog = logs.isEmpty ? null : logs.first;
        final hasLogs = logs.isNotEmpty;
        final isHealthy =
            hasLogs &&
            latestLog!.status == 'success' &&
            _isRecent(latestLog.timestamp);

        final statusColor = !hasLogs
            ? theme.colorScheme.secondary
            : (isHealthy
                ? Colors.green.shade700
                : theme.colorScheme.error);

        final statusText = !hasLogs
            ? l10n.backupHealthStatusNoBackups
            : (isHealthy
                ? l10n.backupHealthStatusHealthy
                : l10n.backupHealthStatusWarning);

        final statusIcon = !hasLogs
            ? Icons.info_outline
            : (isHealthy ? Icons.check_circle_outline : Icons.warning_amber_rounded);

        return AppSectionCard(
          title: l10n.backupHealthDashboardTitle,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: statusColor.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 18, color: statusColor),
                        const SizedBox(width: 6),
                        Text(
                          statusText,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  if (hasLogs)
                    TextButton.icon(
                      onPressed: () {
                        setState(() => _isExpanded = !_isExpanded);
                      },
                      icon: Icon(
                        _isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                      ),
                      label: Text(
                        _isExpanded ? 'Hide Logs' : 'View Logs (${logs.length})',
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              if (latestLog != null) ...[
                Text(
                  'Last Execution: ${_formatTimestamp(latestLog.timestamp)} (${latestLog.triggerType.toUpperCase()})',
                  style: theme.textTheme.bodyMedium,
                ),
                if (latestLog.fileSizeBytes > 0)
                  Text(
                    'Archive Size: ${_formatBytes(latestLog.fileSizeBytes)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ] else
                Text(
                  l10n.backupNoBackupsFoundDetailed,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              if (_isExpanded && hasLogs) ...[
                const Divider(height: 24),
                Text(
                  l10n.backupHealthLogsTitle,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 240),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: logs.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final log = logs[index];
                      final isSuccess = log.status == 'success';
                      return ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          isSuccess ? Icons.check_circle : Icons.error_outline,
                          color: isSuccess
                              ? Colors.green.shade700
                              : theme.colorScheme.error,
                          size: 20,
                        ),
                        title: Text(
                          '${_formatTimestamp(log.timestamp)} — ${log.triggerType.toUpperCase()}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          log.diagnosticMessage.isNotEmpty
                              ? log.diagnosticMessage
                              : (isSuccess
                                  ? l10n.backupHealthStatusSuccess
                                  : l10n.backupHealthStatusFailed),
                        ),
                        trailing: Text(
                          _formatBytes(log.fileSizeBytes),
                          style: theme.textTheme.bodySmall,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        );
      },
      loading: () => const AppSectionCard(
        child: SizedBox(
          height: 80,
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  bool _isRecent(String timestampStr) {
    final dt = DateTime.tryParse(timestampStr);
    if (dt == null) return false;
    return DateTime.now().difference(dt).inDays <= 7;
  }

  String _formatTimestamp(String timestampStr) {
    final dt = DateTime.tryParse(timestampStr);
    if (dt == null) return timestampStr;
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dt.toLocal());
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }
}
