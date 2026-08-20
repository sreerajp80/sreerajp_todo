import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sreerajp_todo/application/providers.dart';
import 'package:sreerajp_todo/core/extensions/localization_extensions.dart';
import 'package:sreerajp_todo/core/utils/date_format_rules.dart';
import 'package:sreerajp_todo/presentation/screens/settings/widgets/settings_choice_list.dart';
import 'package:sreerajp_todo/presentation/shared/date_time_labels.dart';

/// Settings -> Date & time -> Date format.
class DateFormatScreen extends ConsumerWidget {
  const DateFormatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final settings = ref.watch(dateTimeSettingsProvider);
    final notifier = ref.read(dateTimeSettingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.dateTimeDateFormat)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SettingsChoiceList<AppDateFormat>(
            title: l10n.dateFormatTitle,
            subtitle: l10n.dateFormatSubtitle,
            selected: settings.dateFormat,
            onChanged: notifier.setDateFormat,
            choices: [
              for (final option in AppDateFormat.values)
                SettingsChoice(
                  value: option,
                  label: dateFormatName(l10n, option),
                  // Today written in that style, so the choice is obvious.
                  detail: dateFormatSample(option),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
