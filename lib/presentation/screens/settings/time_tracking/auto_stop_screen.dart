import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sreerajp_todo/application/providers.dart';
import 'package:sreerajp_todo/core/extensions/localization_extensions.dart';
import 'package:sreerajp_todo/core/utils/time_tracking_rules.dart';
import 'package:sreerajp_todo/presentation/screens/settings/widgets/settings_choice_list.dart';
import 'package:sreerajp_todo/presentation/screens/settings/widgets/settings_note_card.dart';
import 'package:sreerajp_todo/presentation/shared/widgets/app_section_card.dart';

/// Settings -> Time tracking -> Auto-stop the timer.
class AutoStopScreen extends ConsumerWidget {
  const AutoStopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final settings = ref.watch(timeTrackingSettingsProvider);
    final notifier = ref.read(timeTrackingSettingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.trackingAutoStop)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SettingsChoiceList<AutoStopMode>(
            title: l10n.trackingAutoStop,
            selected: settings.autoStopMode,
            onChanged: notifier.setAutoStopMode,
            choices: [
              SettingsChoice(
                value: AutoStopMode.off,
                label: l10n.trackingAutoStopOff,
                detail: l10n.trackingAutoStopOffDetail,
              ),
              SettingsChoice(
                value: AutoStopMode.midnight,
                label: l10n.trackingAutoStopMidnight,
                detail: l10n.trackingAutoStopMidnightDetail,
              ),
              SettingsChoice(
                value: AutoStopMode.customTime,
                label: l10n.trackingAutoStopCustom,
                detail: l10n.trackingAutoStopCustomDetail,
              ),
            ],
          ),
          if (settings.autoStopMode == AutoStopMode.customTime) ...[
            const SizedBox(height: 16),
            AppSectionCard(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.access_time_rounded),
                title: Text(l10n.trackingAutoStopTime),
                trailing: Text(
                  settings.autoStopTimeOfDay.format(context),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: settings.autoStopTimeOfDay,
                  );
                  if (picked != null) {
                    await notifier.setAutoStopTime(picked);
                  }
                },
              ),
            ),
          ],
          if (settings.autoStopMode != AutoStopMode.off) ...[
            const SizedBox(height: 16),
            SettingsNoteCard(text: l10n.trackingAutoStopNote),
          ],
        ],
      ),
    );
  }
}
