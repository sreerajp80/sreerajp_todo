import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sreerajp_todo/application/providers.dart';
import 'package:sreerajp_todo/core/utils/date_utils.dart';
import 'package:sreerajp_todo/data/models/todo_entity.dart';
import 'package:sreerajp_todo/data/models/todo_status.dart';
import 'package:sreerajp_todo/l10n/app_localizations.dart';

/// Modal dialog allowing users to paste raw Markdown checklist text with live parse preview.
class MarkdownImportDialog extends ConsumerStatefulWidget {
  final String targetDate;

  const MarkdownImportDialog({
    super.key,
    required this.targetDate,
  });

  @override
  ConsumerState<MarkdownImportDialog> createState() =>
      _MarkdownImportDialogState();
}

class _MarkdownImportDialogState
    extends ConsumerState<MarkdownImportDialog> {
  final _textController = TextEditingController();
  List<TodoEntity> _parsedTodos = [];
  bool _isImporting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
    _textController.text = '''- [ ] Plan weekly priorities
  - [ ] Task scoping
  - [x] Review backlog
- [x] Complete project status report
  > Formatted markdown notes included
- [ ] Draft client timecard summary''';
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final text = _textController.text;
    final handoffService = ref.read(dataHandoffServiceProvider);
    final parsed = handoffService.parseMarkdownChecklist(
      text,
      targetDate: widget.targetDate,
    );
    setState(() {
      _parsedTodos = parsed;
      _errorMessage = null;
    });
  }

  Future<void> _handleImport() async {
    if (_parsedTodos.isEmpty) return;

    setState(() {
      _isImporting = true;
      _errorMessage = null;
    });

    try {
      final handoffService = ref.read(dataHandoffServiceProvider);
      final todoRepo = ref.read(todoRepositoryProvider);
      final segmentRepo = ref.read(timeSegmentRepositoryProvider);

      final payload = ref.read(dataHandoffServiceProvider).parseJsonPayload(
            ref.read(dataHandoffServiceProvider).exportToJson(
                  todos: _parsedTodos,
                  timeSegments: [],
                  recurrenceRules: [],
                  date: widget.targetDate,
                ),
          );

      final count = await handoffService.importPayload(
        payload,
        targetDate: widget.targetDate,
        todoRepo: todoRepo,
        segmentRepo: segmentRepo,
      );

      // Refresh daily list state
      ref.invalidate(dailyTodoProvider(widget.targetDate));

      if (mounted) {
        Navigator.of(context).pop(count);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isImporting = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isPast = isPastDate(widget.targetDate);

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.code_rounded, color: theme.colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              l10n.markdownImportTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Target Date: ${widget.targetDate}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _textController,
                maxLines: 7,
                minLines: 4,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                decoration: InputDecoration(
                  hintText: '- [ ] Task title\n  - [ ] Subtask title\n  > Note',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.parseMarkdownPreview,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Chip(
                    label: Text('${_parsedTodos.length} tasks'),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_parsedTodos.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'No `- [ ]` or `- [x]` checklist items detected.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              else
                Container(
                  constraints: const BoxConstraints(maxHeight: 180),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: _parsedTodos.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = _parsedTodos[index];
                      final isCompleted = item.status == TodoStatus.completed;
                      return ListTile(
                        dense: true,
                        leading: Icon(
                          isCompleted
                              ? Icons.check_box_rounded
                              : Icons.check_box_outline_blank_rounded,
                          color: isCompleted
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurfaceVariant,
                          size: 20,
                        ),
                        title: Text(
                          item.title,
                          style: TextStyle(
                            decoration: isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: item.subTasks.isNotEmpty
                            ? Text('${item.subTasks.length} subtasks')
                            : (item.description != null
                                ? Text(
                                    item.description!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  )
                                : null),
                      );
                    },
                  ),
                ),
              if (isPast) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.lock_rounded,
                        color: theme.colorScheme.onErrorContainer,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Past dates are day-locked. Choose today or a future date to import.',
                          style: TextStyle(
                            color: theme.colorScheme.onErrorContainer,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  _errorMessage!,
                  style: TextStyle(color: theme.colorScheme.error, fontSize: 12),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: Text(l10n.cancel),
        ),
        FilledButton.icon(
          onPressed:
              (_parsedTodos.isNotEmpty && !isPast && !_isImporting)
                  ? _handleImport
                  : null,
          icon: _isImporting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.download_rounded, size: 18),
          label: Text(l10n.save),
        ),
      ],
    );
  }
}
