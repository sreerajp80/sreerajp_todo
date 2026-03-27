import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sreerajp_todo/application/providers.dart';
import 'package:sreerajp_todo/core/constants/app_strings.dart';
import 'package:sreerajp_todo/core/errors/error_message_mapper.dart';
import 'package:sreerajp_todo/core/utils/date_utils.dart';
import 'package:sreerajp_todo/core/utils/unicode_utils.dart';
import 'package:sreerajp_todo/data/models/todo_entity.dart';
import 'package:sreerajp_todo/data/models/todo_status.dart';
import 'package:sreerajp_todo/domain/usecases/copy_todos.dart';
import 'package:sreerajp_todo/presentation/shared/theme/app_theme.dart';

class CopyTodosScreen extends ConsumerStatefulWidget {
  const CopyTodosScreen({super.key, this.fromDate, this.preSelectedIds});

  final String? fromDate;
  final List<String>? preSelectedIds;

  @override
  ConsumerState<CopyTodosScreen> createState() => _CopyTodosScreenState();
}

class _CopyTodosScreenState extends ConsumerState<CopyTodosScreen> {
  int _currentStep = 0;
  List<TodoEntity> _sourceTodos = [];
  final Set<String> _selectedIds = {};
  String? _targetDate;
  List<String> _conflictingTitles = [];
  bool _isLoading = true;
  bool _isCopying = false;

  @override
  void initState() {
    super.initState();
    _loadSourceTodos();
  }

  Future<void> _loadSourceTodos() async {
    final fromDate = widget.fromDate ?? todayAsIso();
    final repo = ref.read(todoRepositoryProvider);
    final todos = await repo.getTodosByDate(fromDate);
    if (!mounted) return;
    setState(() {
      _sourceTodos = todos;
      if (widget.preSelectedIds != null) {
        _selectedIds.addAll(
          widget.preSelectedIds!.where((id) => todos.any((t) => t.id == id)),
        );
      }
      _isLoading = false;
    });
  }

  Future<void> _checkConflicts() async {
    if (_targetDate == null) return;
    final repo = ref.read(todoRepositoryProvider);
    final conflicts = <String>[];
    for (final todo in _sourceTodos) {
      if (!_selectedIds.contains(todo.id)) continue;
      final normalizedTitle = nfcNormalize(todo.title);
      if (await repo.titleExistsOnDate(normalizedTitle, _targetDate!)) {
        conflicts.add(todo.id);
      }
    }
    if (!mounted) return;
    setState(() => _conflictingTitles = conflicts);
  }

