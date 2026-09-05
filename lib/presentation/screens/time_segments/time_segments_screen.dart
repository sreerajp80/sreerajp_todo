import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sreerajp_todo/application/providers.dart';
import 'package:sreerajp_todo/core/constants/app_routes.dart';
import 'package:sreerajp_todo/core/errors/error_message_mapper.dart';
import 'package:sreerajp_todo/core/extensions/localization_extensions.dart';
import 'package:sreerajp_todo/core/utils/date_utils.dart';
import 'package:sreerajp_todo/core/utils/duration_utils.dart';
import 'package:sreerajp_todo/data/models/time_segment_entity.dart';
import 'package:sreerajp_todo/data/models/todo_entity.dart';
import 'package:sreerajp_todo/data/models/todo_status.dart';
import 'package:sreerajp_todo/presentation/screens/time_segments/widgets/manual_segment_form.dart';
import 'package:sreerajp_todo/presentation/shared/widgets/adaptive_directionality.dart';
import 'package:sreerajp_todo/presentation/shared/widgets/app_empty_state.dart';
import 'package:sreerajp_todo/presentation/shared/widgets/app_error_state.dart';
import 'package:sreerajp_todo/presentation/shared/widgets/pomodoro_banner.dart';
import 'package:sreerajp_todo/presentation/shared/widgets/timer_controls.dart';

class TimeSegmentsScreen extends ConsumerWidget {
  const TimeSegmentsScreen({super.key, required this.todoId});

  final String todoId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trackingState = ref.watch(timeTrackingProvider(todoId));
    final todoAsync = ref.watch(todoByIdProvider(todoId));

    return todoAsync.when(
      data: (todo) {
        if (todo == null) {
          return Scaffold(
            appBar: AppBar(title: Text(context.l10n.timeSegments)),
            body: AppErrorState(message: context.l10n.errorTodoNotFound),
          );
        }

        final past = isPastDate(todo.date);
        final isTerminal =
            todo.status == TodoStatus.completed ||
            todo.status == TodoStatus.dropped;
        final canAddManual =
            !past && !isTerminal && todo.status != TodoStatus.ported;

        return Scaffold(
          appBar: AppBar(
            title: Text(context.l10n.timeSegments),
            actions: [
              IconButton(
                icon: const Icon(Icons.history_rounded),
                tooltip: context.l10n.taskHistory,
                onPressed: () =>
                    context.push(AppRoutes.todoHistoryPath(todoId)),
              ),
              // Only offered while a timer runs, because the Focus view is
              // about the block happening right now.
              if (trackingState.runningSegment != null)
                IconButton(
                  icon: const Icon(Icons.center_focus_strong_rounded),
                  tooltip: context.l10n.focusOpen,
                  onPressed: () => context.push(AppRoutes.focusPath(todoId)),
                ),
            ],
          ),
          body: SafeArea(
            child: trackingState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : _SegmentsBody(
                    todo: todo,
                    segments: trackingState.segments,
                    runningSegment: trackingState.runningSegment,
                    totalDurationSeconds: trackingState.totalDurationSeconds,
                    isPast: past,
                    isTerminal: isTerminal,
                    todoId: todoId,
                  ),
          ),
          floatingActionButton: canAddManual
              ? FloatingActionButton.extended(
                  onPressed: () => _showManualSegmentDialog(context, ref, todo),
                  icon: const Icon(Icons.add),
                  label: Text(context.l10n.addManualSegment),
                )
              : null,
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(title: Text(context.l10n.timeSegments)),
        body: const SafeArea(child: Center(child: CircularProgressIndicator())),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: Text(context.l10n.timeSegments)),
        body: SafeArea(
          child: AppErrorState(message: mapErrorToMessage(context.l10n, error)),
        ),
      ),
    );
  }

  Future<void> _showManualSegmentDialog(
    BuildContext context,
    WidgetRef ref,
    TodoEntity todo,
  ) async {
    final result = await showModalBottomSheet<TimeSegmentEntity>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (ctx) => ManualSegmentForm(
        todoId: todoId,
        todoDate: todo.date,
        existingSegments: ref.read(timeTrackingProvider(todoId)).segments,
        defaultDuration: ref
            .read(timeTrackingSettingsProvider)
            .manualEntryDuration,
      ),
    );

    if (result != null && context.mounted) {
      await ref
          .read(timeTrackingProvider(todoId).notifier)
          .addManualSegment(result);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.manualSegmentAdded)),
        );
      }
    }
  }
}

