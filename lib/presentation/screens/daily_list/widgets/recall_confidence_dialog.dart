import 'package:flutter/material.dart';
import 'package:sreerajp_todo/data/models/recall_confidence.dart';

class RecallConfidenceDialog extends StatelessWidget {
  const RecallConfidenceDialog({
    super.key,
    required this.todoTitle,
    this.currentLevel = 1,
  });

  final String todoTitle;
  final int currentLevel;

  static Future<RecallConfidence?> show(
    BuildContext context, {
    required String todoTitle,
    int currentLevel = 1,
  }) {
    return showDialog<RecallConfidence>(
      context: context,
      barrierDismissible: true,
      builder: (context) => RecallConfidenceDialog(
        todoTitle: todoTitle,
        currentLevel: currentLevel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final easyDays = 7 * (currentLevel + 1);

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.psychology, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Recall Confidence',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            todoTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'How effortlessly did you recall or complete this task?',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          _ConfidenceOptionTile(
            title: 'Hard',
            subtitle: 'Struggled or forgot. Next review: 1 day',
            badgeText: '1 day',
            color: Colors.redAccent,
            onTap: () => Navigator.of(context).pop(RecallConfidence.hard),
          ),
          const SizedBox(height: 8),
          _ConfidenceOptionTile(
            title: 'Revision',
            subtitle: 'Moderate effort. Next review: 3 days',
            badgeText: '3 days',
            color: Colors.amber.shade800,
            onTap: () => Navigator.of(context).pop(RecallConfidence.revision),
          ),
          const SizedBox(height: 8),
          _ConfidenceOptionTile(
            title: 'Easy',
            subtitle:
                'Effortless! Next review: $easyDays days (Lvl ${currentLevel + 1})',
            badgeText: '$easyDays d',
            color: Colors.green.shade700,
            onTap: () => Navigator.of(context).pop(RecallConfidence.easy),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

class _ConfidenceOptionTile extends StatelessWidget {
  const _ConfidenceOptionTile({
    required this.title,
    required this.subtitle,
    required this.badgeText,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String badgeText;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: color.withValues(alpha: 0.4)),
          borderRadius: BorderRadius.circular(12),
          color: color.withValues(alpha: 0.08),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: color,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                badgeText,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