  Future<void> _executeCopy() async {
    if (_targetDate == null) return;
    setState(() => _isCopying = true);

    try {
      final copyTodos = ref.read(copyTodosProvider);
      final idsToActuallyCopy = _selectedIds
          .where((id) => !_conflictingTitles.contains(id))
          .toList();
      final result = await copyTodos(idsToActuallyCopy, _targetDate!);
      if (!mounted) return;
      context.pop<CopyTodosResult>(result);
    } on Exception catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(mapErrorToMessage(e))));
      setState(() => _isCopying = false);
    }
  }

  void _goToStep(int step) {
    setState(() => _currentStep = step);
    if (step == 2) {
      _checkConflicts();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.copyTodos),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildStepIndicator(theme),
                Expanded(
                  child: switch (_currentStep) {
                    0 => _buildSelectStep(theme),
                    1 => _buildDateStep(theme),
                    2 => _buildPreviewStep(theme),
                    _ => const SizedBox.shrink(),
                  },
                ),
                _buildBottomBar(theme),
              ],
            ),
    );
  }

  Widget _buildStepIndicator(ThemeData theme) {
    const steps = [
      AppStrings.stepSelectItems,
      AppStrings.stepPickDate,
      AppStrings.stepPreview,
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: List.generate(steps.length, (index) {
          final isActive = index == _currentStep;
          final isDone = index < _currentStep;
          return Expanded(
            child: Row(
              children: [
                if (index > 0)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: isDone
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outlineVariant,
                    ),
                  ),
                CircleAvatar(
                  radius: 14,
                  backgroundColor: isActive || isDone
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outlineVariant,
                  child: isDone
                      ? Icon(
                          Icons.check,
                          size: 16,
                          color: theme.colorScheme.onPrimary,
                        )
                      : Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isActive
                                ? theme.colorScheme.onPrimary
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                ),
                if (index < steps.length - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: isDone
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outlineVariant,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSelectStep(ThemeData theme) {
    if (_sourceTodos.isEmpty) {
      return Center(
        child: Text(
          AppStrings.noTodosForDay,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Text(
                '${AppStrings.sourceDate}: ${formatDateFromIso(widget.fromDate ?? todayAsIso())}',
                style: theme.textTheme.titleSmall,
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  setState(() {
                    if (_selectedIds.length == _sourceTodos.length) {
                      _selectedIds.clear();
                    } else {
                      _selectedIds
                        ..clear()
                        ..addAll(_sourceTodos.map((t) => t.id));
                    }
                  });
                },
                child: Text(
                  _selectedIds.length == _sourceTodos.length
                      ? AppStrings.deselectAll
                      : AppStrings.selectAll,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _sourceTodos.length,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemBuilder: (context, index) {
              final todo = _sourceTodos[index];
              final isChecked = _selectedIds.contains(todo.id);
              return CheckboxListTile(
                value: isChecked,
                onChanged: (val) {
                  setState(() {
                    if (val == true) {
                      _selectedIds.add(todo.id);
                    } else {
                      _selectedIds.remove(todo.id);
                    }
                  });
                },
                title: Text(
                  todo.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: todo.description != null
                    ? Text(
                        todo.description!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall,
                      )
                    : null,
                secondary: _buildStatusIndicator(todo, theme),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatusIndicator(TodoEntity todo, ThemeData theme) {
    final color = AppTheme.statusColor(theme, todo.status);
    final icon = switch (todo.status) {
      TodoStatus.completed => Icons.check_circle,
      TodoStatus.dropped => Icons.cancel,
      TodoStatus.ported => Icons.arrow_forward,
      TodoStatus.pending => Icons.radio_button_unchecked,
    };
    return Icon(icon, color: color, size: 20);
  }

  Widget _buildDateStep(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.selectTargetDate, style: theme.textTheme.titleMedium),
          const SizedBox(height: 16),
          if (_targetDate != null)
            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_today),
                title: Text(formatDateFromIso(_targetDate!)),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: _pickDate,
                ),
              ),
            )
          else
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 48),
                  Icon(
                    Icons.calendar_month,
                    size: 64,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_today),
                    label: const Text(AppStrings.selectTargetDate),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          Text(
            '${_selectedIds.length} ${AppStrings.itemsToCopy}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _targetDate != null ? parseIsoDate(_targetDate!) : now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      helpText: AppStrings.selectTargetDate,
    );
    if (picked != null && mounted) {
      setState(() => _targetDate = dateTimeToIso(picked));
    }
  }

  Widget _buildPreviewStep(ThemeData theme) {
    final selectedTodos = _sourceTodos
        .where((t) => _selectedIds.contains(t.id))
        .toList();

    final copyCount = selectedTodos
        .where((t) => !_conflictingTitles.contains(t.id))
        .length;
    final skipCount = _conflictingTitles.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${AppStrings.targetDate}: ${formatDateFromIso(_targetDate!)}',
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              Text(
                '$copyCount ${AppStrings.itemsToCopy}'
                '${skipCount > 0 ? ', $skipCount ${AppStrings.itemsWillBeSkipped}' : ''}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: selectedTodos.length,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemBuilder: (context, index) {
              final todo = selectedTodos[index];
              final isConflict = _conflictingTitles.contains(todo.id);

              return ListTile(
                leading: Icon(
                  isConflict ? Icons.warning_amber : Icons.check_circle_outline,
                  color: isConflict
                      ? theme.colorScheme.error
                      : AppTheme.statusColor(theme, TodoStatus.completed),
                ),
                title: Text(
                  todo.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: isConflict
                      ? TextStyle(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.5,
                          ),
                          decoration: TextDecoration.lineThrough,
                        )
                      : null,
                ),
                subtitle: isConflict
                    ? Text(
                        AppStrings.willBeSkipped,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      )
                    : null,
                trailing: isConflict
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () {
                          setState(() {
                            _selectedIds.remove(todo.id);
                          });
                          _checkConflicts();
                        },
                      ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(ThemeData theme) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            if (_currentStep > 0)
              OutlinedButton(
                onPressed: _isCopying
                    ? null
                    : () => _goToStep(_currentStep - 1),
                child: const Text(AppStrings.back),
              ),
            const Spacer(),
            if (_currentStep < 2)
              FilledButton(
                onPressed: _canAdvance()
                    ? () => _goToStep(_currentStep + 1)
                    : null,
                child: const Text(AppStrings.next),
              ),
            if (_currentStep == 2)
              FilledButton.icon(
                onPressed: _canConfirm() && !_isCopying ? _executeCopy : null,
                icon: _isCopying
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.copy),
                label: Text(
                  '${AppStrings.copyConfirm}'
                  ' (${_selectedIds.where((id) => !_conflictingTitles.contains(id)).length})',
                ),
              ),
          ],
        ),
      ),
    );
  }

  bool _canAdvance() {
    return switch (_currentStep) {
      0 => _selectedIds.isNotEmpty,
      1 => _targetDate != null,
      _ => false,
    };
  }

  bool _canConfirm() {
    return _selectedIds
        .where((id) => !_conflictingTitles.contains(id))
        .isNotEmpty;
  }
}
