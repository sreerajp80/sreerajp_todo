import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sreerajp_todo/application/providers.dart';
import 'package:sreerajp_todo/core/extensions/localization_extensions.dart';
import 'package:sreerajp_todo/core/utils/date_utils.dart';
import 'package:sreerajp_todo/core/utils/duration_utils.dart';
import 'package:sreerajp_todo/data/models/todo_entity.dart';
import 'package:sreerajp_todo/data/models/todo_status.dart';
import 'package:sreerajp_todo/presentation/screens/focus/widgets/focus_pulse_ring.dart';
import 'package:sreerajp_todo/presentation/screens/focus/widgets/focus_sub_task_list.dart';
import 'package:sreerajp_todo/presentation/shared/theme/app_theme.dart';
import 'package:sreerajp_todo/presentation/shared/widgets/adaptive_directionality.dart';
import 'package:sreerajp_todo/presentation/shared/widgets/app_error_state.dart';
import 'package:sreerajp_todo/presentation/shared/widgets/pomodoro_banner.dart';
import 'package:sreerajp_todo/presentation/shared/widgets/timer_controls.dart';

/// The full-screen Focus view for one task.
///
/// It is deliberately plain: a dark ground, the elapsed time in large type,
/// the task, its steps, and nothing else to look at. It owns no state of its
/// own beyond the immersive system bars; every number comes from a provider,
/// and every timer action goes through [TimerActions] so the undo and the
/// "stopped another timer" message behave exactly as they do on the day list.
class FocusScreen extends ConsumerStatefulWidget {
  const FocusScreen({super.key, required this.todoId});

  final String todoId;

  @override
  ConsumerState<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends ConsumerState<FocusScreen> {
  /// Remembers whether the system bars were hidden, so they are only put back
  /// if this screen was the one that hid them.
  bool _hidSystemBars = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _applyImmersive());
  }

  @override
  void dispose() {
    if (_hidSystemBars) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
    super.dispose();
  }

  void _applyImmersive() {
    if (!mounted) return;
    if (!ref.read(timeTrackingSettingsProvider).focusImmersive) return;
    _hidSystemBars = true;
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  Widget build(BuildContext context) {
    final appearance = ref.watch(appearanceProvider);
    final todoAsync = ref.watch(todoByIdProvider(widget.todoId));

    // The Focus view is always dark, whatever the app theme is set to, so the
    // screen stays easy on the eyes during a long block. The user's own accent
    // and font are kept, so it still looks like their app.
    return Theme(
      data: AppTheme.dark(
        accent: appearance.darkAccent,
        fontFamily: appearance.font.family,
      ),
      child: Builder(
        builder: (context) => todoAsync.when(
          data: (todo) => todo == null
              ? _Shell(
                  child: AppErrorState(message: context.l10n.errorTodoNotFound),
                )
              : _FocusBody(todo: todo),
          loading: () =>
              const _Shell(child: Center(child: CircularProgressIndicator())),
          error: (error, _) =>
              _Shell(child: AppErrorState(message: error.toString())),
        ),
      ),
    );
  }
}

/// The dark scaffold every state of the screen sits in.
class _Shell extends StatelessWidget {
  const _Shell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          tooltip: context.l10n.focusLeave,
          onPressed: () => context.pop(),
        ),
        title: Text(context.l10n.focusTitle),
      ),
      body: SafeArea(child: child),
    );
  }
}

class _FocusBody extends ConsumerWidget {
  const _FocusBody({required this.todo});

  final TodoEntity todo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final tracking = ref.watch(timeTrackingProvider(todo.id));
    final settings = ref.watch(timeTrackingSettingsProvider);
    final isRunning = tracking.runningSegment != null;
    final liveSeconds = ref.watch(liveTimerProvider(todo.id)).valueOrNull ?? 0;

    final isPast = isPastDate(todo.date);
    final isTerminal =
        todo.status == TodoStatus.completed ||
        todo.status == TodoStatus.dropped ||
        todo.status == TodoStatus.ported;
    final canTrack = !isPast && !isTerminal;

    final totalSeconds = tracking.totalDurationSeconds + liveSeconds;
    final target = todo.targetSeconds;
    final totalLabel = formatDuration(
      totalSeconds,
      rounding: settings.rounding,
      format: settings.format,
    );

    // Leaving on a stop keeps the flow natural: the block is over, so the day
    // list comes back. Opening the view on a task that is not running is fine
    // and stays put, because there is no stop to react to.
    ref.listen(timeTrackingProvider(todo.id), (previous, next) {
      final was = previous?.runningSegment != null;
      final now = next.runningSegment != null;
      if (was && !now && context.mounted && context.canPop()) context.pop();
    });

    return _Shell(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        children: [
          PomodoroBanner(todoId: todo.id),
          const SizedBox(height: 8),
          AdaptiveDirectionality(
            text: todo.title,
            child: Text(
              todo.title,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (todo.description != null && todo.description!.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: AdaptiveDirectionality(
                text: todo.description!,
                child: Text(
                  todo.description!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 24),
          Center(
            child: FocusPulseRing(
              isRunning: isRunning,
              progress: target == null || target <= 0
                  ? null
                  : totalSeconds / target,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isRunning ? l10n.focusRunningNow : l10n.focusTotalTracked,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // The live time always shows seconds, whatever the display
                  // format is, because a focus timer that jumps a minute at a
                  // time reads as stuck.
                  Text(
                    formatDuration(isRunning ? liveSeconds : totalSeconds),
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w300,
                      fontFeatures: const [FontFeature.tabularFigures()],
                      color: isRunning
                          ? colorScheme.primary
                          : colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Text(
              '${l10n.focusTotalTracked}  $totalLabel',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          if (isRunning) ...[
            const SizedBox(height: 6),
            const Center(child: _NextNudgeLine()),
          ],
          const SizedBox(height: 24),
          if (canTrack)
            _FocusControls(todoId: todo.id, isRunning: isRunning)
          else
            Center(
              child: Text(
                l10n.focusNotRunning,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          const SizedBox(height: 28),
          FocusSubTaskList(
            todoId: todo.id,
            date: todo.date,
            subTasks: todo.subTasks,
            canEdit: canTrack,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

/// Start, pause and stop, laid out large enough to hit without looking.
class _FocusControls extends ConsumerWidget {
  const _FocusControls({required this.todoId, required this.isRunning});

  final String todoId;
  final bool isRunning;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    if (!isRunning) {
      return Center(
        child: FilledButton.icon(
          onPressed: () => TimerActions.start(context, ref, todoId),
          icon: const Icon(Icons.play_arrow_rounded),
          label: Text(l10n.startTimer),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        OutlinedButton.icon(
          onPressed: () => TimerActions.pause(context, ref, todoId),
          icon: const Icon(Icons.pause_rounded),
          label: Text(l10n.pauseTimer),
        ),
        const SizedBox(width: 16),
        FilledButton.icon(
          onPressed: () => TimerActions.stop(context, ref, todoId),
          icon: const Icon(Icons.stop_rounded),
          label: Text(l10n.stopTimer),
        ),
      ],
    );
  }
}

/// Tells the user when the next nudge is due, or that nudges are off.
class _NextNudgeLine extends ConsumerWidget {
  const _NextNudgeLine();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final pulse = ref.watch(focusPulseProvider);

    final style = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    if (!pulse.isArmed) return Text(l10n.focusNudgesOff, style: style);

    final left =
        ref.watch(focusPulseCountdownProvider).valueOrNull ??
        pulse.secondsToNextPulse(DateTime.now());

    return Text(l10n.focusNextNudge(formatDuration(left)), style: style);
  }
}
