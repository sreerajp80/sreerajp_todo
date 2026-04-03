import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:sreerajp_todo/application/providers.dart';
import 'package:sreerajp_todo/core/constants/app_constants.dart';
import 'package:sreerajp_todo/core/constants/app_strings.dart';
import 'package:sreerajp_todo/core/errors/error_message_mapper.dart';
import 'package:sreerajp_todo/core/utils/date_utils.dart';
import 'package:sreerajp_todo/core/utils/unicode_utils.dart' as unicode_utils;
import 'package:sreerajp_todo/data/models/todo_entity.dart';
import 'package:sreerajp_todo/data/models/todo_status.dart';
import 'package:sreerajp_todo/data/models/recurrence_rule_entity.dart';
import 'package:sreerajp_todo/presentation/screens/create_edit_todo/widgets/repeat_option_picker.dart';
import 'package:sreerajp_todo/presentation/screens/create_edit_todo/widgets/title_autocomplete_field.dart';
import 'package:sreerajp_todo/presentation/screens/recurring_tasks/widgets/rrule_frequency_picker.dart';
import 'package:sreerajp_todo/presentation/screens/recurring_tasks/widgets/rrule_preview.dart';
import 'package:sreerajp_todo/presentation/shared/widgets/adaptive_directionality.dart';
import 'package:sreerajp_todo/presentation/shared/widgets/app_section_card.dart';
import 'package:sreerajp_todo/presentation/shared/widgets/confirm_dialog.dart';
import 'package:sreerajp_todo/core/utils/rrule_display_utils.dart';

class CreateEditTodoScreen extends ConsumerStatefulWidget {
  const CreateEditTodoScreen({super.key, this.todoId, this.date});

  final String? todoId;
  final String? date;

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
  final _titleFocusNode = FocusNode();

  TodoStatus _status = TodoStatus.pending;
  String? _portedTo;
  String _effectiveDate = '';
  TodoEntity? _existingTodo;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _uniquenessError;
  Timer? _uniquenessDebounce;

  // Repeat / recurrence state
  SimpleRepeatOption _repeatOption = SimpleRepeatOption.none;
  RruleFrequency _customFrequency = RruleFrequency.daily;
  int _customInterval = 1;
  Set<int> _customWeekDays = {};
  String? _customEndDate;
  bool _hasCustomEndDate = false;
  RecurrenceRuleEntity? _existingRule;

  bool get _isPast => isPastDate(_effectiveDate);
  bool get _isReadOnly => _isPast;

