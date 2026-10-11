import 'package:flutter/material.dart';
import 'package:sreerajp_todo/presentation/screens/help/widgets/help_widgets.dart';
import 'package:sreerajp_todo/presentation/shared/extensions/localization_extensions.dart';

class QrHandoffHelpScreen extends StatelessWidget {
  const QrHandoffHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.helpQrTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            HelpIntro(l10n.helpQrIntro),
            const SizedBox(height: 24),
            HelpSection(
              icon: Icons.qr_code_scanner_rounded,
              title: l10n.helpQrBeamTitle,
              children: [
                HelpBullet(l10n.helpQrBeam1),
                HelpBullet(l10n.helpQrBeam2),
                HelpBullet(l10n.helpQrBeam3),
                HelpBullet(l10n.helpQrBeam4),
              ],
            ),
            HelpSection(
              icon: Icons.send_to_mobile_rounded,
              title: l10n.helpQrHandoffTitle,
              children: [
                HelpBullet(l10n.helpQrHandoff1),
                HelpBullet(l10n.helpQrHandoff2),
                HelpBullet(l10n.helpQrHandoff3),
              ],
            ),
            const SizedBox(height: 8),
            HelpFooter(l10n.helpQrTip),
          ],
        ),
      ),
    );
  }
}
