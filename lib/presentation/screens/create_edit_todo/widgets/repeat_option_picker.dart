import 'package:flutter/material.dart';
import 'package:sreerajp_todo/core/constants/app_strings.dart';

/// Whether the user wants this todo to repeat.
enum SimpleRepeatOption { none, repeat }

/// Two-option picker: None or Repeat...
/// When [repeat] is selected, the [onRepeatRequested] callback fires
/// so the parent can open the full recurrence configuration sheet.
class RepeatOptionPicker extends StatelessWidget {
  const RepeatOptionPicker({
    super.key,
    required this.selected,
    required this.onChanged,
    this.onRepeatRequested,
    this.summaryLabel,
  });

  final SimpleRepeatOption selected;
  final ValueChanged<SimpleRepeatOption> onChanged;
  final VoidCallback? onRepeatRequested;

  /// When repeat is configured, show the human-readable summary.
  final String? summaryLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SegmentedButton<SimpleRepeatOption>(
          segments: [
            const ButtonSegment(
              value: SimpleRepeatOption.none,
              label: Text(AppStrings.repeatNone),
            ),
            const ButtonSegment(
              value: SimpleRepeatOption.repeat,
              label: Text(AppStrings.repeatConfigure),
            ),
          ],
          selected: {selected},
          onSelectionChanged: (newSelection) {
            final option = newSelection.first;
            onChanged(option);
            if (option == SimpleRepeatOption.repeat) {
              onRepeatRequested?.call();
            }
          },
        ),
        if (selected == SimpleRepeatOption.repeat && summaryLabel != null) ...[
          const SizedBox(height: 8),
          InkWell(
            onTap: onRepeatRequested,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(
                    Icons.repeat,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      summaryLabel!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.edit_outlined,
                    size: 14,
                    color: theme.colorScheme.primary.withValues(alpha: 0.6),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
