import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sreerajp_todo/application/providers.dart';
import 'package:sreerajp_todo/core/extensions/localization_extensions.dart';
import 'package:sreerajp_todo/core/utils/date_format_rules.dart';
import 'package:sreerajp_todo/core/utils/date_utils.dart' as date_utils;
import 'package:sreerajp_todo/presentation/screens/settings/widgets/settings_choice_list.dart';
import 'package:sreerajp_todo/presentation/screens/settings/widgets/settings_note_card.dart';
import 'package:sreerajp_todo/presentation/shared/date_time_labels.dart';
import 'package:sreerajp_todo/presentation/shared/widgets/app_section_card.dart';

/// Settings -> Date & time -> Day start.
///
/// This is the one date setting that changes behaviour rather than looks: it
/// moves where the day boundary sits, which is what the Day Lock rule reads.
class DayStartScreen extends ConsumerWidget {
  const DayStartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final settings = ref.watch(dateTimeSettingsProvider);
    final notifier = ref.read(dateTimeSettingsProvider.notifier);

    // Read after watching the settings, so the line below updates the moment a
    // new hour is picked.
    final currentDay = date_utils.formatDateFromIso(date_utils.todayAsIso());

    return Scaffold(
      appBar: AppBar(title: Text(l10n.dateTimeDayStart)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SettingsChoiceList<int>(
            title: l10n.dayStartTitle,
            subtitle: l10n.dayStartSubtitle,
            selected: settings.dayStartHour,
            onChanged: notifier.setDayStartHour,
            choices: [
              for (
                var hour = kMinDayStartHour;
                hour <= kMaxDayStartHour;
                hour++
              )
                SettingsChoice(
                  value: hour,
                  label: dayStartHourLabel(l10n, hour),
                ),
            ],
          ),
          const SizedBox(height: 16),
          AppSectionCard(
            title: l10n.dayStartExplainTitle,
            child: Text(l10n.dayStartExplainBody),
          ),
          const SizedBox(height: 16),
          SettingsNoteCard(
            icon: Icons.today_rounded,
            text: l10n.dayStartCurrentDay(currentDay),
          ),
        ],
      ),
    );
  }
}
