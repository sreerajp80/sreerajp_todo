import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sreerajp_todo/application/providers.dart';
import 'package:sreerajp_todo/core/extensions/localization_extensions.dart';
import 'package:sreerajp_todo/core/utils/duration_utils.dart';
import 'package:sreerajp_todo/core/utils/unicode_utils.dart' as unicode_utils;
import 'package:sreerajp_todo/data/models/daily_reflection_entity.dart';
import 'package:sreerajp_todo/data/models/todo_entity.dart';
import 'package:sreerajp_todo/data/models/todo_status.dart';

class EveningReflectionModal extends ConsumerStatefulWidget {
  const EveningReflectionModal({
    super.key,
    required this.date,
    required this.isPast,
    required this.todos,
  });

  final String date;
  final bool isPast;
  final List<TodoEntity> todos;

  static Future<void> show(
    BuildContext context, {
    required String date,
    required bool isPast,
    required List<TodoEntity> todos,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: EveningReflectionModal(
          date: date,
          isPast: isPast,
          todos: todos,
        ),
      ),
    );
  }

  @override
  ConsumerState<EveningReflectionModal> createState() =>
      _EveningReflectionModalState();
}

class _EveningReflectionModalState
    extends ConsumerState<EveningReflectionModal> {
  final _noteController = TextEditingController();
  bool _isSaving = false;
  bool _isInitialized = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  TextDirection? _toFlutterDirection(unicode_utils.TextDirection? dir) {
    if (dir == unicode_utils.TextDirection.rtl) return TextDirection.rtl;
    if (dir == unicode_utils.TextDirection.ltr) return TextDirection.ltr;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final reflectionAsync = ref.watch(dailyReflectionProvider(widget.date));

    int completedSeconds = 0;
    int droppedSeconds = 0;
    int completedCount = 0;
    int droppedCount = 0;

    for (final todo in widget.todos) {
      final trackingState = ref.watch(timeTrackingProvider(todo.id));
      final duration = trackingState.totalDurationSeconds;
      if (todo.status == TodoStatus.completed) {
        completedSeconds += duration;
        completedCount++;
      } else if (todo.status == TodoStatus.dropped) {
        droppedSeconds += duration;
        droppedCount++;
      }
    }

    final totalTracked = completedSeconds + droppedSeconds;
    final ratioPercent = totalTracked > 0
        ? ((completedSeconds / totalTracked) * 100).round()
        : (completedCount > 0 ? 100 : 0);

    reflectionAsync.whenData((entity) {
      if (!_isInitialized && entity != null) {
        _noteController.text = entity.reflectionNote;
        _isInitialized = true;
      }
    });

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.auto_awesome_outlined,
                  color: colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  context.l10n.eveningReflectionTitle,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Summary Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.12),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.reflectionSummaryTitle,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _MetricTile(
                          label: context.l10n.completedTime,
                          value: formatDuration(completedSeconds),
                          subText: '$completedCount ${context.l10n.statsTotal}',
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MetricTile(
                          label: context.l10n.droppedTime,
                          value: formatDuration(droppedSeconds),
                          subText: '$droppedCount ${context.l10n.statsTotal}',
                          color: colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.l10n.completionRatio,
                        style: theme.textTheme.bodyMedium,
                      ),
                      Text(
                        '$ratioPercent%',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: ratioPercent / 100.0,
                    backgroundColor: colorScheme.error.withValues(alpha: 0.2),
                    color: colorScheme.primary,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Reflection Note Input
            Text(
              context.l10n.eveningReflection,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              enabled: !widget.isPast && !_isSaving,
              maxLines: 4,
              textDirection: _toFlutterDirection(
                unicode_utils.detectTextDirection(_noteController.text),
              ),
              decoration: InputDecoration(
                hintText: context.l10n.reflectionNoteHint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: colorScheme.surface,
              ),
            ),
            const SizedBox(height: 24),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(context.l10n.cancel),
                ),
                if (!widget.isPast) ...[
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: _isSaving ? null : _saveReflection,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.check),
                    label: Text(context.l10n.save),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveReflection() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final now = DateTime.now().toIso8601String();
      final reflection = DailyReflectionEntity(
        date: widget.date,
        reflectionNote: _noteController.text,
        createdAt: now,
        updatedAt: now,
      );

      await ref
          .read(dailyReflectionRepositoryProvider)
          .saveReflection(reflection);
      ref.invalidate(dailyReflectionProvider(widget.date));

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.reflectionSaved)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.subText,
    required this.color,
  });

  final String label;
  final String value;
  final String subText;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            subText,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
