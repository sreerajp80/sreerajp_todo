import 'package:flutter/material.dart';
import 'package:sreerajp_todo/presentation/screens/help/widgets/help_widgets.dart';
import 'package:sreerajp_todo/presentation/shared/extensions/localization_extensions.dart';

class BackupHelpScreen extends StatelessWidget {
  const BackupHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.helpBackupTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            HelpIntro(l10n.helpBackupIntro),
            const SizedBox(height: 24),
            HelpSection(
              icon: Icons.inventory_2_outlined,
              title: l10n.helpBackupContentsTitle,
              children: [
                HelpBullet(l10n.helpBackupContents1),
                HelpBullet(l10n.helpBackupContents2),
                HelpBullet(l10n.helpBackupContents3),
                HelpBullet(l10n.helpBackupContents4),
              ],
            ),
            HelpSection(
              icon: Icons.password_rounded,
              title: l10n.helpBackupPassTitle,
              children: [
                HelpBullet(l10n.helpBackupPass1),
                HelpBullet(l10n.helpBackupPass2),
                HelpBullet(l10n.helpBackupPass3),
              ],
            ),
            HelpSection(
              icon: Icons.restore_rounded,
              title: l10n.helpBackupRestoreTitle,
              children: [
                HelpBullet(l10n.helpBackupRestore1),
                HelpBullet(l10n.helpBackupRestore2),
                HelpBullet(l10n.helpBackupRestore3),
              ],
            ),
            const SizedBox(height: 8),
            HelpFooter(l10n.helpBackupTip),
          ],
        ),
      ),
    );
  }
}
