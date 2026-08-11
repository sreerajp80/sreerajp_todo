import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sreerajp_todo/application/providers.dart';
import 'package:sreerajp_todo/core/extensions/localization_extensions.dart';
import 'package:sreerajp_todo/core/utils/date_utils.dart';
import 'package:sreerajp_todo/core/utils/unicode_utils.dart' as unicode_utils;
import 'package:sreerajp_todo/data/models/daily_intention_entity.dart';

class MorningIntentionCard extends ConsumerStatefulWidget {
  const MorningIntentionCard({
    super.key,
    required this.date,
    required this.isPast,
    required this.onOpenReflection,
  });

  final String date;
  final bool isPast;
  final VoidCallback onOpenReflection;

  @override
  ConsumerState<MorningIntentionCard> createState() =>
      _MorningIntentionCardState();
}

class _MorningIntentionCardState extends ConsumerState<MorningIntentionCard> {
  bool _isExpanded = false;
  int _intentionIndex = 0;

  List<String> _getDefaultIntentions(BuildContext context) {
    return [
      context.l10n.defaultIntention1,
      context.l10n.defaultIntention2,
      context.l10n.defaultIntention3,
      context.l10n.defaultIntention4,
      context.l10n.defaultIntention5,
    ];
  }

  Future<void> _cycleIntention(List<String> defaultIntentions) async {
    if (widget.isPast) return;
    final nextIndex = (_intentionIndex + 1) % defaultIntentions.length;
    setState(() {
      _intentionIndex = nextIndex;
    });

    final newIntention = DailyIntentionEntity(
      date: widget.date,
      intentionText: defaultIntentions[nextIndex],
      createdAt: DateTime.now().toIso8601String(),
    );

    await ref
        .read(dailyReflectionRepositoryProvider)
        .saveIntention(newIntention);
    ref.invalidate(dailyIntentionProvider(widget.date));
  }

  TextDirection? _toFlutterDirection(unicode_utils.TextDirection? dir) {
    if (dir == unicode_utils.TextDirection.rtl) return TextDirection.rtl;
    if (dir == unicode_utils.TextDirection.ltr) return TextDirection.ltr;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final intentionAsync = ref.watch(dailyIntentionProvider(widget.date));
    final defaultIntentions = _getDefaultIntentions(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final intentionText = intentionAsync.when(
      data: (entity) {
        if (entity != null && entity.intentionText.isNotEmpty) {
          return entity.intentionText;
        }
        final dayIndex =
            parseIsoDate(widget.date).day % defaultIntentions.length;
        return defaultIntentions[dayIndex];
      },
      loading: () => defaultIntentions[0],
      error: (err, stack) => defaultIntentions[0],
    );

    final textDir = _toFlutterDirection(
      unicode_utils.detectTextDirection(intentionText),
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer.withValues(alpha: 0.4),
            colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.spa_outlined,
                      color: colorScheme.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.morningIntention,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          intentionText,
                          textDirection: textDir,
                          maxLines: _isExpanded ? 10 : 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: colorScheme.outline,
                    ),
                    onPressed: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                    tooltip: context.l10n.mindfulFocusRules,
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (!widget.isPast) ...[
                    TextButton.icon(
                      onPressed: () => _cycleIntention(defaultIntentions),
                      icon: const Icon(Icons.sync, size: 16),
                      label: Text(context.l10n.cycleIntention),
                    ),
                    const SizedBox(width: 8),
                  ],
                  ElevatedButton.icon(
                    onPressed: widget.onOpenReflection,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primaryContainer,
                      foregroundColor: colorScheme.onPrimaryContainer,
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.nights_stay_outlined, size: 16),
                    label: Text(context.l10n.eveningReflection),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
