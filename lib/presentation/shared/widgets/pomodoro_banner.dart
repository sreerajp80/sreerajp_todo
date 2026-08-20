import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sreerajp_todo/application/pomodoro_notifier.dart';
import 'package:sreerajp_todo/application/providers.dart';
import 'package:sreerajp_todo/core/extensions/localization_extensions.dart';
import 'package:sreerajp_todo/core/utils/duration_utils.dart';

/// Shows which Pomodoro block is running and how long is left.
///
/// Only shown for the todo the current block belongs to, so two open tasks
/// never both claim the same focus block.
class PomodoroBanner extends ConsumerWidget {
  const PomodoroBanner({super.key, required this.todoId});

  final String todoId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final pomodoro = ref.watch(pomodoroProvider);

    if (pomodoro.block == PomodoroBlock.idle) return const SizedBox.shrink();
    if (pomodoro.todoId != null && pomodoro.todoId != todoId) {
      return const SizedBox.shrink();
    }

    final label = switch (pomodoro.block) {
      PomodoroBlock.work => l10n.trackingBlockWork,
      PomodoroBlock.shortBreak => l10n.trackingBlockShortBreak,
      PomodoroBlock.longBreak => l10n.trackingBlockLongBreak,
      PomodoroBlock.idle => '',
    };

    final isBreak = pomodoro.block.isBreak;
    final background = isBreak
        ? colorScheme.tertiaryContainer
        : colorScheme.primaryContainer;
    final foreground = isBreak
        ? colorScheme.onTertiaryContainer
        : colorScheme.onPrimaryContainer;

    // The countdown always shows seconds, whatever the display format is,
    // because a focus timer that jumps a minute at a time reads as stuck.
    final secondsLeft =
        ref.watch(pomodoroCountdownProvider).valueOrNull ??
        pomodoro.secondsLeft(DateTime.now());

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            isBreak ? Icons.coffee_rounded : Icons.center_focus_strong_rounded,
            color: foreground,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              pomodoro.awaitingStart ? l10n.trackingBlockDone : label,
              style: theme.textTheme.titleSmall?.copyWith(color: foreground),
            ),
          ),
          if (pomodoro.awaitingStart)
            TextButton(
              onPressed: () =>
                  ref.read(pomodoroProvider.notifier).startNextBlock(),
              child: Text(l10n.trackingStartNextBlock),
            )
          else
            Text(
              formatDuration(secondsLeft),
              style: theme.textTheme.titleMedium?.copyWith(
                color: foreground,
                fontWeight: FontWeight.w700,
              ),
            ),
        ],
      ),
    );
  }
}
