import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sreerajp_todo/application/providers.dart';
import 'package:sreerajp_todo/core/extensions/localization_extensions.dart';
import 'package:sreerajp_todo/core/utils/time_tracking_rules.dart';
import 'package:sreerajp_todo/presentation/screens/settings/widgets/settings_choice_list.dart';
import 'package:sreerajp_todo/presentation/shared/widgets/app_section_card.dart';

/// Settings -> Time tracking -> Timer behaviour.
class TimerBehaviourScreen extends ConsumerWidget {
  const TimerBehaviourScreen({super.key});

  /// The keep-awake channel is Android only, so the switch is hidden rather
  /// than shown doing nothing on other platforms.
  bool get _supportsKeepAwake => !kIsWeb && Platform.isAndroid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final settings = ref.watch(timeTrackingSettingsProvider);
    final notifier = ref.read(timeTrackingSettingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.trackingTimerBehaviour)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppSectionCard(
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: settings.singleTimer,
                  onChanged: notifier.setSingleTimer,
                  title: Text(l10n.trackingSingleTimer),
                  subtitle: Text(l10n.trackingSingleTimerDetail),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: settings.autoPauseOnBackground,
                  onChanged: notifier.setAutoPauseOnBackground,
                  title: Text(l10n.trackingAutoPause),
                  subtitle: Text(l10n.trackingAutoPauseDetail),
                ),
                if (_supportsKeepAwake)
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: settings.keepScreenAwake,
                    onChanged: notifier.setKeepScreenAwake,
                    title: Text(l10n.trackingKeepScreenAwake),
                    subtitle: Text(l10n.trackingKeepScreenAwakeDetail),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SettingsChoiceList<MinimumSegmentLength>(
            title: l10n.trackingMinimumLength,
            subtitle: l10n.trackingMinimumLengthDetail,
            selected: settings.minimumSegmentLength,
            onChanged: notifier.setMinimumSegmentLength,
            choices: [
              SettingsChoice(
                value: MinimumSegmentLength.off,
                label: l10n.trackingMinimumOff,
              ),
              SettingsChoice(
                value: MinimumSegmentLength.tenSeconds,
                label: l10n.trackingMinimum10s,
              ),
              SettingsChoice(
                value: MinimumSegmentLength.thirtySeconds,
                label: l10n.trackingMinimum30s,
              ),
              SettingsChoice(
                value: MinimumSegmentLength.oneMinute,
                label: l10n.trackingMinimum1m,
              ),
              SettingsChoice(
                value: MinimumSegmentLength.fiveMinutes,
                label: l10n.trackingMinimum5m,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
