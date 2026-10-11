import 'package:flutter/material.dart';
import 'package:sreerajp_todo/presentation/screens/help/widgets/help_widgets.dart';
import 'package:sreerajp_todo/presentation/shared/extensions/localization_extensions.dart';

class RecurringTasksHelpScreen extends StatelessWidget {
  const RecurringTasksHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.helpRecurringTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            HelpIntro(l10n.helpRecurringIntro),
            const SizedBox(height: 24),
            HelpSection(
              icon: Icons.repeat_rounded,
              title: l10n.helpRecurringRulesTitle,
              children: [
                HelpBullet(l10n.helpRecurringRules1),
                HelpBullet(l10n.helpRecurringRules2),
                HelpBullet(l10n.helpRecurringRules3),
              ],
            ),
            HelpSection(
              icon: Icons.copy_all_rounded,
              title: l10n.helpRecurringCopyTitle,
              children: [
                HelpBullet(l10n.helpRecurringCopy1),
                HelpBullet(l10n.helpRecurringCopy2),
                HelpBullet(l10n.helpRecurringCopy3),
              ],
            ),
            const SizedBox(height: 8),
            HelpFooter(l10n.helpRecurringTip),
          ],
        ),
      ),
    );
  }
}
