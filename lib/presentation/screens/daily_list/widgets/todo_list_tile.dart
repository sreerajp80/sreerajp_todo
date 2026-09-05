import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sreerajp_todo/core/constants/app_routes.dart';
import 'package:sreerajp_todo/application/providers.dart';
import 'package:sreerajp_todo/core/extensions/localization_extensions.dart';
import 'package:sreerajp_todo/core/utils/duration_utils.dart';
import 'package:sreerajp_todo/data/models/todo_entity.dart';
import 'package:sreerajp_todo/data/models/todo_status.dart';
import 'package:sreerajp_todo/presentation/shared/task_default_labels.dart';
import 'package:sreerajp_todo/presentation/shared/theme/app_theme.dart';
import 'package:sreerajp_todo/presentation/shared/widgets/status_badge.dart';
import 'package:sreerajp_todo/presentation/shared/widgets/timer_controls.dart';
import 'package:sreerajp_todo/presentation/shared/widgets/undo_status_snackbar.dart';

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
    this.onReopen,
    required this.onPort,
    required this.onCopy,
    required this.onEdit,
    required this.onDelete,
    required this.onMove,
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
  final VoidCallback? onReopen;
  final VoidCallback onPort;
  final VoidCallback onCopy;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onMove;
  final VoidCallback onViewSegments;
  final int animationIndex;

  /// Tracked time against the target, with a thin bar underneath.
  ///
  /// Display only. Passing the target changes the colour and nothing else: no
  /// timer is stopped and no status is changed, because a target is a guess and
  /// not a rule.
  Widget _buildTargetProgress(
    BuildContext context, {
    required int trackedSeconds,
    required int targetSeconds,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isOver = trackedSeconds > targetSeconds;
    final barColor = isOver ? colorScheme.error : colorScheme.primary;
    final fraction = targetSeconds <= 0
        ? 0.0
        : (trackedSeconds / targetSeconds).clamp(0.0, 1.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isOver
              ? context.l10n.targetOverBy(
                  formatDuration(trackedSeconds - targetSeconds),
                )
              : context.l10n.targetProgressLabel(
                  formatDuration(trackedSeconds),
                  formatDuration(targetSeconds),
                ),
          style: theme.textTheme.labelSmall?.copyWith(
            color: isOver ? colorScheme.error : colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 3),
        SizedBox(
          width: 120,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: fraction,
              minHeight: 3,
              backgroundColor: colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
        ),
      ],
    );
  }

  TodoStatus _effectiveStatus({
    required bool isRunning,
    required int totalDurationSeconds,
  }) {
    if (todo.status == TodoStatus.pending &&
        (isRunning || totalDurationSeconds > 0)) {
      return TodoStatus.working;
    }
    return todo.status;
  }

  String _statusLabel(BuildContext context, TodoStatus status) {
    return switch (status) {
      TodoStatus.pending => context.l10n.statusPending,
      TodoStatus.working => context.l10n.statusWorking,
      TodoStatus.completed => context.l10n.statusCompleted,
      TodoStatus.dropped => context.l10n.statusDropped,
      TodoStatus.ported => context.l10n.statusPorted,
    };
  }

  bool _canShowQuickActions(TodoStatus status) {
    return status == TodoStatus.pending || status == TodoStatus.working;
  }

  bool _canReopen(TodoStatus status) {
    return status == TodoStatus.completed || status == TodoStatus.dropped;
  }

  bool _canPort(TodoStatus status) {
    return status == TodoStatus.pending || status == TodoStatus.working;
  }

  BoxDecoration _buildCardDecoration(
    bool isDark,
    bool isSelected,
    ColorScheme colorScheme,
    TodoStatus status,
    bool isRunning,
  ) {
    final List<Color> gradientColors;
    final Color borderColor;
    final double borderWidth;

    if (isSelected) {
      gradientColors = isDark
          ? [const Color(0xFF2E4F7E), const Color(0xFF1C3459)]
          : [const Color(0xFFEDF3FF), const Color(0xFFD5E4FF)];
      borderColor = colorScheme.primary.withValues(alpha: isDark ? 0.55 : 0.30);
      borderWidth = 1.0;
    } else if (isRunning) {
      gradientColors = isDark
          ? [const Color(0xFF1B3E55), const Color(0xFF102535)]
          : [const Color(0xFFE6F3FF), const Color(0xFFCBE2FF)];
      borderColor = isDark ? const Color(0xFF4A90C4) : const Color(0xFF4A8FD4);
      borderWidth = 1.5;
    } else {
      switch (status) {
        case TodoStatus.completed:
          gradientColors = isDark
              ? [const Color(0xFF182E1F), const Color(0xFF0F1E13)]
              : [const Color(0xFFEEF8EF), const Color(0xFFD5EFD8)];
          borderColor = isDark
              ? const Color(0xFF2E6840)
              : const Color(0xFF7DC48A);
          borderWidth = 1.0;
        case TodoStatus.dropped:
          gradientColors = isDark
              ? [const Color(0xFF2E1818), const Color(0xFF1E1010)]
              : [const Color(0xFFFFF1F1), const Color(0xFFFFDDDD)];
          borderColor = isDark
              ? const Color(0xFF6B3030)
              : const Color(0xFFDE8888);
          borderWidth = 1.0;
        case TodoStatus.ported:
          gradientColors = isDark
              ? [const Color(0xFF2E2510), const Color(0xFF1E180A)]
              : [const Color(0xFFFFF9EE), const Color(0xFFFFEDD0)];
          borderColor = isDark
              ? const Color(0xFF6B4E1A)
              : const Color(0xFFD9A855);
          borderWidth = 1.0;
        case TodoStatus.pending:
          gradientColors = isDark
              ? [const Color(0xFF1F3457), const Color(0xFF142440)]
              : [Colors.white, const Color(0xFFECF2FF)];
          borderColor = isDark
              ? const Color(0xFF3A5472)
              : const Color(0xFFCFDDFA);
          borderWidth = 1.0;
        case TodoStatus.working:
          gradientColors = isDark
              ? [const Color(0xFF163347), const Color(0xFF0F2433)]
              : [const Color(0xFFEAF6FF), const Color(0xFFD6EBFF)];
          borderColor = isDark
              ? const Color(0xFF3B7AA6)
              : const Color(0xFF86B9E4);
          borderWidth = 1.0;
      }
    }

    if (isDark) {
      return BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: borderWidth),
        boxShadow: [
          BoxShadow(
            color: isRunning
                ? borderColor.withValues(alpha: 0.25)
                : Colors.black.withValues(alpha: 0.44),
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
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: borderWidth),
        boxShadow: [
          BoxShadow(
            color: isRunning
                ? borderColor.withValues(alpha: 0.25)
                : const Color(0xFF2B4D8F).withValues(alpha: 0.14),
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

  Widget _buildPopupMenu(
    BuildContext context,
    ColorScheme colorScheme,
    TodoStatus displayStatus,
  ) {
    return PopupMenuButton<String>(
      tooltip: context.l10n.openTaskActions,
      icon: Icon(Icons.more_vert, color: colorScheme.onSurfaceVariant),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      itemBuilder: (context) => [
        if (!isPast && _canReopen(displayStatus) && onReopen != null)
          PopupMenuItem(
            value: 'reopen',
            child: Row(
              children: [
                const Icon(Icons.replay_rounded, size: 20),
                const SizedBox(width: 8),
                Text(context.l10n.reopenAction),
              ],
            ),
          ),
        if (_canPort(displayStatus))
          PopupMenuItem(
            value: 'port',
            child: Row(
              children: [
                const Icon(Icons.arrow_forward, size: 20),
                const SizedBox(width: 8),
                Text(context.l10n.port),
              ],
            ),
          ),
        PopupMenuItem(
          value: 'history',
          child: Row(
            children: [
              const Icon(Icons.history_rounded, size: 20),
              const SizedBox(width: 8),
              Text(context.l10n.taskHistory),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'segments',
          child: Row(
            children: [
              const Icon(Icons.timer_outlined, size: 20),
              const SizedBox(width: 8),
              Text(context.l10n.viewSegments),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              const Icon(Icons.edit_outlined, size: 20),
              const SizedBox(width: 8),
              Text(context.l10n.edit),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'copy',
          child: Row(
            children: [
              const Icon(Icons.copy_outlined, size: 20),
              const SizedBox(width: 8),
              Text(context.l10n.copy),
            ],
          ),
        ),
        if (!isPast && _canPort(displayStatus))
          PopupMenuItem(
            value: 'move',
            child: Row(
              children: [
                const Icon(Icons.drive_file_move_outline, size: 20),
                const SizedBox(width: 8),
                Text(context.l10n.moveTodo),
              ],
            ),
          ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              const Icon(Icons.delete_outline, size: 20),
              const SizedBox(width: 8),
              Text(context.l10n.delete),
            ],
          ),
        ),
      ],
      onSelected: (value) {
        switch (value) {
          case 'reopen':
            onReopen?.call();
          case 'port':
            onPort();
          case 'history':
            context.push(AppRoutes.todoHistoryPath(todo.id));
          case 'segments':
            onViewSegments();
          case 'edit':
            onEdit();
          case 'copy':
            onCopy();
          case 'move':
            onMove();
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
    final priorityDotColor = priorityColor(theme, todo.priority);
    final trackingState = ref.watch(timeTrackingProvider(todo.id));
    final isRunning = trackingState.runningSegment != null;
    final trackingSettings = ref.watch(timeTrackingSettingsProvider);
    final isPaused =
        !isRunning && ref.watch(pausedTodosProvider).contains(todo.id);

    final totalSeconds = trackingState.totalDurationSeconds;
    final liveElapsed = ref.watch(liveTimerProvider(todo.id));
    final displaySeconds = isRunning
        ? totalSeconds + (liveElapsed.valueOrNull ?? 0)
        : totalSeconds;
    final displayStatus = _effectiveStatus(
      isRunning: isRunning,
      totalDurationSeconds: totalSeconds,
    );
    final statusColor = AppTheme.statusColor(theme, displayStatus);
    final tileTap = isMultiSelectMode
        ? (isPast ? null : onTap)
        : onViewSegments;
    final tileLongPress = isPast ? null : onLongPress;
    final showQuickActions =
        !isMultiSelectMode && !isPast && _canShowQuickActions(displayStatus);
    final showReopenAction =
        !isMultiSelectMode &&
        !isPast &&
        _canReopen(displayStatus) &&
        onReopen != null;

    final isDark = theme.brightness == Brightness.dark;

    final pendingPrereqs =
        ref.watch(pendingPrerequisitesProvider(todo.id)).valueOrNull ?? [];
    final isBlocked = pendingPrereqs.isNotEmpty;

    final completedSubTasks = todo.subTasks
        .where((st) => st.isCompleted)
        .length;
    final totalSubTasks = todo.subTasks.length;

    final tile = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: _buildCardDecoration(
          isDark,
          isSelected,
          colorScheme,
          displayStatus,
          isRunning,
        ),
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
                                    label: context.l10n.toggleSelection,
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
                              // An ordinary priority has no colour and so gets
                              // no dot, which keeps a plain list plain.
                              if (priorityDotColor != null)
                                Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: Tooltip(
                                    message: priorityName(
                                      context.l10n,
                                      todo.priority,
                                    ),
                                    child: Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        color: priorityDotColor,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
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
                                            alpha:
                                                theme.brightness ==
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
                              if (showReopenAction) ...[
                                const SizedBox(width: 8),
                                _buildCompactActionButton(
                                  context,
                                  icon: Icons.replay_rounded,
                                  tooltip: context.l10n.reopenAction,
                                  onPressed: onReopen!,
                                  backgroundColor: AppTheme.statusColor(
                                    theme,
                                    displayStatus,
                                  ).withValues(alpha: 0.14),
                                  foregroundColor: AppTheme.statusColor(
                                    theme,
                                    displayStatus,
                                  ),
                                ),
                              ],
                              if (showQuickActions) ...[
                                const SizedBox(width: 8),
                                _buildCompactActionButton(
                                  context,
                                  icon: Icons.check_circle_outline,
                                  tooltip: context.l10n.completeAction,
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
                                  tooltip: context.l10n.dropAction,
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
                                // Pause sits beside Stop while a timer runs,
                                // so ending a block and taking a break are
                                // never the same tap.
                                if (isRunning) ...[
                                  _buildCompactActionButton(
                                    context,
                                    icon: Icons.pause_circle_outline_rounded,
                                    tooltip: context.l10n.pauseTimer,
                                    onPressed: () => TimerActions.pause(
                                      context,
                                      ref,
                                      todo.id,
                                    ),
                                    backgroundColor:
                                        colorScheme.secondaryContainer,
                                    foregroundColor:
                                        colorScheme.onSecondaryContainer,
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                _buildCompactActionButton(
                                  context,
                                  icon: isRunning
                                      ? Icons.stop_circle_outlined
                                      : isPaused
                                      ? Icons.play_circle_outline_rounded
                                      : Icons.play_circle_fill_rounded,
                                  tooltip: isRunning
                                      ? context.l10n.stopTimer
                                      : isPaused
                                      ? context.l10n.resumeTimer
                                      : context.l10n.startTimer,
                                  onPressed: () {
                                    if (isRunning) {
                                      TimerActions.stop(context, ref, todo.id);
                                      return;
                                    }
                                    if (isBlocked) {
                                      showAppSnackBar(
                                        context,
                                        message: context.l10n.blockedWarning,
                                        backgroundColor: colorScheme.error,
                                      );
                                    }
                                    TimerActions.start(context, ref, todo.id);
                                  },
                                  backgroundColor: isRunning
                                      ? colorScheme.errorContainer
                                      : isBlocked
                                      ? colorScheme.errorContainer.withValues(
                                          alpha: 0.3,
                                        )
                                      : colorScheme.primaryContainer,
                                  foregroundColor: isRunning
                                      ? colorScheme.onErrorContainer
                                      : isBlocked
                                      ? colorScheme.error
                                      : colorScheme.onPrimaryContainer,
                                ),
                              ],
                              if (!isMultiSelectMode) ...[
                                if (isPast) ...[
                                  Padding(
                                    padding: const EdgeInsets.only(left: 6),
                                    child: Semantics(
                                      button: true,
                                      label: context.l10n.delete,
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
                                        tooltip: context.l10n.delete,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 2),
                                    child: Semantics(
                                      label: context.l10n.lockedTask,
                                      child: Icon(
                                        Icons.lock_outline,
                                        size: 20,
                                        color: colorScheme.onSurface.withValues(
                                          alpha: 0.44,
                                        ),
                                      ),
                                    ),
                                  ),
                                ] else
                                  _buildPopupMenu(
                                    context,
                                    colorScheme,
                                    displayStatus,
                                  ),
                              ],
                            ],
                          ),
                          // Row 2: status badge + timer + subtask pill + blocked badge + metadata
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              StatusBadge(
                                label: _statusLabel(context, displayStatus),
                                status: displayStatus,
                              ),
                              if (totalSubTasks > 0)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: completedSubTasks == totalSubTasks
                                        ? colorScheme.primaryContainer
                                        : colorScheme.surfaceContainerHigh,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: colorScheme.outlineVariant,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        completedSubTasks == totalSubTasks
                                            ? Icons.check_circle_outline
                                            : Icons.checklist_rounded,
                                        size: 13,
                                        color:
                                            completedSubTasks == totalSubTasks
                                            ? colorScheme.primary
                                            : colorScheme.onSurfaceVariant,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '$completedSubTasks/$totalSubTasks',
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color:
                                                  completedSubTasks ==
                                                      totalSubTasks
                                                  ? colorScheme.primary
                                                  : colorScheme
                                                        .onSurfaceVariant,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              // A paused task looks different from a stopped
                              // one, so the Resume button is not a surprise.
                              if (isPaused)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colorScheme.secondaryContainer,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: colorScheme.outlineVariant,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.pause_rounded,
                                        size: 13,
                                        color: colorScheme.onSecondaryContainer,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        context.l10n.timerPaused,
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: colorScheme
                                                  .onSecondaryContainer,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              if (isBlocked)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colorScheme.errorContainer
                                        .withValues(alpha: 0.6),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: colorScheme.error.withValues(
                                        alpha: 0.4,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.warning_amber_rounded,
                                        size: 13,
                                        color: colorScheme.onErrorContainer,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${context.l10n.blockedBy} ${pendingPrereqs.length}',
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color:
                                                  colorScheme.onErrorContainer,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              // Tapping the time chip opens the full screen
                              // Focus view for this task.
                              if (displaySeconds > 0 || isRunning)
                                GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: isMultiSelectMode
                                      ? null
                                      : () => context.push(
                                          AppRoutes.focusPath(todo.id),
                                        ),
                                  child: Tooltip(
                                    message: context.l10n.focusOpen,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isRunning
                                            ? colorScheme.primaryContainer
                                            : colorScheme.surfaceContainerLow,
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                        border: Border.all(
                                          color: isRunning
                                              ? colorScheme.primary.withValues(
                                                  alpha: 0.22,
                                                )
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
                                            isRunning
                                                ? formatDuration(displaySeconds)
                                                : formatDuration(
                                                    displaySeconds,
                                                    rounding: trackingSettings
                                                        .rounding,
                                                    format:
                                                        trackingSettings.format,
                                                  ),
                                            style: theme.textTheme.labelMedium
                                                ?.copyWith(
                                                  color: isRunning
                                                      ? colorScheme.primary
                                                      : colorScheme
                                                            .onSurfaceVariant,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              if (todo.targetSeconds != null)
                                _buildTargetProgress(
                                  context,
                                  trackedSeconds: displaySeconds,
                                  targetSeconds: todo.targetSeconds!,
                                ),
                              if (todo.sourceDate != null)
                                Text(
                                  '${context.l10n.copiedFrom} ${todo.sourceDate}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              if (todo.status == TodoStatus.ported &&
                                  todo.portedTo != null)
                                Text(
                                  '${context.l10n.portedTo}: ${todo.portedTo}',
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

    final animatedTile = TweenAnimationBuilder<double>(
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

    // Swipe-right reveal is only for today's todos, and not in multi-select.
    if (isPast || isMultiSelectMode) {
      return animatedTile;
    }

    return _SwipeRevealWrapper(
      onEdit: onEdit,
      onDelete: onDelete,
      onCopy: onCopy,
      onMove: onMove,
      child: animatedTile,
    );
  }
}

/// Slides a child widget to the right to reveal action buttons behind it.
///
/// Four action buttons are revealed: Edit, Copy, Move, Delete.
/// Tapping an action or tapping anywhere else closes the panel.
class _SwipeRevealWrapper extends StatefulWidget {
  const _SwipeRevealWrapper({
    required this.onEdit,
    required this.onDelete,
    required this.onCopy,
    required this.onMove,
    required this.child,
  });

  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onCopy;
  final VoidCallback onMove;
  final Widget child;

  @override
  State<_SwipeRevealWrapper> createState() => _SwipeRevealWrapperState();
}

class _SwipeRevealWrapperState extends State<_SwipeRevealWrapper>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;

  /// Width of the revealed action area.
  static const double _revealWidth = 200;

  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.35, 0),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _open() {
    if (!_isOpen) {
      _controller.forward();
      setState(() => _isOpen = true);
    }
  }

  void _close() {
    if (_isOpen) {
      _controller.reverse();
      setState(() => _isOpen = false);
    }
  }

  void _handleAction(VoidCallback action) {
    _close();
    action();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        if (details.delta.dx > 2) {
          _open();
        } else if (details.delta.dx < -2) {
          _close();
        }
      },
      child: Stack(
        children: [
          // Action buttons revealed behind the card
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) =>
                  Opacity(opacity: _controller.value, child: child),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 12),
                  child: SizedBox(
                    width: _revealWidth,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _SwipeActionButton(
                          icon: Icons.edit_outlined,
                          label: context.l10n.edit,
                          color: colorScheme.primary,
                          onTap: () => _handleAction(widget.onEdit),
                        ),
                        _SwipeActionButton(
                          icon: Icons.copy_outlined,
                          label: context.l10n.copy,
                          color: colorScheme.tertiary,
                          onTap: () => _handleAction(widget.onCopy),
                        ),
                        _SwipeActionButton(
                          icon: Icons.drive_file_move_outline,
                          label: context.l10n.moveTodo,
                          color: colorScheme.secondary,
                          onTap: () => _handleAction(widget.onMove),
                        ),
                        _SwipeActionButton(
                          icon: Icons.delete_outline,
                          label: context.l10n.delete,
                          color: colorScheme.error,
                          onTap: () => _handleAction(widget.onDelete),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // The card itself slides right
          SlideTransition(
            position: _slideAnimation,
            child: GestureDetector(
              onTap: _isOpen ? _close : null,
              behavior: _isOpen
                  ? HitTestBehavior.opaque
                  : HitTestBehavior.translucent,
              child: AbsorbPointer(absorbing: _isOpen, child: widget.child),
            ),
          ),
        ],
      ),
    );
  }
}

class _SwipeActionButton extends StatelessWidget {
  const _SwipeActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        button: true,
        label: label,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 22, color: color),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
