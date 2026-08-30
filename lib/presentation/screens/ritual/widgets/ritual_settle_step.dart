import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sreerajp_todo/application/providers.dart';
import 'package:sreerajp_todo/core/extensions/localization_extensions.dart';
import 'package:sreerajp_todo/core/utils/ritual_rules.dart';
import 'package:sreerajp_todo/data/models/todo_entity.dart';
import 'package:sreerajp_todo/data/models/todo_priority.dart';
import 'package:sreerajp_todo/presentation/screens/daily_list/widgets/carry_over_sheet.dart';
import 'package:sreerajp_todo/presentation/shared/widgets/adaptive_directionality.dart';

/// Step 3: settle the day.
///
/// Two short lists. What is left over from before can be carried into today,
/// and up to [kRitualFocusLimit] of today's tasks can be marked as the ones to
/// lead the day.
///
/// Neither list writes anything of its own. Carry-over goes through the same
/// `CopyTodos` use case the carry-over sheet uses, and marking a task as focus
/// is an ordinary priority change through `DailyTodoNotifier`, so the day lock,
/// title uniqueness and NFC normalisation all still apply.
class RitualSettleStep extends ConsumerStatefulWidget {
  const RitualSettleStep({
    super.key,
    required this.date,
    required this.onCarried,
    required this.onFocusChanged,
    required this.onDone,
  });

  /// Today, as `yyyy-MM-dd`.
  final String date;

  /// Reports how many tasks were copied in, for the summary on the last step.
  final ValueChanged<int> onCarried;

  /// Reports how many tasks are marked as focus, for the same summary.
  final ValueChanged<int> onFocusChanged;

  /// Moves on to the last step.
  final VoidCallback onDone;

  @override
  ConsumerState<RitualSettleStep> createState() => _RitualSettleStepState();
}

class _RitualSettleStepState extends ConsumerState<RitualSettleStep> {
  List<TodoEntity> _leftovers = const [];
  List<TodoEntity> _today = const [];
  final Set<String> _pickedLeftovers = {};
  final Set<String> _focus = {};
  bool _loading = true;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final lookBack = ref.read(taskDefaultsProvider).carryOverLookBack;
    final leftovers = await CarryOverSheet.findCandidates(
      ref,
      targetDate: widget.date,
      lookBack: lookBack,
    );
    final today = await ref
        .read(todoRepositoryProvider)
        .getTodosByDate(widget.date);

    if (!mounted) return;
    setState(() {
      _leftovers = leftovers;
      _today = today;
      _pickedLeftovers
        ..clear()
        ..addAll(leftovers.map((todo) => todo.id));
      // A task already at high priority is already the kind of task this step
      // is asking about, so it starts ticked rather than being demoted.
      _focus
        ..clear()
        ..addAll(
          today
              .where((todo) => todo.priority == TodoPriority.high)
              .take(kRitualFocusLimit)
              .map((todo) => todo.id),
        );
      _loading = false;
    });
    widget.onFocusChanged(_focus.length);
  }

  Future<void> _carryOver() async {
    if (_busy || _pickedLeftovers.isEmpty) return;
    setState(() => _busy = true);

    final ids = _leftovers
        .where((todo) => _pickedLeftovers.contains(todo.id))
        .map((todo) => todo.id)
        .toList();

    final result = await ref.read(copyTodosProvider)(ids, widget.date);
    ref.invalidate(dailyTodoProvider(widget.date));
    if (!mounted) return;

    widget.onCarried(result.copied.length);
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      SnackBar(content: Text(l10n.carryOverDone(result.copied.length))),
    );

    // The copies are new tasks on today, so the second list has to be read
    // again before they can be picked as focus.
    await _load();
    if (!mounted) return;
    setState(() {
      _busy = false;
      _leftovers = const [];
    });
  }

  Future<void> _toggleFocus(TodoEntity todo) async {
    if (_busy) return;

    final adding = !_focus.contains(todo.id);
    if (adding && _focus.length >= kRitualFocusLimit) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.ritualSettleFocusLimit)),
      );
      return;
    }

    setState(() {
      _busy = true;
      if (adding) {
        _focus.add(todo.id);
      } else {
        _focus.remove(todo.id);
      }
    });

    await ref
        .read(dailyTodoProvider(widget.date).notifier)
        .updateTodo(
          todo.copyWith(
            priority: adding ? TodoPriority.high : TodoPriority.normal,
            updatedAt: DateTime.now().toIso8601String(),
          ),
        );

    if (!mounted) return;
    setState(() => _busy = false);
    widget.onFocusChanged(_focus.length);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final l10n = context.l10n;
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        Text(l10n.ritualSettleCarryTitle, style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        if (_leftovers.isEmpty)
          Text(
            l10n.ritualSettleCarryEmpty,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          )
        else ...[
          for (final todo in _leftovers)
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _pickedLeftovers.contains(todo.id),
              onChanged: _busy
                  ? null
                  : (checked) => setState(() {
                      if (checked ?? false) {
                        _pickedLeftovers.add(todo.id);
                      } else {
                        _pickedLeftovers.remove(todo.id);
                      }
                    }),
              title: AdaptiveDirectionality(
                text: todo.title,
                child: Text(todo.title, maxLines: 2),
              ),
            ),
          const SizedBox(height: 8),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: FilledButton.tonal(
              onPressed: _busy || _pickedLeftovers.isEmpty ? null : _carryOver,
              child: Text(l10n.carryOverAction),
            ),
          ),
        ],
        const SizedBox(height: 24),
        Text(l10n.ritualSettleFocusTitle, style: theme.textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(
          l10n.ritualSettleFocusHint,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
        const SizedBox(height: 8),
        if (_today.isEmpty)
          Text(
            l10n.ritualSettleFocusEmpty,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          )
        else
          for (final todo in _today)
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _focus.contains(todo.id),
              onChanged: _busy ? null : (_) => _toggleFocus(todo),
              title: AdaptiveDirectionality(
                text: todo.title,
                child: Text(todo.title, maxLines: 2),
              ),
            ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: _busy ? null : widget.onDone,
          child: Text(l10n.ritualContinue),
        ),
      ],
    );
  }
}
