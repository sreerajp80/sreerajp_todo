import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sreerajp_todo/application/providers.dart';
import 'package:sreerajp_todo/core/errors/exceptions.dart';
import 'package:sreerajp_todo/core/extensions/localization_extensions.dart';
import 'package:sreerajp_todo/core/utils/date_utils.dart';
import 'package:sreerajp_todo/core/utils/task_default_rules.dart';
import 'package:sreerajp_todo/core/utils/unicode_utils.dart';
import 'package:sreerajp_todo/data/models/todo_entity.dart';
import 'package:sreerajp_todo/data/models/todo_status.dart';
import 'package:sreerajp_todo/domain/repositories/todo_repository.dart';
import 'package:sreerajp_todo/presentation/shared/widgets/adaptive_directionality.dart';

/// What the user chose in the carry-over sheet.
class CarryOverOutcome {
  const CarryOverOutcome({
    required this.copied,
    required this.skipped,
    required this.neverAskAgain,
  });

  /// How many tasks were carried over to today.
  final int copied;

  /// How many were left out because the same title already exists today.
  final int skipped;

  /// True when the user asked never to be offered this again.
  final bool neverAskAgain;
}

/// The sheet that offers to carry unfinished tasks forward into today.
///
/// Moving a task preserves its unique ID, time segments, and history.
class CarryOverSheet extends ConsumerStatefulWidget {
  const CarryOverSheet({
    super.key,
    required this.candidates,
    required this.targetDate,
  });

  /// The unfinished tasks found on the earlier day or days.
  final List<TodoEntity> candidates;

  /// The day the ticked tasks are carried over to.
  final String targetDate;

  /// Looks for unfinished tasks to carry into [targetDate].
  ///
  /// Walks back day by day, at most [lookBack] days, and stops at the first day
  /// that has any unfinished task. Tasks already completed/dropped on more recent
  /// days or already present on [targetDate] are excluded.
  static Future<List<TodoEntity>> findCandidates(
    dynamic ref, {
    required String targetDate,
    required CarryOverLookBack lookBack,
  }) async {
    final repository = ref is TodoRepository
        ? ref
        : (ref as dynamic).read(todoRepositoryProvider) as TodoRepository;
    final target = parseIsoDate(targetDate);
    final seenTitles = <String>{};

    final todayTodos = await repository.getTodosByDate(targetDate);
    for (final t in todayTodos) {
      seenTitles.add(nfcNormalize(t.title).trim().toLowerCase());
    }

    for (var back = 1; back <= lookBack.days; back++) {
      final day = dateTimeToIso(target.subtract(Duration(days: back)));
      final todos = await repository.getTodosByDate(day);
      final unfinished = <TodoEntity>[];
      for (final todo in todos) {
        final norm = nfcNormalize(todo.title).trim().toLowerCase();
        if (seenTitles.contains(norm)) continue;
        seenTitles.add(norm);

        if (todo.status == TodoStatus.pending ||
            todo.status == TodoStatus.working) {
          unfinished.add(todo);
        }
      }
      if (unfinished.isNotEmpty) return unfinished;
    }
    return const [];
  }

  /// Looks for ALL unfinished tasks across all [lookBackDays] days before [targetDate].
  ///
  /// Deduplicates tasks by title against already collected candidates, tasks
  /// completed/dropped on more recent days, and tasks already existing on [targetDate].
  static Future<List<TodoEntity>> findAllUnfinishedCandidates(
    dynamic ref, {
    required String targetDate,
    int lookBackDays = kDefaultCarryOverLookBackDays,
  }) async {
    final repository = ref is TodoRepository
        ? ref
        : (ref as dynamic).read(todoRepositoryProvider) as TodoRepository;
    final target = parseIsoDate(targetDate);
    final allUnfinished = <TodoEntity>[];
    final seenTitles = <String>{};

    final todayTodos = await repository.getTodosByDate(targetDate);
    for (final t in todayTodos) {
      seenTitles.add(nfcNormalize(t.title).trim().toLowerCase());
    }

    for (var back = 1; back <= lookBackDays; back++) {
      final day = dateTimeToIso(target.subtract(Duration(days: back)));
      final todos = await repository.getTodosByDate(day);
      for (final todo in todos) {
        final norm = nfcNormalize(todo.title).trim().toLowerCase();
        if (seenTitles.contains(norm)) continue;
        seenTitles.add(norm);

        if (todo.status == TodoStatus.pending ||
            todo.status == TodoStatus.working) {
          allUnfinished.add(todo);
        }
      }
    }
    return allUnfinished;
  }

