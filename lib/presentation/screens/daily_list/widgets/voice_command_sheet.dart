import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:sreerajp_todo/application/providers.dart';
import 'package:sreerajp_todo/application/voice_capture_state.dart';
import 'package:sreerajp_todo/core/constants/app_routes.dart';
import 'package:sreerajp_todo/core/errors/error_message_mapper.dart';
import 'package:sreerajp_todo/core/extensions/localization_extensions.dart';
import 'package:sreerajp_todo/core/platform/speech_channel.dart';
import 'package:sreerajp_todo/core/utils/date_utils.dart';
import 'package:sreerajp_todo/core/utils/duration_utils.dart';
import 'package:sreerajp_todo/core/utils/unicode_utils.dart' as unicode_utils;
import 'package:sreerajp_todo/core/voice/voice_parse_result.dart';
import 'package:sreerajp_todo/data/models/todo_entity.dart';
import 'package:sreerajp_todo/data/models/todo_priority.dart';
import 'package:sreerajp_todo/data/models/todo_status.dart';
import 'package:sreerajp_todo/l10n/app_localizations.dart';
import 'package:sreerajp_todo/presentation/shared/widgets/undo_status_snackbar.dart';

/// Which language the recogniser is asked to listen in.
enum _VoiceLanguage {
  english('en-IN'),
  malayalam('ml-IN');

  const _VoiceLanguage(this.localeTag);

  final String localeTag;
}

/// The floating sheet behind the microphone button on the day list.
///
/// One sentence in, one ready-made task out. Can create the task directly
/// with title uniqueness, Day-Lock, and NFC normalisation, or hand it over to
/// the create screen for full customization.
///
/// Where there is no microphone — Windows, an older phone, a phone with no
/// offline language pack — the sheet simply shows its text box, and the
/// parser works exactly the same on typed words.
class VoiceCommandSheet extends ConsumerStatefulWidget {
  const VoiceCommandSheet({
    super.key,
    required this.fallbackDate,
    this.returnResult = false,
  });

  /// The day the user was looking at.
  ///
  /// Used when the sentence names no day of its own, so opening the sheet on
  /// tomorrow's list and saying "buy milk" puts the task on tomorrow.
  final String fallbackDate;

  /// Whether to return the [VoiceParseResult] directly to the caller on completion.
  final bool returnResult;

  /// Opens the sheet over the day list or an edit screen.
  static Future<VoiceParseResult?> show(
    BuildContext context, {
    required String date,
    bool returnResult = false,
  }) {
    return showModalBottomSheet<VoiceParseResult?>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) =>
          VoiceCommandSheet(fallbackDate: date, returnResult: returnResult),
    );
  }

  @override
  ConsumerState<VoiceCommandSheet> createState() => _VoiceCommandSheetState();
}

