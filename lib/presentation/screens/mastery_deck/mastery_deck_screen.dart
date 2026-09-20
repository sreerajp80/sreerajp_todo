import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sreerajp_todo/application/providers.dart';
import 'package:sreerajp_todo/core/constants/app_routes.dart';
import 'package:sreerajp_todo/core/extensions/localization_extensions.dart';
import 'package:sreerajp_todo/core/utils/date_utils.dart';
import 'package:sreerajp_todo/core/utils/duration_utils.dart';
import 'package:sreerajp_todo/core/utils/unicode_utils.dart';
import 'package:sreerajp_todo/presentation/shared/theme/app_theme.dart';
import 'package:sreerajp_todo/presentation/shared/widgets/confirm_dialog.dart';
import 'package:sreerajp_todo/presentation/shared/widgets/responsive_scaffold.dart';
import 'package:uuid/uuid.dart';

final masteryDeckItemsProvider =
    FutureProvider.autoDispose<List<SpacedRepetitionItemEntity>>((ref) async {
      final repo = ref.watch(spacedRepetitionRepositoryProvider);
      return repo.getAllItems();
    });

class MasteryDeckScreen extends ConsumerWidget {
  const MasteryDeckScreen({super.key});

  static const _uuid = Uuid();

  void _showCreateDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(context.l10n.newMasteryDeck),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: context.l10n.masteryDeckName,
                  hintText: context.l10n.masteryDeckNameHint,
                ),
                autofocus: true,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: context.l10n.masteryDeckDescription,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(context.l10n.cancel),
            ),
            FilledButton(
              onPressed: () async {
                final rawTitle = titleController.text.trim();
                if (rawTitle.isEmpty) return;

                final now = DateTime.now();
                final todayStr = dateTimeToIso(now);
                final nowIso = now.toUtc().toIso8601String();

                final item = SpacedRepetitionItemEntity(
                  id: _uuid.v4(),
                  title: nfcNormalize(rawTitle),
                  description: descriptionController.text.trim().isNotEmpty
                      ? nfcNormalize(descriptionController.text.trim())
                      : null,
                  level: 1,
                  easeFactor: 2.5,
                  intervalDays: 1,
                  nextReviewDate: todayStr,
                  active: true,
                  createdAt: nowIso,
                  updatedAt: nowIso,
                );

                // Creating a deck creates only the deck. No todo is created.
                await ref
                    .read(spacedRepetitionRepositoryProvider)
                    .insertItem(item);

                if (context.mounted) {
                  Navigator.of(context).pop();
                  ref.invalidate(allMasteryDecksProvider);
                  ref.invalidate(masteryDeckItemsProvider);
                }
              },
              child: Text(context.l10n.save),
            ),
          ],
        );
      },
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
    ref.invalidate(masteryDeckItemsProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(masteryDeckItemsProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ResponsiveScaffold(
      currentDestination: AppScaffoldDestination.masteryDeck,
      appBar: AppBar(
        title: Text(context.l10n.masteryDecksTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(allMasteryDecksProvider);
              ref.invalidate(masteryDeckItemsProvider);
            },
            tooltip: context.l10n.tooltipRefresh,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: Text(context.l10n.newMasteryDeck),
      ),
      body: itemsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) =>
            Center(child: Text(context.l10n.decksLoadError(err.toString()))),
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.psychology_outlined,
                      size: 72,
                      color: colorScheme.primary.withValues(alpha: 0.4),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      context.l10n.noMasteryDecks,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.l10n.noMasteryDecksSubtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: () => _showCreateDialog(context, ref),
                      icon: const Icon(Icons.add_rounded),
                      label: Text(context.l10n.newMasteryDeck),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = items[index];
              return _MasteryDeckCard(
                deck: item,
                onTap: () async {
                  await context.push(AppRoutes.masteryDeckDetailPath(item.id));
                  ref.invalidate(masteryDeckItemsProvider);
                  ref.invalidate(allMasteryDecksProvider);
                },
                onDelete: () => _deleteDeck(context, ref, item),
              );
            },
          );
        },
      ),
    );
  }
}

class _MasteryDeckCard extends ConsumerWidget {
  const _MasteryDeckCard({
    required this.deck,
    required this.onTap,
    required this.onDelete,
  });

  final SpacedRepetitionItemEntity deck;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final progressAsync = ref.watch(masteryDeckProgressProvider(deck.id));

    final progress = progressAsync.maybeWhen(
      data: (p) => p,
      orElse: () => MasteryDeckProgress.empty,
    );

    final isCompleted =
        progress.totalTasks > 0 &&
        progress.completedTasks == progress.totalTasks;
    final percent = (progress.completionRatio * 100).toInt();

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isCompleted
              ? AppTheme.statusColor(
                  theme,
                  TodoStatus.completed,
                ).withValues(alpha: 0.4)
              : colorScheme.outlineVariant.withValues(alpha: 0.6),
          width: isCompleted ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title, Description, Delete Menu
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? AppTheme.statusColor(
                              theme,
                              TodoStatus.completed,
                            ).withValues(alpha: 0.15)
                          : colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isCompleted
                          ? Icons.military_tech_rounded
                          : Icons.psychology_outlined,
                      color: isCompleted
                          ? AppTheme.statusColor(theme, TodoStatus.completed)
                          : colorScheme.onPrimaryContainer,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          deck.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (deck.description != null &&
                            deck.description!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            deck.description!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      size: 20,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    onPressed: onDelete,
                    tooltip: context.l10n.deleteDeck,
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Progress Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.l10n.masteryOverallProgress,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '$percent%',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isCompleted
                          ? AppTheme.statusColor(theme, TodoStatus.completed)
                          : colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: progress.totalTasks > 0
                      ? progress.completionRatio
                      : 0.0,
                  minHeight: 6,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isCompleted
                        ? AppTheme.statusColor(theme, TodoStatus.completed)
                        : colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Status Summary Row
              Wrap(
                spacing: 8,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    context.l10n.masteryTasksCount(
                      progress.completedTasks,
                      progress.totalTasks,
                    ),
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (progress.totalTrackedSeconds > 0) ...[
                    Text('•', style: TextStyle(color: colorScheme.outline)),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          size: 13,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          formatDuration(progress.totalTrackedSeconds),
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
