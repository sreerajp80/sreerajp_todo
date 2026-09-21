import 'package:flutter/material.dart';
import 'package:sreerajp_todo/core/extensions/localization_extensions.dart';

enum DeleteChoice { fromTodayOnly, entireHistory }

Future<DeleteChoice?> showDeleteTaskChoiceDialog(BuildContext context) {
  return showDialog<DeleteChoice>(
    context: context,
    builder: (context) {
      final theme = Theme.of(context);
      final colorScheme = theme.colorScheme;

      return AlertDialog(
        title: Text(context.l10n.deleteMultiDayTaskTitle),
        content: Text(context.l10n.deleteMultiDayTaskMessage),
        actionsPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: Text(context.l10n.cancel),
          ),
          OutlinedButton(
            onPressed: () =>
                Navigator.of(context).pop(DeleteChoice.fromTodayOnly),
            child: Text(context.l10n.deleteFromTodayOnly),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
            ),
            onPressed: () =>
                Navigator.of(context).pop(DeleteChoice.entireHistory),
            child: Text(context.l10n.deleteEntireHistory),
          ),
        ],
      );
    },
  );
}
