import 'package:flutter/material.dart';
import 'package:sreerajp_todo/core/constants/app_strings.dart';
import 'package:sreerajp_todo/data/models/todo_status.dart';
import 'package:sreerajp_todo/presentation/shared/theme/app_theme.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    required this.status,
    this.semanticLabel,
  });

  final String label;
  final TodoStatus status;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = AppTheme.statusColor(theme, status);

    return Semantics(
      label: semanticLabel ?? AppStrings.statusSemantics(label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: color.withValues(alpha: 0.38)),
        ),
        child: ExcludeSemantics(
          child: Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