class _VoiceCommandSheetState extends ConsumerState<VoiceCommandSheet> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  late _VoiceLanguage _language;
  bool _languageChosen = false;

  @override
  void initState() {
    super.initState();
    _language = _VoiceLanguage.english;
    // Asking the host what it can do takes a moment, so it is started before
    // the first frame rather than while the user waits on a tap.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(voiceCaptureProvider.notifier).prepare();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// Keeps the text box showing whatever the recogniser last heard.
  ///
  /// Only ever writes when the words really changed, or the caret would jump
  /// to the start every time the state rebuilt while the user was typing.
  void _syncController(String text) {
    if (_controller.text == text) return;
    _controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  Future<void> _toggleListening(VoiceCaptureState state) async {
    final notifier = ref.read(voiceCaptureProvider.notifier);
    if (state.stage == VoiceCaptureStage.listening) {
      await notifier.stopListening();
    } else {
      _focusNode.unfocus();
      await notifier.startListening(_language.localeTag);
    }
  }

  /// The day the task will land on.
  ///
  /// A sentence that named a day wins. One that named none keeps the day the
  /// user was already looking at, so opening tomorrow's list and saying
  /// "buy milk" does not quietly drop the task on today.
  String _effectiveDate(VoiceParseResult result) =>
      result.matched.contains(VoiceField.date)
      ? result.date
      : widget.fallbackDate;

  bool _isSaving = false;
  String? _duplicateError;

  void _onTextChanged(String text) {
    if (_duplicateError != null) {
      setState(() => _duplicateError = null);
    }
    ref.read(voiceCaptureProvider.notifier).setText(text);
  }

  /// Builds the final task description combining spoken description and time note.
  String? _buildFinalDescription(VoiceParseResult result) {
    final strings = context.l10n;
    final timeLabel = result.timeOfDayLabel;
    final timeNote = timeLabel == null
        ? null
        : unicode_utils.nfcNormalize(strings.voiceTimeNote(timeLabel));

    if (result.description != null && result.description!.isNotEmpty) {
      final normalizedDesc = unicode_utils.nfcNormalize(result.description!);
      if (timeNote != null) {
        return '$normalizedDesc\n\n$timeNote';
      }
      return normalizedDesc;
    }
    return timeNote;
  }

  /// Saves the task directly into the database, obeying Day-Lock, title uniqueness, and NFC normalization.
  Future<void> _saveTaskDirectly(VoiceParseResult result) async {
    if (widget.returnResult) {
      Navigator.of(context).pop(result);
      return;
    }

    final title = result.title.trim();
    if (title.isEmpty) return;

    final date = _effectiveDate(result);
    final normalizedTitle = unicode_utils.nfcNormalize(title);

    setState(() {
      _isSaving = true;
      _duplicateError = null;
    });

    try {
      final repo = ref.read(todoRepositoryProvider);
      final exists = await repo.titleExistsOnDate(normalizedTitle, date);
      if (exists) {
        if (!mounted) return;
        setState(() {
          _isSaving = false;
          _duplicateError = context.l10n.voiceDuplicateTitle;
        });
        return;
      }

      final finalDescription = _buildFinalDescription(result);
      final defaults = ref.read(taskDefaultsProvider);
      final priority = result.priority != null
          ? TodoPriority.values.byName(result.priority!.name)
          : defaults.priority;
      final targetSeconds = result.targetSeconds ?? defaults.targetTime.seconds;

      final now = DateTime.now().toUtc().toIso8601String();
      final todo = TodoEntity(
        id: const Uuid().v4(),
        date: date,
        title: normalizedTitle,
        description: finalDescription,
        status: TodoStatus.pending,
        priority: priority,
        targetSeconds: targetSeconds,
        sortOrder: 0,
        createdAt: now,
        updatedAt: now,
      );

      await repo.createTodo(todo);
      ref.invalidate(dailyTodoProvider(date));

      if (!mounted) return;
      Navigator.of(context).pop(result);
      showAppSnackBar(context, message: context.l10n.todoCreated);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _duplicateError = mapErrorToMessage(context.l10n, e);
      });
    }
  }

  /// Hands the reading over to the normal create screen.
  void _editInForm(VoiceParseResult result) {
    if (widget.returnResult) {
      Navigator.of(context).pop(result);
      return;
    }

    final path = AppRoutes.createTodoPath(
      date: _effectiveDate(result),
      title: result.title.trim(),
      description: _buildFinalDescription(result),
      targetSeconds: result.targetSeconds,
      priority: result.priority?.name,
    );

    Navigator.of(context).pop();
    context.push(path);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = context.l10n;
    final state = ref.watch(voiceCaptureProvider);
    final notifier = ref.read(voiceCaptureProvider.notifier);

    _syncController(state.text);

    // The sheet opens in whichever language the app itself is showing, unless
    // the user has already picked one here.
    if (!_languageChosen) {
      final localeCode = Localizations.localeOf(context).languageCode;
      _language = localeCode == 'ml'
          ? _VoiceLanguage.malayalam
          : _VoiceLanguage.english;
    }

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(strings.voiceSheetTitle, style: theme.textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(
                strings.voiceSheetOfflineNote,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              _LanguagePicker(
                value: _language,
                onChanged: (value) => setState(() {
                  _language = value;
                  _languageChosen = true;
                }),
              ),
              const SizedBox(height: 16),
              if (state.canListen)
                _MicrophoneButton(
                  isListening: state.stage == VoiceCaptureStage.listening,
                  onPressed: () => _toggleListening(state),
                ),
              if (state.canListen) const SizedBox(height: 16),
              TextField(
                controller: _controller,
                focusNode: _focusNode,
                minLines: 1,
                maxLines: 3,
                textInputAction: TextInputAction.done,
                textDirection: _directionOf(state.text),
                decoration: InputDecoration(
                  labelText: strings.voiceSheetFieldLabel,
                  hintText: strings.voiceSheetExample,
                  border: const OutlineInputBorder(),
                  suffixIcon: state.text.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.clear),
                          tooltip: strings.voiceClear,
                          onPressed: () {
                            _controller.clear();
                            notifier.reset();
                            if (_duplicateError != null) {
                              setState(() => _duplicateError = null);
                            }
                          },
                        ),
                ),
                onChanged: _onTextChanged,
              ),
              if (_duplicateError != null) ...[
                const SizedBox(height: 8),
                Text(
                  _duplicateError!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              _StatusLine(state: state),
              if (state.result != null) ...[
                const SizedBox(height: 12),
                _UnderstoodChips(
                  result: state.result!,
                  effectiveDate: _effectiveDate(state.result!),
                ),
              ],
              const SizedBox(height: 20),
              Row(
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(strings.cancel),
                  ),
                  if (!widget.returnResult && state.canCreate) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      tooltip: strings.voiceEditDetails,
                      icon: const Icon(Icons.edit_note_rounded),
                      onPressed: () => _editInForm(state.result!),
                    ),
                  ],
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: state.canCreate && !_isSaving
                          ? () => _saveTaskDirectly(state.result!)
                          : null,
                      icon: _isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.check_rounded),
                      label: Text(strings.voiceCreateTask),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  TextDirection? _directionOf(String text) =>
      switch (unicode_utils.detectTextDirection(text)) {
        unicode_utils.TextDirection.rtl => TextDirection.rtl,
        unicode_utils.TextDirection.ltr => TextDirection.ltr,
        null => null,
      };
}

