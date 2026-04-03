import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sreerajp_todo/application/providers.dart';
import 'package:sreerajp_todo/core/constants/app_strings.dart';
import 'package:sreerajp_todo/core/errors/error_message_mapper.dart';
import 'package:sreerajp_todo/core/utils/date_utils.dart';
import 'package:sreerajp_todo/core/utils/duration_utils.dart';
import 'package:sreerajp_todo/data/models/time_segment_entity.dart';
import 'package:sreerajp_todo/data/models/todo_entity.dart';
import 'package:sreerajp_todo/data/models/todo_status.dart';
import 'package:sreerajp_todo/presentation/screens/time_segments/widgets/manual_segment_form.dart';
import 'package:sreerajp_todo/presentation/shared/widgets/app_empty_state.dart';
import 'package:sreerajp_todo/presentation/shared/widgets/app_error_state.dart';

final _timeFormat = DateFormat.Hm();

class TimeSegmentsScreen extends ConsumerWidget {
  const TimeSegmentsScreen({super.key, required this.todoId});

  final String todoId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trackingState = ref.watch(timeTrackingProvider(todoId));
    final todoAsync = ref.watch(_todoByIdProvider(todoId));

    return todoAsync.when(
      data: (todo) {
        if (todo == null) {
          return Scaffold(
            appBar: AppBar(title: const Text(AppStrings.timeSegments)),
            body: AppErrorState(message: AppStrings.errors.todoNotFound),
          );
        }

        final past = isPastDate(todo.date);
        final isTerminal =
            todo.status == TodoStatus.completed ||
            todo.status == TodoStatus.dropped;
        final canAddManual =
            !past && !isTerminal && todo.status != TodoStatus.ported;

        return Scaffold(
          appBar: AppBar(title: const Text(AppStrings.timeSegments)),
          body: trackingState.isLoading
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
          floatingActionButton: canAddManual
              ? FloatingActionButton.extended(
                  onPressed: () => _showManualSegmentDialog(context, ref, todo),
                  icon: const Icon(Icons.add),
                  label: const Text(AppStrings.addManualSegment),
                )
              : null,
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(title: const Text(AppStrings.timeSegments)),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: const Text(AppStrings.timeSegments)),
        body: AppErrorState(message: mapErrorToMessage(error)),
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
      isScrollControlled: true,
      builder: (ctx) => ManualSegmentForm(
        todoId: todoId,
        todoDate: todo.date,
        existingSegments: ref.read(timeTrackingProvider(todoId)).segments,
      ),
    );

    if (result != null && context.mounted) {
      await ref
          .read(timeTrackingProvider(todoId).notifier)
          .addManualSegment(result);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.manualSegmentAdded)),
        );
      }
    }
  }
}

final _todoByIdProvider = FutureProvider.family<TodoEntity?, String>((
  ref,
  todoId,
) {
  return ref.read(todoRepositoryProvider).getTodoById(todoId);
});

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
    final runningExtra = runningSegment != null
        ? (liveElapsed.valueOrNull ?? 0)
        : 0;
    final grandTotal = totalDurationSeconds + runningExtra;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(theme, colorScheme, grandTotal),
        const Divider(height: 1),
        if (segments.isEmpty)
          const Expanded(
            child: AppEmptyState(
              icon: Icons.timer_off,
              title: AppStrings.noSegments,
              message: AppStrings.noSegmentsRecordedDetailed,
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
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
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildHeader(
    ThemeData theme,
    ColorScheme colorScheme,
    int grandTotal,
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
            label: AppStrings.totalTimeForTask(
              todo.title,
              formatDuration(grandTotal),
            ),
            child: ExcludeSemantics(
              child: Row(
                children: [
                  Icon(Icons.access_time, size: 20, color: colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    '${AppStrings.totalTime}: ${formatDuration(grandTotal)}',
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
  });

  final int index;
  final TimeSegmentEntity segment;
  final bool isRunning;
  final String todoId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final startDt = DateTime.parse(segment.startTime);
    final startStr = _timeFormat.format(startDt);

    String endStr;
    String durationStr;

    if (isRunning) {
      endStr = AppStrings.emptyValue;
      final liveElapsed = ref.watch(liveTimerProvider(todoId));
      final elapsed = liveElapsed.valueOrNull ?? 0;
      durationStr = AppStrings.segmentRunning;
      if (elapsed > 0) {
        durationStr = formatDuration(elapsed);
      }
    } else if (segment.endTime != null) {
      final endDt = DateTime.parse(segment.endTime!);
      endStr = _timeFormat.format(endDt);
      durationStr = formatDuration(segment.durationSeconds ?? 0);
    } else {
      endStr = AppStrings.emptyValue;
      durationStr = AppStrings.emptyValue;
    }

    final typeLabel = segment.manual
        ? AppStrings.segmentManual
        : AppStrings.segmentAuto;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Semantics(
          label: AppStrings.segmentSemantics(
            index: index,
            start: startStr,
            end: endStr,
            duration: durationStr,
            type: typeLabel,
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
                    message: AppStrings.segmentInterruptedTooltip,
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
                          Text(startStr, style: theme.textTheme.bodyMedium),
                          Text(
                            ' -> ',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            endStr,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: isRunning ? colorScheme.primary : null,
                              fontWeight: isRunning ? FontWeight.w700 : null,
                            ),
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
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
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
        isManual ? AppStrings.manualSegmentShort : label,
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
