import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sreerajp_todo/application/providers.dart';
import 'package:sreerajp_todo/core/constants/app_strings.dart';
import 'package:sreerajp_todo/core/utils/duration_utils.dart';
import 'package:sreerajp_todo/data/models/todo_entity.dart';
import 'package:sreerajp_todo/data/models/todo_status.dart';
import 'package:sreerajp_todo/presentation/shared/theme/app_theme.dart';
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
    required this.onViewSegments,
    required this.animationIndex,
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
  final VoidCallback onViewSegments;
  final int animationIndex;

  bool get _isTerminal =>
      todo.status == TodoStatus.completed || todo.status == TodoStatus.dropped;

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
    final statusColor = AppTheme.statusColor(theme, todo.status);

    final tile = Card(
      elevation: isSelected ? 2 : 0,
      color: isSelected
          ? colorScheme.primaryContainer.withValues(alpha: 0.52)
          : null,
      child: Semantics(
        container: true,
        label: todo.title,
        child: InkWell(
          onTap: isMultiSelectMode ? onTap : onEdit,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                if (isMultiSelectMode)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Semantics(
                      button: true,
                      label: AppStrings.toggleSelection,
                      child: Icon(
                        isSelected
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: isSelected
                            ? colorScheme.primary
                            : colorScheme.onSurfaceVariant,
                      ),
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
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          StatusBadge(
                            label: _statusLabel(),
                            status: todo.status,
                          ),
                          if (displaySeconds > 0 || isRunning)
                            Semantics(
                              label: isRunning
                                  ? AppStrings.runningTimerForTask(todo.title)
                                  : AppStrings.totalTimeForTask(
                                      todo.title,
                                      formatDuration(displaySeconds),
                                    ),
                              child: ExcludeSemantics(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isRunning
                                          ? Icons.timer
                                          : Icons.access_time,
                                      size: 14,
                                      color: isRunning
                                          ? colorScheme.primary
                                          : colorScheme.onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      formatDuration(displaySeconds),
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: isRunning
                                                ? colorScheme.primary
                                                : colorScheme.onSurfaceVariant,
                                            fontWeight: isRunning
                                                ? FontWeight.w700
                                                : FontWeight.normal,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (todo.sourceDate != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
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
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '${AppStrings.portedTo}: ${todo.portedTo}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.w700,
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
                    Semantics(
                      button: true,
                      label: isRunning
                          ? AppStrings.stopTimerForTask(todo.title)
                          : AppStrings.startTimerForTask(todo.title),
                      child: IconButton(
                        icon: Icon(
                          isRunning ? Icons.stop_circle : Icons.play_circle,
                          color: isRunning
                              ? colorScheme.error
                              : colorScheme.primary,
                        ),
                        tooltip: isRunning
                            ? AppStrings.stopTimer
                            : AppStrings.startTimer,
                        onPressed: () {
                          final notifier = ref.read(
                            timeTrackingProvider(todo.id).notifier,
                          );
                          if (isRunning) {
                            notifier.stopTimer();
                          } else {
                            notifier.startTimer();
                          }
                        },
                      ),
                    ),
                  if (isPast)
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Semantics(
                        label: AppStrings.lockedTask,
                        child: Icon(
                          Icons.lock_outline,
                          size: 20,
                          color: colorScheme.onSurface.withValues(alpha: 0.44),
                        ),
                      ),
                    )
                  else
                    PopupMenuButton<String>(
                      tooltip: AppStrings.openTaskActions,
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
                          value: 'segments',
                          child: Row(
                            children: [
                              Icon(Icons.timer_outlined, size: 20),
                              SizedBox(width: 8),
                              Text(AppStrings.viewSegments),
                            ],
                          ),
                        ),
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
                          case 'segments':
                            onViewSegments();
                          case 'edit':
                            onEdit();
                          case 'copy':
                            onCopy();
                          case 'delete':
                            onDelete();
                        }
                      },
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(
        milliseconds: 180 + (animationIndex * 24).clamp(0, 220),
      ),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 16),
            child: child,
          ),
        );
      },
      child: isPast ? Opacity(opacity: 0.74, child: tile) : tile,
    );
  }
}
