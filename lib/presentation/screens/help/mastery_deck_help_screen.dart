import 'package:flutter/material.dart';
import 'package:sreerajp_todo/presentation/screens/help/widgets/help_widgets.dart';
import 'package:sreerajp_todo/presentation/shared/extensions/localization_extensions.dart';

class MasteryDeckHelpScreen extends StatelessWidget {
  const MasteryDeckHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.helpMasteryTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            HelpIntro(l10n.helpMasteryIntro),
            const SizedBox(height: 24),
            HelpSection(
              icon: Icons.psychology_outlined,
              title: l10n.helpMasteryReviewTitle,
              children: [
                HelpBullet(l10n.helpMasteryReview1),
                HelpBullet(l10n.helpMasteryReview2),
                HelpBullet(l10n.helpMasteryReview3),
              ],
            ),
            HelpSection(
              icon: Icons.style_outlined,
              title: l10n.helpMasteryDecksTitle,
              children: [
                HelpBullet(l10n.helpMasteryDecks1),
                HelpBullet(l10n.helpMasteryDecks2),
                HelpBullet(l10n.helpMasteryDecks3),
              ],
            ),
            HelpSection(
              icon: Icons.military_tech_outlined,
              title: l10n.helpMasteryLevelsTitle,
              children: [
                HelpBullet(l10n.helpMasteryLevels1),
                HelpBullet(l10n.helpMasteryLevels2),
              ],
            ),
            const SizedBox(height: 8),
            HelpFooter(l10n.helpMasteryTip),
          ],
        ),
      ),
    );
  }
}