class _LanguagePicker extends StatelessWidget {
  const _LanguagePicker({required this.value, required this.onChanged});

  final _VoiceLanguage value;
  final ValueChanged<_VoiceLanguage> onChanged;

  @override
  Widget build(BuildContext context) {
    final strings = context.l10n;

    return SegmentedButton<_VoiceLanguage>(
      segments: <ButtonSegment<_VoiceLanguage>>[
        ButtonSegment<_VoiceLanguage>(
          value: _VoiceLanguage.english,
          label: Text(strings.voiceLanguageEnglish),
        ),
        ButtonSegment<_VoiceLanguage>(
          value: _VoiceLanguage.malayalam,
          label: Text(strings.voiceLanguageMalayalam),
        ),
      ],
      selected: <_VoiceLanguage>{value},
      showSelectedIcon: false,
      onSelectionChanged: (selection) => onChanged(selection.first),
    );
  }
}

class _MicrophoneButton extends StatelessWidget {
  const _MicrophoneButton({required this.isListening, required this.onPressed});

  final bool isListening;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = context.l10n;

    return Column(
      children: [
        SizedBox(
          width: 72,
          height: 72,
          child: FloatingActionButton(
            heroTag: 'voice-sheet-mic',
            tooltip: strings.tooltipVoiceRecord,
            onPressed: onPressed,
            backgroundColor: isListening
                ? theme.colorScheme.error
                : theme.colorScheme.primaryContainer,
            foregroundColor: isListening
                ? theme.colorScheme.onError
                : theme.colorScheme.onPrimaryContainer,
            child: Icon(isListening ? Icons.stop : Icons.mic, size: 32),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          isListening ? strings.voiceListening : strings.voiceTapToSpeak,
          style: theme.textTheme.labelLarge,
        ),
      ],
    );
  }
}

