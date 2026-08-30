import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sreerajp_todo/application/pending_alert_notifier.dart';
import 'package:sreerajp_todo/application/providers.dart';
import 'package:sreerajp_todo/core/constants/app_routes.dart';
import 'package:sreerajp_todo/core/extensions/localization_extensions.dart';
import 'package:sreerajp_todo/core/utils/date_utils.dart';
import 'package:sreerajp_todo/core/utils/duration_utils.dart';
import 'package:sreerajp_todo/data/models/todo_entity.dart';
import 'package:sreerajp_todo/data/models/todo_status.dart';
import 'package:sreerajp_todo/presentation/shared/task_default_labels.dart';
import 'package:sreerajp_todo/presentation/shared/widgets/adaptive_directionality.dart';

/// Modal bottom sheet presenting today's and previous days' pending todos.
class PendingTodosAlertSheet extends ConsumerStatefulWidget {
  const PendingTodosAlertSheet({
    super.key,
    required this.todayTodos,
    this.previousTodos = const [],
  });

  final List<TodoEntity> todayTodos;
  final List<TodoEntity> previousTodos;

  static Future<void> show(
    BuildContext context, {
    required List<TodoEntity> todayTodos,
    List<TodoEntity> previousTodos = const [],
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => PendingTodosAlertSheet(
        todayTodos: todayTodos,
        previousTodos: previousTodos,
      ),
    );
  }

  static Future<void> showPayload(
    BuildContext context,
    PendingAlertPayload payload,
  ) {
    return show(
      context,
      todayTodos: payload.todayTodos,
      previousTodos: payload.previousTodos,
    );
  }

  @override
  ConsumerState<PendingTodosAlertSheet> createState() =>
      _PendingTodosAlertSheetState();
}

class _PendingTodosAlertSheetState
    extends ConsumerState<PendingTodosAlertSheet> {
  late List<TodoEntity> _todayTodos;
  late List<TodoEntity> _previousTodos;

  @override
  void initState() {
    super.initState();
    _todayTodos = List.of(widget.todayTodos);
    _previousTodos = List.of(widget.previousTodos);
  }

  int get _totalCount => _todayTodos.length + _previousTodos.length;

  Future<void> _portTask(TodoEntity todo) async {
    final today = todayAsIso();
    try {
      final moveUseCase = ref.read(moveTodoProvider);
      await moveUseCase(todo.id, today);

      if (!mounted) return;

      final updatedTodo = await ref
          .read(todoRepositoryProvider)
          .getTodoById(todo.id);

      setState(() {
        _previousTodos.removeWhere((t) => t.id == todo.id);
        if (updatedTodo != null) {
          _todayTodos.removeWhere((t) => t.id == todo.id);
          _todayTodos.add(updatedTodo);
        }
      });

      ref.invalidate(dailyTodoProvider(todo.date));
      ref.invalidate(dailyTodoProvider(today));
      ref.invalidate(statisticsProvider);
      ref.invalidate(pendingAlertPayloadProvider);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.taskMovedToToday),
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final today = todayAsIso();

    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      minChildSize: 0.4,
      maxChildSize: 0.94,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant.withAlpha(80),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.notifications_active_rounded,
                      color: theme.colorScheme.onPrimaryContainer,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.pendingAlertsSheetTitle,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _totalCount == 0
                              ? l10n.pendingAlertsSheetEmpty
                              : l10n.pendingAlertsSheetCount(_totalCount),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 8),

              // Todos List
              Expanded(
                child: _totalCount == 0
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle_outline_rounded,
                              size: 56,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              l10n.pendingAlertsSheetEmpty,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      )
                    : ListView(
                        controller: scrollController,
                        children: [
                          if (_todayTodos.isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.today_rounded,
                                    size: 18,
                                    color: theme.colorScheme.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    l10n.pendingAlertsTodaySection,
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: theme.colorScheme.primary,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            ..._todayTodos.map(
                              (todo) => _buildTodayTodoCard(
                                context,
                                theme,
                                l10n,
                                todo,
                                today,
                              ),
                            ),
                          ],
                          if (_previousTodos.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.history_rounded,
                                    size: 18,
                                    color: theme.colorScheme.secondary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    l10n.pendingAlertsPreviousSection,
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: theme.colorScheme.secondary,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            ..._previousTodos.map(
                              (todo) => _buildPreviousTodoCard(
                                context,
                                theme,
                                l10n,
                                todo,
                              ),
                            ),
                          ],
                        ],
                      ),
              ),

              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),

              // Action buttons footer
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        ref
                            .read(pendingAlertSettingsProvider.notifier)
                            .snoozeInterval(const Duration(hours: 1));
                      },
                      child: Text(
                        l10n.pendingAlertsSnooze,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        context.go(AppRoutes.dailyListPath(today));
                      },
                      child: Text(
                        l10n.pendingAlertsGoToToday,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.pendingAlertsDismiss),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTodayTodoCard(
    BuildContext context,
    ThemeData theme,
    dynamic l10n,
    TodoEntity todo,
    String today,
  ) {
    final priorityDotColor = priorityColor(theme, todo.priority);
    final isWorking = todo.status == TodoStatus.working;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      color: theme.colorScheme.surfaceContainerHighest.withAlpha(120),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withAlpha(80)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: priorityDotColor != null
            ? Tooltip(
                message: priorityName(l10n, todo.priority),
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: priorityDotColor,
                    shape: BoxShape.circle,
                  ),
                ),
              )
            : Icon(
                isWorking
                    ? Icons.play_circle_fill_rounded
                    : Icons.radio_button_unchecked,
                color: isWorking
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
        title: AdaptiveDirectionality(
          text: todo.title,
          child: Text(
            todo.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        subtitle: todo.targetSeconds != null && todo.targetSeconds! > 0
            ? Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      size: 14,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      formatDuration(todo.targetSeconds!),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              )
            : null,
        trailing: FilledButton.tonalIcon(
          onPressed: () async {
            Navigator.of(context).pop();
            if (!isWorking) {
              await ref
                  .read(timeTrackingProvider(todo.id).notifier)
                  .startTimer();
            }
            if (context.mounted) {
              context.go(AppRoutes.dailyListPath(today));
            }
          },
          icon: Icon(
            isWorking ? Icons.visibility_rounded : Icons.play_arrow_rounded,
            size: 18,
          ),
          label: Text(isWorking ? 'View' : l10n.pendingAlertsStartTimer),
        ),
        onTap: () {
          Navigator.of(context).pop();
          context.go(AppRoutes.dailyListPath(today));
        },
      ),
    );
  }

  Widget _buildPreviousTodoCard(
    BuildContext context,
    ThemeData theme,
    dynamic l10n,
    TodoEntity todo,
  ) {
    final priorityDotColor = priorityColor(theme, todo.priority);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      color: theme.colorScheme.surfaceContainerHighest.withAlpha(120),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withAlpha(80)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: priorityDotColor != null
            ? Tooltip(
                message: priorityName(l10n, todo.priority),
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: priorityDotColor,
                    shape: BoxShape.circle,
                  ),
                ),
              )
            : const Icon(Icons.history_rounded, size: 20),
        title: AdaptiveDirectionality(
          text: todo.title,
          child: Text(
            todo.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            todo.date,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        trailing: FilledButton.icon(
          onPressed: () => _portTask(todo),
          icon: const Icon(Icons.arrow_forward_rounded, size: 16),
          label: Text(l10n.pendingAlertsPortToToday),
        ),
      ),
    );
  }
}
