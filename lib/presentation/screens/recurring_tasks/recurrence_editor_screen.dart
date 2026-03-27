import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sreerajp_todo/application/providers.dart';
import 'package:sreerajp_todo/core/constants/app_strings.dart';
import 'package:sreerajp_todo/core/utils/date_utils.dart';
import 'package:sreerajp_todo/core/errors/error_message_mapper.dart';
import 'package:sreerajp_todo/data/models/recurrence_rule_entity.dart';
import 'package:sreerajp_todo/presentation/screens/create_edit_todo/widgets/title_autocomplete_field.dart';
import 'package:sreerajp_todo/presentation/screens/recurring_tasks/widgets/rrule_frequency_picker.dart';
import 'package:sreerajp_todo/presentation/screens/recurring_tasks/widgets/rrule_preview.dart';
import 'package:sreerajp_todo/presentation/shared/widgets/adaptive_directionality.dart';
import 'package:uuid/uuid.dart';

class RecurrenceEditorScreen extends ConsumerStatefulWidget {
  const RecurrenceEditorScreen({super.key, this.ruleId});

  final String? ruleId;

  bool get isEditing => ruleId != null;

  @override
  ConsumerState<RecurrenceEditorScreen> createState() =>
      _RecurrenceEditorScreenState();
}

class _RecurrenceEditorScreenState
    extends ConsumerState<RecurrenceEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _titleFocusNode = FocusNode();
  final _intervalController = TextEditingController(text: '1');

  RruleFrequency _frequency = RruleFrequency.daily;
  Set<int> _selectedWeekDays = {};
  int _dayOfMonth = 1;
  bool _useOrdinalWeekday = false;
  int _ordinalPosition = 1;
  int _ordinalWeekday = DateTime.monday;
  int _yearlyMonth = 1;
  int _yearlyDay = 1;
  String _startDate = todayAsIso();
  String? _endDate;
  bool _hasEndDate = false;
  bool _isLoading = false;

  RecurrenceRuleEntity? _existingRule;

  static const _uuid = Uuid();

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      _loadExistingRule();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _titleFocusNode.dispose();
    _intervalController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingRule() async {
    final notifier = ref.read(recurrenceRulesProvider.notifier);
    final rule = await notifier.findById(widget.ruleId!);
    if (rule == null || !mounted) return;

    _existingRule = rule;
    _titleController.text = rule.title;
    _descriptionController.text = rule.description ?? '';
    _startDate = rule.startDate;
    _endDate = rule.endDate;
    _hasEndDate = rule.endDate != null;

    _parseRruleIntoFields(rule.rrule);
    setState(() {});
  }

  void _parseRruleIntoFields(String rruleStr) {
    final parts = <String, String>{};
    for (final part in rruleStr.split(';')) {
      final idx = part.indexOf('=');
      if (idx > 0) {
        parts[part.substring(0, idx)] = part.substring(idx + 1);
      }
    }

    final freq = parts['FREQ'] ?? 'DAILY';
    _frequency = switch (freq) {
      'WEEKLY' => RruleFrequency.weekly,
      'MONTHLY' => RruleFrequency.monthly,
      'YEARLY' => RruleFrequency.yearly,
      _ => RruleFrequency.daily,
    };

    _intervalController.text = parts['INTERVAL'] ?? '1';

    if (parts.containsKey('BYDAY') && _frequency == RruleFrequency.weekly) {
      _selectedWeekDays = parts['BYDAY']!
          .split(',')
          .map(_dayAbbrevToInt)
          .whereType<int>()
          .toSet();
    }

    if (_frequency == RruleFrequency.monthly) {
      if (parts.containsKey('BYDAY')) {
        final byDay = parts['BYDAY']!;
        final match = RegExp(r'^([+-]?\d+)(\w{2})$').firstMatch(byDay);
        if (match != null) {
          _useOrdinalWeekday = true;
          _ordinalPosition = int.tryParse(match.group(1)!) ?? 1;
          _ordinalWeekday = _dayAbbrevToInt(match.group(2)!) ?? DateTime.monday;
        }
      } else if (parts.containsKey('BYMONTHDAY')) {
        _dayOfMonth = int.tryParse(parts['BYMONTHDAY']!) ?? 1;
      }
    }

    if (_frequency == RruleFrequency.yearly) {
      if (parts.containsKey('BYMONTH')) {
        _yearlyMonth = int.tryParse(parts['BYMONTH']!) ?? 1;
      }
      if (parts.containsKey('BYMONTHDAY')) {
        _yearlyDay = int.tryParse(parts['BYMONTHDAY']!) ?? 1;
      }
    }
  }

  int? _dayAbbrevToInt(String abbrev) {
    return switch (abbrev.toUpperCase()) {
      'MO' => DateTime.monday,
      'TU' => DateTime.tuesday,
      'WE' => DateTime.wednesday,
      'TH' => DateTime.thursday,
      'FR' => DateTime.friday,
      'SA' => DateTime.saturday,
      'SU' => DateTime.sunday,
      _ => null,
    };
  }

  String _intToDayAbbrev(int day) {
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

  String _buildRruleString() {
    final parts = <String>[];
    final interval = int.tryParse(_intervalController.text) ?? 1;

    switch (_frequency) {
      case RruleFrequency.daily:
        parts.add('FREQ=DAILY');
        if (interval > 1) parts.add('INTERVAL=$interval');
      case RruleFrequency.weekly:
        parts.add('FREQ=WEEKLY');
        if (interval > 1) parts.add('INTERVAL=$interval');
        if (_selectedWeekDays.isNotEmpty) {
          final sorted = _selectedWeekDays.toList()..sort();
          parts.add('BYDAY=${sorted.map(_intToDayAbbrev).join(',')}');
        }
      case RruleFrequency.monthly:
        parts.add('FREQ=MONTHLY');
        if (interval > 1) parts.add('INTERVAL=$interval');
        if (_useOrdinalWeekday) {
          parts.add(
            'BYDAY=$_ordinalPosition${_intToDayAbbrev(_ordinalWeekday)}',
          );
        } else {
          parts.add('BYMONTHDAY=$_dayOfMonth');
        }
      case RruleFrequency.yearly:
        parts.add('FREQ=YEARLY');
        if (interval > 1) parts.add('INTERVAL=$interval');
        parts.add('BYMONTH=$_yearlyMonth');
        parts.add('BYMONTHDAY=$_yearlyDay');
    }

    return parts.join(';');
  }

  Future<void> _pickStartDate() async {
    final current = parseIsoDate(_startDate);
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _startDate = dateTimeToIso(picked));
    }
  }

  Future<void> _pickEndDate() async {
    final current = _endDate != null ? parseIsoDate(_endDate!) : DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: parseIsoDate(_startDate),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _endDate = dateTimeToIso(picked));
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_frequency == RruleFrequency.weekly && _selectedWeekDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.selectDaysOfWeek)),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final now = DateTime.now().toUtc().toIso8601String();
      final rruleStr = _buildRruleString();
      final notifier = ref.read(recurrenceRulesProvider.notifier);

      if (widget.isEditing && _existingRule != null) {
        final updated = _existingRule!.copyWith(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          rrule: rruleStr,
          startDate: _startDate,
          endDate: _hasEndDate ? _endDate : null,
          updatedAt: now,
        );
        await notifier.updateRule(updated);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text(AppStrings.recurrenceRuleUpdated)),
          );
        }
      } else {
        final rule = RecurrenceRuleEntity(
          id: _uuid.v4(),
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          rrule: rruleStr,
          startDate: _startDate,
          endDate: _hasEndDate ? _endDate : null,
          createdAt: now,
          updatedAt: now,
        );
        await notifier.createRule(rule);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text(AppStrings.recurrenceRuleSaved)),
          );
        }
      }

      if (mounted) context.pop();
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(mapErrorToMessage(e))));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = widget.isEditing
        ? AppStrings.editRecurrence
        : AppStrings.newRecurrence;
    final rruleStr = _buildRruleString();

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  TitleAutocompleteField(
                    controller: _titleController,
                    focusNode: _titleFocusNode,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return AppStrings.titleRequired;
                      }
                      return null;
                    },
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 16),
                  AdaptiveDirectionality(
                    text: _descriptionController.text,
                    child: TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: AppStrings.descriptionHint,
                        prefixIcon: Icon(Icons.description),
                        alignLabelWithHint: true,
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text(AppStrings.frequency, style: theme.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  RruleFrequencyPicker(
                    selected: _frequency,
                    onChanged: (freq) => setState(() {
                      _frequency = freq;
                      if (freq == RruleFrequency.weekly &&
                          _selectedWeekDays.isEmpty) {
                        _selectedWeekDays = {DateTime.now().weekday};
                      }
                    }),
                  ),
                  const SizedBox(height: 16),

                  _buildIntervalField(),
                  const SizedBox(height: 16),

                  if (_frequency == RruleFrequency.weekly) ...[
                    Text(
                      AppStrings.daysOfWeek,
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    _buildDayOfWeekPicker(),
                    const SizedBox(height: 16),
                  ],

                  if (_frequency == RruleFrequency.monthly) ...[
                    _buildMonthlyOptions(),
                    const SizedBox(height: 16),
                  ],

                  if (_frequency == RruleFrequency.yearly) ...[
                    _buildYearlyOptions(),
                    const SizedBox(height: 16),
                  ],

                  _buildDateSection(),
                  const SizedBox(height: 16),

                  RrulePreview(
                    rruleString: rruleStr,
                    startDate: _startDate,
                    endDate: _hasEndDate ? _endDate : null,
                  ),
                  const SizedBox(height: 24),

                  FilledButton.icon(
                    onPressed: _titleController.text.trim().isEmpty
                        ? null
                        : _save,
                    icon: const Icon(Icons.save),
                    label: const Text(AppStrings.save),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildIntervalField() {
    final unitLabel = switch (_frequency) {
      RruleFrequency.daily => AppStrings.days,
      RruleFrequency.weekly => AppStrings.weeks,
      RruleFrequency.monthly => AppStrings.months,
      RruleFrequency.yearly => AppStrings.years,
    };

    return Row(
      children: [
        Text(
          '${AppStrings.every} ',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        SizedBox(
          width: 60,
          child: TextFormField(
            controller: _intervalController,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            onChanged: (_) => setState(() {}),
            validator: (value) {
              final n = int.tryParse(value ?? '');
              if (n == null || n < 1) {
                return AppStrings.errors.intervalMustBeAtLeastOne;
              }
              return null;
            },
          ),
        ),
        const SizedBox(width: 8),
        Text(unitLabel, style: Theme.of(context).textTheme.bodyLarge),
      ],
    );
  }

  Widget _buildDayOfWeekPicker() {
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
        final selected = _selectedWeekDays.contains(day);
        return FilterChip(
          label: Text(label),
          selected: selected,
          onSelected: (value) {
            setState(() {
              if (value) {
                _selectedWeekDays.add(day);
              } else {
                _selectedWeekDays.remove(day);
              }
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildMonthlyOptions() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.dayOfMonth, style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: false, label: Text(AppStrings.specificDate)),
              ButtonSegment(
                value: true,
                label: Text(AppStrings.ordinalWeekday),
              ),
            ],
            selected: {_useOrdinalWeekday},
            onSelectionChanged: (s) =>
                setState(() => _useOrdinalWeekday = s.first),
          ),
        ),
        const SizedBox(height: 12),
        if (_useOrdinalWeekday)
          _buildOrdinalWeekdayPicker()
        else
          _buildDayOfMonthPicker(),
      ],
    );
  }

  Widget _buildDayOfMonthPicker() {
    return Row(
      children: [
        Text(' ', style: Theme.of(context).textTheme.bodyLarge),
        SizedBox(
          width: 80,
          child: DropdownButtonFormField<int>(
            initialValue: _dayOfMonth.clamp(1, 31),
            items: List.generate(
              31,
              (i) => DropdownMenuItem(value: i + 1, child: Text('${i + 1}')),
            ),
            onChanged: (v) => setState(() => _dayOfMonth = v ?? 1),
          ),
        ),
      ],
    );
  }

  Widget _buildOrdinalWeekdayPicker() {
    const ordinalLabels = [
      (1, AppStrings.first),
      (2, AppStrings.second),
      (3, AppStrings.third),
      (4, AppStrings.fourth),
      (-1, AppStrings.last),
    ];

    const weekdayLabels = [
      (DateTime.monday, AppStrings.mondayLong),
      (DateTime.tuesday, AppStrings.tuesdayLong),
      (DateTime.wednesday, AppStrings.wednesdayLong),
      (DateTime.thursday, AppStrings.thursdayLong),
      (DateTime.friday, AppStrings.fridayLong),
      (DateTime.saturday, AppStrings.saturdayLong),
      (DateTime.sunday, AppStrings.sundayLong),
    ];

    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<int>(
            initialValue: ordinalLabels.any((e) => e.$1 == _ordinalPosition)
                ? _ordinalPosition
                : 1,
            items: ordinalLabels
                .map((e) => DropdownMenuItem(value: e.$1, child: Text(e.$2)))
                .toList(),
            onChanged: (v) => setState(() => _ordinalPosition = v ?? 1),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: DropdownButtonFormField<int>(
            initialValue: _ordinalWeekday,
            items: weekdayLabels
                .map((e) => DropdownMenuItem(value: e.$1, child: Text(e.$2)))
                .toList(),
            onChanged: (v) =>
                setState(() => _ordinalWeekday = v ?? DateTime.monday),
          ),
        ),
      ],
    );
  }

  Widget _buildYearlyOptions() {
    const monthLabels = [
      (1, AppStrings.january),
      (2, AppStrings.february),
      (3, AppStrings.march),
      (4, AppStrings.april),
      (5, AppStrings.may),
      (6, AppStrings.june),
      (7, AppStrings.july),
      (8, AppStrings.august),
      (9, AppStrings.september),
      (10, AppStrings.october),
      (11, AppStrings.november),
      (12, AppStrings.december),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.month, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<int>(
                initialValue: _yearlyMonth,
                items: monthLabels
                    .map(
                      (e) => DropdownMenuItem(value: e.$1, child: Text(e.$2)),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _yearlyMonth = v ?? 1),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 80,
              child: DropdownButtonFormField<int>(
                initialValue: _yearlyDay.clamp(1, 31),
                items: List.generate(
                  31,
                  (i) =>
                      DropdownMenuItem(value: i + 1, child: Text('${i + 1}')),
                ),
                onChanged: (v) => setState(() => _yearlyDay = v ?? 1),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateSection() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.startDate, style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        InkWell(
          onTap: _pickStartDate,
          child: InputDecorator(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.calendar_today),
            ),
            child: Text(formatDateFromIso(_startDate)),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Text(AppStrings.endDate, style: theme.textTheme.titleSmall),
            const SizedBox(width: 8),
            Switch(
              value: _hasEndDate,
              onChanged: (v) {
                setState(() {
                  _hasEndDate = v;
                  if (v && _endDate == null) {
                    _endDate = _startDate;
                  }
                });
              },
            ),
            if (!_hasEndDate)
              Text(
                AppStrings.noEndDate,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
        if (_hasEndDate) ...[
          const SizedBox(height: 8),
          InkWell(
            onTap: _pickEndDate,
            child: InputDecorator(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.calendar_today),
              ),
              child: Text(formatDateFromIso(_endDate ?? _startDate)),
            ),
          ),
        ],
      ],
    );
  }
}
