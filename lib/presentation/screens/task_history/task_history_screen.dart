import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sreerajp_todo/application/providers.dart';
import 'package:sreerajp_todo/core/errors/error_message_mapper.dart';
import 'package:sreerajp_todo/core/extensions/localization_extensions.dart';
import 'package:sreerajp_todo/core/utils/date_utils.dart';
import 'package:sreerajp_todo/core/utils/duration_utils.dart';
import 'package:sreerajp_todo/data/models/todo_entity.dart';
import 'package:sreerajp_todo/data/models/todo_history_entity.dart';
import 'package:sreerajp_todo/data/models/todo_status.dart';
import 'package:sreerajp_todo/presentation/shared/task_default_labels.dart';
import 'package:sreerajp_todo/presentation/shared/widgets/adaptive_directionality.dart';
import 'package:sreerajp_todo/presentation/shared/widgets/app_empty_state.dart';
import 'package:sreerajp_todo/presentation/shared/widgets/app_error_state.dart';
import 'package:sreerajp_todo/presentation/shared/widgets/status_badge.dart';

class TaskHistoryScreen extends ConsumerWidget {
  const TaskHistoryScreen({super.key, required this.todoId});

  final String todoId;

  String _formatEventTimestamp(String isoString) {
    try {
      final dt = DateTime.parse(isoString).toLocal();
      return DateFormat('MMM d, yyyy • hh:mm:ss a').format(dt);
    } catch (_) {
      return isoString;
    }
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final todoAsync = ref.watch(todoByIdProvider(todoId));
    final historyAsync = ref.watch(todoHistoryProvider(todoId));
    final trackingState = ref.watch(timeTrackingProvider(todoId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.taskHistory)),
      body: todoAsync.when(
        data: (todo) {
          if (todo == null) {
            return AppErrorState(message: l10n.errorTodoNotFound);
          }

          return historyAsync.when(
            data: (history) {
              return ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                children: [
                  _buildTaskSummaryCard(
                    context,
                    theme,
                    todo,
                    trackingState.totalDurationSeconds,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    l10n.taskHistorySubtitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (history.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: AppEmptyState(
                        icon: Icons.history,
                        title: l10n.taskHistory,
                        message: l10n.taskHistoryEmpty,
                      ),
                    )
                  else
                    ...history.asMap().entries.map((entry) {
                      final index = entry.key;
                      final event = entry.value;
                      final isLast = index == history.length - 1;
                      return _buildTimelineTile(
                        context,
                        theme,
                        event,
                        isLast: isLast,
                      );
                    }),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) =>
                AppErrorState(message: mapErrorToMessage(l10n, err)),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => AppErrorState(message: mapErrorToMessage(l10n, err)),
      ),
    );
  }

  Widget _buildTaskSummaryCard(
    BuildContext context,
    ThemeData theme,
    TodoEntity todo,
    int totalTrackedSeconds,
  ) {
    final l10n = context.l10n;
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withAlpha(120),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withAlpha(90)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: AdaptiveDirectionality(
                    text: todo.title,
                    child: Text(
                      todo.title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                StatusBadge(
                  status: todo.status,
                  label: _statusLabel(context, todo.status),
                ),
              ],
            ),
            if (todo.description != null && todo.description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              AdaptiveDirectionality(
                text: todo.description!,
                child: Text(
                  todo.description!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      formatDateFromIso(todo.date),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                if (todo.sourceDate != null && todo.sourceDate != todo.date)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.move_up_rounded,
                        size: 16,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${l10n.eventMoved}: ${formatDateFromIso(todo.sourceDate!)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.flag_rounded,
                      size: 16,
                      color: priorityColor(theme, todo.priority),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      priorityName(l10n, todo.priority),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.timer_rounded,
                      size: 16,
                      color: theme.colorScheme.secondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      formatDuration(totalTrackedSeconds),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineTile(
    BuildContext context,
    ThemeData theme,
    TodoHistoryEntity event, {
    required bool isLast,
  }) {
    final config = _getEventConfig(theme, event.eventType);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator (icon + connecting vertical line)
          Column(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: config.backgroundColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: config.iconColor, width: 1.5),
                ),
                child: Icon(config.icon, size: 18, color: config.iconColor),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: theme.colorScheme.outlineVariant.withAlpha(120),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          // Event content card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withAlpha(
                    70,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant.withAlpha(60),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          config.title(context),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: config.iconColor,
                          ),
                        ),
                        Text(
                          _formatEventTimestamp(event.eventTime),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      event.description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _EventConfig _getEventConfig(
    ThemeData theme,
    TodoHistoryEventType eventType,
  ) {
    switch (eventType) {
      case TodoHistoryEventType.created:
        return _EventConfig(
          icon: Icons.add_task_rounded,
          iconColor: Colors.green,
          backgroundColor: Colors.green.withAlpha(30),
          title: (ctx) => ctx.l10n.eventCreated,
        );
      case TodoHistoryEventType.moved:
        return _EventConfig(
          icon: Icons.move_up_rounded,
          iconColor: Colors.orange,
          backgroundColor: Colors.orange.withAlpha(30),
          title: (ctx) => ctx.l10n.eventMoved,
        );
      case TodoHistoryEventType.timerStarted:
        return _EventConfig(
          icon: Icons.play_arrow_rounded,
          iconColor: theme.colorScheme.primary,
          backgroundColor: theme.colorScheme.primary.withAlpha(30),
          title: (ctx) => ctx.l10n.eventTimerStarted,
        );
      case TodoHistoryEventType.timerStopped:
        return _EventConfig(
          icon: Icons.stop_rounded,
          iconColor: Colors.blueGrey,
          backgroundColor: Colors.blueGrey.withAlpha(30),
          title: (ctx) => 'Timer Session',
        );
      case TodoHistoryEventType.timerPaused:
        return _EventConfig(
          icon: Icons.pause_rounded,
          iconColor: Colors.amber,
          backgroundColor: Colors.amber.withAlpha(30),
          title: (ctx) => ctx.l10n.timerPaused,
        );
      case TodoHistoryEventType.manualSegmentAdded:
        return _EventConfig(
          icon: Icons.more_time_rounded,
          iconColor: Colors.teal,
          backgroundColor: Colors.teal.withAlpha(30),
          title: (ctx) => 'Manual Time',
        );
      case TodoHistoryEventType.statusChanged:
        return _EventConfig(
          icon: Icons.published_with_changes_rounded,
          iconColor: theme.colorScheme.secondary,
          backgroundColor: theme.colorScheme.secondary.withAlpha(30),
          title: (ctx) => 'Status Change',
        );
      case TodoHistoryEventType.subtaskToggled:
        return _EventConfig(
          icon: Icons.checklist_rounded,
          iconColor: Colors.purple,
          backgroundColor: Colors.purple.withAlpha(30),
          title: (ctx) => ctx.l10n.eventSubtaskToggled,
        );
      case TodoHistoryEventType.edited:
        return _EventConfig(
          icon: Icons.edit_note_rounded,
          iconColor: Colors.indigo,
          backgroundColor: Colors.indigo.withAlpha(30),
          title: (ctx) => ctx.l10n.eventEdited,
        );
    }
  }
}

class _EventConfig {
  const _EventConfig({
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.title,
  });

  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final String Function(BuildContext) title;
}
