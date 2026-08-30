import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:sreerajp_todo/application/providers.dart';
import 'package:sreerajp_todo/core/constants/app_constants.dart';
import 'package:sreerajp_todo/core/constants/app_routes.dart';
import 'package:sreerajp_todo/core/errors/error_message_mapper.dart';
import 'package:sreerajp_todo/core/extensions/localization_extensions.dart';
import 'package:sreerajp_todo/core/utils/date_utils.dart';
import 'package:sreerajp_todo/core/utils/unicode_utils.dart' as unicode_utils;
import 'package:sreerajp_todo/data/models/todo_entity.dart';
import 'package:sreerajp_todo/data/models/todo_priority.dart';
import 'package:sreerajp_todo/data/models/todo_status.dart';
import 'package:sreerajp_todo/data/models/recurrence_rule_entity.dart';
import 'package:sreerajp_todo/presentation/screens/create_edit_todo/widgets/repeat_option_picker.dart';
import 'package:sreerajp_todo/core/utils/task_default_rules.dart';
import 'package:sreerajp_todo/presentation/screens/create_edit_todo/widgets/priority_selector.dart';
import 'package:sreerajp_todo/presentation/screens/create_edit_todo/widgets/target_time_field.dart';
import 'package:sreerajp_todo/presentation/screens/create_edit_todo/widgets/title_autocomplete_field.dart';
import 'package:sreerajp_todo/presentation/screens/recurring_tasks/widgets/rrule_frequency_picker.dart';
import 'package:sreerajp_todo/presentation/screens/recurring_tasks/widgets/rrule_preview.dart';
import 'package:sreerajp_todo/presentation/shared/widgets/adaptive_directionality.dart';
import 'package:sreerajp_todo/presentation/shared/widgets/app_section_card.dart';
import 'package:sreerajp_todo/presentation/shared/widgets/confirm_dialog.dart';
import 'package:sreerajp_todo/core/utils/rrule_display_utils.dart';

import 'package:sreerajp_todo/data/models/sub_task_item.dart';

class CreateEditTodoScreen extends ConsumerStatefulWidget {
  const CreateEditTodoScreen({
    super.key,
    this.todoId,
    this.date,
    this.initialTitle,
    this.initialDescription,
    this.initialTargetSeconds,
    this.initialPriority,
  });

  final String? todoId;
  final String? date;

  /// A title to open the form with, sent by the voice task sheet.
  ///
  /// All four `initial` values are ignored while editing an existing task, so
  /// a saved task can never be overwritten by a stale link.
  final String? initialTitle;

  /// A description to open the form with. The voice sheet uses it to note a
  /// spoken time of day, which has no column of its own on a task.
  final String? initialDescription;

  /// A tracking target to open the form with, in seconds.
  final int? initialTargetSeconds;

  /// A priority to open the form with, as its stored name. Anything
  /// unrecognised falls back to the setting in Settings.
  final String? initialPriority;

  bool get isEditing => todoId != null;

  @override
  ConsumerState<CreateEditTodoScreen> createState() =>
      _CreateEditTodoScreenState();
}

class _CreateEditTodoScreenState extends ConsumerState<CreateEditTodoScreen> {
  static const _uuid = Uuid();

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _newSubTaskController = TextEditingController();
  final _titleFocusNode = FocusNode();

  TodoStatus _status = TodoStatus.pending;
  TodoPriority _priority = TodoPriority.normal;
  int? _targetSeconds;
  String? _portedTo;
  String _effectiveDate = '';
  TodoEntity? _existingTodo;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _uniquenessError;
  Timer? _uniquenessDebounce;

  // Sub-task & Task dependency state
  List<SubTaskItem> _subTasks = [];
  List<String> _prerequisiteTodoIds = [];
  List<TodoEntity> _availablePrerequisites = [];

  // Repeat / recurrence state
  SimpleRepeatOption _repeatOption = SimpleRepeatOption.none;
  RruleFrequency _customFrequency = RruleFrequency.daily;
  int _customInterval = 1;
  Set<int> _customWeekDays = {};
  String? _customEndDate;
  bool _hasCustomEndDate = false;
  _EndMode _customEndMode = _EndMode.never;
  int _customEndDays = 7;
  RecurrenceRuleEntity? _existingRule;

