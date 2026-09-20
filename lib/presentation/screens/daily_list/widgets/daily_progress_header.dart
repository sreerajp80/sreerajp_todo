import 'package:flutter/material.dart';
import 'package:sreerajp_todo/core/extensions/localization_extensions.dart';
import 'package:sreerajp_todo/domain/entities/todo_entity.dart';
import 'package:sreerajp_todo/domain/entities/todo_status.dart';
import 'package:sreerajp_todo/presentation/shared/theme/app_theme.dart';

/// A modern, motivating daily progress summary card shown at the top of the daily list.
class DailyProgressHeader extends StatelessWidget {
  const DailyProgressHeader({
    super.key,
    required this.todos,
    required this.date,
  });

  final List<TodoEntity> todos;
  final String date;

  @override
  Widget build(BuildContext context) {
    if (todos.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final l10n = context.l10n;

    final total = todos.length;
    final completed = todos
        .where((t) => t.status == TodoStatus.completed)
        .length;
    final working = todos.where((t) => t.status == TodoStatus.working).length;
    final pending = todos.where((t) => t.status == TodoStatus.pending).length;
    final fraction = total > 0 ? (completed / total).clamp(0.0, 1.0) : 0.0;
    final percent = (fraction * 100).round();
    final isAllDone = completed == total && total > 0;

    final progressColor = isAllDone
        ? AppTheme.statusColor(theme, TodoStatus.completed)
        : colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF141A26) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? const Color(0xFF232D3F) : const Color(0xFFE2E8F0),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.25)
                  : const Color(0xFF0F172A).withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isAllDone
                            ? 'All caught up! 🎉'
                            : '$completed of $total ${l10n.statusCompleted.toLowerCase()}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isAllDone
                            ? 'Great job finishing today’s agenda.'
                            : '$pending ${l10n.statusPending.toLowerCase()}${working > 0 ? ' • $working ${l10n.statusWorking.toLowerCase()}' : ''}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: progressColor.withValues(
                      alpha: isDark ? 0.20 : 0.12,
                    ),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: progressColor.withValues(
                        alpha: isDark ? 0.40 : 0.25,
                      ),
                      width: 1.0,
                    ),
                  ),
                  child: Text(
                    '$percent%',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: progressColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: fraction),
                duration: const Duration(milliseconds: 450),
                curve: Curves.easeOutCubic,
                builder: (context, val, _) {
                  return LinearProgressIndicator(
                    value: val,
                    minHeight: 6,
                    backgroundColor: isDark
                        ? const Color(0xFF1E2838)
                        : const Color(0xFFF1F5F9),
                    valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
