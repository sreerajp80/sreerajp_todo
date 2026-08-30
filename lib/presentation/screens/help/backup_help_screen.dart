import 'package:flutter/material.dart';
import 'package:sreerajp_todo/presentation/screens/help/widgets/help_widgets.dart';

class BackupHelpScreen extends StatelessWidget {
  const BackupHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Encrypted Backup & Restore')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: const [
            HelpIntro(
              'A backup creates a single encrypted archive (.todobak / ZIP) containing your tasks, time records, recurrence rules, and settings. '
              'Use it to transfer data to a new phone, recover after a factory reset, or keep periodic offline archives.',
            ),
            SizedBox(height: 24),
            HelpSection(
              icon: Icons.inventory_2_outlined,
              title: 'What the Backup Contains',
              children: [
                HelpBullet(
                  'All tasks, descriptions, statuses, and historical time segments.',
                ),
                HelpBullet('Recurring task rules and generation schedules.'),
                HelpBullet(
                  'Mastery Deck cards, review intervals, and mastery levels.',
                ),
                HelpBullet(
                  'Your personalized settings (Theme mode, accent colors, typography, task defaults).',
                ),
              ],
            ),
            HelpSection(
              icon: Icons.password_rounded,
              title: 'Password Encryption Safety',
              children: [
                HelpBullet(
                  'Backup archives are strongly encrypted with a passphrase you choose using AES-256 standard encryption.',
                ),
                HelpBullet(
                  'The app does NOT store your backup passphrase anywhere. You must remember or store it in a password manager.',
                ),
                HelpBullet(
                  'If you lose the passphrase, the backup cannot be decrypted or recovered by anyone.',
                ),
              ],
            ),
            HelpSection(
              icon: Icons.restore_rounded,
              title: 'Restoring from a Backup',
              children: [
                HelpBullet(
                  'Restoring replaces what is currently in the app and rebuilds an exact copy from the backup file.',
                ),
                HelpBullet(
                  'Before restoring, the app verifies the archive checksum, decrypts with your passphrase, and validates data schema version.',
                ),
                HelpBullet(
                  'If you want to merge tasks between two devices without replacing existing data, use "Local Wi-Fi Sync" instead.',
                ),
              ],
            ),
            SizedBox(height: 8),
            HelpFooter(
              'Tip: After creating a backup, save the file to a secure location such as an external USB drive, SD card, or your personal cloud storage.',
            ),
          ],
        ),
      ),
    );
  }
}