  bool get _isPast => isPastDate(_effectiveDate);
  bool get _isReadOnly => _isPast;

  @override
  void initState() {
    super.initState();
    _effectiveDate = widget.date ?? todayAsIso();
    if (!widget.isEditing) {
      // A brand new task opens on the values chosen in Settings. An existing
      // task keeps whatever it was saved with, so editing never rewrites it.
      final defaults = ref.read(taskDefaultsProvider);
      _status = switch (defaults.newTaskStatus) {
        NewTaskStatus.pending => TodoStatus.pending,
        NewTaskStatus.working => TodoStatus.working,
      };
      _priority = defaults.priority;
      _targetSeconds = defaults.targetTime.seconds;

      // Anything the voice sheet understood overrides those defaults, but only
      // where it actually understood something. A sentence that named no
      // priority leaves the Settings priority alone.
      if (widget.initialTitle != null && widget.initialTitle!.isNotEmpty) {
        _titleController.text = widget.initialTitle!;
        // A spoken title has never been through the field, so run the same
        // duplicate check typing would have run. Two tasks with the same title
        // on one day are refused whatever put the words there.
        _checkTitleUniqueness(widget.initialTitle!);
      }
      if (widget.initialDescription != null &&
          widget.initialDescription!.isNotEmpty) {
        _descriptionController.text = widget.initialDescription!;
      }
      if (widget.initialTargetSeconds != null &&
          widget.initialTargetSeconds! > 0) {
        _targetSeconds = widget.initialTargetSeconds;
      }
      if (widget.initialPriority != null) {
        _priority = TodoPriority.fromDbString(widget.initialPriority);
      }
    }
    _loadData();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _newSubTaskController.dispose();
    _titleFocusNode.dispose();
    _uniquenessDebounce?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    final repo = ref.read(todoRepositoryProvider);
    final dayTodos = await repo.getTodosByDate(_effectiveDate);
    _availablePrerequisites = dayTodos
        .where((t) => t.id != widget.todoId)
        .toList();

    if (widget.isEditing) {
      final todo = await repo.getTodoById(widget.todoId!);
      if (todo != null && mounted) {
        RecurrenceRuleEntity? rule;
        if (todo.recurrenceRuleId != null) {
          rule = await ref
              .read(recurrenceRulesProvider.notifier)
              .findById(todo.recurrenceRuleId!);
        }
        setState(() {
          _existingTodo = todo;
          _titleController.text = todo.title;
          _descriptionController.text = todo.description ?? '';
          _status = todo.status;
          _priority = todo.priority;
          _targetSeconds = todo.targetSeconds;
          _portedTo = todo.portedTo;
          _effectiveDate = todo.date;
          _subTasks = List.from(todo.subTasks);
          _prerequisiteTodoIds = List.from(todo.prerequisiteTodoIds);
          if (rule != null) {
            _existingRule = rule;
            _repeatOption = SimpleRepeatOption.repeat;
            _parseRruleIntoFields(rule.rrule);
            _hasCustomEndDate = rule.endDate != null;
            _customEndDate = rule.endDate;
            _customEndMode = rule.endDate != null
                ? _EndMode.onDate
                : _EndMode.never;
          }
          _isLoading = false;
        });
      } else {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } else {
      setState(() => _isLoading = false);
    }
  }

  void _checkTitleUniqueness(String title) {
    _uniquenessDebounce?.cancel();
    if (title.trim().isEmpty) {
      setState(() => _uniquenessError = null);
      return;
    }
    _uniquenessDebounce = Timer(
      const Duration(milliseconds: kAutocompleteDebounceMills),
      () async {
        final repo = ref.read(todoRepositoryProvider);
        final exists = await repo.titleExistsOnDate(
          title.trim(),
          _effectiveDate,
          excludeId: _existingTodo?.id,
        );
        if (mounted) {
          setState(() {
            _uniquenessError = exists ? context.l10n.errorDuplicateTitle : null;
          });
        }
      },
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_uniquenessError != null) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final now = DateTime.now().toUtc().toIso8601String();
      final normalizedTitle = unicode_utils.nfcNormalize(
        _titleController.text.trim(),
      );
      final description = _descriptionController.text.trim().isEmpty
          ? null
          : unicode_utils.nfcNormalize(_descriptionController.text.trim());

      if (widget.isEditing && _existingTodo != null) {
        // Handle recurrence rule changes in edit mode
        String? recurrenceRuleId = _existingTodo!.recurrenceRuleId;
        final rulesNotifier = ref.read(recurrenceRulesProvider.notifier);

        if (_repeatOption == SimpleRepeatOption.repeat) {
          final rruleStr = _buildRruleFromRepeatOption();
          if (_existingRule != null) {
            // Update existing rule
            final updatedRule = _existingRule!.copyWith(
              title: normalizedTitle,
              description: description,
              rrule: rruleStr,
              endDate: _hasCustomEndDate ? _customEndDate : null,
              updatedAt: now,
            );
            await rulesNotifier.updateRule(updatedRule);
            recurrenceRuleId = _existingRule!.id;
          } else {
            // Create new rule
            final ruleId = _uuid.v4();
            recurrenceRuleId = ruleId;
            final rule = RecurrenceRuleEntity(
              id: ruleId,
              title: normalizedTitle,
              description: description,
              rrule: rruleStr,
              startDate: _effectiveDate,
              endDate: _hasCustomEndDate ? _customEndDate : null,
              createdAt: now,
              updatedAt: now,
            );
            await rulesNotifier.createRule(rule);
          }
        } else if (_repeatOption == SimpleRepeatOption.none &&
            _existingRule != null) {
          // User removed the repeat — delete the rule
          await rulesNotifier.deleteRule(_existingRule!.id);
          recurrenceRuleId = null;
        }

        final updated = _existingTodo!.copyWith(
          title: normalizedTitle,
          description: description,
          status: _status,
          priority: _priority,
          targetSeconds: _targetSeconds,
          portedTo: _status == TodoStatus.ported ? _portedTo : null,
          recurrenceRuleId: recurrenceRuleId,
          subTasks: _subTasks,
          prerequisiteTodoIds: _prerequisiteTodoIds,
          updatedAt: now,
        );
        final notifier = ref.read(dailyTodoProvider(_effectiveDate).notifier);
        await notifier.updateTodo(updated);
      } else {
        // Create recurrence rule if repeat is set
        String? recurrenceRuleId;
        if (_repeatOption != SimpleRepeatOption.none) {
          final ruleId = _uuid.v4();
          recurrenceRuleId = ruleId;
          final rruleStr = _buildRruleFromRepeatOption();
          final rule = RecurrenceRuleEntity(
            id: ruleId,
            title: normalizedTitle,
            description: description,
            rrule: rruleStr,
            startDate: _effectiveDate,
            endDate: _hasCustomEndDate ? _customEndDate : null,
            createdAt: now,
            updatedAt: now,
          );
          await ref.read(recurrenceRulesProvider.notifier).createRule(rule);
        }

        final todo = TodoEntity(
          id: _uuid.v4(),
          date: _effectiveDate,
          title: normalizedTitle,
          description: description,
          status: _status,
          priority: _priority,
          targetSeconds: _targetSeconds,
          portedTo: _status == TodoStatus.ported ? _portedTo : null,
          recurrenceRuleId: recurrenceRuleId,
          sortOrder: 0,
          subTasks: _subTasks,
          prerequisiteTodoIds: _prerequisiteTodoIds,
          createdAt: now,
          updatedAt: now,
        );
        final notifier = ref.read(dailyTodoProvider(_effectiveDate).notifier);
        await notifier.createTodo(todo);
      }

      // Generate recurring tasks for the look-ahead window
      if (_repeatOption == SimpleRepeatOption.repeat) {
        await ref.read(generateRecurringTasksProvider).call();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isEditing
                  ? context.l10n.todoUpdated
                  : _repeatOption != SimpleRepeatOption.none
                  ? context.l10n.recurrenceCreated
                  : context.l10n.todoCreated,
            ),
          ),
        );
        context.pop();
      }
    } on Exception catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(mapErrorToMessage(context.l10n, error))),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _onStatusChanged(TodoStatus? newStatus) async {
    if (newStatus == null || _isReadOnly) {
      return;
    }
    if (newStatus == TodoStatus.working) {
      return;
    }

    // The two questions are settings now, and the same settings the day list
    // tile reads, so both routes to a status change behave the same way.
    final defaults = ref.read(taskDefaultsProvider);

    if (newStatus == TodoStatus.dropped && defaults.confirmDrop) {
      final confirmed = await showConfirmDialog(
        context,
        title: context.l10n.confirmDrop,
        content: context.l10n.confirmDropBody,
      );
      if (!confirmed || !mounted) {
        return;
      }
    }

    if (newStatus == TodoStatus.completed && defaults.confirmComplete) {
      final confirmed = await showConfirmDialog(
        context,
        title: context.l10n.confirmCompleteTitle,
        content: context.l10n.confirmCompleteBody,
      );
      if (!confirmed || !mounted) {
        return;
      }
    }

    if (newStatus == TodoStatus.ported && widget.isEditing) {
      final confirmed = await showConfirmDialog(
        context,
        title: context.l10n.confirmPort,
        content: context.l10n.confirmPortBody,
      );
      if (!confirmed || !mounted) {
        return;
      }

      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final picked = await showDatePicker(
        context: context,
        initialDate: tomorrow,
        firstDate: tomorrow,
        lastDate: DateTime.now().add(const Duration(days: 365)),
        helpText: context.l10n.selectTargetDate,
      );
      if (picked == null || !mounted) {
        return;
      }

      final targetDate = dateTimeToIso(picked);
      try {
        final notifier = ref.read(dailyTodoProvider(_effectiveDate).notifier);
        await notifier.portTodo(_existingTodo!.id, targetDate);
        ref.invalidate(dailyTodoProvider(targetDate));
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(context.l10n.todoPorted)));
          context.pop();
        }
      } on Exception catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(mapErrorToMessage(context.l10n, error))),
          );
        }
      }
      return;
    }

    if (newStatus == TodoStatus.ported && !widget.isEditing) {
      return;
    }

    setState(() => _status = newStatus);
  }

  @override
  Widget build(BuildContext context) {
    final title = _isReadOnly && widget.isEditing
        ? context.l10n.viewTodo
        : widget.isEditing
        ? context.l10n.editTodo
        : context.l10n.createTodo;
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(title)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          if (widget.isEditing && widget.todoId != null)
            IconButton(
              icon: const Icon(Icons.history_rounded),
              tooltip: context.l10n.taskHistory,
              onPressed: () =>
                  context.push(AppRoutes.todoHistoryPath(widget.todoId!)),
            ),
          if (_isPast)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Row(
                children: [
                  Icon(
                    Icons.lock_outline,
                    size: 16,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    context.l10n.readOnlyPastDate,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              AppSectionCard(
                title: context.l10n.details,
                subtitle: formatDateFromIso(_effectiveDate),
                child: Column(
                  children: [
                    TitleAutocompleteField(
                      controller: _titleController,
                      focusNode: _titleFocusNode,
                      enabled: !_isReadOnly,
                      onChanged: _checkTitleUniqueness,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return context.l10n.titleRequired;
                        }
                        if (_uniquenessError != null) {
                          return _uniquenessError;
                        }
                        return null;
                      },
                    ),
                    if (_uniquenessError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6, left: 12),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _uniquenessError!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.error,
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 14),
                    _buildDescriptionField(),
                    if (_existingTodo?.sourceDate != null) ...[
                      const SizedBox(height: 14),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '${context.l10n.copiedFrom} ${_existingTodo!.sourceDate}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontStyle: FontStyle.italic,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AppSectionCard(
                title: context.l10n.priorityLabel,
                child: PrioritySelector(
                  selected: _priority,
                  enabled: !_isReadOnly,
                  onChanged: (priority) => setState(() => _priority = priority),
                ),
              ),
              const SizedBox(height: 16),
              AppSectionCard(
                title: context.l10n.targetTimeLabel,
                child: TargetTimeField(
                  targetSeconds: _targetSeconds,
                  enabled: !_isReadOnly,
                  onChanged: (seconds) => _targetSeconds = seconds,
                ),
              ),
              const SizedBox(height: 16),
              _buildSubTaskCard(),
              if (_availablePrerequisites.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildPrerequisitesCard(),
              ],
              if (!_isReadOnly) ...[
                const SizedBox(height: 16),
                AppSectionCard(
                  title: context.l10n.repeat,
                  child: RepeatOptionPicker(
                    selected: _repeatOption,
                    onChanged: (option) {
                      setState(() => _repeatOption = option);
                    },
                    onRepeatRequested: _showCustomRecurrenceSheet,
                    summaryLabel: _repeatSummary,
                  ),
                ),
                if (_repeatOption == SimpleRepeatOption.repeat) ...[
                  const SizedBox(height: 8),
                  RrulePreview(
                    rruleString: _buildRruleFromRepeatOption(),
                    startDate: _effectiveDate,
                    endDate: _hasCustomEndDate ? _customEndDate : null,
                  ),
                ],
              ],
              const SizedBox(height: 16),
              AppSectionCard(
                title: context.l10n.taskStatus,
                subtitle: widget.isEditing
                    ? context.l10n.editTodo
                    : context.l10n.createTodo,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatusSelector(),
                    if (_status == TodoStatus.ported && _portedTo != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        '${context.l10n.portedTo}: $_portedTo',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.tertiary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 18),
              if (!_isReadOnly)
                FilledButton.icon(
                  onPressed: _isSaving ? null : _save,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_rounded),
                  label: Text(context.l10n.save),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _parseRruleIntoFields(String rrule) {
    final parts = <String, String>{};
    for (final part in rrule.split(';')) {
      final idx = part.indexOf('=');
      if (idx > 0) {
        parts[part.substring(0, idx)] = part.substring(idx + 1);
      }
    }
    final freq = parts['FREQ'];
    if (freq != null) {
      _customFrequency = switch (freq) {
        'DAILY' => RruleFrequency.daily,
        'WEEKLY' => RruleFrequency.weekly,
        'MONTHLY' => RruleFrequency.monthly,
        'YEARLY' => RruleFrequency.yearly,
        _ => RruleFrequency.daily,
      };
    }
    _customInterval = int.tryParse(parts['INTERVAL'] ?? '1') ?? 1;
    final byDay = parts['BYDAY'];
    if (byDay != null) {
      _customWeekDays = byDay.split(',').map(_dayAbbrevToInt).toSet();
    }
  }

  static int _dayAbbrevToInt(String abbrev) {
    return switch (abbrev.toUpperCase()) {
      'MO' => DateTime.monday,
      'TU' => DateTime.tuesday,
      'WE' => DateTime.wednesday,
      'TH' => DateTime.thursday,
      'FR' => DateTime.friday,
      'SA' => DateTime.saturday,
      'SU' => DateTime.sunday,
      _ => DateTime.monday,
    };
  }

  String? get _repeatSummary {
    if (_repeatOption == SimpleRepeatOption.none) return null;
    return describeRrule(_buildRruleFromRepeatOption());
  }

  String _buildRruleFromRepeatOption() {
    if (_repeatOption == SimpleRepeatOption.none) return '';
    final parts = <String>[];
    switch (_customFrequency) {
      case RruleFrequency.daily:
        parts.add('FREQ=DAILY');
        if (_customInterval > 1) parts.add('INTERVAL=$_customInterval');
      case RruleFrequency.weekly:
        parts.add('FREQ=WEEKLY');
        if (_customInterval > 1) parts.add('INTERVAL=$_customInterval');
        if (_customWeekDays.isNotEmpty) {
          final sorted = _customWeekDays.toList()..sort();
          parts.add('BYDAY=${sorted.map(_intToDayAbbrev).join(',')}');
        }
      case RruleFrequency.monthly:
        parts.add('FREQ=MONTHLY');
        if (_customInterval > 1) parts.add('INTERVAL=$_customInterval');
      case RruleFrequency.yearly:
        parts.add('FREQ=YEARLY');
        if (_customInterval > 1) parts.add('INTERVAL=$_customInterval');
    }
    return parts.join(';');
  }

  static String _intToDayAbbrev(int day) {
    return switch (day) {
      DateTime.monday => 'MO',
      DateTime.tuesday => 'TU',
      DateTime.wednesday => 'WE',
      DateTime.thursday => 'TH',
      DateTime.friday => 'FR',
      DateTime.saturday => 'SA',
      DateTime.sunday => 'SU',
      _ => 'MO',
    };
  }

  Future<void> _showCustomRecurrenceSheet() async {
    var freq = _customFrequency;
    var interval = _customInterval;
    var weekDays = Set<int>.from(_customWeekDays);
    var endMode = _customEndMode;
    var endDate = _customEndDate;
    var endDays = _customEndDays;

    if (freq == RruleFrequency.weekly && weekDays.isEmpty) {
      weekDays = {parseIsoDate(_effectiveDate).weekday};
    }

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final theme = Theme.of(context);
            final unitLabel = switch (freq) {
              RruleFrequency.daily => context.l10n.days,
              RruleFrequency.weekly => context.l10n.weeks,
              RruleFrequency.monthly => context.l10n.months,
              RruleFrequency.yearly => context.l10n.years,
            };

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.frequency,
                        style: theme.textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      RruleFrequencyPicker(
                        selected: freq,
                        onChanged: (f) => setSheetState(() {
                          freq = f;
                          if (f == RruleFrequency.weekly && weekDays.isEmpty) {
                            weekDays = {parseIsoDate(_effectiveDate).weekday};
                          }
                        }),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Text(
                            '${context.l10n.every} ',
                            style: theme.textTheme.bodyLarge,
                          ),
                          SizedBox(
                            width: 60,
                            child: TextFormField(
                              initialValue: interval.toString(),
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              onChanged: (v) {
                                final n = int.tryParse(v);
                                if (n != null && n >= 1) {
                                  setSheetState(() => interval = n);
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(unitLabel, style: theme.textTheme.bodyLarge),
                        ],
                      ),
                      if (freq == RruleFrequency.weekly) ...[
                        const SizedBox(height: 16),
                        Text(
                          context.l10n.daysOfWeek,
                          style: theme.textTheme.titleSmall,
                        ),
                        const SizedBox(height: 8),
                        _buildSheetDayOfWeekPicker(weekDays, setSheetState),
                      ],
                      const SizedBox(height: 16),
                      Text(
                        context.l10n.ends,
                        style: theme.textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SegmentedButton<_EndMode>(
                          segments: [
                            ButtonSegment(
                              value: _EndMode.never,
                              label: Text(context.l10n.endsNever),
                            ),
                            ButtonSegment(
                              value: _EndMode.onDate,
                              label: Text(context.l10n.endsOnDate),
                            ),
                            ButtonSegment(
                              value: _EndMode.forDays,
                              label: Text(context.l10n.endsAfterDays),
                            ),
                          ],
                          selected: {endMode},
                          onSelectionChanged: (s) => setSheetState(() {
                            endMode = s.first;
                            if (endMode == _EndMode.onDate && endDate == null) {
                              endDate = _effectiveDate;
                            }
                          }),
                        ),
                      ),
                      if (endMode == _EndMode.onDate) ...[
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () async {
                            final current = endDate != null
                                ? parseIsoDate(endDate!)
                                : DateTime.now();
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: current,
                              firstDate: parseIsoDate(_effectiveDate),
                              lastDate: DateTime(2030),
                            );
                            if (picked != null) {
                              setSheetState(
                                () => endDate = dateTimeToIso(picked),
                              );
                            }
                          },
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.calendar_today),
                            ),
                            child: Text(
                              formatDateFromIso(endDate ?? _effectiveDate),
                            ),
                          ),
                        ),
                      ],
                      if (endMode == _EndMode.forDays) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              '${context.l10n.endsAfterDays} ',
                              style: theme.textTheme.bodyLarge,
                            ),
                            SizedBox(
                              width: 64,
                              child: TextFormField(
                                initialValue: endDays.toString(),
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                onChanged: (v) {
                                  final n = int.tryParse(v);
                                  if (n != null && n >= 1) {
                                    setSheetState(() => endDays = n);
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              context.l10n.days,
                              style: theme.textTheme.bodyLarge,
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${context.l10n.endDate}: '
                          '${formatDateFromIso(_resolveEndDays(endDays))}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: Text(context.l10n.save),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    if (result == true && mounted) {
      setState(() {
        _customFrequency = freq;
        _customInterval = interval;
        _customWeekDays = weekDays;
        _customEndMode = endMode;
        _customEndDays = endDays;
        switch (endMode) {
          case _EndMode.never:
            _hasCustomEndDate = false;
            _customEndDate = null;
          case _EndMode.onDate:
            _hasCustomEndDate = true;
            _customEndDate = endDate ?? _effectiveDate;
          case _EndMode.forDays:
            _hasCustomEndDate = true;
            _customEndDate = _resolveEndDays(endDays);
        }
      });
    }
  }

  /// Resolves a "for N days" end condition to an ISO end date. The window is
  /// [days] calendar days starting on [_effectiveDate], so the inclusive end
  /// date is start + (days - 1). "For 1 day" ends on the start date itself.
  String _resolveEndDays(int days) =>
      dateTimeToIso(parseIsoDate(_effectiveDate).add(Duration(days: days - 1)));

  Widget _buildSheetDayOfWeekPicker(
    Set<int> weekDays,
    StateSetter setSheetState,
  ) {
    final dayLabels = [
      (DateTime.monday, context.l10n.monday),
      (DateTime.tuesday, context.l10n.tuesday),
      (DateTime.wednesday, context.l10n.wednesday),
      (DateTime.thursday, context.l10n.thursday),
      (DateTime.friday, context.l10n.friday),
      (DateTime.saturday, context.l10n.saturday),
      (DateTime.sunday, context.l10n.sunday),
    ];

    return Wrap(
      spacing: 4,
      children: dayLabels.map((entry) {
        final (day, label) = entry;
        final selected = weekDays.contains(day);
        return FilterChip(
          label: Text(label),
          selected: selected,
          onSelected: (value) {
            setSheetState(() {
              if (value) {
                weekDays.add(day);
              } else {
                weekDays.remove(day);
              }
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildDescriptionField() {
    return AdaptiveDirectionality(
      text: _descriptionController.text,
      child: TextFormField(
        controller: _descriptionController,
        enabled: !_isReadOnly,
        maxLines: 4,
        decoration: InputDecoration(
          labelText: context.l10n.descriptionHint,
          prefixIcon: const Icon(Icons.notes_rounded),
          alignLabelWithHint: true,
        ),
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  Widget _buildStatusSelector() {
    final theme = Theme.of(context);
    final options = <_StatusOption>[
      if (_status == TodoStatus.working)
        _StatusOption(
          status: TodoStatus.working,
          label: context.l10n.statusWorking,
          icon: Icons.play_circle_fill_rounded,
        ),
      if (_status != TodoStatus.working)
        _StatusOption(
          status: TodoStatus.pending,
          label: context.l10n.statusPending,
          icon: Icons.radio_button_unchecked,
        ),
      _StatusOption(
        status: TodoStatus.completed,
        label: context.l10n.statusCompleted,
        icon: Icons.check_circle_outline,
      ),
      _StatusOption(
        status: TodoStatus.dropped,
        label: context.l10n.statusDropped,
        icon: Icons.cancel_outlined,
      ),
      if (widget.isEditing)
        _StatusOption(
          status: TodoStatus.ported,
          label: context.l10n.statusPorted,
          icon: Icons.arrow_forward,
        ),
    ];

    bool isSelectable(TodoStatus status) {
      if (_isReadOnly || status == TodoStatus.working) {
        return false;
      }
      if (_status == TodoStatus.working && status == TodoStatus.pending) {
        return false;
      }
      return true;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 8.0;
        const minOptionWidth = 120.0;

        var columns = (constraints.maxWidth / minOptionWidth).floor();
        if (columns < 1) {
          columns = 1;
        }
        if (columns > options.length) {
          columns = options.length;
        }

        final optionWidth =
            (constraints.maxWidth - (spacing * (columns - 1))) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final option in options)
              SizedBox(
                width: optionWidth,
                child: Semantics(
                  selected: _status == option.status,
                  child: TextButton(
                    onPressed: isSelectable(option.status)
                        ? () => _onStatusChanged(option.status)
                        : null,
                    style:
                        TextButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          foregroundColor: _status == option.status
                              ? theme.colorScheme.onPrimaryContainer
                              : theme.colorScheme.onSurfaceVariant,
                          backgroundColor: _status == option.status
                              ? theme.colorScheme.primaryContainer
                              : theme.colorScheme.surface,
                          disabledForegroundColor: theme.colorScheme.onSurface
                              .withValues(alpha: 0.38),
                          disabledBackgroundColor: theme
                              .colorScheme
                              .surfaceContainerHighest
                              .withValues(alpha: 0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ).copyWith(
                          side: WidgetStateProperty.resolveWith((states) {
                            final isDisabled = states.contains(
                              WidgetState.disabled,
                            );
                            return BorderSide(
                              color: isDisabled
                                  ? theme.colorScheme.outlineVariant.withValues(
                                      alpha: 0.5,
                                    )
                                  : _status == option.status
                                  ? theme.colorScheme.primary.withValues(
                                      alpha: 0.28,
                                    )
                                  : theme.colorScheme.outlineVariant,
                            );
                          }),
                        ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(option.icon, size: 18),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            option.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildSubTaskCard() {
    final theme = Theme.of(context);
    final completedCount = _subTasks.where((st) => st.isCompleted).length;
    return AppSectionCard(
      title: context.l10n.subTasks,
      subtitle: _subTasks.isNotEmpty
          ? '$completedCount/${_subTasks.length}'
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!_isReadOnly)
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _newSubTaskController,
                    decoration: InputDecoration(
                      hintText: context.l10n.addSubTask,
                      isDense: true,
                    ),
                    onFieldSubmitted: (_) => _addSubTask(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  icon: const Icon(Icons.add_rounded),
                  onPressed: _addSubTask,
                ),
              ],
            ),
          if (_subTasks.isNotEmpty) ...[
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _subTasks.length,
              separatorBuilder: (_, _) => const Divider(height: 8),
              itemBuilder: (context, index) {
                final item = _subTasks[index];
                return Row(
                  children: [
                    Checkbox(
                      value: item.isCompleted,
                      onChanged: _isReadOnly
                          ? null
                          : (val) {
                              setState(() {
                                _subTasks[index] = item.copyWith(
                                  isCompleted: val ?? false,
                                );
                              });
                            },
                    ),
                    Expanded(
                      child: Text(
                        item.title,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          decoration: item.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                    ),
                    if (!_isReadOnly)
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18),
                        onPressed: () {
                          setState(() {
                            _subTasks.removeAt(index);
                          });
                        },
                      ),
                  ],
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  void _addSubTask() {
    final text = _newSubTaskController.text.trim();
    if (text.isEmpty) return;
    final now = DateTime.now().toUtc().toIso8601String();
    setState(() {
      _subTasks.add(
        SubTaskItem(
          id: _uuid.v4(),
          todoId: widget.todoId ?? '',
          title: unicode_utils.nfcNormalize(text),
          sortOrder: _subTasks.length,
          createdAt: now,
          updatedAt: now,
        ),
      );
      _newSubTaskController.clear();
    });
  }

  Widget _buildPrerequisitesCard() {
    return AppSectionCard(
      title: context.l10n.prerequisiteTasks,
      subtitle: '${_prerequisiteTodoIds.length} selected',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _availablePrerequisites.map((todo) {
          final isSelected = _prerequisiteTodoIds.contains(todo.id);
          return FilterChip(
            selected: isSelected,
            label: Text(todo.title),
            avatar: isSelected
                ? const Icon(Icons.check_rounded, size: 16)
                : const Icon(Icons.link_rounded, size: 16),
            onSelected: _isReadOnly
                ? null
                : (selected) {
                    setState(() {
                      if (selected) {
                        _prerequisiteTodoIds.add(todo.id);
                      } else {
                        _prerequisiteTodoIds.remove(todo.id);
                      }
                    });
                  },
          );
        }).toList(),
      ),
    );
  }
}

enum _EndMode { never, onDate, forDays }

class _StatusOption {
  const _StatusOption({
    required this.status,
    required this.label,
    required this.icon,
  });

  final TodoStatus status;
  final String label;
  final IconData icon;
}
