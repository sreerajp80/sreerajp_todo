import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sreerajp_todo/application/providers.dart';
import 'package:sreerajp_todo/core/extensions/localization_extensions.dart';
import 'package:sreerajp_todo/core/utils/app_lock_rules.dart';
import 'package:sreerajp_todo/l10n/app_localizations.dart';
import 'package:sreerajp_todo/presentation/screens/settings/widgets/settings_choice_list.dart';
import 'package:sreerajp_todo/presentation/screens/settings/widgets/settings_note_card.dart';
import 'package:sreerajp_todo/presentation/shared/security_labels.dart';
import 'package:sreerajp_todo/presentation/shared/widgets/app_section_card.dart';

/// Settings -> Security & privacy -> App lock.
class AppLockScreen extends ConsumerStatefulWidget {
  const AppLockScreen({super.key});

  @override
  ConsumerState<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends ConsumerState<AppLockScreen> {
  /// Whether the phone has a screen lock of its own. Read once, because it
  /// cannot change while this page is open.
  bool _deviceCredentialAvailable = false;

  @override
  void initState() {
    super.initState();
    _loadDeviceCredentialSupport();
  }

  Future<void> _loadDeviceCredentialSupport() async {
    final available = await ref
        .read(securitySettingsProvider.notifier)
        .isDeviceCredentialAvailable();
    if (!mounted) return;
    setState(() => _deviceCredentialAvailable = available);
  }

  Future<void> _onModeChosen(AppLockMode mode) async {
    final notifier = ref.read(securitySettingsProvider.notifier);
    final l10n = context.l10n;

    if (mode == AppLockMode.off) {
      await notifier.disableLock();
      // Turning the lock off while the app is open must not leave a lock
      // screen sitting on top of it.
      ref.read(appLockProvider.notifier).releaseBecauseLockDisabled();
      if (mounted) _showMessage(l10n.appLockRemoved);
      return;
    }

    if (mode == AppLockMode.deviceCredential) {
      if (!_deviceCredentialAvailable) return;
      await notifier.useDeviceCredential();
      if (mounted) _showMessage(l10n.appLockSaved);
      return;
    }

    await _promptForSecret(mode);
  }

  Future<void> _promptForSecret(AppLockMode mode) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => _SecretDialog(mode: mode),
    );
    if (saved == true && mounted) {
      _showMessage(context.l10n.appLockSaved);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final settings = ref.watch(securitySettingsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.securityAppLock)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SettingsChoiceList<AppLockMode>(
            title: l10n.appLockModeTitle,
            subtitle: l10n.appLockModeSubtitle,
            selected: settings.lockMode,
            onChanged: _onModeChosen,
            choices: [
              for (final mode in AppLockMode.values)
                SettingsChoice(
                  value: mode,
                  label: appLockModeName(l10n, mode),
                  detail: _detailFor(l10n, mode),
                ),
            ],
          ),
          if (settings.needsTypedSecret) ...[
            const SizedBox(height: 16),
            AppSectionCard(
              child: Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: () => _promptForSecret(settings.lockMode),
                  icon: const Icon(Icons.edit_outlined),
                  label: Text(l10n.appLockChange),
                ),
              ),
            ),
          ],
          if (settings.isLockEnabled) ...[
            const SizedBox(height: 16),
            AppSectionCard(
              title: l10n.appLockWarningTitle,
              child: Text(l10n.appLockWarningBody),
            ),
          ],
          if (!_deviceCredentialAvailable) ...[
            const SizedBox(height: 16),
            SettingsNoteCard(text: l10n.appLockDeviceUnavailable),
          ],
        ],
      ),
    );
  }

  String? _detailFor(AppLocalizations l10n, AppLockMode mode) {
    if (mode != AppLockMode.deviceCredential) return null;
    return _deviceCredentialAvailable
        ? l10n.appLockDeviceCredentialDetail
        : l10n.appLockDeviceUnavailable;
  }
}

/// Asks for a new PIN or password twice, and saves it when both match.
class _SecretDialog extends ConsumerStatefulWidget {
  const _SecretDialog({required this.mode});

  final AppLockMode mode;

  @override
  ConsumerState<_SecretDialog> createState() => _SecretDialogState();
}

class _SecretDialogState extends ConsumerState<_SecretDialog> {
  final _firstController = TextEditingController();
  final _secondController = TextEditingController();

  String? _error;
  bool _isSaving = false;

  bool get _isPin => widget.mode == AppLockMode.pin;

  @override
  void dispose() {
    // Clearing the controllers first means the typed secret is not left
    // sitting in a detached buffer.
    _firstController.clear();
    _secondController.clear();
    _firstController.dispose();
    _secondController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    final first = _firstController.text;
    final second = _secondController.text;

    final rejection = validateNewSecret(widget.mode, first);
    if (rejection != null) {
      setState(() {
        _error = secretRejectionMessage(l10n, widget.mode, rejection);
      });
      return;
    }
    if (first != second) {
      setState(() {
        _error = secretRejectionMessage(
          l10n,
          widget.mode,
          SecretRejection.mismatch,
        );
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _error = null;
    });

    final failure = await ref
        .read(securitySettingsProvider.notifier)
        .setSecret(widget.mode, first);

    if (!mounted) return;
    if (failure != null) {
      setState(() {
        _isSaving = false;
        _error = secretRejectionMessage(l10n, widget.mode, failure);
      });
      return;
    }
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AlertDialog(
      title: Text(_isPin ? l10n.appLockSetPin : l10n.appLockSetPassword),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _firstController,
            autofocus: true,
            obscureText: true,
            keyboardType: _isPin ? TextInputType.number : TextInputType.text,
            inputFormatters: _isPin
                ? [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(kMaxPinLength),
                  ]
                : null,
            decoration: InputDecoration(labelText: l10n.appLockNewSecret),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _secondController,
            obscureText: true,
            keyboardType: _isPin ? TextInputType.number : TextInputType.text,
            inputFormatters: _isPin
                ? [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(kMaxPinLength),
                  ]
                : null,
            decoration: InputDecoration(labelText: l10n.appLockConfirmSecret),
            onSubmitted: (_) => _save(),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _save,
          child: Text(l10n.save),
        ),
      ],
    );
  }
}
