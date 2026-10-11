import 'package:flutter/material.dart';
import 'package:sreerajp_todo/presentation/screens/help/widgets/help_widgets.dart';
import 'package:sreerajp_todo/presentation/shared/extensions/localization_extensions.dart';

class TaskManagementHelpScreen extends StatelessWidget {
  const TaskManagementHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.helpTaskMgmtTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            HelpIntro(l10n.helpTaskMgmtIntro),
            const SizedBox(height: 24),
            HelpSection(
              icon: Icons.lock_clock_outlined,
              title: l10n.helpTaskMgmtDayLockTitle,
              children: [
                HelpBullet(l10n.helpTaskMgmtDayLock1),
                HelpBullet(l10n.helpTaskMgmtDayLock2),
                HelpBullet(l10n.helpTaskMgmtDayLock3),
              ],
            ),
            HelpSection(
              icon: Icons.checklist_rounded,
              title: l10n.helpTaskMgmtStatusTitle,
              children: [
                HelpBullet(l10n.helpTaskMgmtStatus1),
                HelpBullet(l10n.helpTaskMgmtStatus2),
                HelpBullet(l10n.helpTaskMgmtStatus3),
              ],
            ),
            HelpSection(
              icon: Icons.undo_rounded,
              title: l10n.helpTaskMgmtUndoTitle,
              children: [
                HelpBullet(l10n.helpTaskMgmtUndo1),
                HelpBullet(l10n.helpTaskMgmtUndo2),
              ],
            ),
            HelpSection(
              icon: Icons.translate_rounded,
              title: l10n.helpTaskMgmtUnicodeTitle,
              children: [
                HelpBullet(l10n.helpTaskMgmtUnicode1),
                HelpBullet(l10n.helpTaskMgmtUnicode2),
                HelpBullet(l10n.helpTaskMgmtUnicode3),
              ],
            ),
            const SizedBox(height: 8),
            HelpFooter(l10n.helpTaskMgmtTip),
          ],
        ),
      ),
    );
  }
}
