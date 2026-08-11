import 'package:flutter/material.dart';
import 'package:sreerajp_todo/data/services/air_qr_payload_service.dart';

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
                _getTitle(),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _getSubtitle(),
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
                    subtitle: Text('Date: ${todo.date}'),
                  );
                },
              ),
            ),
          ] else if (payload.type == AirQrPayloadType.backup) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.backup, color: Colors.indigo),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Full App Backup Payload (${payload.rawJson.length} keys)',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            const Text('Unrecognized AirQR payload format.'),
          ],
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () =>
                    Navigator.of(context).pop(AirQrMergeDecision.cancel),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () => Navigator.of(context)
                    .pop(AirQrMergeDecision.skipDuplicates),
                child: const Text('Skip Duplicates'),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () =>
                    Navigator.of(context).pop(AirQrMergeDecision.importAll),
                child: const Text('Import All'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getTitle() {
    switch (payload.type) {
      case AirQrPayloadType.tasks:
        return 'AirQR Tasks Received';
      case AirQrPayloadType.timecard:
        return 'AirQR Timecard Received';
      case AirQrPayloadType.backup:
        return 'AirQR Backup Received';
      case AirQrPayloadType.unknown:
        return 'AirQR Payload Received';
    }
  }

  String _getSubtitle() {
    switch (payload.type) {
      case AirQrPayloadType.tasks:
        return '${payload.todos.length} tasks ready to merge into your list.';
      case AirQrPayloadType.timecard:
        return 'Daily timecard with ${payload.todos.length} items ready to merge.';
      case AirQrPayloadType.backup:
        return 'Full app database backup received via optical air-gap.';
      case AirQrPayloadType.unknown:
        return 'Scanned payload format is not supported.';
    }
  }
}
