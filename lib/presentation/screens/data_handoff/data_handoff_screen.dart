import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:sreerajp_todo/application/providers.dart';
import 'package:sreerajp_todo/core/utils/date_utils.dart';
import 'package:sreerajp_todo/data/models/time_segment_entity.dart';
import 'package:sreerajp_todo/domain/entities/data_handoff_payload.dart';
import 'package:sreerajp_todo/l10n/app_localizations.dart';
import 'package:sreerajp_todo/presentation/screens/data_handoff/widgets/markdown_import_dialog.dart';

/// Screen facilitating offline multi-format JSON payload and Markdown checklist export and ingestion.
class DataHandoffScreen extends ConsumerStatefulWidget {
  const DataHandoffScreen({super.key});

  @override
  ConsumerState<DataHandoffScreen> createState() => _DataHandoffScreenState();
}

class _DataHandoffScreenState extends ConsumerState<DataHandoffScreen> {
  late String _targetDate;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _targetDate = todayAsIso();
  }

  Future<void> _selectDate() async {
    final initialDate = DateTime.tryParse(_targetDate) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() {
        _targetDate = dateTimeToIso(picked);
      });
    }
  }

  Future<void> _handleExportJson() async {
    setState(() => _isProcessing = true);
    try {
      final todoRepo = ref.read(todoRepositoryProvider);
      final segmentRepo = ref.read(timeSegmentRepositoryProvider);
      final ruleRepo = ref.read(recurrenceRuleRepositoryProvider);
      final handoffService = ref.read(dataHandoffServiceProvider);

      final todos = await todoRepo.getTodosByDate(_targetDate);
      final segments = <TimeSegmentEntity>[];
      for (final t in todos) {
        final todoSegs = await segmentRepo.getSegments(t.id);
        segments.addAll(todoSegs);
      }
      final rules = await ruleRepo.findAll();

      final jsonString = handoffService.exportToJson(
        todos: todos,
        timeSegments: segments,
        recurrenceRules: rules,
        date: _targetDate,
      );

      final fileName = 'sreerajp_todo_data_$_targetDate.json';
      final savedPath = await handoffService.exportToFile(
        content: jsonString,
        defaultFileName: fileName,
      );

      if (mounted && savedPath != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export saved to ${p.basename(savedPath)}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _handleExportMarkdown() async {
    setState(() => _isProcessing = true);
    try {
      final todoRepo = ref.read(todoRepositoryProvider);
      final segmentRepo = ref.read(timeSegmentRepositoryProvider);
      final handoffService = ref.read(dataHandoffServiceProvider);

      final todos = await todoRepo.getTodosByDate(_targetDate);
      final segments = <TimeSegmentEntity>[];
      for (final t in todos) {
        final todoSegs = await segmentRepo.getSegments(t.id);
        segments.addAll(todoSegs);
      }

      final mdString = handoffService.exportToMarkdown(
        todos: todos,
        timeSegments: segments,
        date: _targetDate,
      );

      // Offer options: Save to File or Copy to Clipboard
      if (!mounted) return;
      showModalBottomSheet(
        context: context,
        builder: (ctx) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.file_download_outlined),
                title: const Text('Save Markdown File (.md)'),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  final fileName = 'sreerajp_todo_checklist_$_targetDate.md';
                  final savedPath = await handoffService.exportToFile(
                    content: mdString,
                    defaultFileName: fileName,
                  );
                  if (mounted && savedPath != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Saved to ${p.basename(savedPath)}'),
                      ),
                    );
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.copy_rounded),
                title: const Text('Copy Markdown to Clipboard'),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  await Clipboard.setData(ClipboardData(text: mdString));
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Markdown copied to clipboard.'),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _handleImportFile() async {
    final isPast = isPastDate(_targetDate);
    if (isPast) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Target date is past (day-locked). Select today or a future date to import.',
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);
    try {
      final handoffService = ref.read(dataHandoffServiceProvider);
      final fileResult = await handoffService.pickAndReadImportFile();

      if (fileResult == null) {
        setState(() => _isProcessing = false);
        return;
      }

      final extension = p.extension(fileResult.fileName).toLowerCase();
      final todoRepo = ref.read(todoRepositoryProvider);
      final segmentRepo = ref.read(timeSegmentRepositoryProvider);

      int importedCount = 0;

      if (extension == '.json') {
        final payload = handoffService.parseJsonPayload(fileResult.content);
        importedCount = await handoffService.importPayload(
          payload,
          targetDate: _targetDate,
          todoRepo: todoRepo,
          segmentRepo: segmentRepo,
        );
      } else {
        // .md or .txt checklist format
        final todos = handoffService.parseMarkdownChecklist(
          fileResult.content,
          targetDate: _targetDate,
        );
        final payload = DataHandoffPayload(
          date: _targetDate,
          exportedAt: DateTime.now().toIso8601String(),
          todos: todos,
        );
        importedCount = await handoffService.importPayload(
          payload,
          targetDate: _targetDate,
          todoRepo: todoRepo,
          segmentRepo: segmentRepo,
        );
      }

      ref.invalidate(dailyTodoProvider(_targetDate));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Successfully imported $importedCount tasks onto $_targetDate.',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Import failed: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _handlePasteMarkdown() async {
    final result = await showDialog<int?>(
      context: context,
      builder: (ctx) => MarkdownImportDialog(targetDate: _targetDate),
    );

    if (result != null && result > 0 && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Imported $result tasks onto $_targetDate.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isPast = isPastDate(_targetDate);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.dataHandoffHeader)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Banner Card
            Card(
              elevation: 0,
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: theme.colorScheme.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.swap_horiz_rounded,
                        color: theme.colorScheme.onPrimary,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.dataHandoffTitle,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.dataHandoffSubtitle,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Target Date Bar
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
              child: ListTile(
                leading: Icon(
                  Icons.calendar_month_rounded,
                  color: theme.colorScheme.primary,
                ),
                title: Text(
                  l10n.targetDateLabel,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                subtitle: Text(
                  _targetDate,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isPast)
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Chip(
                          avatar: const Icon(Icons.lock_rounded, size: 14),
                          label: const Text('Day Locked'),
                          visualDensity: VisualDensity.compact,
                          backgroundColor: theme.colorScheme.errorContainer,
                          labelStyle: TextStyle(
                            color: theme.colorScheme.onErrorContainer,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    OutlinedButton(
                      onPressed: _selectDate,
                      child: Text(l10n.actionChange),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Export Actions Section
            Text(
              'Export Data Options',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.data_object_rounded),
                    title: Text(l10n.exportJsonLabel),
                    subtitle: Text(l10n.exportJsonDesc),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: _isProcessing ? null : _handleExportJson,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.checklist_rounded),
                    title: Text(l10n.exportMarkdownLabel),
                    subtitle: Text(l10n.exportMarkdownDesc),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: _isProcessing ? null : _handleExportMarkdown,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Import Actions Section
            Text(
              'Ingest & Import Options',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.file_open_rounded),
                    title: Text(l10n.importFileLabel),
                    subtitle: Text(l10n.importFileDesc),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: (_isProcessing || isPast) ? null : _handleImportFile,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.edit_note_rounded),
                    title: Text(l10n.pasteMarkdownLabel),
                    subtitle: Text(l10n.pasteMarkdownDesc),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: (_isProcessing || isPast)
                        ? null
                        : _handlePasteMarkdown,
                  ),
                ],
              ),
            ),

            if (_isProcessing) ...[
              const SizedBox(height: 24),
              const Center(child: CircularProgressIndicator()),
            ],
          ],
        ),
      ),
    );
  }
}
