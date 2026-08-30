import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sreerajp_todo/application/providers.dart';
import 'package:sreerajp_todo/core/constants/app_routes.dart';
import 'package:sreerajp_todo/core/extensions/localization_extensions.dart';
import 'package:sreerajp_todo/presentation/screens/settings/widgets/settings_nav_card.dart';
import 'package:sreerajp_todo/presentation/screens/settings/widgets/settings_note_card.dart';
import 'package:sreerajp_todo/presentation/shared/security_labels.dart';
import 'package:sreerajp_todo/presentation/shared/widgets/app_section_card.dart';

/// Security & privacy hub reached from Settings -> Security & privacy.
class SecurityScreen extends ConsumerWidget {
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final settings = ref.watch(securitySettingsProvider);
    final notifier = ref.read(securitySettingsProvider.notifier);
    // The secure window flag is an Android window flag. Everywhere else the
    // switch would do nothing, so it is shown disabled with a reason.
    final secureFlagSupported = Platform.isAndroid;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsSecurity)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            SettingsNavCard(
              icon: Icons.lock_outline_rounded,
              title: l10n.securityAppLock,
              subtitle: appLockModeName(l10n, settings.lockMode),
              onTap: () => context.push(AppRoutes.appLock),
            ),
            const SizedBox(height: 16),
            SettingsNavCard(
              icon: Icons.timer_off_outlined,
              title: l10n.securityAutoLock,
              subtitle: settings.isLockEnabled
                  ? autoLockDelayName(l10n, settings.autoLockDelay)
                  : l10n.securityAutoLockSubtitle,
              onTap: () => context.push(AppRoutes.autoLock),
            ),
            const SizedBox(height: 16),
            AppSectionCard(
              title: l10n.securityScreenPrivacy,
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: settings.secureScreen,
                onChanged: secureFlagSupported
                    ? notifier.setSecureScreen
                    : null,
                title: Text(l10n.securitySecureScreen),
                subtitle: Text(
                  secureFlagSupported
                      ? l10n.securitySecureScreenDetail
                      : l10n.securitySecureScreenUnsupported,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SettingsNoteCard(text: l10n.securityNotificationsNote),
            const SizedBox(height: 16),
            SettingsNavCard(
              icon: Icons.key_outlined,
              title: l10n.securityDatabaseKey,
              subtitle: l10n.securityDatabaseKeySubtitle,
              onTap: () => context.push(AppRoutes.databaseKey),
            ),
          ],
        ),
      ),
    );
  }
}
