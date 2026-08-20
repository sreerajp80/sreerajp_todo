import 'package:flutter/material.dart';
import 'package:sreerajp_todo/core/extensions/localization_extensions.dart';
import 'package:sreerajp_todo/data/models/todo_priority.dart';
import 'package:sreerajp_todo/presentation/shared/task_default_labels.dart';

/// A row of chips for picking how important a task is.
///
/// Kept as chips rather than a dropdown because there are only four values and
/// the chosen one carries a colour, which a closed dropdown would hide.
class PrioritySelector extends StatelessWidget {
  const PrioritySelector({
    super.key,
    required this.selected,
    required this.onChanged,
    this.enabled = true,
  });

  final TodoPriority selected;
  final ValueChanged<TodoPriority> onChanged;

  /// False on a day-locked task, where the chips are shown but cannot be used.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final priority in TodoPriority.values)
          ChoiceChip(
            label: Text(priorityName(l10n, priority)),
            selected: selected == priority,
            onSelected: enabled ? (_) => onChanged(priority) : null,
            avatar: switch (priorityColor(theme, priority)) {
              final Color color => CircleAvatar(
                backgroundColor: color,
                radius: 6,
              ),
              null => null,
            },
          ),
      ],
    );
  }
}
