import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:sreerajp_todo/application/daily_todo_notifier.dart';
import 'package:sreerajp_todo/application/daily_todo_state.dart';
import 'package:sreerajp_todo/application/providers.dart';
import 'package:sreerajp_todo/core/constants/app_routes.dart';
import 'package:sreerajp_todo/core/constants/app_strings.dart';
import 'package:sreerajp_todo/core/errors/error_message_mapper.dart';
import 'package:sreerajp_todo/core/utils/date_utils.dart';
import 'package:sreerajp_todo/data/models/todo_status.dart';
import 'package:sreerajp_todo/domain/usecases/copy_todos.dart';
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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dailyTodoProvider(widget.date));
    final notifier = ref.read(dailyTodoProvider(widget.date).notifier);
    final hasUndoStack = state.undoStack.isNotEmpty;

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
                  : ReorderableListView.builder(
                      key: ValueKey(
                        'list-${widget.date}-${state.todos.length}',
                      ),
                      buildDefaultDragHandles: !_isPast,
                      padding: const EdgeInsets.only(bottom: 88),
                      itemCount: state.todos.length,
                      onReorder: (oldIndex, newIndex) {
                        if (!_isPast) {
                          notifier.reorder(oldIndex, newIndex);
                        }
                      },
                      itemBuilder: (context, index) {
                        final todo = state.todos[index];
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
                                    onUndo: () =>
                                        notifier.undoLastStatusChange(),
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
                          onCopy: () =>
                              _openCopyWizard(preSelectedIds: [todo.id]),
                          onEdit: () =>
                              context.push(AppRoutes.editTodoPath(todo.id)),
                          onViewSegments: () {
                            context.push(AppRoutes.timeSegmentsPath(todo.id));
                          },
                          onDelete: () async {
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
                                    const SnackBar(
                                      content: Text(AppStrings.todoDeleted),
                                    ),
                                  );
                                }
                              } on Exception catch (error) {
                                if (context.mounted) {
                                  _showError(error);
                                }
                              }
                            }
                          },
                        );
                      },
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
      title: LayoutBuilder(
        builder: (context, constraints) {
          final dateLabel = _buildAppBarDateLabel(constraints.maxWidth);
          return Row(
            children: [
              _buildDateNavigationButton(
                icon: Icons.chevron_left,
                onPressed: _goToPreviousDay,
                tooltip: AppStrings.previousDay,
              ),
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => _showCalendar = !_showCalendar),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      dateLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
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
          );
        },
      ),
      actions: [
        if (!isToday(widget.date))
          TextButton(
            onPressed: _goToToday,
            child: const Text(AppStrings.today),
          ),
        IconButton(
          icon: const Icon(Icons.calendar_month),
          onPressed: () => setState(() => _showCalendar = !_showCalendar),
          tooltip: AppStrings.openCalendar,
        ),
        if (hasUndoStack)
          IconButton(
            icon: const Icon(Icons.undo),
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
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () => context.push(AppRoutes.search),
          tooltip: AppStrings.searchResults,
        ),
        PopupMenuButton<String>(
          itemBuilder: (context) => [
            if (!_isPast)
              const PopupMenuItem(
                value: 'copy_day',
                child: Row(
                  children: [
                    Icon(Icons.copy_all, size: 20),
                    SizedBox(width: 8),
                    Text(AppStrings.copyToAnotherDay),
                  ],
                ),
              ),
            const PopupMenuItem(
              value: 'recurring',
              child: Row(
                children: [
                  Icon(Icons.repeat, size: 20),
                  SizedBox(width: 8),
                  Text(AppStrings.recurringTasks),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'backup',
              child: Row(
                children: [
                  const Icon(Icons.backup_outlined, size: 20),
                  const SizedBox(width: 8),
                  Text(AppStrings.backup.label),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'statistics',
              child: Row(
                children: [
                  Icon(Icons.bar_chart, size: 20),
                  SizedBox(width: 8),
                  Text(AppStrings.statistics),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            switch (value) {
              case 'copy_day':
                _openCopyWizard();
              case 'recurring':
                context.push(AppRoutes.recurring);
              case 'backup':
                context.push(AppRoutes.backup);
              case 'statistics':
                context.push(AppRoutes.statistics);
            }
          },
        ),
      ],
    );
  }

  String _buildAppBarDateLabel(double maxWidth) {
    if (maxWidth < 220) {
      return DateFormat('E, MMM d').format(parseIsoDate(widget.date));
    }

    return formatDateFromIso(widget.date);
  }

  Widget _buildDateNavigationButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return IconButton(
      icon: Icon(icon, size: 20),
      onPressed: onPressed,
      tooltip: tooltip,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(width: 36, height: 36),
      visualDensity: VisualDensity.compact,
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
            icon: const Icon(Icons.check_circle_outline),
            label: const Text(AppStrings.completeAll),
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
          icon: const Icon(Icons.cancel_outlined),
          label: const Text(AppStrings.markDropped),
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
