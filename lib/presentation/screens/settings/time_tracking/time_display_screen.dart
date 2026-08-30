import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sreerajp_todo/application/providers.dart';
import 'package:sreerajp_todo/core/extensions/localization_extensions.dart';
import 'package:sreerajp_todo/core/utils/duration_utils.dart';
import 'package:sreerajp_todo/core/utils/time_tracking_rules.dart';
import 'package:sreerajp_todo/presentation/screens/settings/widgets/settings_choice_list.dart';
import 'package:sreerajp_todo/presentation/screens/settings/widgets/settings_note_card.dart';
import 'package:sreerajp_todo/presentation/shared/widgets/app_section_card.dart';

/// Settings -> Time tracking -> Time display.
class TimeDisplayScreen extends ConsumerWidget {
  const TimeDisplayScreen({super.key});

  /// 1 hour 37 minutes 20 seconds, used to preview the chosen settings.
  static const int _sampleSeconds = 5840;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final settings = ref.watch(timeTrackingSettingsProvider);
    final notifier = ref.read(timeTrackingSettingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.trackingTimeDisplay)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            AppSectionCard(
              child: Center(
                child: Text(
                  formatDuration(
                    _sampleSeconds,
                    rounding: settings.rounding,
                    format: settings.format,
                  ),
                  style: theme.textTheme.headlineMedium,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SettingsChoiceList<DurationFormat>(
              title: l10n.trackingFormat,
              selected: settings.format,
              onChanged: notifier.setFormat,
              choices: [
                SettingsChoice(
                  value: DurationFormat.hhmmss,
                  label: l10n.trackingFormatHhmmss,
                ),
                SettingsChoice(
                  value: DurationFormat.hhmm,
                  label: l10n.trackingFormatHhmm,
                ),
                SettingsChoice(
                  value: DurationFormat.decimalHours,
                  label: l10n.trackingFormatDecimal,
                ),
              ],
            ),
            const SizedBox(height: 16),
            SettingsNoteCard(text: l10n.trackingFormatNote),
            const SizedBox(height: 16),
            SettingsChoiceList<DurationRounding>(
              title: l10n.trackingRounding,
              subtitle: l10n.trackingRoundingDetail,
              selected: settings.rounding,
              onChanged: notifier.setRounding,
              choices: [
                SettingsChoice(
                  value: DurationRounding.off,
                  label: l10n.trackingRoundingOff,
                ),
                SettingsChoice(
                  value: DurationRounding.nearestMinute,
                  label: l10n.trackingRounding1m,
                ),
                SettingsChoice(
                  value: DurationRounding.nearest5Minutes,
                  label: l10n.trackingRounding5m,
                ),
                SettingsChoice(
                  value: DurationRounding.nearest15Minutes,
                  label: l10n.trackingRounding15m,
                ),
              ],
            ),
            const SizedBox(height: 16),
            SettingsChoiceList<ManualEntryDuration>(
              title: l10n.trackingManualDefault,
              subtitle: l10n.trackingManualDefaultDetail,
              selected: settings.manualEntryDuration,
              onChanged: notifier.setManualEntryDuration,
              choices: [
                SettingsChoice(
                  value: ManualEntryDuration.fifteenMinutes,
                  label: l10n.trackingManual15m,
                ),
                SettingsChoice(
                  value: ManualEntryDuration.thirtyMinutes,
                  label: l10n.trackingManual30m,
                ),
                SettingsChoice(
                  value: ManualEntryDuration.oneHour,
                  label: l10n.trackingManual1h,
                ),
                SettingsChoice(
                  value: ManualEntryDuration.twoHours,
                  label: l10n.trackingManual2h,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
