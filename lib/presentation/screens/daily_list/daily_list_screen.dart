import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:sreerajp_todo/application/daily_todo_notifier.dart';
import 'package:sreerajp_todo/application/daily_todo_state.dart';
import 'package:sreerajp_todo/application/providers.dart';
import 'package:sreerajp_todo/core/constants/app_routes.dart';
import 'package:sreerajp_todo/core/constants/app_strings.dart';
import 'package:sreerajp_todo/core/errors/error_message_mapper.dart';
import 'package:sreerajp_todo/core/utils/date_utils.dart';
import 'package:sreerajp_todo/data/models/todo_entity.dart';
import 'package:sreerajp_todo/data/models/todo_status.dart';
import 'package:sreerajp_todo/domain/usecases/copy_todos.dart';
import 'package:sreerajp_todo/presentation/screens/daily_list/todo_sort_option.dart';
import 'package:sreerajp_todo/presentation/screens/daily_list/widgets/todo_list_tile.dart';
import 'package:sreerajp_todo/presentation/shared/widgets/app_empty_state.dart';
import 'package:sreerajp_todo/presentation/shared/widgets/confirm_dialog.dart';
import 'package:sreerajp_todo/presentation/shared/widgets/responsive_scaffold.dart';
import 'package:sreerajp_todo/presentation/shared/widgets/undo_status_snackbar.dart';

class DailyListScreen extends ConsumerStatefulWidget {
  const DailyListScreen({super.key, required this.date});

  final String date;

  @override
  ConsumerState<DailyListScreen> createState() => _DailyListScreenState();
}

class _DailyListScreenState extends ConsumerState<DailyListScreen> {
  bool _showCalendar = false;
  TodoSortOption _sortOption = TodoSortOption.manual;

