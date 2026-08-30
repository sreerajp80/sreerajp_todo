import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:sreerajp_todo/core/utils/date_format_rules.dart';
import 'package:sreerajp_todo/presentation/shared/date_time_labels.dart';
import 'package:sreerajp_todo/application/daily_todo_notifier.dart';
import 'package:sreerajp_todo/application/daily_todo_state.dart';
import 'package:sreerajp_todo/application/providers.dart';
import 'package:sreerajp_todo/application/task_defaults_notifier.dart';
import 'package:sreerajp_todo/core/constants/app_routes.dart';
import 'package:sreerajp_todo/core/constants/todo_sort_option.dart';
import 'package:sreerajp_todo/core/errors/error_message_mapper.dart';
import 'package:sreerajp_todo/core/extensions/localization_extensions.dart';
import 'package:sreerajp_todo/core/utils/date_utils.dart';
import 'package:sreerajp_todo/data/models/todo_entity.dart';
import 'package:sreerajp_todo/data/models/todo_status.dart';
import 'package:sreerajp_todo/domain/usecases/copy_todos.dart';
import 'package:sreerajp_todo/presentation/screens/daily_list/day_list_filters.dart';
import 'package:sreerajp_todo/presentation/screens/daily_list/widgets/carry_over_sheet.dart';
import 'package:sreerajp_todo/presentation/screens/daily_list/widgets/evening_reflection_modal.dart';
import 'package:sreerajp_todo/presentation/screens/daily_list/widgets/morning_intention_card.dart';
import 'package:sreerajp_todo/presentation/screens/daily_list/widgets/voice_command_sheet.dart';
import 'package:sreerajp_todo/presentation/screens/daily_list/widgets/recall_confidence_dialog.dart';
import 'package:sreerajp_todo/presentation/screens/daily_list/widgets/todo_list_tile.dart';
import 'package:sreerajp_todo/core/utils/task_default_rules.dart';
import 'package:sreerajp_todo/presentation/shared/task_default_labels.dart';
import 'package:sreerajp_todo/presentation/shared/widgets/app_empty_state.dart';
import 'package:sreerajp_todo/presentation/shared/widgets/confirm_dialog.dart';
import 'package:sreerajp_todo/presentation/shared/widgets/responsive_scaffold.dart';
import 'package:sreerajp_todo/presentation/shared/widgets/undo_status_snackbar.dart';
import 'package:sreerajp_todo/presentation/widgets/air_qr_share_dialog.dart';
import 'package:sreerajp_todo/data/services/air_qr_payload_service.dart';
import 'package:sreerajp_todo/presentation/widgets/air_qr_preview_sheet.dart';

class DailyListScreen extends ConsumerStatefulWidget {
  const DailyListScreen({super.key, required this.date});

  final String date;

  @override
  ConsumerState<DailyListScreen> createState() => _DailyListScreenState();
}

class _DailyListScreenState extends ConsumerState<DailyListScreen> {
  bool _showCalendar = false;

  /// The sort picked from the app bar menu on this screen. Null means "use the
  /// saved default", so a screen the user has not touched always follows
  /// Settings even after the setting changes.
  TodoSortOption? _sortOption;

  /// Set when the user taps "Show" on the hidden-tasks line. It lasts for this
  /// visit only and is never saved, because it is a peek and not a preference.
  bool _revealHidden = false;

  /// Guards the carry-over sheet so it is opened at most once per screen, even
  /// if the widget rebuilds while the sheet is still being prepared.
  bool _carryOverChecked = false;

  bool get _isPast => isPastDate(widget.date);

  /// True once the evening close has been considered for this screen, so it is
  /// never offered twice in one visit.
  bool _eveningCloseChecked = false;

