import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sreerajp_todo/application/providers.dart';
import 'package:sreerajp_todo/core/errors/error_message_mapper.dart';
import 'package:sreerajp_todo/core/extensions/localization_extensions.dart';
import 'package:sreerajp_todo/data/models/sub_task_item.dart';
import 'package:sreerajp_todo/presentation/shared/widgets/adaptive_directionality.dart';

/// The tickable step list shown in the Focus view.
///
/// Ticks go through the daily todo notifier, so the day-lock and every other
/// repository rule still applies. A locked day simply cannot be ticked.
class FocusSubTaskList extends ConsumerWidget {
  const FocusSubTaskList({
    super.key,
    required this.todoId,
    required this.date,
    required this.subTasks,
    required this.canEdit,
  });

  final String todoId;
  final String date;
  final List<SubTaskItem> subTasks;

  /// False for a past day or a task that is already finished or dropped.
  final bool canEdit;

  Future<void> _toggle(
    BuildContext context,
    WidgetRef ref,
    SubTaskItem item,
    bool value,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    try {
      await ref
          .read(dailyTodoProvider(date).notifier)
          .toggleSubTask(todoId, item.id, value);
      ref.invalidate(todoByIdProvider(todoId));
    } on Exception catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(mapErrorToMessage(l10n, e))),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;

    if (subTasks.isEmpty) {
      return Text(
        l10n.focusNoSteps,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      );
    }

    final done = subTasks.where((s) => s.isCompleted).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              l10n.focusSteps,
              style: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$done/${subTasks.length}',
              style: theme.textTheme.labelLarge?.copyWith(
                color: done == subTasks.length
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        for (final item in subTasks)
          AdaptiveDirectionality(
            text: item.title,
            child: CheckboxListTile(
              value: item.isCompleted,
              onChanged: canEdit
                  ? (value) => _toggle(context, ref, item, value ?? false)
                  : null,
              contentPadding: EdgeInsets.zero,
              dense: true,
              controlAffinity: ListTileControlAffinity.leading,
              title: Text(
                item.title,
                style: theme.textTheme.bodyLarge?.copyWith(
                  decoration: item.isCompleted
                      ? TextDecoration.lineThrough
                      : null,
                  color: item.isCompleted
                      ? colorScheme.onSurfaceVariant
                      : colorScheme.onSurface,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