class _SegmentsBody extends ConsumerWidget {
  const _SegmentsBody({
    required this.todo,
    required this.segments,
    required this.runningSegment,
    required this.totalDurationSeconds,
    required this.isPast,
    required this.isTerminal,
    required this.todoId,
  });

  final TodoEntity todo;
  final List<TimeSegmentEntity> segments;
  final TimeSegmentEntity? runningSegment;
  final int totalDurationSeconds;
  final bool isPast;
  final bool isTerminal;
  final String todoId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final liveElapsed = ref.watch(liveTimerProvider(todoId));
    final isRunning = runningSegment != null;
    final runningExtra = isRunning ? (liveElapsed.valueOrNull ?? 0) : 0;
    final grandTotal = totalDurationSeconds + runningExtra;
    final settings = ref.watch(timeTrackingSettingsProvider);
    final isPaused =
        !isRunning && ref.watch(pausedTodosProvider).contains(todoId);
    final canTrack = !isPast && !isTerminal;

    // A running total keeps its seconds; a settled one follows the settings.
    final totalText = isRunning
        ? formatDuration(grandTotal)
        : formatDuration(
            grandTotal,
            rounding: settings.rounding,
            format: settings.format,
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context, theme, colorScheme, grandTotal, totalText),
        if (canTrack)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                if (isRunning) ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => TimerActions.pause(context, ref, todoId),
                      icon: const Icon(Icons.pause_rounded),
                      label: Text(context.l10n.pauseTimer),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => TimerActions.stop(context, ref, todoId),
                      icon: const Icon(Icons.stop_rounded),
                      label: Text(context.l10n.stopTimer),
                    ),
                  ),
                ] else
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => TimerActions.start(context, ref, todoId),
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: Text(
                        isPaused
                            ? context.l10n.resumeTimer
                            : context.l10n.startTimer,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        if (settings.pomodoroEnabled)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: PomodoroBanner(todoId: todoId),
          ),
        const Divider(height: 1),
        if (segments.isEmpty)
          Expanded(
            child: AppEmptyState(
              icon: Icons.timer_off,
              title: context.l10n.noSegments,
              message: context.l10n.noSegmentsRecordedDetailed,
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 80),
              itemCount: segments.length,
              itemBuilder: (context, index) {
                final segment = segments[index];
                final isRunning =
                    runningSegment != null && segment.id == runningSegment!.id;
                return _SegmentTile(
                  index: index + 1,
                  segment: segment,
                  isRunning: isRunning,
                  todoId: todoId,
                  isPast: isPast,
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildHeader(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    int grandTotal,
    String totalText,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            todo.title,
            style: theme.textTheme.titleLarge,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            formatDateFromIso(todo.date),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Semantics(
            label: context.l10n.totalTimeForTask(todo.title, totalText),
            child: ExcludeSemantics(
              child: Row(
                children: [
                  Icon(Icons.access_time, size: 20, color: colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    '${context.l10n.totalTime}: $totalText',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentTile extends ConsumerWidget {
  const _SegmentTile({
    required this.index,
    required this.segment,
    required this.isRunning,
    required this.todoId,
    required this.isPast,
  });

  final int index;
  final TimeSegmentEntity segment;
  final bool isRunning;
  final String todoId;
  final bool isPast;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final startDt = DateTime.parse(segment.startTime);
    final startStr = formatTime(startDt);

    String endStr;
    String durationStr;

    if (isRunning) {
      endStr = context.l10n.emptyValue;
      final liveElapsed = ref.watch(liveTimerProvider(todoId));
      final elapsed = liveElapsed.valueOrNull ?? 0;
      durationStr = context.l10n.segmentRunning;
      if (elapsed > 0) {
        durationStr = formatDuration(elapsed);
      }
    } else if (segment.endTime != null) {
      final endDt = DateTime.parse(segment.endTime!);
      endStr = formatTime(endDt);
      final settings = ref.watch(timeTrackingSettingsProvider);
      durationStr = formatDuration(
        segment.durationSeconds ?? 0,
        rounding: settings.rounding,
        format: settings.format,
      );
    } else {
      endStr = context.l10n.emptyValue;
      durationStr = context.l10n.emptyValue;
    }

    final typeLabel = segment.manual
        ? context.l10n.segmentManual
        : context.l10n.segmentAuto;

    final hasNote = segment.notes != null && segment.notes!.isNotEmpty;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Semantics(
          label: segment.editedAfterCompletion
              ? '${context.l10n.segmentSemantics(index, startStr, endStr, durationStr, typeLabel)}. '
                    '${context.l10n.segmentEditedAfterCompletionTooltip}'
              : context.l10n.segmentSemantics(
                  index,
                  startStr,
                  endStr,
                  durationStr,
                  typeLabel,
                ),
          child: ExcludeSemantics(
            child: Row(
              children: [
                SizedBox(
                  width: 28,
                  child: Text(
                    '#$index',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                if (isRunning)
                  _BlinkingDot(color: colorScheme.primary)
                else if (segment.interrupted)
                  Tooltip(
                    message: context.l10n.segmentInterruptedTooltip,
                    child: Icon(
                      Icons.warning_amber,
                      size: 18,
                      color: colorScheme.error,
                    ),
                  )
                else
                  const SizedBox(width: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _buildTappableTime(
                            context,
                            ref,
                            label: startStr,
                            isStart: true,
                            theme: theme,
                            colorScheme: colorScheme,
                          ),
                          Text(
                            ' -> ',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          _buildTappableTime(
                            context,
                            ref,
                            label: endStr,
                            isStart: false,
                            theme: theme,
                            colorScheme: colorScheme,
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            durationStr,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isRunning
                                  ? colorScheme.primary
                                  : colorScheme.onSurfaceVariant,
                              fontWeight: isRunning
                                  ? FontWeight.w700
                                  : FontWeight.normal,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _TypeBadge(
                            label: typeLabel,
                            isManual: segment.manual,
                          ),
                          if (segment.editedAfterCompletion) ...[
                            const SizedBox(width: 6),
                            _EditedBadge(editedAtIso: segment.timesEditedAt),
                          ],
                        ],
                      ),
                      if (hasNote) ...[
                        const SizedBox(height: 6),
                        AdaptiveDirectionality(
                          text: segment.notes!,
                          child: Text(
                            segment.notes!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    hasNote
                        ? Icons.sticky_note_2
                        : Icons.sticky_note_2_outlined,
                    size: 20,
                    color: hasNote
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
                  ),
                  tooltip: context.l10n.editSegmentNote,
                  onPressed: () => _editNote(context, ref),
                ),
                if (!isPast)
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      size: 20,
                      color: colorScheme.error,
                    ),
                    tooltip: context.l10n.deleteTimeSegment,
                    onPressed: () => _confirmDelete(context, ref),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Whether the segment times can be edited: not running, not past, and the
  /// segment has an end time (closed).
  ///
  /// A completed or dropped task is still editable on purpose. Fixing a wrong
  /// start or end time is a correction, not new tracked time, and the segment
  /// is marked as edited so the change stays visible.
  bool get _canEditTimes => !isRunning && !isPast && segment.endTime != null;

  Widget _buildTappableTime(
    BuildContext context,
    WidgetRef ref, {
    required String label,
    required bool isStart,
    required ThemeData theme,
    required ColorScheme colorScheme,
  }) {
    final style = theme.textTheme.bodyMedium?.copyWith(
      color: isRunning && !isStart ? colorScheme.primary : null,
      fontWeight: isRunning && !isStart ? FontWeight.w700 : null,
    );

    if (!_canEditTimes) {
      return Text(label, style: style);
    }

    return InkWell(
      borderRadius: BorderRadius.circular(6),
      onTap: () => _editTime(context, ref, isStart: isStart),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: style?.copyWith(
                decoration: TextDecoration.underline,
                decorationStyle: TextDecorationStyle.dotted,
                decorationColor: colorScheme.primary.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(width: 2),
            Icon(
              Icons.edit_outlined,
              size: 12,
              color: colorScheme.primary.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editTime(
    BuildContext context,
    WidgetRef ref, {
    required bool isStart,
  }) async {
    final startDt = DateTime.parse(segment.startTime);
    final endDt = segment.endTime != null
        ? DateTime.parse(segment.endTime!)
        : null;

    if (endDt == null) return;

    final initial = isStart
        ? TimeOfDay.fromDateTime(startDt)
        : TimeOfDay.fromDateTime(endDt);

    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      helpText: context.l10n.editSegmentTime,
    );
    if (picked == null || !context.mounted) return;

    final newDt = DateTime(
      startDt.year,
      startDt.month,
      startDt.day,
      picked.hour,
      picked.minute,
    );

    final newStart = isStart ? newDt : startDt;
    final newEnd = isStart ? endDt : newDt;

    try {
      await ref
          .read(timeTrackingProvider(todoId).notifier)
          .updateSegmentTimes(segment.id, newStart, newEnd);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.segmentTimeUpdated)),
        );
      }
    } on Exception catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _editNote(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController(text: segment.notes ?? '');

    final saved = await showDialog<String?>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(dialogContext.l10n.editSegmentNote),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 3,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            labelText: dialogContext.l10n.segmentNoteLabel,
            hintText: dialogContext.l10n.segmentNoteHint,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(dialogContext.l10n.cancel),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(controller.text.trim()),
            child: Text(dialogContext.l10n.save),
          ),
        ],
      ),
    );

    controller.dispose();
    if (saved == null) return;

    await ref
        .read(timeTrackingProvider(todoId).notifier)
        .updateSegmentNotes(segment.id, saved);
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(dialogCtx.l10n.confirmDeleteSegment),
        content: Text(dialogCtx.l10n.confirmDeleteSegmentBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: Text(dialogCtx.l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogCtx).colorScheme.error,
              foregroundColor: Theme.of(dialogCtx).colorScheme.onError,
            ),
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            child: Text(dialogCtx.l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final notifier = ref.read(timeTrackingProvider(todoId).notifier);

    try {
      await notifier.deleteSegment(segment);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.timeSegmentDeleted),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: context.l10n.undo,
              onPressed: () {
                notifier.restoreSegment(segment);
              },
            ),
          ),
        );
      }
    } on Exception catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}

/// Small marker on a segment whose start or end time was changed after the
/// task was already completed or dropped, so the user can tell corrected
/// slots apart from the ones the timer recorded.
class _EditedBadge extends StatelessWidget {
  const _EditedBadge({required this.editedAtIso});

  final String? editedAtIso;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final lines = <String>[context.l10n.segmentEditedAfterCompletionTooltip];
    final iso = editedAtIso;
    if (iso != null && iso.isNotEmpty) {
      try {
        final local = DateTime.parse(iso).toLocal();
        lines.add(context.l10n.segmentEditedOn(formatDateTime(local)));
      } on FormatException {
        // A stamp we cannot read is simply not shown.
      }
    }

    return Tooltip(
      message: lines.join('\n'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.edit_calendar_rounded,
              size: 12,
              color: colorScheme.onErrorContainer,
            ),
            const SizedBox(width: 4),
            Text(
              context.l10n.segmentEditedBadge,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onErrorContainer,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.label, required this.isManual});

  final String label;
  final bool isManual;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bgColor = isManual
        ? colorScheme.tertiaryContainer
        : colorScheme.surfaceContainerHighest;
    final textColor = isManual
        ? colorScheme.onTertiaryContainer
        : colorScheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        isManual ? context.l10n.manualSegmentShort : label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _BlinkingDot extends StatefulWidget {
  const _BlinkingDot({required this.color});

  final Color color;

  @override
  State<_BlinkingDot> createState() => _BlinkingDotState();
}

class _BlinkingDotState extends State<_BlinkingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(
        width: 10,
        height: 10,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
      ),
    );
  }
}
