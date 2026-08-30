import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sreerajp_todo/application/providers.dart';
import 'package:sreerajp_todo/core/extensions/localization_extensions.dart';
import 'package:sreerajp_todo/core/utils/date_format_rules.dart';
import 'package:sreerajp_todo/presentation/screens/settings/widgets/settings_choice_list.dart';
import 'package:sreerajp_todo/presentation/shared/date_time_labels.dart';

/// Settings -> Date & time -> Clock.
class ClockFormatScreen extends ConsumerWidget {
  const ClockFormatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final settings = ref.watch(dateTimeSettingsProvider);
    final notifier = ref.read(dateTimeSettingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.dateTimeClock)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            SettingsChoiceList<ClockFormat>(
              title: l10n.clockFormatTitle,
              subtitle: l10n.clockFormatSubtitle,
              selected: settings.clockFormat,
              onChanged: notifier.setClockFormat,
              choices: [
                for (final option in ClockFormat.values)
                  SettingsChoice(
                    value: option,
                    label: clockFormatName(l10n, option),
                    // Shows the real result, so the choice needs no explaining.
                    detail: clockFormatSample(option),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
