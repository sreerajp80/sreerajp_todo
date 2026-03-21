import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:sreerajp_todo/application/providers.dart';
import 'package:sreerajp_todo/core/constants/app_constants.dart';
import 'package:sreerajp_todo/core/constants/app_strings.dart';
import 'package:sreerajp_todo/core/utils/date_utils.dart';
import 'package:sreerajp_todo/core/utils/unicode_utils.dart' as unicode_utils;
import 'package:sreerajp_todo/data/models/todo_entity.dart';
import 'package:sreerajp_todo/data/models/todo_status.dart';
import 'package:sreerajp_todo/presentation/screens/create_edit_todo/widgets/title_autocomplete_field.dart';
import 'package:sreerajp_todo/presentation/shared/widgets/confirm_dialog.dart';

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
        setState(() {
          _existingTodo = todo;
          _titleController.text = todo.title;
          _descriptionController.text = todo.description ?? '';
          _status = todo.status;
          _portedTo = todo.portedTo;
          _effectiveDate = todo.date;
          _isLoading = false;
        });
      } else {
        if (mounted) setState(() => _isLoading = false);
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
    if (!_formKey.currentState!.validate()) return;
    if (_uniquenessError != null) return;

    setState(() => _isSaving = true);

    try {
      final now = DateTime.now().toUtc().toIso8601String();
      final normalizedTitle =
          unicode_utils.nfcNormalize(_titleController.text.trim());
      final description = _descriptionController.text.trim().isEmpty
          ? null
          : unicode_utils.nfcNormalize(_descriptionController.text.trim());

      if (widget.isEditing && _existingTodo != null) {
        final updated = _existingTodo!.copyWith(
          title: normalizedTitle,
          description: description,
          status: _status,
          portedTo: _status == TodoStatus.ported ? _portedTo : null,
          updatedAt: now,
        );
        final notifier =
            ref.read(dailyTodoProvider(_effectiveDate).notifier);
        await notifier.updateTodo(updated);
      } else {
        final todo = TodoEntity(
          id: _uuid.v4(),
          date: _effectiveDate,
          title: normalizedTitle,
          description: description,
          status: _status,
          portedTo: _status == TodoStatus.ported ? _portedTo : null,
          sortOrder: 0,
          createdAt: now,
          updatedAt: now,
        );
        final notifier =
            ref.read(dailyTodoProvider(_effectiveDate).notifier);
        await notifier.createTodo(todo);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isEditing
                  ? AppStrings.todoUpdated
                  : AppStrings.todoCreated,
            ),
          ),
        );
        context.pop();
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _onStatusChanged(TodoStatus? newStatus) async {
    if (newStatus == null || _isReadOnly) return;

    if (newStatus == TodoStatus.dropped) {
      final confirmed = await showConfirmDialog(
        context,
        title: AppStrings.confirmDrop,
        content: AppStrings.confirmDropBody,
      );
      if (!confirmed || !mounted) return;
    }

    if (newStatus == TodoStatus.ported && widget.isEditing) {
      final confirmed = await showConfirmDialog(
        context,
        title: AppStrings.confirmPort,
        content: AppStrings.confirmPortBody,
      );
      if (!confirmed || !mounted) return;

      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final picked = await showDatePicker(
        context: context,
        initialDate: tomorrow,
        firstDate: tomorrow,
        lastDate: DateTime.now().add(const Duration(days: 365)),
        helpText: AppStrings.selectTargetDate,
      );
      if (picked == null || !mounted) return;

      final targetDate = dateTimeToIso(picked);
      try {
        final notifier =
            ref.read(dailyTodoProvider(_effectiveDate).notifier);
        await notifier.portTodo(_existingTodo!.id, targetDate);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text(AppStrings.todoPorted)),
          );
          context.pop();
        }
      } on Exception catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString())),
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
    final title = widget.isEditing ? AppStrings.editTodo : AppStrings.createTodo;
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
                padding: const EdgeInsets.only(top: 4, left: 12),
                child: Text(
                  _uniquenessError!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            _buildDescriptionField(theme),
            const SizedBox(height: 24),
            _buildStatusSelector(theme),
            if (_status == TodoStatus.ported && _portedTo != null) ...[
              const SizedBox(height: 8),
              Text(
                '${AppStrings.portedTo}: $_portedTo',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFFF9A825),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: 24),
            if (_existingTodo?.sourceDate != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  '${AppStrings.copiedFrom} ${_existingTodo!.sourceDate}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            if (!_isReadOnly)
              FilledButton.icon(
                onPressed: _isSaving ? null : _save,
                icon: _isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: const Text(AppStrings.save),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionField(ThemeData theme) {
    final text = _descriptionController.text;
    final textDir = unicode_utils.detectTextDirection(text);
    final flutterDir = textDir == unicode_utils.TextDirection.rtl
        ? TextDirection.rtl
        : TextDirection.ltr;

    return TextFormField(
      controller: _descriptionController,
      enabled: !_isReadOnly,
      textDirection: flutterDir,
      maxLines: 4,
      decoration: const InputDecoration(
        labelText: AppStrings.descriptionHint,
        prefixIcon: Icon(Icons.notes),
        alignLabelWithHint: true,
      ),
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _buildStatusSelector(ThemeData theme) {
    return SegmentedButton<TodoStatus>(
      segments: [
        const ButtonSegment(
          value: TodoStatus.pending,
          label: Text(AppStrings.statusPending),
          icon: Icon(Icons.radio_button_unchecked),
        ),
        const ButtonSegment(
          value: TodoStatus.completed,
          label: Text(AppStrings.statusCompleted),
          icon: Icon(Icons.check_circle_outline),
        ),
        const ButtonSegment(
          value: TodoStatus.dropped,
          label: Text(AppStrings.statusDropped),
          icon: Icon(Icons.cancel_outlined),
        ),
        if (widget.isEditing)
          const ButtonSegment(
            value: TodoStatus.ported,
            label: Text(AppStrings.statusPorted),
            icon: Icon(Icons.arrow_forward),
          ),
      ],
      selected: {_status},
      onSelectionChanged: _isReadOnly
          ? null
          : (selected) => _onStatusChanged(selected.first),
    );
  }
}
