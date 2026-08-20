import 'package:flutter/material.dart';
import 'package:sreerajp_todo/presentation/shared/widgets/app_section_card.dart';

/// One option in a [SettingsChoiceList].
@immutable
class SettingsChoice<T> {
  const SettingsChoice({required this.value, required this.label, this.detail});

  final T value;
  final String label;

  /// Optional second line explaining what the option does.
  final String? detail;
}

/// A card holding a single-pick list of radio options.
///
/// Used by every time-tracking page that offers a straight choice, so the
/// pages stay short and all read the same way.
class SettingsChoiceList<T> extends StatelessWidget {
  const SettingsChoiceList({
    super.key,
    required this.title,
    required this.choices,
    required this.selected,
    required this.onChanged,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final List<SettingsChoice<T>> choices;
  final T selected;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      title: title,
      subtitle: subtitle,
      child: RadioGroup<T>(
        groupValue: selected,
        onChanged: (value) {
          if (value != null) onChanged(value);
        },
        child: Column(
          children: [
            for (final choice in choices)
              RadioListTile<T>(
                value: choice.value,
                contentPadding: EdgeInsets.zero,
                title: Text(choice.label),
                subtitle: choice.detail == null ? null : Text(choice.detail!),
              ),
          ],
        ),
      ),
    );
  }
}