  bool get _isPast => isPastDate(widget.date);

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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mapErrorToMessage(error))));
  }

  Future<void> _handleRecurringDelete(
    BuildContext context,
    DailyTodoNotifier notifier,
    TodoEntity todo,
  ) async {
    final choice = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.confirmDeleteRecurring),
        content: const Text(AppStrings.confirmDeleteRecurringBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop('this'),
            child: const Text(AppStrings.deleteOnlyThis),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop('all'),
            child: const Text(AppStrings.deleteAllOccurrences),
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
              content: Text('$count ${AppStrings.allOccurrencesDeleted}'),
            ),
          );
        }
      } else {
        await notifier.deleteTodo(todo.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text(AppStrings.todoDeleted)),
          );
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
      helpText: AppStrings.selectTargetDate,
    );
    if (picked != null && mounted) {
      final targetDate = dateTimeToIso(picked);
      try {
        await ref
            .read(dailyTodoProvider(widget.date).notifier)
            .portTodo(todoId, targetDate);
        if (mounted) {
          showUndoSnackBar(
            context,
            message: AppStrings.todoPorted,
            onUndo: () {
              ref
                  .read(dailyTodoProvider(widget.date).notifier)
                  .undoLastStatusChange();
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
      final message = StringBuffer();
      message.write('${result.copied.length} ${AppStrings.todosCopied}');
      if (result.skipped.isNotEmpty) {
        message.write(', ${result.skipped.length} ${AppStrings.todosSkipped}');
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message.toString())));
    }
  }

  List<TodoEntity> _applySorting(List<TodoEntity> todos) {
    if (_sortOption == TodoSortOption.manual) return todos;
    final sorted = [...todos];
    switch (_sortOption) {
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
          final aTime =
              ref.read(timeTrackingProvider(a.id)).totalDurationSeconds;
          final bTime =
              ref.read(timeTrackingProvider(b.id)).totalDurationSeconds;
          return bTime.compareTo(aTime);
        });
      case TodoSortOption.timeLeast:
        sorted.sort((a, b) {
          final aTime =
              ref.read(timeTrackingProvider(a.id)).totalDurationSeconds;
          final bTime =
              ref.read(timeTrackingProvider(b.id)).totalDurationSeconds;
          return aTime.compareTo(bTime);
        });
      case TodoSortOption.status:
        const rank = {
          TodoStatus.pending: 0,
          TodoStatus.completed: 1,
          TodoStatus.dropped: 2,
          TodoStatus.ported: 3,
        };
        sorted.sort(
          (a, b) => (rank[a.status] ?? 0).compareTo(rank[b.status] ?? 0),
        );
      case TodoSortOption.manual:
        break;
    }
    return sorted;
  }

  PopupMenuItem<TodoSortOption> _buildSortMenuItem(
    TodoSortOption option,
    IconData icon,
    String label,
  ) {
    final isSelected = _sortOption == option;
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
    final hasUndoStack = state.undoStack.isNotEmpty;
    final sortedTodos = _applySorting(state.todos);

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
          try {
            await notifier.markCompleted(todo.id);
            if (context.mounted) {
              showUndoSnackBar(
                context,
                message:
                    '${AppStrings.statusChangedTo} ${AppStrings.statusCompleted}',
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
          final confirmed = await showConfirmDialog(
            context,
            title: AppStrings.confirmDrop,
            content: AppStrings.confirmDropBody,
          );
          if (confirmed && context.mounted) {
            try {
              await notifier.markDropped(todo.id);
              if (context.mounted) {
                showUndoSnackBar(
                  context,
                  message:
                      '${AppStrings.statusChangedTo} ${AppStrings.statusDropped}',
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
            title: AppStrings.confirmPort,
            content: AppStrings.confirmPortBody,
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
              title: AppStrings.confirmDelete,
              content: AppStrings.confirmDeleteBody,
            );
            if (confirmed && context.mounted) {
              try {
                await notifier.deleteTodo(todo.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text(AppStrings.todoDeleted)),
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
          : _buildNormalAppBar(hasUndoStack, notifier),
      floatingActionButton: _isPast
          ? null
          : FloatingActionButton(
              onPressed: () {
                context.push('${AppRoutes.createTodo}?date=${widget.date}');
              },
              tooltip: AppStrings.createTodo,
              child: const Icon(Icons.add),
            ),
      body: Column(
        children: [
          if (_showCalendar) _buildCalendar(),
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
                          ? AppStrings.noTasksTodayTitle
                          : AppStrings.noTodosForDay,
                      message: _isPast
                          ? AppStrings.noTasksForPastDayMessage
                          : AppStrings.noTasksTodayMessage,
                      actionLabel: _isPast ? null : AppStrings.addFirstTask,
                      onAction: _isPast
                          ? null
                          : () => context.push(
                              '${AppRoutes.createTodo}?date=${widget.date}',
                            ),
                    )
                  : _sortOption == TodoSortOption.manual
                  ? ReorderableListView.builder(
                      key: ValueKey('list-${widget.date}-${state.todos.length}'),
                      buildDefaultDragHandles: !_isPast,
                      padding: const EdgeInsets.only(bottom: 88),
                      itemCount: sortedTodos.length,
                      onReorder: (oldIndex, newIndex) {
                        if (!_isPast) {
                          notifier.reorder(oldIndex, newIndex);
                        }
                      },
                      itemBuilder: buildTile,
                    )
                  : ListView.builder(
                      key: ValueKey(
                        'sorted-${widget.date}-${state.todos.length}-${_sortOption.name}',
                      ),
                      padding: const EdgeInsets.only(bottom: 88),
                      itemCount: sortedTodos.length,
                      itemBuilder: buildTile,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildNormalAppBar(
    bool hasUndoStack,
    DailyTodoNotifier notifier,
  ) {
    return AppBar(
      titleSpacing: 0,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDateNavigationButton(
            icon: Icons.chevron_left,
            onPressed: _goToPreviousDay,
            tooltip: AppStrings.previousDay,
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
            tooltip: AppStrings.nextDay,
          ),
        ],
      ),
      actions: [
        if (!isToday(widget.date))
          _buildActionIcon(
            icon: Icons.today,
            onPressed: _goToToday,
            tooltip: AppStrings.today,
          ),
        _buildActionIcon(
          icon: Icons.calendar_month,
          onPressed: () => setState(() => _showCalendar = !_showCalendar),
          tooltip: AppStrings.openCalendar,
        ),
        _buildActionIcon(
          icon: Icons.search,
          onPressed: () => context.push(AppRoutes.search),
          tooltip: AppStrings.searchResults,
        ),
        if (!_isPast)
          _buildActionIcon(
            icon: Icons.copy_all,
            onPressed: () => _openCopyWizard(),
            tooltip: AppStrings.copyToAnotherDay,
          ),
        if (hasUndoStack)
          _buildActionIcon(
            icon: Icons.undo,
            onPressed: () {
              ref
                  .read(dailyTodoProvider(widget.date).notifier)
                  .undoLastStatusChange();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text(AppStrings.undoStatusChange)),
              );
            },
            tooltip: AppStrings.undo,
          ),
        PopupMenuButton<TodoSortOption>(
          icon: Icon(
            Icons.sort,
            size: 22,
            color: _sortOption != TodoSortOption.manual
                ? Theme.of(context).colorScheme.primary
                : null,
          ),
          padding: EdgeInsets.zero,
          tooltip: AppStrings.sortTodos,
          onSelected: (option) => setState(() => _sortOption = option),
          itemBuilder: (context) => [
            _buildSortMenuItem(
              TodoSortOption.manual,
              Icons.reorder,
              AppStrings.sortManual,
            ),
            const PopupMenuDivider(),
            _buildSortMenuItem(
              TodoSortOption.nameAsc,
              Icons.sort_by_alpha,
              AppStrings.sortNameAZ,
            ),
            _buildSortMenuItem(
              TodoSortOption.nameDesc,
              Icons.sort_by_alpha,
              AppStrings.sortNameZA,
            ),
            const PopupMenuDivider(),
            _buildSortMenuItem(
              TodoSortOption.createdOldest,
              Icons.arrow_upward,
              AppStrings.sortCreatedOldest,
            ),
            _buildSortMenuItem(
              TodoSortOption.createdNewest,
              Icons.arrow_downward,
              AppStrings.sortCreatedNewest,
            ),
            const PopupMenuDivider(),
            _buildSortMenuItem(
              TodoSortOption.timeMost,
              Icons.timer,
              AppStrings.sortTimeMost,
            ),
            _buildSortMenuItem(
              TodoSortOption.timeLeast,
              Icons.timer_outlined,
              AppStrings.sortTimeLeast,
            ),
            const PopupMenuDivider(),
            _buildSortMenuItem(
              TodoSortOption.status,
              Icons.flag_outlined,
              AppStrings.sortByStatus,
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
        return todo.status == TodoStatus.pending;
      } on StateError {
        return false;
      }
    });

    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: () => notifier.clearSelection(),
      ),
      title: Text(AppStrings.selectedCount(selectedCount)),
      actions: [
        if (canComplete)
          TextButton.icon(
            icon: const Icon(Icons.check_circle_outline, size: 18),
            label: const Text(
              AppStrings.completeAll,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            onPressed: () async {
              final ids = Set<String>.from(selectedIds);
              await notifier.bulkMarkCompleted(ids);
              if (mounted) {
                showUndoSnackBar(
                  context,
                  message: '$selectedCount ${AppStrings.bulkStatusChanged}',
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
          label: const Text(
            AppStrings.markDropped,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          onPressed: () async {
            final confirmed = await showConfirmDialog(
              context,
              title: AppStrings.confirmBulkDrop,
              content: AppStrings.confirmBulkDropBody,
            );
            if (confirmed && mounted) {
              final ids = Set<String>.from(selectedIds);
              await notifier.bulkMarkDropped(ids);
              if (mounted) {
                showUndoSnackBar(
                  context,
                  message: '$selectedCount ${AppStrings.bulkStatusChanged}',
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
          tooltip: AppStrings.copy,
          onPressed: () =>
              _openCopyWizard(preSelectedIds: selectedIds.toList()),
        ),
        IconButton(
          icon: const Icon(Icons.select_all),
          tooltip: AppStrings.selectAll,
          onPressed: () => notifier.selectAll(),
        ),
      ],
    );
  }

  Widget _buildCalendar() {
    final focusedDay = parseIsoDate(widget.date);
    return TableCalendar(
      firstDay: DateTime(2020),
      lastDay: DateTime(2030),
      focusedDay: focusedDay,
      selectedDayPredicate: (day) => isSameDay(day, focusedDay),
      calendarFormat: CalendarFormat.month,
      headerStyle: const HeaderStyle(formatButtonVisible: false),
      onDaySelected: (selectedDay, _) {
        setState(() => _showCalendar = false);
        _navigateToDate(dateTimeToIso(selectedDay));
      },
    );
  }
}
