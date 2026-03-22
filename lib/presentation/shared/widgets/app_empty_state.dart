import 'package:flutter/material.dart';

class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Semantics(
            container: true,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 64,
                  color: colorScheme.onSurface.withValues(alpha: 0.32),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: theme.textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (actionLabel != null && onAction != null) ...[
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: onAction,
                    icon: const Icon(Icons.add),
                    label: Text(actionLabel!),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