  /// Shows the sheet and returns what happened, or null if it was dismissed.
  static Future<CarryOverOutcome?> show(
    BuildContext context, {
    required List<TodoEntity> candidates,
    required String targetDate,
  }) {
    return showModalBottomSheet<CarryOverOutcome>(
      context: context,
      isScrollControlled: true,
      builder: (context) =>
          CarryOverSheet(candidates: candidates, targetDate: targetDate),
    );
  }

  @override
  ConsumerState<CarryOverSheet> createState() => _CarryOverSheetState();
}

class _CarryOverSheetState extends ConsumerState<CarryOverSheet> {
  late final Set<String> _selected = {
    for (final todo in widget.candidates) todo.id,
  };
  bool _busy = false;

  Future<void> _carryOver() async {
    if (_selected.isEmpty || _busy) return;
    setState(() => _busy = true);

    final moveTodo = ref.read(moveTodoProvider);
    final ordered = widget.candidates
        .where((todo) => _selected.contains(todo.id))
        .map((todo) => todo.id)
        .toList();

    var movedCount = 0;
    var skippedCount = 0;

    try {
      for (final id in ordered) {
        try {
          await moveTodo(id, widget.targetDate);
          movedCount++;
        } on DuplicateTitleException {
          skippedCount++;
        }
      }
      if (!mounted) return;
      Navigator.of(context).pop(
        CarryOverOutcome(
          copied: movedCount,
          skipped: skippedCount,
          neverAskAgain: false,
        ),
      );
    } on Exception {
      if (!mounted) return;
      setState(() => _busy = false);
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final allSelected = _selected.length == widget.candidates.length;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.carryOverTitle, style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(l10n.carryOverBody, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 8),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton(
                onPressed: _busy
                    ? null
                    : () => setState(() {
                        if (allSelected) {
                          _selected.clear();
                        } else {
                          _selected.addAll(
                            widget.candidates.map((todo) => todo.id),
                          );
                        }
                      }),
                child: Text(
                  allSelected
                      ? l10n.carryOverClearAll
                      : l10n.carryOverSelectAll,
                ),
              ),
            ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.candidates.length,
                itemBuilder: (context, index) {
                  final todo = widget.candidates[index];
                  return CheckboxListTile(
                    value: _selected.contains(todo.id),
                    onChanged: _busy
                        ? null
                        : (checked) => setState(() {
                            if (checked ?? false) {
                              _selected.add(todo.id);
                            } else {
                              _selected.remove(todo.id);
                            }
                          }),
                    title: AdaptiveDirectionality(
                      text: todo.title,
                      child: Text(todo.title, maxLines: 2),
                    ),
                    subtitle: Text(formatDateFromIso(todo.date)),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              children: [
                TextButton(
                  onPressed: _busy
                      ? null
                      : () => Navigator.of(context).pop(
                          const CarryOverOutcome(
                            copied: 0,
                            skipped: 0,
                            neverAskAgain: true,
                          ),
                        ),
                  child: Text(l10n.carryOverNeverAsk),
                ),
                TextButton(
                  onPressed: _busy ? null : () => Navigator.of(context).pop(),
                  child: Text(l10n.carryOverNotNow),
                ),
                FilledButton(
                  onPressed: _busy || _selected.isEmpty ? null : _carryOver,
                  child: Text(l10n.carryOverAction),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
