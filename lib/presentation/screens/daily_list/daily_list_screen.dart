import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:sreerajp_todo/application/daily_todo_notifier.dart';
import 'package:sreerajp_todo/application/daily_todo_state.dart';
import 'package:sreerajp_todo/application/providers.dart';
import 'package:sreerajp_todo/core/constants/app_routes.dart';
import 'package:sreerajp_todo/core/constants/app_strings.dart';
import 'package:sreerajp_todo/core/utils/date_utils.dart';
import 'package:sreerajp_todo/data/models/todo_status.dart';
import 'package:sreerajp_todo/presentation/screens/daily_list/widgets/todo_list_tile.dart';
import 'package:sreerajp_todo/presentation/shared/widgets/confirm_dialog.dart';
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
    final prev = current.subtract(const Duration(days: 1));
    _navigateToDate(dateTimeToIso(prev));
  }

  void _goToNextDay() {
    final current = parseIsoDate(widget.date);
    final next = current.add(const Duration(days: 1));
    _navigateToDate(dateTimeToIso(next));
  }

  void _goToToday() {
    _navigateToDate(todayAsIso());
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
        await ref.read(dailyTodoProvider(widget.date).notifier).portTodo(
              todoId,
              targetDate,
            );
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
      } on Exception catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString())),
          );
        }
      }
    }
  }

  Future<void> _showCopyDatePicker(List<String> todoIds) async {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final picked = await showDatePicker(
      context: context,
      initialDate: tomorrow,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: AppStrings.selectTargetDate,
    );
    if (picked != null && mounted) {
      final targetDate = dateTimeToIso(picked);
      try {
        final result = await ref
            .read(dailyTodoProvider(widget.date).notifier)
            .copyTodos(todoIds, targetDate);
        if (mounted) {
          final msg = StringBuffer();
          msg.write('${result.copied.length} ${AppStrings.todosCopied}');
          if (result.skipped.isNotEmpty) {
            msg.write(', ${result.skipped.length} ${AppStrings.todosSkipped}');
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(msg.toString())),
          );
        }
      } on Exception catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString())),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dailyTodoProvider(widget.date));
    final notifier = ref.read(dailyTodoProvider(widget.date).notifier);
    final theme = Theme.of(context);
    final hasUndoStack = state.undoStack.isNotEmpty;

    return Scaffold(
      appBar: state.isMultiSelectMode
          ? _buildMultiSelectAppBar(state, notifier)
          : _buildNormalAppBar(hasUndoStack, notifier),
      body: Column(
        children: [
          if (_showCalendar) _buildCalendar(),
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.todos.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.task_alt,
                              size: 64,
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              AppStrings.noTodosForDay,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ReorderableListView.builder(
                        buildDefaultDragHandles: !_isPast,
                        padding: const EdgeInsets.only(bottom: 80),
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
                            todo: todo,
                            isPast: _isPast,
                            isSelected:
                                state.selectedIds.contains(todo.id),
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
                              await notifier.markCompleted(todo.id);
                              if (context.mounted) {
                                showUndoSnackBar(
                                  context,
                                  message:
                                      '${AppStrings.statusChangedTo} ${AppStrings.statusCompleted}',
                                  onUndo: () =>
                                      notifier.undoLastStatusChange(),
                                );
                              }
                            },
                            onDrop: () async {
                              final confirmed = await showConfirmDialog(
                                context,
                                title: AppStrings.confirmDrop,
                                content: AppStrings.confirmDropBody,
                              );
                              if (confirmed && context.mounted) {
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
                            onCopy: () => _showCopyDatePicker([todo.id]),
                            onEdit: () {
                              if (_isPast) {
                                context.push(
                                    AppRoutes.editTodoPath(todo.id));
                              } else {
                                context.push(
                                    AppRoutes.editTodoPath(todo.id));
                              }
                            },
                            onDelete: () async {
                              final confirmed = await showConfirmDialog(
                                context,
                                title: AppStrings.confirmDelete,
                                content: AppStrings.confirmDeleteBody,
                              );
                              if (confirmed && context.mounted) {
                                await notifier.deleteTodo(todo.id);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text(AppStrings.todoDeleted),
                                    ),
                                  );
                                }
                              }
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: _isPast
          ? null
          : FloatingActionButton(
              onPressed: () {
                context.push('${AppRoutes.createTodo}?date=${widget.date}');
              },
              tooltip: AppStrings.createTodo,
              child: const Icon(Icons.add),
            ),
    );
  }

  PreferredSizeWidget _buildNormalAppBar(
    bool hasUndoStack,
    DailyTodoNotifier notifier,
  ) {
    return AppBar(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: _goToPreviousDay,
            tooltip: 'Previous day',
          ),
          GestureDetector(
            onTap: () => setState(() => _showCalendar = !_showCalendar),
            child: Text(
              formatDateFromIso(widget.date),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _goToNextDay,
            tooltip: 'Next day',
          ),
        ],
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
          tooltip: 'Calendar',
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
            const PopupMenuItem(
              value: 'backup',
              child: Row(
                children: [
                  Icon(Icons.backup_outlined, size: 20),
                  SizedBox(width: 8),
                  Text(AppStrings.backup),
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

  PreferredSizeWidget _buildMultiSelectAppBar(
    DailyTodoState dailyState,
    DailyTodoNotifier notifier,
  ) {
    final selectedCount = dailyState.selectedIds.length;
    final selectedIds = dailyState.selectedIds;

    final canComplete = selectedIds.any((id) {
      try {
        final todo = dailyState.todos.firstWhere((t) => t.id == id);
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
              _showCopyDatePicker(selectedIds.toList()),
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
