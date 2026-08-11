import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sreerajp_todo/application/providers.dart';
import 'package:sreerajp_todo/core/constants/app_routes.dart';
import 'package:sreerajp_todo/core/extensions/localization_extensions.dart';
import 'package:sreerajp_todo/presentation/screens/settings/widgets/settings_link_tile.dart';
import 'package:sreerajp_todo/presentation/shared/widgets/app_section_card.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    final selectedLanguageCode = locale?.languageCode ?? 'system';

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.settingsLabel)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppSectionCard(
            title: context.l10n.settingsAppearance,
            subtitle: context.l10n.settingsThemeMode,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SegmentedButton<ThemeMode>(
                segments: [
                  ButtonSegment(
                    value: ThemeMode.system,
                    label: Text(context.l10n.settingsFollowSystem),
                    icon: const Icon(Icons.brightness_auto_outlined),
                  ),
                  ButtonSegment(
                    value: ThemeMode.light,
                    label: Text(context.l10n.settingsLight),
                    icon: const Icon(Icons.light_mode_outlined),
                  ),
                  ButtonSegment(
                    value: ThemeMode.dark,
                    label: Text(context.l10n.settingsDark),
                    icon: const Icon(Icons.dark_mode_outlined),
                  ),
                ],
                selected: {themeMode},
                onSelectionChanged: (selection) {
                  ref.read(themeModeProvider.notifier).state = selection.first;
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          AppSectionCard(
            title: context.l10n.settingsLanguage,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SegmentedButton<String>(
                segments: [
                  ButtonSegment(
                    value: 'system',
                    label: Text(context.l10n.settingsLanguageSystem),
                    icon: const Icon(Icons.language_outlined),
                  ),
                  ButtonSegment(
                    value: 'en',
                    label: Text(context.l10n.settingsLanguageEnglish),
                    icon: const Icon(Icons.abc_outlined),
                  ),
                  ButtonSegment(
                    value: 'ml',
                    label: Text(context.l10n.settingsLanguageMalayalam),
                    icon: const Icon(Icons.translate_outlined),
                  ),
                ],
                selected: {selectedLanguageCode},
                onSelectionChanged: (selection) {
                  ref.read(localeProvider.notifier).setLocale(selection.first);
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          AppSectionCard(
            title: context.l10n.settingsShortcuts,
            child: Column(
              children: [
                SettingsLinkTile(
                  icon: Icons.backup_rounded,
                  title: context.l10n.backupLabel,
                  onTap: () => context.push(AppRoutes.backup),
                ),
                const Divider(height: 20),
                SettingsLinkTile(
                  icon: Icons.shield_outlined,
                  title: context.l10n.settingsPermissions,
                  onTap: () => context.push(AppRoutes.permissions),
                ),
                const Divider(height: 20),
                SettingsLinkTile(
                  icon: Icons.info_outline_rounded,
                  title: context.l10n.settingsAboutApp,
                  onTap: () => context.push(AppRoutes.about),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppSectionCard(
            title: context.l10n.settingsOfflineTitle,
            child: Text(context.l10n.settingsOfflineBody),
          ),
        ],
      ),
    );
  }
}
