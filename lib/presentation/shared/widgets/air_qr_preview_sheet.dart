import 'package:flutter/material.dart';
import 'package:sreerajp_todo/application/providers.dart';
import 'package:sreerajp_todo/l10n/app_localizations.dart';

enum AirQrMergeDecision { importAll, skipDuplicates, cancel }

/// Preview bottom sheet presented to user when an AirQR optical stream is reassembled.
Future<AirQrMergeDecision?> showAirQrPreviewSheet(
  BuildContext context,
  AirQrParsedPayload payload,
) {
  return showModalBottomSheet<AirQrMergeDecision>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => AirQrPreviewSheet(payload: payload),
  );
}

class AirQrPreviewSheet extends StatelessWidget {
  final AirQrParsedPayload payload;

  const AirQrPreviewSheet({super.key, required this.payload});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.qr_code_2, color: Colors.blue, size: 28),
              const SizedBox(width: 10),
              Text(
                _getTitle(l10n),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _getSubtitle(l10n),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          if (payload.type == AirQrPayloadType.tasks ||
              payload.type == AirQrPayloadType.timecard) ...[
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 240),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: payload.todos.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final todo = payload.todos[index];
                  return ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      todo.status.name == 'completed'
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: todo.status.name == 'completed'
                          ? Colors.green
                          : Colors.grey,
                    ),
                    title: Text(
                      todo.title,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(l10n.airQrDatePrefix(todo.date)),
                  );
                },
              ),
            ),
          ] else if (payload.type == AirQrPayloadType.backup) ...[
            DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.backup, color: Colors.indigo),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.airQrBackupPayloadEntries(payload.rawJson.length),
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            Text(l10n.airQrPayloadFormatError),
          ],
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () =>
                    Navigator.of(context).pop(AirQrMergeDecision.cancel),
                child: Text(l10n.cancel),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () => Navigator.of(
                  context,
                ).pop(AirQrMergeDecision.skipDuplicates),
                child: Text(l10n.airQrSkipDuplicates),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () =>
                    Navigator.of(context).pop(AirQrMergeDecision.importAll),
                child: Text(l10n.airQrImportAll),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getTitle(AppLocalizations l10n) {
    return switch (payload.type) {
      AirQrPayloadType.tasks => l10n.airQrReceivedTasks,
      AirQrPayloadType.timecard => l10n.airQrReceivedTimecard,
      AirQrPayloadType.backup => l10n.airQrReceivedBackup,
      AirQrPayloadType.unknown => l10n.airQrReceivedUnknown,
    };
  }

  String _getSubtitle(AppLocalizations l10n) {
    return switch (payload.type) {
      AirQrPayloadType.tasks => l10n.airQrTasksReady(payload.todos.length),
      AirQrPayloadType.timecard => l10n.airQrTimecardReady(
        payload.todos.length,
      ),
      AirQrPayloadType.backup => l10n.airQrBackupReceivedDetail,
      AirQrPayloadType.unknown => l10n.airQrPayloadFormatError,
    };
  }
}