  @override
  void initState() {
    super.initState();
    _effectiveDate = widget.date ?? todayAsIso();
    _loadData();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _titleFocusNode.dispose();
    _uniquenessDebounce?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (widget.isEditing) {
      final repo = ref.read(todoRepositoryProvider);
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
          _portedTo = todo.portedTo;
          _effectiveDate = todo.date;
          if (rule != null) {
            _existingRule = rule;
            _repeatOption = SimpleRepeatOption.repeat;
            _parseRruleIntoFields(rule.rrule);
            _hasCustomEndDate = rule.endDate != null;
            _customEndDate = rule.endDate;
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
            _uniquenessError = exists ? AppStrings.errors.duplicateTitle : null;
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
          portedTo: _status == TodoStatus.ported ? _portedTo : null,
          recurrenceRuleId: recurrenceRuleId,
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
          portedTo: _status == TodoStatus.ported ? _portedTo : null,
          recurrenceRuleId: recurrenceRuleId,
          sortOrder: 0,
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
                  ? AppStrings.todoUpdated
                  : _repeatOption != SimpleRepeatOption.none
                  ? AppStrings.recurrenceCreated
                  : AppStrings.todoCreated,
            ),
          ),
        );
        context.pop();
      }
    } on Exception catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(mapErrorToMessage(error))));
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

    if (newStatus == TodoStatus.dropped) {
      final confirmed = await showConfirmDialog(
        context,
        title: AppStrings.confirmDrop,
        content: AppStrings.confirmDropBody,
      );
      if (!confirmed || !mounted) {
        return;
      }
    }

    if (newStatus == TodoStatus.ported && widget.isEditing) {
      final confirmed = await showConfirmDialog(
        context,
        title: AppStrings.confirmPort,
        content: AppStrings.confirmPortBody,
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
        helpText: AppStrings.selectTargetDate,
      );
      if (picked == null || !mounted) {
        return;
      }

      final targetDate = dateTimeToIso(picked);
      try {
        final notifier = ref.read(dailyTodoProvider(_effectiveDate).notifier);
        await notifier.portTodo(_existingTodo!.id, targetDate);
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text(AppStrings.todoPorted)));
          context.pop();
        }
      } on Exception catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(mapErrorToMessage(error))));
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
        ? AppStrings.viewTodo
        : widget.isEditing
        ? AppStrings.editTodo
        : AppStrings.createTodo;
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
                    AppStrings.readOnlyPastDate,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AppSectionCard(
              title: AppStrings.details,
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
                        return AppStrings.titleRequired;
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
                        '${AppStrings.copiedFrom} ${_existingTodo!.sourceDate}',
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
            if (!_isReadOnly) ...[
              const SizedBox(height: 16),
              AppSectionCard(
                title: AppStrings.repeat,
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
              title: AppStrings.taskStatus,
              subtitle: widget.isEditing
                  ? AppStrings.editTodo
                  : AppStrings.createTodo,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusSelector(),
                  if (_status == TodoStatus.ported && _portedTo != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      '${AppStrings.portedTo}: $_portedTo',
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
                label: const Text(AppStrings.save),
              ),
          ],
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
    var hasEnd = _hasCustomEndDate;
    var endDate = _customEndDate;

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
              RruleFrequency.daily => AppStrings.days,
              RruleFrequency.weekly => AppStrings.weeks,
              RruleFrequency.monthly => AppStrings.months,
              RruleFrequency.yearly => AppStrings.years,
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
                        AppStrings.frequency,
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
                            '${AppStrings.every} ',
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
                          AppStrings.daysOfWeek,
                          style: theme.textTheme.titleSmall,
                        ),
                        const SizedBox(height: 8),
                        _buildSheetDayOfWeekPicker(weekDays, setSheetState),
                      ],
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Text(
                            AppStrings.endDate,
                            style: theme.textTheme.titleSmall,
                          ),
                          const SizedBox(width: 8),
                          Switch(
                            value: hasEnd,
                            onChanged: (v) {
                              setSheetState(() {
                                hasEnd = v;
                                if (v && endDate == null) {
                                  endDate = _effectiveDate;
                                }
                              });
                            },
                          ),
                          if (!hasEnd)
                            Text(
                              AppStrings.noEndDate,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                        ],
                      ),
                      if (hasEnd) ...[
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
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text(AppStrings.save),
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
        _hasCustomEndDate = hasEnd;
        _customEndDate = endDate;
      });
    }
  }

  Widget _buildSheetDayOfWeekPicker(
    Set<int> weekDays,
    StateSetter setSheetState,
  ) {
    const dayLabels = [
      (DateTime.monday, AppStrings.monday),
      (DateTime.tuesday, AppStrings.tuesday),
      (DateTime.wednesday, AppStrings.wednesday),
      (DateTime.thursday, AppStrings.thursday),
      (DateTime.friday, AppStrings.friday),
      (DateTime.saturday, AppStrings.saturday),
      (DateTime.sunday, AppStrings.sunday),
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
        decoration: const InputDecoration(
          labelText: AppStrings.descriptionHint,
          prefixIcon: Icon(Icons.notes_rounded),
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
        const _StatusOption(
          status: TodoStatus.working,
          label: AppStrings.statusWorking,
          icon: Icons.play_circle_fill_rounded,
        ),
      if (_status != TodoStatus.working)
        const _StatusOption(
          status: TodoStatus.pending,
          label: AppStrings.statusPending,
          icon: Icons.radio_button_unchecked,
        ),
      const _StatusOption(
        status: TodoStatus.completed,
        label: AppStrings.statusCompleted,
        icon: Icons.check_circle_outline,
      ),
      const _StatusOption(
        status: TodoStatus.dropped,
        label: AppStrings.statusDropped,
        icon: Icons.cancel_outlined,
      ),
      if (widget.isEditing)
        const _StatusOption(
          status: TodoStatus.ported,
          label: AppStrings.statusPorted,
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
}

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
