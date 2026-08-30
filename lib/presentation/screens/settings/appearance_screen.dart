import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sreerajp_todo/core/constants/app_routes.dart';
import 'package:sreerajp_todo/core/extensions/localization_extensions.dart';
import 'package:sreerajp_todo/presentation/screens/settings/widgets/settings_nav_card.dart';

/// Appearance hub reached from Settings -> Appearance. It only holds links to
/// the appearance pages.
class AppearanceScreen extends StatelessWidget {
  const AppearanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsAppearance)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            SettingsNavCard(
              icon: Icons.brightness_6_outlined,
              title: l10n.settingsThemeMode,
              subtitle: l10n.appearanceThemeModeSubtitle,
              onTap: () => context.push(AppRoutes.themeMode),
            ),
            const SizedBox(height: 16),
            SettingsNavCard(
              icon: Icons.text_fields_rounded,
              title: l10n.appearanceTypography,
              subtitle: l10n.appearanceTypographySubtitle,
              onTap: () => context.push(AppRoutes.typography),
            ),
            const SizedBox(height: 16),
            SettingsNavCard(
              icon: Icons.color_lens_outlined,
              title: l10n.appearanceAccentColor,
              subtitle: l10n.appearanceAccentColorSubtitle,
              onTap: () => context.push(AppRoutes.accentColor),
            ),
          ],
        ),
      ),
    );
  }
}
