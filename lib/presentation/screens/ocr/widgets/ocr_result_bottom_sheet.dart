import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sreerajp_todo/application/providers.dart';
import 'package:sreerajp_todo/core/constants/app_constants.dart';
import 'package:sreerajp_todo/core/extensions/localization_extensions.dart';
import 'package:sreerajp_todo/domain/entities/ocr_task_result.dart';

/// Interactive review sheet displaying OCR recognized task title and description.
///
/// Allows the user to inspect, edit, check title uniqueness, copy the raw text,
/// and either create the task directly, open the full task editor, or apply back
/// to the calling form.
class OcrResultBottomSheet extends ConsumerStatefulWidget {
  const OcrResultBottomSheet({
    super.key,
    required this.result,
    required this.date,
    this.returnResultDirectly = false,
    required this.onOpenEditor,
    required this.onRetake,
  });

  final OcrTaskResult result;
  final String date;
  final bool returnResultDirectly;
  final void Function(String title, String description) onOpenEditor;
  final VoidCallback onRetake;

  static Future<void> show({
    required BuildContext context,
    required OcrTaskResult result,
    required String date,
    bool returnResultDirectly = false,
    required void Function(String title, String description) onOpenEditor,
    required VoidCallback onRetake,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => OcrResultBottomSheet(
        result: result,
        date: date,
        returnResultDirectly: returnResultDirectly,
        onOpenEditor: onOpenEditor,
        onRetake: onRetake,
      ),
    );
  }

  @override
  ConsumerState<OcrResultBottomSheet> createState() =>
      _OcrResultBottomSheetState();
}

class _OcrResultBottomSheetState extends ConsumerState<OcrResultBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  String? _uniquenessError;
  Timer? _uniquenessDebounce;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.result.title);
    _descriptionController = TextEditingController(
      text: widget.result.description,
    );
    _checkTitleUniqueness(_titleController.text);
  }

  @override
  void dispose() {
    _uniquenessDebounce?.cancel();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _checkTitleUniqueness(String title) {
    _uniquenessDebounce?.cancel();
    final trimmed = title.trim();
    if (trimmed.isEmpty) {
      setState(() => _uniquenessError = null);
      return;
    }
    _uniquenessDebounce = Timer(
      const Duration(milliseconds: kAutocompleteDebounceMills),
      () async {
        final repo = ref.read(todoRepositoryProvider);
        final exists = await repo.titleExistsOnDate(trimmed, widget.date);
        if (mounted) {
          setState(() {
            _uniquenessError = exists ? context.l10n.errorDuplicateTitle : null;
          });
        }
      },
    );
  }

  void _handleOpenEditor() {
    if (!_formKey.currentState!.validate()) return;
    if (_uniquenessError != null) return;
    widget.onOpenEditor(
      _titleController.text.trim(),
      _descriptionController.text.trim(),
    );
  }

  void _swapFields() {
    final temp = _titleController.text;
    _titleController.text = _descriptionController.text;
    _descriptionController.text = temp;
    _checkTitleUniqueness(_titleController.text);
  }

  void _copyRawText() {
    Clipboard.setData(ClipboardData(text: widget.result.rawText));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.ocrRawTextCopied),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final systemBottomPadding = MediaQuery.paddingOf(context).bottom;
    final effectiveBottom =
        math.max(systemBottomPadding, 16.0) + bottomInset + 12.0;

    final screenH = MediaQuery.sizeOf(context).height;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: screenH * 0.92),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.fromLTRB(20, 12, 20, effectiveBottom),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.4,
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Title and header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(
                          alpha: 0.12,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.document_scanner,
                        color: theme.colorScheme.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.ocrReviewTitle,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            l10n.ocrScanSubtitle,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: l10n.tooltipClose,
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Task Name field
                TextFormField(
                  controller: _titleController,
                  autofocus: false,
                  decoration: InputDecoration(
                    labelText: l10n.ocrTaskNameLabel,
                    prefixIcon: const Icon(Icons.title),
                    errorText: _uniquenessError,
                    suffixIcon: _titleController.text.isNotEmpty
                        ? IconButton(
                            tooltip: l10n.tooltipClear,
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _titleController.clear();
                              _checkTitleUniqueness('');
                            },
                          )
                        : null,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.ocrTaskNameEmpty;
                    }
                    return null;
                  },
                  onChanged: _checkTitleUniqueness,
                ),
                const SizedBox(height: 8),

                // Interchange / Swap fields button
                Center(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      _swapFields();
                    },
                    icon: const Icon(Icons.swap_vert, size: 20),
                    label: Text(
                      l10n.ocrSwapFields,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.primary,
                      side: BorderSide(
                        color: theme.colorScheme.primary.withValues(
                          alpha: 0.35,
                        ),
                      ),
                      backgroundColor: theme.colorScheme.primary.withValues(
                        alpha: 0.08,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Description field
                TextFormField(
                  controller: _descriptionController,
                  minLines: 3,
                  maxLines: 6,
                  decoration: InputDecoration(
                    labelText: l10n.ocrDescriptionLabel,
                    alignLabelWithHint: true,
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(bottom: 48),
                      child: Icon(Icons.notes),
                    ),
                    suffixIcon: _descriptionController.text.isNotEmpty
                        ? IconButton(
                            tooltip: l10n.tooltipClear,
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () => _descriptionController.clear(),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 12),

                // Expandable Raw OCR Text card
                if (widget.result.rawText.isNotEmpty)
                  Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                    child: ExpansionTile(
                      shape: const RoundedRectangleBorder(),
                      collapsedShape: const RoundedRectangleBorder(),
                      leading: const Icon(Icons.text_fields, size: 20),
                      title: Text(
                        l10n.ocrRawTextTitle,
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.copy, size: 18),
                            tooltip: l10n.ocrRawTextCopied,
                            onPressed: _copyRawText,
                          ),
                          const Icon(Icons.expand_more),
                        ],
                      ),
                      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: SelectableText(
                            widget.result.rawText,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontFamily: 'monospace',
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 20),

                // Action buttons
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: widget.onRetake,
                      icon: const Icon(Icons.refresh, size: 18),
                      label: Text(l10n.ocrRetake),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _handleOpenEditor,
                        icon: Icon(
                          widget.returnResultDirectly
                              ? Icons.check
                              : Icons.arrow_forward,
                          size: 18,
                        ),
                        label: Text(
                          widget.returnResultDirectly
                              ? l10n.ocrApplyToForm
                              : l10n.ocrContinueToCreate,
                        ),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
