import 'package:flutter/material.dart';
import 'package:sreerajp_todo/core/extensions/localization_extensions.dart';

enum RruleFrequency { daily, weekly, monthly, yearly }

class RruleFrequencyPicker extends StatelessWidget {
  const RruleFrequencyPicker({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final RruleFrequency selected;
  final ValueChanged<RruleFrequency> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SegmentedButton<RruleFrequency>(
        segments: [
          ButtonSegment(
            value: RruleFrequency.daily,
            label: Text(context.l10n.daily),
          ),
          ButtonSegment(
            value: RruleFrequency.weekly,
            label: Text(context.l10n.weekly),
          ),
          ButtonSegment(
            value: RruleFrequency.monthly,
            label: Text(context.l10n.monthly),
          ),
          ButtonSegment(
            value: RruleFrequency.yearly,
            label: Text(context.l10n.yearly),
          ),
        ],
        selected: {selected},
        onSelectionChanged: (newSelection) {
          onChanged(newSelection.first);
        },
      ),
    );
  }
}
