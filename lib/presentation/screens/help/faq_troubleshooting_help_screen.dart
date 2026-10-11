import 'package:flutter/material.dart';
import 'package:sreerajp_todo/presentation/screens/help/widgets/help_widgets.dart';
import 'package:sreerajp_todo/presentation/shared/extensions/localization_extensions.dart';

class FaqTroubleshootingHelpScreen extends StatelessWidget {
  const FaqTroubleshootingHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.helpFaqTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            HelpIntro(l10n.helpFaqIntro),
            const SizedBox(height: 24),
            HelpSection(
              icon: Icons.help_outline_rounded,
              title: l10n.helpFaqGeneralTitle,
              children: [
                HelpFaqItem(
                  question: l10n.helpFaqEditPastQ,
                  answer: l10n.helpFaqEditPastA,
                ),
                HelpFaqItem(
                  question: l10n.helpFaqTimerDoneQ,
                  answer: l10n.helpFaqTimerDoneA,
                ),
                HelpFaqItem(
                  question: l10n.helpFaqUndoQ,
                  answer: l10n.helpFaqUndoA,
                ),
              ],
            ),
            HelpSection(
              icon: Icons.timer_outlined,
              title: l10n.helpFaqTimeTitle,
              children: [
                HelpFaqItem(
                  question: l10n.helpFaqTwoTimersQ,
                  answer: l10n.helpFaqTwoTimersA,
                ),
                HelpFaqItem(
                  question: l10n.helpFaqForgotStopQ,
                  answer: l10n.helpFaqForgotStopA,
                ),
                HelpFaqItem(
                  question: l10n.helpFaqShortTapsQ,
                  answer: l10n.helpFaqShortTapsA,
                ),
              ],
            ),
            HelpSection(
              icon: Icons.security_rounded,
              title: l10n.helpFaqPrivacyTitle,
              children: [
                HelpFaqItem(
                  question: l10n.helpFaqUploadQ,
                  answer: l10n.helpFaqUploadA,
                ),
                HelpFaqItem(
                  question: l10n.helpFaqLostPassQ,
                  answer: l10n.helpFaqLostPassA,
                ),
              ],
            ),
            HelpSection(
              icon: Icons.sync_alt_rounded,
              title: l10n.helpFaqSyncTitle,
              children: [
                HelpFaqItem(
                  question: l10n.helpFaqNewPhoneQ,
                  answer: l10n.helpFaqNewPhoneA,
                ),
                HelpFaqItem(
                  question: l10n.helpFaqDiscoverQ,
                  answer: l10n.helpFaqDiscoverA,
                ),
              ],
            ),
            const SizedBox(height: 8),
            HelpFooter(l10n.helpFaqFooter),
          ],
        ),
      ),
    );
  }
}
