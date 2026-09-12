import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sreerajp_todo/application/providers.dart';
import 'package:sreerajp_todo/core/constants/app_routes.dart';
import 'package:sreerajp_todo/core/extensions/localization_extensions.dart';
import 'package:sreerajp_todo/core/utils/date_utils.dart';
import 'package:sreerajp_todo/core/utils/duration_utils.dart';
import 'package:sreerajp_todo/data/models/spaced_repetition_item_entity.dart';
import 'package:sreerajp_todo/data/models/todo_entity.dart';
import 'package:sreerajp_todo/data/models/todo_status.dart';
import 'package:sreerajp_todo/presentation/shared/theme/app_theme.dart';
import 'package:sreerajp_todo/presentation/shared/widgets/confirm_dialog.dart';
import 'package:sreerajp_todo/presentation/shared/widgets/status_badge.dart';

final _masteryDeckDetailItemProvider =
    FutureProvider.family<SpacedRepetitionItemEntity?, String>((
      ref,
      deckId,
    ) async {
      final repo = ref.watch(spacedRepetitionRepositoryProvider);
      return repo.getItemById(deckId);
    });

class MasteryDeckDetailScreen extends ConsumerWidget {
  const MasteryDeckDetailScreen({super.key, required this.deckId});

  final String deckId;

  String _statusLabel(BuildContext context, TodoStatus status) {
    return switch (status) {
      TodoStatus.pending => context.l10n.statusPending,
      TodoStatus.working => context.l10n.statusWorking,
      TodoStatus.completed => context.l10n.statusCompleted,
      TodoStatus.dropped => context.l10n.statusDropped,
      TodoStatus.ported => context.l10n.statusPorted,
    };
  }

  void _onAddTodo(BuildContext context) {
    context.push(
      AppRoutes.createTodoPath(
        date: todayAsIso(),
        masteryDeckId: deckId,
      ),
    );
  }

