import 'package:flutter/material.dart';
import 'package:sreerajp_todo/core/constants/app_strings.dart';

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
    return SegmentedButton<RruleFrequency>(
      segments: const [
        ButtonSegment(
          value: RruleFrequency.daily,
          label: Text(AppStrings.daily),
        ),
        ButtonSegment(
          value: RruleFrequency.weekly,
          label: Text(AppStrings.weekly),
        ),
        ButtonSegment(
          value: RruleFrequency.monthly,
          label: Text(AppStrings.monthly),
        ),
        ButtonSegment(
          value: RruleFrequency.yearly,
          label: Text(AppStrings.yearly),
        ),
      ],
      selected: {selected},
      onSelectionChanged: (newSelection) {
        onChanged(newSelection.first);
      },
    );
  }
}
