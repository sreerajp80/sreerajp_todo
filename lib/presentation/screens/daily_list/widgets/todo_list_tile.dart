import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sreerajp_todo/application/providers.dart';
import 'package:sreerajp_todo/core/constants/app_strings.dart';
import 'package:sreerajp_todo/core/utils/duration_utils.dart';
import 'package:sreerajp_todo/data/models/todo_entity.dart';
import 'package:sreerajp_todo/data/models/todo_status.dart';
import 'package:sreerajp_todo/presentation/shared/widgets/status_badge.dart';

class TodoListTile extends ConsumerWidget {
  const TodoListTile({
    super.key,
    required this.todo,
    required this.isPast,
    required this.isSelected,
    required this.isMultiSelectMode,
    required this.onTap,
    required this.onLongPress,
    required this.onComplete,
    required this.onDrop,
    required this.onPort,
    required this.onCopy,
    required this.onEdit,
    required this.onDelete,
  });

  final TodoEntity todo;
  final bool isPast;
  final bool isSelected;
  final bool isMultiSelectMode;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onComplete;
  final VoidCallback onDrop;
  final VoidCallback onPort;
  final VoidCallback onCopy;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  bool get _isTerminal =>
      todo.status == TodoStatus.completed || todo.status == TodoStatus.dropped;

  Color _statusColor(ColorScheme colorScheme) {
    return switch (todo.status) {
      TodoStatus.completed => const Color(0xFF2E7D32),
      TodoStatus.dropped => const Color(0xFFC62828),
      TodoStatus.ported => const Color(0xFFF9A825),
      TodoStatus.pending => colorScheme.onSurfaceVariant,
    };
  }

  String _statusLabel() {
    return switch (todo.status) {
      TodoStatus.completed => AppStrings.statusCompleted,
      TodoStatus.dropped => AppStrings.statusDropped,
      TodoStatus.ported => AppStrings.statusPorted,
      TodoStatus.pending => AppStrings.statusPending,
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final trackingState = ref.watch(timeTrackingProvider(todo.id));
    final isRunning = trackingState.runningSegment != null;

    final totalSeconds = trackingState.totalDurationSeconds;
    final liveElapsed = ref.watch(liveTimerProvider(todo.id));
    final displaySeconds = isRunning
        ? totalSeconds + (liveElapsed.valueOrNull ?? 0)
        : totalSeconds;

    Widget tile = Card(
      elevation: isSelected ? 3 : 1,
      color: isSelected
          ? colorScheme.primaryContainer.withValues(alpha: 0.5)
          : null,
      child: InkWell(
        onTap: isMultiSelectMode ? onTap : onEdit,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              if (isMultiSelectMode)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Icon(
                    isSelected
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (todo.recurrenceRuleId != null)
                          Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Icon(
                              Icons.repeat,
                              size: 16,
                              color: colorScheme.primary,
                            ),
                          ),
                        Expanded(
                          child: Text(
                            todo.title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              decoration: todo.status == TodoStatus.completed
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        StatusBadge(
                          label: _statusLabel(),
                          color: _statusColor(colorScheme),
                        ),
                        const SizedBox(width: 8),
                        if (displaySeconds > 0 || isRunning)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isRunning ? Icons.timer : Icons.access_time,
                                size: 14,
                                color: isRunning
                                    ? colorScheme.primary
                                    : colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                formatDuration(displaySeconds),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: isRunning
                                      ? colorScheme.primary
                                      : colorScheme.onSurfaceVariant,
                                  fontWeight: isRunning
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    if (todo.sourceDate != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          '${AppStrings.copiedFrom} ${todo.sourceDate}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    if (todo.status == TodoStatus.ported &&
                        todo.portedTo != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          '→ ${todo.portedTo}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: const Color(0xFFF9A825),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (!isMultiSelectMode) ...[
                if (!_isTerminal &&
                    !isPast &&
                    todo.status != TodoStatus.ported)
                  IconButton(
                    icon: Icon(
                      isRunning ? Icons.stop_circle : Icons.play_circle,
                      color:
                          isRunning ? colorScheme.error : colorScheme.primary,
                    ),
                    tooltip:
                        isRunning ? AppStrings.stopTimer : AppStrings.startTimer,
                    onPressed: () {
                      final notifier =
                          ref.read(timeTrackingProvider(todo.id).notifier);
                      if (isRunning) {
                        notifier.stopTimer();
                      } else {
                        notifier.startTimer();
                      }
                    },
                  ),
                if (isPast)
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      Icons.lock_outline,
                      size: 20,
                      color: colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                  )
                else
                  _buildOverflowMenu(context),
              ],
            ],
          ),
        ),
      ),
    );

    if (isPast) {
      tile = Opacity(opacity: 0.7, child: tile);
    }

    return tile;
  }

  Widget _buildOverflowMenu(BuildContext context) {
    return PopupMenuButton<String>(
      itemBuilder: (context) => [
        if (todo.status == TodoStatus.pending) ...[
          const PopupMenuItem(
            value: 'complete',
            child: Row(
              children: [
                Icon(Icons.check_circle_outline, size: 20),
                SizedBox(width: 8),
                Text(AppStrings.statusCompleted),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'drop',
            child: Row(
              children: [
                Icon(Icons.cancel_outlined, size: 20),
                SizedBox(width: 8),
                Text(AppStrings.statusDropped),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'port',
            child: Row(
              children: [
                Icon(Icons.arrow_forward, size: 20),
                SizedBox(width: 8),
                Text(AppStrings.port),
              ],
            ),
          ),
        ],
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit_outlined, size: 20),
              SizedBox(width: 8),
              Text(AppStrings.edit),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'copy',
          child: Row(
            children: [
              Icon(Icons.copy_outlined, size: 20),
              SizedBox(width: 8),
              Text(AppStrings.copy),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline, size: 20),
              SizedBox(width: 8),
              Text(AppStrings.delete),
            ],
          ),
        ),
      ],
      onSelected: (value) {
        switch (value) {
          case 'complete':
            onComplete();
          case 'drop':
            onDrop();
          case 'port':
            onPort();
          case 'edit':
            onEdit();
          case 'copy':
            onCopy();
          case 'delete':
            onDelete();
        }
      },
    );
  }
}
