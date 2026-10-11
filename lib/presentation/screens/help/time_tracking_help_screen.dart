import 'package:flutter/material.dart';
import 'package:sreerajp_todo/presentation/screens/help/widgets/help_widgets.dart';
import 'package:sreerajp_todo/presentation/shared/extensions/localization_extensions.dart';

class TimeTrackingHelpScreen extends StatelessWidget {
  const TimeTrackingHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.helpTimeTrackingTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            HelpIntro(l10n.helpTimeTrackingIntro),
            const SizedBox(height: 24),
            HelpSection(
              icon: Icons.timer_outlined,
              title: l10n.helpTimeTrackingSegmentsTitle,
              children: [
                HelpBullet(l10n.helpTimeTrackingSegments1),
                HelpBullet(l10n.helpTimeTrackingSegments2),
                HelpBullet(l10n.helpTimeTrackingSegments3),
              ],
            ),
            HelpSection(
              icon: Icons.play_circle_outline_rounded,
              title: l10n.helpTimeTrackingSingleTitle,
              children: [
                HelpBullet(l10n.helpTimeTrackingSingle1),
                HelpBullet(l10n.helpTimeTrackingSingle2),
                HelpBullet(l10n.helpTimeTrackingSingle3),
              ],
            ),
            HelpSection(
              icon: Icons.bolt_rounded,
              title: l10n.helpTimeTrackingAutoTitle,
              children: [
                HelpBullet(l10n.helpTimeTrackingAuto1),
                HelpBullet(l10n.helpTimeTrackingAuto2),
                HelpBullet(l10n.helpTimeTrackingAuto3),
              ],
            ),
            const SizedBox(height: 8),
            HelpFooter(l10n.helpTimeTrackingTip),
          ],
        ),
      ),
    );
  }
}
