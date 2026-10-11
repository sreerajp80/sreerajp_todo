import 'package:flutter/material.dart';
import 'package:sreerajp_todo/presentation/screens/help/widgets/help_widgets.dart';
import 'package:sreerajp_todo/presentation/shared/extensions/localization_extensions.dart';

class WifiSyncHelpScreen extends StatelessWidget {
  const WifiSyncHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.helpWifiTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            HelpIntro(l10n.helpWifiIntro),
            const SizedBox(height: 24),
            HelpSection(
              icon: Icons.wifi_tethering_rounded,
              title: l10n.helpWifiHowTitle,
              children: [
                HelpBullet(l10n.helpWifiHow1),
                HelpBullet(l10n.helpWifiHow2),
                HelpBullet(l10n.helpWifiHow3),
              ],
            ),
            HelpSection(
              icon: Icons.lock_outline_rounded,
              title: l10n.helpWifiEncryptionTitle,
              children: [
                HelpBullet(l10n.helpWifiEncryption1),
                HelpBullet(l10n.helpWifiEncryption2),
              ],
            ),
            HelpSection(
              icon: Icons.merge_type_rounded,
              title: l10n.helpWifiModesTitle,
              children: [
                HelpBullet(l10n.helpWifiModes1),
                HelpBullet(l10n.helpWifiModes2),
              ],
            ),
            const SizedBox(height: 8),
            HelpFooter(l10n.helpWifiTip),
          ],
        ),
      ),
    );
  }
}
