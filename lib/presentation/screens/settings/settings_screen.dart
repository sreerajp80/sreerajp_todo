import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sreerajp_todo/application/providers.dart';
import 'package:sreerajp_todo/core/constants/app_routes.dart';
import 'package:sreerajp_todo/core/constants/app_strings.dart';
import 'package:sreerajp_todo/presentation/screens/settings/widgets/settings_link_tile.dart';
import 'package:sreerajp_todo/presentation/shared/widgets/app_section_card.dart';
import 'package:sreerajp_todo/presentation/shared/widgets/responsive_scaffold.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return ResponsiveScaffold(
      currentDestination: AppScaffoldDestination.settings,
      appBar: AppBar(title: Text(AppStrings.settings.label)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppSectionCard(
            title: AppStrings.settings.appearance,
            subtitle: AppStrings.settings.themeMode,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SegmentedButton<ThemeMode>(
                segments: [
                  ButtonSegment(
                    value: ThemeMode.system,
                    label: Text(AppStrings.settings.followSystem),
                    icon: const Icon(Icons.brightness_auto_outlined),
                  ),
                  ButtonSegment(
                    value: ThemeMode.light,
                    label: Text(AppStrings.settings.light),
                    icon: const Icon(Icons.light_mode_outlined),
                  ),
                  ButtonSegment(
                    value: ThemeMode.dark,
                    label: Text(AppStrings.settings.dark),
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
            title: AppStrings.settings.shortcuts,
            child: Column(
              children: [
                SettingsLinkTile(
                  icon: Icons.backup_rounded,
                  title: AppStrings.backup.label,
                  onTap: () => context.push(AppRoutes.backup),
                ),
                const Divider(height: 20),
                SettingsLinkTile(
                  icon: Icons.shield_outlined,
                  title: AppStrings.settings.permissions,
                  onTap: () => context.push(AppRoutes.permissions),
                ),
                const Divider(height: 20),
                SettingsLinkTile(
                  icon: Icons.info_outline_rounded,
                  title: AppStrings.settings.aboutApp,
                  onTap: () => context.push(AppRoutes.about),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppSectionCard(
            title: AppStrings.settings.offlineTitle,
            child: Text(AppStrings.settings.offlineBody),
          ),
        ],
      ),
    );
  }
}
