import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sreerajp_todo/application/providers.dart';
import 'package:sreerajp_todo/core/utils/date_utils.dart';
import 'package:sreerajp_todo/core/utils/unicode_utils.dart';
import 'package:sreerajp_todo/data/models/spaced_repetition_item_entity.dart';
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
          title: const Text('New Mastery Deck Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Task / Item Title',
                  hintText: 'e.g. Lalitha Sahasranamam Ch 1',
                ),
                autofocus: true,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
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

                await ref
                    .read(spacedRepetitionRepositoryProvider)
                    .insertItem(item);
                await ref.read(generateSpacedRepetitionTasksProvider).call();

                if (context.mounted) {
                  Navigator.of(context).pop();
                  ref.invalidate(masteryDeckItemsProvider);
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(masteryDeckItemsProvider);
    final theme = Theme.of(context);

    return ResponsiveScaffold(
      currentDestination: AppScaffoldDestination.masteryDeck,
      appBar: AppBar(
        title: const Text('Mastery Decks (SRS)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(masteryDeckItemsProvider),
            tooltip: 'Refresh Deck',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('New Mastery Item'),
      ),
      body: itemsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error loading deck: $err')),
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.psychology,
                    size: 64,
                    color: theme.colorScheme.primary.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Mastery Deck items yet',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add tasks or use #mastery in todo titles to track spaced repetition.',
                    style: theme.textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final item = items[index];
              return Card(
                elevation: 1,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Text(
                      'L${item.level}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  title: Text(
                    item.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Next review: ${item.nextReviewDate} (${item.intervalDays}d interval)'
                    '${item.description != null ? '\n${item.description}' : ''}',
                  ),
                  isThreeLine: item.description != null,
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () async {
                      await ref
                          .read(spacedRepetitionRepositoryProvider)
                          .deleteItem(item.id);
                      ref.invalidate(masteryDeckItemsProvider);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