/// The one line under the text box that says what just happened.
class _StatusLine extends StatelessWidget {
  const _StatusLine({required this.state});

  final VoiceCaptureState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = context.l10n;

    final message = _message(strings);
    if (message == null) {
      return Text(
        strings.voiceSheetExample,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.info_outline,
          size: 18,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            message,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  String? _message(AppLocalizations strings) {
    final error = state.error;
    if (error != null) {
      return switch (error) {
        SpeechErrorCode.permissionDenied => strings.voiceErrorPermission,
        SpeechErrorCode.noMatch => strings.voiceErrorNoMatch,
        SpeechErrorCode.noOfflineLanguage =>
          strings.voiceErrorNoOfflineLanguage,
        SpeechErrorCode.busy => strings.voiceErrorBusy,
        SpeechErrorCode.unknown => strings.voiceErrorUnknown,
      };
    }

    final unavailable = state.unavailable;
    if (unavailable != null) {
      return switch (unavailable) {
        SpeechUnavailableReason.unsupported => strings.voiceUnavailableDevice,
        SpeechUnavailableReason.noRecogniser =>
          strings.voiceUnavailableNoRecogniser,
        SpeechUnavailableReason.noOfflineEngine =>
          strings.voiceUnavailableNoOffline,
        SpeechUnavailableReason.missingPermission =>
          strings.voiceUnavailableNoPermission,
      };
    }

    if (state.result?.dateWasClamped ?? false) {
      return strings.voiceDateMovedToToday;
    }
    return null;
  }
}

/// The little row of chips showing what the sentence was understood to mean.
class _UnderstoodChips extends StatelessWidget {
  const _UnderstoodChips({required this.result, required this.effectiveDate});

  final VoiceParseResult result;

  /// The day the task will really land on, which is not always the day the
  /// parser worked out. See `_VoiceCommandSheetState._effectiveDate`.
  final String effectiveDate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = context.l10n;

    final chips = <Widget>[
      _chip(
        context,
        Icons.title,
        result.title.trim().isEmpty ? strings.voiceNoTitle : result.title,
      ),
      if (result.description != null && result.description!.isNotEmpty)
        _chip(
          context,
          Icons.notes_rounded,
          '${strings.voiceDescriptionHeading}: ${result.description!}',
        ),
      _chip(context, Icons.event, formatShortDateFromIso(effectiveDate)),
      if (result.hasTimeOfDay)
        _chip(context, Icons.schedule, result.timeOfDayLabel!),
      if (result.targetSeconds != null)
        _chip(context, Icons.timer, formatDuration(result.targetSeconds!)),
      if (result.priority != null)
        _chip(context, Icons.flag, _priorityLabel(strings, result.priority!)),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(strings.voiceUnderstoodHeading, style: theme.textTheme.labelLarge),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: chips),
      ],
    );
  }

  Widget _chip(BuildContext context, IconData icon, String label) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(
        label,
        textDirection: switch (unicode_utils.detectTextDirection(label)) {
          unicode_utils.TextDirection.rtl => TextDirection.rtl,
          unicode_utils.TextDirection.ltr => TextDirection.ltr,
          null => null,
        },
      ),
    );
  }

  String _priorityLabel(AppLocalizations strings, VoicePriority priority) =>
      switch (priority) {
        VoicePriority.low => strings.priorityLow,
        VoicePriority.normal => strings.priorityNormal,
        VoicePriority.high => strings.priorityHigh,
        VoicePriority.urgent => strings.priorityUrgent,
      };
}