  /// The order in force right now: this screen's pick, or the saved default.
  TodoSortOption get _effectiveSort =>
      _sortOption ?? ref.read(taskDefaultsProvider).sortOption;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(dailyTodoProvider(widget.date).notifier).loadTodos();
      }
      _maybeOfferCarryOver();
      _maybeOfferEveningClose();
    });
  }

  @override
  void didUpdateWidget(DailyListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.date != widget.date) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(dailyTodoProvider(widget.date).notifier).loadTodos();
        }
      });
    }
  }

  /// Offers the evening reflection once, later in the day.
  ///
  /// Part of Ritual mode, and off unless both that and "evening close" are
  /// turned on. It opens the reflection modal that already exists rather than
  /// anything of its own: the ritual closes the day with the same tool the app
  /// has always used.
  Future<void> _maybeOfferEveningClose() async {
    if (_eveningCloseChecked || !mounted) return;
    _eveningCloseChecked = true;

    final today = todayAsIso();
    if (widget.date != today) return;

    final ritual = ref.read(ritualProvider);
    if (!ritual.shouldOfferEveningClose(today, DateTime.now())) return;

    // Marked before the modal opens, so a crash or a force-close cannot make
    // it reappear over and over on the same evening.
    await ref.read(ritualProvider.notifier).markEveningAsked(today);
    if (!mounted) return;

    await EveningReflectionModal.show(
      context,
      date: widget.date,
      isPast: _isPast,
      todos: ref.read(dailyTodoProvider(widget.date)).todos,
    );
  }

  /// Offers to copy unfinished tasks forward, at most once a day.
  ///
  /// Only today is offered. A past day is read-only and a future day has no
  /// "leftovers" to speak of, so neither would make sense.
  Future<void> _maybeOfferCarryOver() async {
    if (_carryOverChecked || !mounted) return;
    _carryOverChecked = true;

    final defaults = ref.read(taskDefaultsProvider);
    final today = todayAsIso();
    if (widget.date != today) return;

    final notifier = ref.read(taskDefaultsProvider.notifier);

    // If automatic carry-over is enabled (default: ON):
    if (defaults.autoCarryOverEnabled) {
      if (defaults.carryOverLastAsked == today) return;
      await notifier.markCarryOverAsked(today);

      final List<TodoEntity> candidates;
      try {
        candidates = await CarryOverSheet.findAllUnfinishedCandidates(
          ref,
          targetDate: today,
          lookBackDays: defaults.carryOverLookBackDays,
        );
      } on Exception catch (error) {
        if (mounted) _showError(error);
        return;
      }

      if (candidates.isEmpty || !mounted) return;

      final ordered = candidates.map((todo) => todo.id).toList();
      try {
        final result = await ref.read(copyTodosProvider)(ordered, today);
        if (result.copied.isNotEmpty) {
          ref.invalidate(dailyTodoProvider(today));
          ref.invalidate(pendingAlertPayloadProvider);
          ref.invalidate(statisticsProvider);

          if (mounted) {
            final message = context.l10n.autoCarryOverDone(
              result.copied.length,
            );
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(message)));
          }
        }
      } catch (error) {
        if (mounted) _showError(error);
      }
      return;
    }

    if (!shouldAskCarryOver(
      enabled: defaults.carryOverEnabled,
      lastAskedIso: defaults.carryOverLastAsked,
      todayIso: today,
    )) {
      return;
    }

    // Marked before the sheet opens, so a crash or a force-close cannot make
    // the sheet reappear over and over on the same day.
    await notifier.markCarryOverAsked(today);

    final List<TodoEntity> candidates;
    try {
      candidates = await CarryOverSheet.findCandidates(
        ref,
        targetDate: today,
        lookBack: defaults.carryOverLookBack,
      );
    } on Exception catch (error) {
      if (mounted) _showError(error);
      return;
    }
    if (candidates.isEmpty || !mounted) return;

    final outcome = await CarryOverSheet.show(
      context,
      candidates: candidates,
      targetDate: today,
    );
    if (outcome == null || !mounted) return;

    if (outcome.neverAskAgain) {
      await notifier.setCarryOverEnabled(false);
      return;
    }

    if (outcome.copied > 0) {
      ref.invalidate(dailyTodoProvider(today));
      ref.invalidate(pendingAlertPayloadProvider);
      ref.invalidate(statisticsProvider);
    }
    if (!mounted) return;

    final parts = <String>[
      context.l10n.carryOverDone(outcome.copied),
      if (outcome.skipped > 0) context.l10n.carryOverSkipped(outcome.skipped),
    ];
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(parts.join(' · '))));
  }

  void _navigateToDate(String date) {
    context.go(AppRoutes.dailyListPath(date));
  }

  void _goToPreviousDay() {
    final current = parseIsoDate(widget.date);
    final previousDay = current.subtract(const Duration(days: 1));
    _navigateToDate(dateTimeToIso(previousDay));
  }

  void _goToNextDay() {
    final current = parseIsoDate(widget.date);
    final nextDay = current.add(const Duration(days: 1));
    _navigateToDate(dateTimeToIso(nextDay));
  }

  void _goToToday() {
    _navigateToDate(todayAsIso());
  }

  void _showError(Object error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mapErrorToMessage(context.l10n, error))),
    );
  }

  Future<void> _handleRecurringDelete(
    BuildContext context,
    DailyTodoNotifier notifier,
    TodoEntity todo,
  ) async {
    final choice = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.confirmDeleteRecurring),
        content: Text(context.l10n.confirmDeleteRecurringBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop('this'),
            child: Text(context.l10n.deleteOnlyThis),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop('future'),
            child: Text(context.l10n.deleteThisAndFuture),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop('all'),
            child: Text(context.l10n.deleteAllOccurrences),
          ),
        ],
      ),
    );
    if (choice == null || !context.mounted) return;
    try {
      if (choice == 'all') {
        final count = await notifier.deleteAllByRecurrenceRuleId(
          todo.recurrenceRuleId!,
        );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$count ${context.l10n.allOccurrencesDeleted}'),
            ),
          );
        }
      } else if (choice == 'future') {
        final count = await notifier.deleteFutureByRecurrenceRuleId(
          todo.recurrenceRuleId!,
        );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$count ${context.l10n.futureOccurrencesDeleted}'),
            ),
          );
        }
      } else {
        await notifier.deleteTodo(todo.id);
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(context.l10n.todoDeleted)));
        }
      }
    } on Exception catch (error) {
      if (context.mounted) {
        _showError(error);
      }
    }
  }

  Future<void> _showPortDatePicker(String todoId) async {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final picked = await showDatePicker(
      context: context,
      initialDate: tomorrow,
      firstDate: tomorrow,
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: context.l10n.selectTargetDate,
    );
    if (picked != null && mounted) {
      final targetDate = dateTimeToIso(picked);
      try {
        await ref
            .read(dailyTodoProvider(widget.date).notifier)
            .portTodo(todoId, targetDate);
        if (mounted) {
          ref.invalidate(dailyTodoProvider(targetDate));
          showUndoSnackBar(
            context,
            message: context.l10n.todoPorted,
            onUndo: () {
              ref
                  .read(dailyTodoProvider(widget.date).notifier)
                  .undoLastStatusChange();
              ref.invalidate(dailyTodoProvider(targetDate));
            },
          );
        }
      } on Exception catch (error) {
        if (mounted) {
          _showError(error);
        }
      }
    }
  }

  Future<void> _openCopyWizard({List<String>? preSelectedIds}) async {
    final result = await context.push<CopyTodosResult>(
      AppRoutes.copyTodosPath(widget.date),
      extra: preSelectedIds,
    );
    if (result != null && mounted) {
      ref.read(dailyTodoProvider(widget.date).notifier).loadTodos();
      for (final copy in result.copied) {
        ref.invalidate(dailyTodoProvider(copy.date));
      }
      final message = StringBuffer();
      message.write('${result.copied.length} ${context.l10n.todosCopied}');
      if (result.skipped.isNotEmpty) {
        message.write(
          ', ${result.skipped.length} ${context.l10n.todosSkipped}',
        );
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message.toString())));
    }
  }

  Future<void> _handleAirQrScan() async {
    final result = await context.push<Map<String, dynamic>>(
      AppRoutes.airQrScan,
    );
    if (result != null && mounted) {
      final payload = result['payload'] as AirQrParsedPayload?;
      final decision = result['decision'] as AirQrMergeDecision?;
      if (payload != null &&
          decision != null &&
          decision != AirQrMergeDecision.cancel &&
          payload.todos.isNotEmpty) {
        final repository = ref.read(todoRepositoryProvider);
        int importedCount = 0;
        for (final todo in payload.todos) {
          try {
            await repository.createTodo(todo.copyWith(date: widget.date));
            importedCount++;
          } catch (_) {
            // Ignore duplicate title lock exceptions if skip mode
          }
        }
        if (mounted && importedCount > 0) {
          ref.invalidate(dailyTodoProvider(widget.date));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'AirQR sync complete: Imported $importedCount tasks.',
              ),
            ),
          );
        }
      }
    }
  }

  TodoStatus _effectiveStatus(
    TodoEntity todo,
    int totalDurationSeconds,
    bool isRunning,
  ) {
    if (todo.status == TodoStatus.pending &&
        (isRunning || totalDurationSeconds > 0)) {
      return TodoStatus.working;
    }
    return todo.status;
  }

  /// Applies the show/hide setting, unless the user has peeked at the hidden
  /// tasks for this visit.
  List<TodoEntity> _applyFilters(
    List<TodoEntity> todos,
    TaskDefaults defaults,
  ) {
    if (_revealHidden) return todos;
    return filterVisibleTodos(
      todos,
      showCompleted: defaults.showCompleted,
      showDropped: defaults.showDropped,
    );
  }

  List<TodoEntity> _applySinking(
    List<TodoEntity> todos,
    TaskDefaults defaults,
  ) {
    if (!defaults.sinkFinished) return todos;
    return sinkFinishedTodos(todos);
  }

  List<TodoEntity> _applySorting(List<TodoEntity> todos) {
    final sortOption = _effectiveSort;
    if (sortOption == TodoSortOption.manual) return todos;
    final sorted = [...todos];
    final trackingStates = {
      for (final todo in todos)
        todo.id: ref.watch(timeTrackingProvider(todo.id)),
    };

    switch (sortOption) {
      case TodoSortOption.nameAsc:
        sorted.sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );
      case TodoSortOption.nameDesc:
        sorted.sort(
          (a, b) => b.title.toLowerCase().compareTo(a.title.toLowerCase()),
        );
      case TodoSortOption.createdOldest:
        sorted.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      case TodoSortOption.createdNewest:
        sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case TodoSortOption.timeMost:
        sorted.sort((a, b) {
          final aTime = trackingStates[a.id]?.totalDurationSeconds ?? 0;
          final bTime = trackingStates[b.id]?.totalDurationSeconds ?? 0;
          return bTime.compareTo(aTime);
        });
      case TodoSortOption.timeLeast:
        sorted.sort((a, b) {
          final aTime = trackingStates[a.id]?.totalDurationSeconds ?? 0;
          final bTime = trackingStates[b.id]?.totalDurationSeconds ?? 0;
          return aTime.compareTo(bTime);
        });
      case TodoSortOption.status:
        const rank = {
          TodoStatus.pending: 0,
          TodoStatus.working: 1,
          TodoStatus.completed: 2,
          TodoStatus.dropped: 3,
          TodoStatus.ported: 4,
        };
        sorted.sort((a, b) {
          final aState = trackingStates[a.id];
          final bState = trackingStates[b.id];
          final aStatus = _effectiveStatus(
            a,
            aState?.totalDurationSeconds ?? 0,
            aState?.runningSegment != null,
          );
          final bStatus = _effectiveStatus(
            b,
            bState?.totalDurationSeconds ?? 0,
            bState?.runningSegment != null,
          );
          return (rank[aStatus] ?? 0).compareTo(rank[bStatus] ?? 0);
        });
      case TodoSortOption.priorityHigh:
        // Highest first. Ties keep the manual order, which the list already
        // arrives in, because List.sort is not stable on its own.
        final manualRank = {
          for (var i = 0; i < todos.length; i++) todos[i].id: i,
        };
        sorted.sort((a, b) {
          final byPriority = b.priority.index.compareTo(a.priority.index);
          if (byPriority != 0) return byPriority;
          return (manualRank[a.id] ?? 0).compareTo(manualRank[b.id] ?? 0);
        });
      case TodoSortOption.manual:
        break;
    }
    return sorted;
  }

  /// Translates a drag inside the visible list into a move inside the full
  /// list held by the notifier.
  ///
  /// The two can differ once tasks are hidden or sunk to the bottom, so the
  /// dragged task is placed just before whatever it was dropped in front of.
  void _reorderVisible(
    DailyTodoNotifier notifier,
    List<TodoEntity> visible,
    List<TodoEntity> all,
    int oldIndex,
    int newIndex,
  ) {
    if (visible.length == all.length &&
        !ref.read(taskDefaultsProvider).sinkFinished) {
      notifier.reorder(oldIndex, newIndex);
      return;
    }

    final moved = visible[oldIndex];
    final visibleAfter = [...visible]..removeAt(oldIndex);
    final targetSlot = oldIndex < newIndex ? newIndex - 1 : newIndex;
    final anchor = targetSlot < visibleAfter.length
        ? visibleAfter[targetSlot]
        : null;

    final realOld = all.indexWhere((todo) => todo.id == moved.id);
    if (realOld < 0) return;
    final realAfter = [...all]..removeAt(realOld);
    final desired = anchor == null
        ? realAfter.length
        : realAfter.indexWhere((todo) => todo.id == anchor.id);
    if (desired < 0) return;

    // `reorder` expects Flutter's own index convention, where a downward move
    // counts the slot the item still occupies.
    notifier.reorder(realOld, desired >= realOld ? desired + 1 : desired);
  }

  PopupMenuItem<TodoSortOption> _buildSortMenuItem(TodoSortOption option) {
    final icon = sortOptionIcon(option);
    final label = sortOptionName(context.l10n, option);
    final isSelected = _effectiveSort == option;
    final color = Theme.of(context).colorScheme.primary;
    return PopupMenuItem<TodoSortOption>(
      value: option,
      child: Row(
        children: [
          Icon(icon, size: 18, color: isSelected ? color : null),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: isSelected
                  ? TextStyle(color: color, fontWeight: FontWeight.w600)
                  : null,
            ),
          ),
          if (isSelected) Icon(Icons.check, size: 16, color: color),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dailyTodoProvider(widget.date));
    final notifier = ref.read(dailyTodoProvider(widget.date).notifier);
    final defaults = ref.watch(taskDefaultsProvider);
    final hasUndoStack = state.undoStack.isNotEmpty;
    final visibleTodos = _applyFilters(state.todos, defaults);
    final sortedTodos = _applySinking(_applySorting(visibleTodos), defaults);
    final hiddenCount = state.todos.length - visibleTodos.length;

    Widget buildTile(BuildContext ctx, int index) {
      final todo = sortedTodos[index];
      return TodoListTile(
        key: ValueKey(todo.id),
        animationIndex: index,
        todo: todo,
        isPast: _isPast,
        isSelected: state.selectedIds.contains(todo.id),
        isMultiSelectMode: state.isMultiSelectMode,
        onTap: () {
          if (state.isMultiSelectMode) {
            notifier.toggleSelect(todo.id);
          }
        },
        onLongPress: () {
          notifier.toggleSelect(todo.id);
        },
        onComplete: () async {
          if (defaults.confirmComplete) {
            final confirmed = await showConfirmDialog(
              context,
              title: context.l10n.confirmCompleteTitle,
              content: context.l10n.confirmCompleteBody,
            );
            if (!confirmed || !context.mounted) return;
          }
          try {
            final isSrs =
                todo.spacedRepetitionItemId != null ||
                todo.title.contains('#mastery') ||
                todo.title.contains('#spaced-repetition');

            if (isSrs) {
              final confidence = await RecallConfidenceDialog.show(
                context,
                todoTitle: todo.title,
              );
              if (confidence == null) return;

              await notifier.markSrsCompleted(
                todo.id,
                confidence,
                ref.read(completeSrsTodoProvider),
              );
            } else {
              await notifier.markCompleted(todo.id);
            }

            if (context.mounted) {
              showUndoSnackBar(
                context,
                message:
                    '${context.l10n.statusChangedTo} ${context.l10n.statusCompleted}',
                onUndo: () => notifier.undoLastStatusChange(),
              );
            }
          } on Exception catch (error) {
            if (context.mounted) {
              _showError(error);
            }
          }
        },
        onDrop: () async {
          // The question is now a setting. When it is off the drop happens on
          // the tap, and the undo SnackBar is the safety net.
          var confirmed = true;
          if (defaults.confirmDrop) {
            confirmed = await showConfirmDialog(
              context,
              title: context.l10n.confirmDrop,
              content: context.l10n.confirmDropBody,
            );
          }
          if (confirmed && context.mounted) {
            try {
              await notifier.markDropped(todo.id);
              if (context.mounted) {
                showUndoSnackBar(
                  context,
                  message:
                      '${context.l10n.statusChangedTo} ${context.l10n.statusDropped}',
                  onUndo: () => notifier.undoLastStatusChange(),
                );
              }
            } on Exception catch (error) {
              if (context.mounted) {
                _showError(error);
              }
            }
          }
        },
        onPort: () async {
          final confirmed = await showConfirmDialog(
            context,
            title: context.l10n.confirmPort,
            content: context.l10n.confirmPortBody,
          );
          if (confirmed) {
            await _showPortDatePicker(todo.id);
          }
        },
        onCopy: () => _openCopyWizard(preSelectedIds: [todo.id]),
        onEdit: () => context.push(AppRoutes.editTodoPath(todo.id)),
        onViewSegments: () {
          context.push(AppRoutes.timeSegmentsPath(todo.id));
        },
        onDelete: () async {
          if (todo.recurrenceRuleId != null) {
            await _handleRecurringDelete(context, notifier, todo);
          } else {
            final confirmed = await showConfirmDialog(
              context,
              title: context.l10n.confirmDelete,
              content: context.l10n.confirmDeleteBody,
            );
            if (confirmed && context.mounted) {
              try {
                await notifier.deleteTodo(todo.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(context.l10n.todoDeleted)),
                  );
                }
              } on Exception catch (error) {
                if (context.mounted) {
                  _showError(error);
                }
              }
            }
          }
        },
      );
    }

    return ResponsiveScaffold(
      currentDestination: AppScaffoldDestination.daily,
      appBar: state.isMultiSelectMode
          ? _buildMultiSelectAppBar(state, notifier)
          : _buildNormalAppBar(hasUndoStack, notifier, state),
      floatingActionButton: _isPast ? null : _buildFabs(),
      body: Column(
        children: [
          if (_showCalendar) _buildCalendar(),
          MorningIntentionCard(
            date: widget.date,
            isPast: _isPast,
            onOpenReflection: () => EveningReflectionModal.show(
              context,
              date: widget.date,
              isPast: _isPast,
              todos: state.todos,
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : state.todos.isEmpty
                  ? AppEmptyState(
                      key: ValueKey('empty-${widget.date}'),
                      icon: Icons.task_alt,
                      title: isToday(widget.date)
                          ? context.l10n.noTasksTodayTitle
                          : context.l10n.noTodosForDay,
                      message: _isPast
                          ? context.l10n.noTasksForPastDayMessage
                          : context.l10n.noTasksTodayMessage,
                      actionLabel: _isPast ? null : context.l10n.addFirstTask,
                      onAction: _isPast
                          ? null
                          : () => context.push(
                              '${AppRoutes.createTodo}?date=${widget.date}',
                            ),
                    )
                  : _effectiveSort == TodoSortOption.manual
                  ? ReorderableListView.builder(
                      key: ValueKey(
                        'list-${widget.date}-${sortedTodos.length}',
                      ),
                      buildDefaultDragHandles: !_isPast,
                      padding: const EdgeInsets.only(bottom: 88),
                      itemCount: sortedTodos.length,
                      // ignore: deprecated_member_use
                      onReorder: (oldIndex, newIndex) {
                        if (!_isPast) {
                          _reorderVisible(
                            notifier,
                            sortedTodos,
                            state.todos,
                            oldIndex,
                            newIndex,
                          );
                        }
                      },
                      itemBuilder: buildTile,
                    )
                  : ListView.builder(
                      key: ValueKey(
                        'sorted-${widget.date}-${sortedTodos.length}-${_effectiveSort.name}',
                      ),
                      padding: const EdgeInsets.only(bottom: 88),
                      itemCount: sortedTodos.length,
                      itemBuilder: buildTile,
                    ),
            ),
          ),
          if (hiddenCount > 0) _buildHiddenTasksBar(hiddenCount),
        ],
      ),
    );
  }

  /// The line that owns up to a filter having hidden something.
  ///
  /// Without it an empty-looking day and a day with everything finished look
  /// exactly the same.
  Widget _buildHiddenTasksBar(int hiddenCount) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 8, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              context.l10n.hiddenTasksCount(hiddenCount),
              style: theme.textTheme.bodySmall,
            ),
          ),
          TextButton(
            onPressed: () => setState(() => _revealHidden = true),
            child: Text(context.l10n.showHiddenTasks),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildNormalAppBar(
    bool hasUndoStack,
    DailyTodoNotifier notifier,
    DailyTodoState state,
  ) {
    return AppBar(
      titleSpacing: 0,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDateNavigationButton(
            icon: Icons.chevron_left,
            onPressed: _goToPreviousDay,
            tooltip: context.l10n.previousDay,
          ),
          Flexible(
            child: InkWell(
              onTap: () => setState(() => _showCalendar = !_showCalendar),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Text(
                  _buildAppBarDateLabel(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
          ),
          _buildDateNavigationButton(
            icon: Icons.chevron_right,
            onPressed: _goToNextDay,
            tooltip: context.l10n.nextDay,
          ),
        ],
      ),
      actions: [
        if (!isToday(widget.date))
          _buildActionIcon(
            icon: Icons.today,
            onPressed: _goToToday,
            tooltip: context.l10n.today,
          ),
        _buildActionIcon(
          icon: Icons.calendar_month,
          onPressed: () => setState(() => _showCalendar = !_showCalendar),
          tooltip: context.l10n.openCalendar,
        ),
        _buildActionIcon(
          icon: Icons.search,
          onPressed: () => context.push(AppRoutes.search),
          tooltip: context.l10n.searchResults,
        ),
        _buildActionIcon(
          icon: Icons.copy_all,
          onPressed: () => _openCopyWizard(),
          tooltip: context.l10n.copyToAnotherDay,
        ),
        if (isToday(widget.date) && ref.watch(ritualProvider).enabled)
          _buildActionIcon(
            icon: Icons.self_improvement_rounded,
            onPressed: () => context.push(AppRoutes.ritual),
            tooltip: context.l10n.ritualRunNow,
          ),
        _buildActionIcon(
          icon: Icons.auto_awesome_outlined,
          onPressed: () => EveningReflectionModal.show(
            context,
            date: widget.date,
            isPast: _isPast,
            todos: state.todos,
          ),
          tooltip: context.l10n.eveningReflection,
        ),
        if (hasUndoStack)
          _buildActionIcon(
            icon: Icons.undo,
            onPressed: () {
              ref
                  .read(dailyTodoProvider(widget.date).notifier)
                  .undoLastStatusChange();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(context.l10n.undoStatusChange)),
              );
            },
            tooltip: context.l10n.undo,
          ),
        PopupMenuButton<TodoSortOption>(
          icon: Icon(
            Icons.sort,
            size: 22,
            color: _effectiveSort != TodoSortOption.manual
                ? Theme.of(context).colorScheme.primary
                : null,
          ),
          padding: EdgeInsets.zero,
          tooltip: context.l10n.sortTodos,
          onSelected: (option) {
            setState(() => _sortOption = option);
            // Saves only when "remember the last order I pick" is on. The
            // notifier owns that rule, so the screen does not repeat it.
            ref.read(taskDefaultsProvider.notifier).rememberSortOption(option);
          },
          itemBuilder: (context) => [
            _buildSortMenuItem(TodoSortOption.manual),
            const PopupMenuDivider(),
            _buildSortMenuItem(TodoSortOption.nameAsc),
            _buildSortMenuItem(TodoSortOption.nameDesc),
            const PopupMenuDivider(),
            _buildSortMenuItem(TodoSortOption.createdOldest),
            _buildSortMenuItem(TodoSortOption.createdNewest),
            const PopupMenuDivider(),
            _buildSortMenuItem(TodoSortOption.timeMost),
            _buildSortMenuItem(TodoSortOption.timeLeast),
            const PopupMenuDivider(),
            _buildSortMenuItem(TodoSortOption.status),
            _buildSortMenuItem(TodoSortOption.priorityHigh),
          ],
        ),
        PopupMenuButton<_AppBarMoreOption>(
          icon: const Icon(Icons.more_vert, size: 22),
          padding: EdgeInsets.zero,
          tooltip: context.l10n.moreOptions,
          onSelected: (option) {
            switch (option) {
              case _AppBarMoreOption.settings:
                context.push(AppRoutes.settings);
                break;
              case _AppBarMoreOption.wifiSync:
                context.push(AppRoutes.wifiSync);
                break;
              case _AppBarMoreOption.airQrShare:
                showAirQrShareDialog(
                  context,
                  title: 'AirQR Sync (${widget.date})',
                  todos: state.todos,
                  date: widget.date,
                );
                break;
              case _AppBarMoreOption.airQrScan:
                _handleAirQrScan();
                break;
              case _AppBarMoreOption.dataHandoff:
                context.push(AppRoutes.dataHandoff);
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: _AppBarMoreOption.settings,
              child: Row(
                children: [
                  const Icon(Icons.settings_outlined, size: 20),
                  const SizedBox(width: 12),
                  Expanded(child: Text(context.l10n.settingsLabel)),
                ],
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem(
              value: _AppBarMoreOption.wifiSync,
              child: Row(
                children: [
                  const Icon(Icons.wifi_tethering, size: 20),
                  const SizedBox(width: 12),
                  Expanded(child: Text(context.l10n.wifiSyncTitle)),
                ],
              ),
            ),
            PopupMenuItem(
              value: _AppBarMoreOption.airQrShare,
              child: Row(
                children: [
                  const Icon(Icons.qr_code_2, size: 20),
                  const SizedBox(width: 12),
                  Expanded(child: Text(context.l10n.airQrShareTitle)),
                ],
              ),
            ),
            PopupMenuItem(
              value: _AppBarMoreOption.airQrScan,
              child: Row(
                children: [
                  const Icon(Icons.qr_code_scanner, size: 20),
                  const SizedBox(width: 12),
                  Expanded(child: Text(context.l10n.airQrScanTitle)),
                ],
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem(
              value: _AppBarMoreOption.dataHandoff,
              child: Row(
                children: [
                  const Icon(Icons.import_export_rounded, size: 20),
                  const SizedBox(width: 12),
                  Expanded(child: Text(context.l10n.dataHandoffTitle)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  String _buildAppBarDateLabel() {
    return formatDateFromIso(widget.date);
  }

  Widget _buildActionIcon({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return IconButton(
      icon: Icon(icon, size: 22),
      onPressed: onPressed,
      tooltip: tooltip,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(width: 36, height: 36),
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildDateNavigationButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return IconButton(
      icon: Icon(icon, size: 22),
      onPressed: onPressed,
      tooltip: tooltip,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      constraints: const BoxConstraints.tightFor(width: 44, height: 44),
    );
  }

  PreferredSizeWidget _buildMultiSelectAppBar(
    DailyTodoState dailyState,
    DailyTodoNotifier notifier,
  ) {
    final selectedCount = dailyState.selectedIds.length;
    final selectedIds = dailyState.selectedIds;

    final canComplete = selectedIds.any((id) {
      try {
        final todo = dailyState.todos.firstWhere((item) => item.id == id);
        return todo.status == TodoStatus.pending ||
            todo.status == TodoStatus.working;
      } on StateError {
        return false;
      }
    });

    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: () => notifier.clearSelection(),
      ),
      title: Text(context.l10n.selectedCount(selectedCount)),
      actions: [
        if (canComplete)
          TextButton.icon(
            icon: const Icon(Icons.check_circle_outline, size: 18),
            label: Text(
              context.l10n.completeAll,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            onPressed: () async {
              final ids = Set<String>.from(selectedIds);
              await notifier.bulkMarkCompleted(ids);
              if (mounted) {
                showUndoSnackBar(
                  context,
                  message: '$selectedCount ${context.l10n.bulkStatusChanged}',
                  onUndo: () {
                    for (var i = 0; i < ids.length; i++) {
                      notifier.undoLastStatusChange();
                    }
                  },
                );
              }
            },
          ),
        TextButton.icon(
          icon: const Icon(Icons.cancel_outlined, size: 18),
          label: Text(
            context.l10n.markDropped,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          onPressed: () async {
            final confirmed = await showConfirmDialog(
              context,
              title: context.l10n.confirmBulkDrop,
              content: context.l10n.confirmBulkDropBody,
            );
            if (confirmed && mounted) {
              final ids = Set<String>.from(selectedIds);
              await notifier.bulkMarkDropped(ids);
              if (mounted) {
                showUndoSnackBar(
                  context,
                  message: '$selectedCount ${context.l10n.bulkStatusChanged}',
                  onUndo: () {
                    for (var i = 0; i < ids.length; i++) {
                      notifier.undoLastStatusChange();
                    }
                  },
                );
              }
            }
          },
        ),
        IconButton(
          icon: const Icon(Icons.copy),
          tooltip: context.l10n.copy,
          onPressed: () =>
              _openCopyWizard(preSelectedIds: selectedIds.toList()),
        ),
        IconButton(
          icon: const Icon(Icons.select_all),
          tooltip: context.l10n.selectAll,
          onPressed: () => notifier.selectAll(),
        ),
      ],
    );
  }

  /// The add button, with the voice button stacked above it when the user has
  /// turned voice input on. Both are hidden on a past day, which is read-only.
  Widget _buildFabs() {
    final strings = context.l10n;
    final voiceEnabled = ref.watch(taskDefaultsProvider).voiceInputEnabled;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (voiceEnabled) ...[
          FloatingActionButton.small(
            heroTag: 'day-list-voice',
            onPressed: () => VoiceCommandSheet.show(context, date: widget.date),
            tooltip: strings.voiceOpenTooltip,
            child: const Icon(Icons.mic),
          ),
          const SizedBox(height: 12),
        ],
        FloatingActionButton(
          heroTag: 'day-list-add',
          onPressed: () {
            context.push(AppRoutes.createTodoPath(date: widget.date));
          },
          tooltip: strings.createTodo,
          child: const Icon(Icons.add),
        ),
      ],
    );
  }

  Widget _buildCalendar() {
    final focusedDay = parseIsoDate(widget.date);
    final dateSettings = ref.watch(dateTimeSettingsProvider);
    // Days the user does not work are styled like a weekend, so the calendar
    // shows the same week shape statistics count on.
    final offDays = [
      for (final weekday in kAllWeekdays)
        if (!dateSettings.workingDays.contains(weekday)) weekday,
    ];
    return TableCalendar(
      firstDay: DateTime(2020),
      lastDay: DateTime(2030),
      focusedDay: focusedDay,
      selectedDayPredicate: (day) => isSameDay(day, focusedDay),
      calendarFormat: CalendarFormat.month,
      startingDayOfWeek: startingDayOfWeekFor(dateSettings.weekStart),
      weekendDays: offDays,
      headerStyle: const HeaderStyle(formatButtonVisible: false),
      onDaySelected: (selectedDay, _) {
        setState(() => _showCalendar = false);
        _navigateToDate(dateTimeToIso(selectedDay));
      },
    );
  }
}

enum _AppBarMoreOption {
  settings,
  wifiSync,
  airQrShare,
  airQrScan,
  dataHandoff,
}
