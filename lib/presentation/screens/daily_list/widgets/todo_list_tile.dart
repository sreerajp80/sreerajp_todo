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

  String _statusLabel() {
    return switch (todo.status) {
      TodoStatus.completed => AppStrings.statusCompleted,
      TodoStatus.dropped => AppStrings.statusDropped,
      TodoStatus.ported => AppStrings.statusPorted,
      TodoStatus.pending => AppStrings.statusPending,
    };
  }

  BoxDecoration _buildCardDecoration(
    bool isDark,
    bool isSelected,
    ColorScheme colorScheme,
  ) {
    if (isDark) {
      return BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isSelected
              ? [const Color(0xFF2E4F7E), const Color(0xFF1C3459)]
              : [const Color(0xFF1F3457), const Color(0xFF142440)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isSelected
              ? colorScheme.primary.withValues(alpha: 0.55)
              : const Color(0xFF3A5472),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.44),
            blurRadius: 18,
            offset: const Offset(0, 8),
            spreadRadius: -4,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.20),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      );
    } else {
      return BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isSelected
              ? [const Color(0xFFEDF3FF), const Color(0xFFD5E4FF)]
              : [Colors.white, const Color(0xFFECF2FF)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isSelected
              ? colorScheme.primary.withValues(alpha: 0.30)
              : const Color(0xFFCFDDFA),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2B4D8F).withValues(alpha: 0.14),
            blurRadius: 18,
            offset: const Offset(0, 7),
            spreadRadius: -3,
          ),
          BoxShadow(
            color: const Color(0xFF2B4D8F).withValues(alpha: 0.07),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      );
    }
  }

  Widget _buildCompactActionButton(
    BuildContext context, {
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
    required Color backgroundColor,
    required Color foregroundColor,
  }) {
    return Semantics(
      button: true,
      label: tooltip,
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 40,
            height: 40,
            child: Icon(icon, size: 20, color: foregroundColor),
          ),
        ),
      ),
    );
  }

  Widget _buildPopupMenu(BuildContext context, ColorScheme colorScheme) {
    return PopupMenuButton<String>(
      tooltip: AppStrings.openTaskActions,
      icon: Icon(
        Icons.more_vert,
        color: colorScheme.onSurfaceVariant,
      ),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      itemBuilder: (context) => [
        if (todo.status == TodoStatus.pending)
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
    );
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
    final tileTap = isMultiSelectMode ? (isPast ? null : onTap) : onEdit;
    final tileLongPress = isPast ? null : onLongPress;
    final showQuickActions =
        !isMultiSelectMode && !isPast && todo.status == TodoStatus.pending;

    final isDark = theme.brightness == Brightness.dark;

    final tile = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: DecoratedBox(
        decoration: _buildCardDecoration(isDark, isSelected, colorScheme),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Material(
                color: Colors.transparent,
                child: Semantics(
                  container: true,
                  label: todo.title,
                  child: InkWell(
                    onTap: tileTap,
                    onLongPress: tileLongPress,
                    borderRadius: BorderRadius.circular(24),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Row 1: [select?] [recurrence?] title [complete] [drop] [play/stop] [menu/lock]
                          Row(
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
                                      size: 22,
                                      color: isSelected
                                          ? colorScheme.primary
                                          : colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              if (todo.recurrenceRuleId != null)
                                Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.repeat,
                                    size: 14,
                                    color: colorScheme.onPrimaryContainer,
                                  ),
                                ),
                              Expanded(
                                child: Text(
                                  todo.title,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    decoration:
                                        todo.status == TodoStatus.completed
                                            ? TextDecoration.lineThrough
                                            : null,
                                    color: todo.status == TodoStatus.completed
                                        ? colorScheme.onSurface.withValues(
                                            alpha: theme.brightness ==
                                                    Brightness.dark
                                                ? 0.62
                                                : 0.45,
                                          )
                                        : null,
                                    decorationColor:
                                        todo.status == TodoStatus.completed
                                            ? statusColor
                                            : null,
                                    decorationThickness: 2,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (showQuickActions) ...[
                                const SizedBox(width: 8),
                                _buildCompactActionButton(
                                  context,
                                  icon: Icons.check_circle_outline,
                                  tooltip: AppStrings.completeAction,
                                  onPressed: onComplete,
                                  backgroundColor: AppTheme.statusColor(
                                    theme,
                                    TodoStatus.completed,
                                  ).withValues(alpha: 0.14),
                                  foregroundColor: AppTheme.statusColor(
                                    theme,
                                    TodoStatus.completed,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                _buildCompactActionButton(
                                  context,
                                  icon: Icons.cancel_outlined,
                                  tooltip: AppStrings.dropAction,
                                  onPressed: onDrop,
                                  backgroundColor: AppTheme.statusColor(
                                    theme,
                                    TodoStatus.dropped,
                                  ).withValues(alpha: 0.14),
                                  foregroundColor: AppTheme.statusColor(
                                    theme,
                                    TodoStatus.dropped,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Builder(
                                  builder: (context) {
                                    final notifier = ref.read(
                                      timeTrackingProvider(todo.id).notifier,
                                    );
                                    return _buildCompactActionButton(
                                      context,
                                      icon: isRunning
                                          ? Icons.stop_circle_outlined
                                          : Icons.play_circle_fill_rounded,
                                      tooltip: isRunning
                                          ? AppStrings.stopTimer
                                          : AppStrings.startTimer,
                                      onPressed: () {
                                        if (isRunning) {
                                          notifier.stopTimer();
                                        } else {
                                          notifier.startTimer();
                                        }
                                      },
                                      backgroundColor: isRunning
                                          ? colorScheme.errorContainer
                                          : colorScheme.primaryContainer,
                                      foregroundColor: isRunning
                                          ? colorScheme.onErrorContainer
                                          : colorScheme.onPrimaryContainer,
                                    );
                                  },
                                ),
                              ],
                              if (!isMultiSelectMode) ...[
                                if (isPast) ...[
                                  Padding(
                                    padding: const EdgeInsets.only(left: 6),
                                    child: Semantics(
                                      button: true,
                                      label: AppStrings.delete,
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.delete_outline,
                                          size: 20,
                                          color: colorScheme.onSurface
                                              .withValues(alpha: 0.44),
                                        ),
                                        onPressed: onDelete,
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        tooltip: AppStrings.delete,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 2),
                                    child: Semantics(
                                      label: AppStrings.lockedTask,
                                      child: Icon(
                                        Icons.lock_outline,
                                        size: 20,
                                        color: colorScheme.onSurface
                                            .withValues(alpha: 0.44),
                                      ),
                                    ),
                                  ),
                                ] else
                                  _buildPopupMenu(context, colorScheme),
                              ],
                            ],
                          ),
                          // Row 2: status badge + timer + metadata
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
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isRunning
                                        ? colorScheme.primaryContainer
                                        : colorScheme.surfaceContainerLow,
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(
                                      color: isRunning
                                          ? colorScheme.primary
                                              .withValues(alpha: 0.22)
                                          : colorScheme.outlineVariant,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isRunning
                                            ? Icons.timer_rounded
                                            : Icons.access_time_rounded,
                                        size: 14,
                                        color: isRunning
                                            ? colorScheme.primary
                                            : colorScheme.onSurfaceVariant,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        formatDuration(displaySeconds),
                                        style: theme.textTheme.labelMedium
                                            ?.copyWith(
                                          color: isRunning
                                              ? colorScheme.primary
                                              : colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              if (todo.sourceDate != null)
                                Text(
                                  '${AppStrings.copiedFrom} ${todo.sourceDate}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              if (todo.status == TodoStatus.ported &&
                                  todo.portedTo != null)
                                Text(
                                  '${AppStrings.portedTo}: ${todo.portedTo}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: statusColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Subtle shine line at top edge simulating a light source above
            Positioned(
              top: 1,
              left: 20,
              right: 20,
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.white.withValues(alpha: isDark ? 0.10 : 0.60),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],
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
