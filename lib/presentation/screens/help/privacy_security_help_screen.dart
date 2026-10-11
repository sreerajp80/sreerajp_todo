import 'package:flutter/material.dart';
import 'package:sreerajp_todo/presentation/screens/help/widgets/help_widgets.dart';
import 'package:sreerajp_todo/presentation/shared/extensions/localization_extensions.dart';

class PrivacySecurityHelpScreen extends StatelessWidget {
  const PrivacySecurityHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.helpPrivacyTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            HelpIntro(l10n.helpPrivacyIntro),
            const SizedBox(height: 24),
            HelpSection(
              icon: Icons.key_rounded,
              title: l10n.helpPrivacyDbTitle,
              children: [
                HelpBullet(l10n.helpPrivacyDb1),
                HelpBullet(l10n.helpPrivacyDb2),
                HelpBullet(l10n.helpPrivacyDb3),
              ],
            ),
            HelpSection(
              icon: Icons.fingerprint_rounded,
              title: l10n.helpPrivacyLockTitle,
              children: [
                HelpBullet(l10n.helpPrivacyLock1),
                HelpBullet(l10n.helpPrivacyLock2),
              ],
            ),
            HelpSection(
              icon: Icons.screenshot_outlined,
              title: l10n.helpPrivacyShotTitle,
              children: [
                HelpBullet(l10n.helpPrivacyShot1),
                HelpBullet(l10n.helpPrivacyShot2),
              ],
            ),
            HelpSection(
              icon: Icons.cloud_off_rounded,
              title: l10n.helpPrivacyNetTitle,
              children: [
                HelpBullet(l10n.helpPrivacyNet1),
                HelpBullet(l10n.helpPrivacyNet2),
              ],
            ),
            const SizedBox(height: 8),
            HelpFooter(l10n.helpPrivacyTip),
          ],
        ),
      ),
    );
  }
}
