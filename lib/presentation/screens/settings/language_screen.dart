import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sreerajp_todo/application/providers.dart';
import 'package:sreerajp_todo/core/extensions/localization_extensions.dart';
import 'package:sreerajp_todo/presentation/shared/widgets/app_section_card.dart';

/// Language picker: system default, English or Malayalam.
class LanguageScreen extends ConsumerWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final locale = ref.watch(localeProvider);
    final selected = locale?.languageCode ?? 'system';

    final options = <({String code, String label, IconData icon})>[
      (
        code: 'system',
        label: l10n.settingsLanguageSystem,
        icon: Icons.language_outlined,
      ),
      (
        code: 'en',
        label: l10n.settingsLanguageEnglish,
        icon: Icons.abc_outlined,
      ),
      (
        code: 'ml',
        label: l10n.settingsLanguageMalayalam,
        icon: Icons.translate_outlined,
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsLanguage)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppSectionCard(
            title: l10n.settingsLanguage,
            subtitle: l10n.settingsLanguageSubtitle,
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
            child: RadioGroup<String>(
              groupValue: selected,
              onChanged: (value) {
                if (value == null) return;
                ref.read(localeProvider.notifier).setLocale(value);
              },
              child: Column(
                children: [
                  for (final option in options)
                    RadioListTile<String>(
                      value: option.code,
                      contentPadding: EdgeInsets.zero,
                      secondary: Icon(option.icon),
                      title: Text(option.label),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