  Future<void> _deleteDeck(
    BuildContext context,
    WidgetRef ref,
    SpacedRepetitionItemEntity deck,
  ) async {
    final confirmed = await showConfirmDialog(
      context,
      title: context.l10n.deleteDeck,
      content: context.l10n.deleteDeckConfirmation,
    );

    if (!confirmed || !context.mounted) return;

    await ref.read(spacedRepetitionRepositoryProvider).deleteItem(deck.id);
    ref.invalidate(allMasteryDecksProvider);
    ref.invalidate(masteryDeckTodosProvider(deck.id));
    ref.invalidate(masteryDeckProgressProvider(deck.id));

    if (context.mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final deckAsync = ref.watch(_masteryDeckDetailItemProvider(deckId));
    final todosAsync = ref.watch(masteryDeckTodosProvider(deckId));
    final progressAsync = ref.watch(masteryDeckProgressProvider(deckId));

    return Scaffold(
      appBar: AppBar(
        title: deckAsync.maybeWhen(
          data: (deck) => Text(deck?.title ?? context.l10n.masteryDecksTitle),
          orElse: () => Text(context.l10n.masteryDecksTitle),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              ref.invalidate(_masteryDeckDetailItemProvider(deckId));
              ref.invalidate(masteryDeckTodosProvider(deckId));
              ref.invalidate(masteryDeckProgressProvider(deckId));
            },
            tooltip: 'Refresh',
          ),
          deckAsync.maybeWhen(
            data: (deck) => deck != null
                ? PopupMenuButton<String>(
                    onSelected: (action) {
                      if (action == 'delete') {
                        _deleteDeck(context, ref, deck);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_outline_rounded,
                              color: colorScheme.error,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              context.l10n.deleteDeck,
                              style: TextStyle(color: colorScheme.error),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _onAddTodo(context),
        icon: const Icon(Icons.add_task_rounded),
        label: Text(context.l10n.addTodoToDeck),
      ),
      body: deckAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error loading deck: $err')),
        data: (deck) {
          if (deck == null) {
            return const Center(child: Text('Deck not found'));
          }

          final progress = progressAsync.maybeWhen(
            data: (p) => p,
            orElse: () => MasteryDeckProgress.empty,
          );

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
            children: [
              // Header Card
              Card(
                elevation: 0,
                color: colorScheme.surfaceContainerLow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.psychology_outlined,
                              color: colorScheme.onPrimaryContainer,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  deck.title,
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (deck.description != null &&
                                    deck.description!.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    deck.description!,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Progress Bar & Stats
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            context.l10n.masteryOverallProgress,
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${(progress.completionRatio * 100).toInt()}%',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: progress.totalTasks > 0
                              ? progress.completionRatio
                              : 0.0,
                          minHeight: 8,
                          backgroundColor: colorScheme.surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            progress.completionRatio >= 1.0
                                ? AppTheme.statusColor(
                                    theme,
                                    TodoStatus.completed,
                                  )
                                : colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildStatPill(
                            context,
                            icon: Icons.checklist_rounded,
                            label: context.l10n.masteryTasksCount(
                              progress.completedTasks,
                              progress.totalTasks,
                            ),
                            color: colorScheme.secondaryContainer,
                            textColor: colorScheme.onSecondaryContainer,
                          ),
                          if (progress.totalTrackedSeconds > 0)
                            _buildStatPill(
                              context,
                              icon: Icons.timer_outlined,
                              label: formatDuration(
                                progress.totalTrackedSeconds,
                              ),
                              color: colorScheme.primaryContainer,
                              textColor: colorScheme.onPrimaryContainer,
                            ),
                          if (progress.workingTasks > 0)
                            _buildStatPill(
                              context,
                              icon: Icons.pending_actions_rounded,
                              label:
                                  '${progress.workingTasks} ${_statusLabel(context, TodoStatus.working)}',
                              color: AppTheme.statusColor(
                                theme,
                                TodoStatus.working,
                              ).withValues(alpha: 0.15),
                              textColor: AppTheme.statusColor(
                                theme,
                                TodoStatus.working,
                              ),
                            ),
                          if (progress.pendingTasks > 0)
                            _buildStatPill(
                              context,
                              icon: Icons.hourglass_empty_rounded,
                              label:
                                  '${progress.pendingTasks} ${_statusLabel(context, TodoStatus.pending)}',
                              color: colorScheme.surfaceContainerHighest,
                              textColor: colorScheme.onSurfaceVariant,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Todos Section Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tasks in Deck',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    todosAsync.maybeWhen(
                      data: (todos) => Text(
                        '${todos.length}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      orElse: () => const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Todos List
              todosAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (err, _) => Center(
                  child: Text('Error loading tasks: $err'),
                ),
                data: (todos) {
                  if (todos.isEmpty) {
                    return Card(
                      elevation: 0,
                      color: colorScheme.surfaceContainerLowest,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: colorScheme.outlineVariant),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 40,
                          horizontal: 16,
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.assignment_outlined,
                              size: 48,
                              color: colorScheme.primary.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              context.l10n.noMasteryTodos,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              context.l10n.noMasteryTodosSubtitle,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            FilledButton.icon(
                              onPressed: () => _onAddTodo(context),
                              icon: const Icon(Icons.add, size: 18),
                              label: Text(context.l10n.addTodoToDeck),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: todos.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final todo = todos[index];
                      return _buildTodoTile(context, ref, todo);
                    },
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatPill(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodoTile(BuildContext context, WidgetRef ref, TodoEntity todo) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isCompleted = todo.status == TodoStatus.completed;

    return Card(
      elevation: 0,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isCompleted
              ? colorScheme.outlineVariant.withValues(alpha: 0.3)
              : colorScheme.outlineVariant,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () async {
          await context.push(AppRoutes.editTodoPath(todo.id));
          ref.invalidate(masteryDeckTodosProvider(deckId));
          ref.invalidate(masteryDeckProgressProvider(deckId));
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              // Status Toggle Button
              IconButton(
                icon: Icon(
                  isCompleted
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: isCompleted
                      ? AppTheme.statusColor(theme, TodoStatus.completed)
                      : colorScheme.onSurfaceVariant,
                ),
                onPressed: () async {
                  final newStatus = isCompleted
                      ? TodoStatus.pending
                      : TodoStatus.completed;
                  await ref.read(todoRepositoryProvider).updateStatus(
                    todo.id,
                    newStatus,
                  );
                  ref.invalidate(masteryDeckTodosProvider(deckId));
                  ref.invalidate(masteryDeckProgressProvider(deckId));
                  ref.invalidate(dailyTodoProvider(todo.date));
                },
                tooltip: isCompleted
                    ? context.l10n.reopenAction
                    : context.l10n.completeAction,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      todo.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        decoration: isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        color: isCompleted
                            ? colorScheme.onSurface.withValues(alpha: 0.5)
                            : colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        StatusBadge(
                          label: _statusLabel(context, todo.status),
                          status: todo.status,
                        ),
                        Text(
                          todo.date,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (todo.targetSeconds != null)
                          Text(
                            'Target: ${formatDuration(todo.targetSeconds!)}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        if (todo.subTasks.isNotEmpty)
                          Text(
                            '${todo.subTasks.where((s) => s.isCompleted).length}/${todo.subTasks.length} subtasks',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
