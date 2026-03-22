import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sreerajp_todo/application/providers.dart';
import 'package:sreerajp_todo/core/constants/app_routes.dart';
import 'package:sreerajp_todo/core/constants/app_strings.dart';
import 'package:sreerajp_todo/core/errors/exceptions.dart';
import 'package:sreerajp_todo/core/utils/date_utils.dart';
import 'package:sreerajp_todo/data/backup/backup_file_info.dart';
import 'package:sreerajp_todo/presentation/screens/backup/widgets/backup_list_tile.dart';
import 'package:sreerajp_todo/presentation/shared/widgets/app_empty_state.dart';
import 'package:sreerajp_todo/presentation/shared/widgets/confirm_dialog.dart';
import 'package:sreerajp_todo/presentation/shared/widgets/responsive_scaffold.dart';

class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  List<BackupFileInfo> _backups = const [];
  String? _backupDirectory;
  String? _busyMessage;
  bool _isLoading = true;

  bool get _isBusy => _busyMessage != null;

  @override
  void initState() {
    super.initState();
    _loadBackups();
  }

  Future<void> _loadBackups() async {
    final backupService = ref.read(backupServiceProvider);
    final directory = await backupService.getDefaultBackupDirectory();
    final backups = await backupService.listBackups(directory);
    if (!mounted) {
      return;
    }

    setState(() {
      _backupDirectory = directory;
      _backups = backups;
      _isLoading = false;
    });
  }

  Future<void> _handleExport() async {
    final passphrase = await _showPassphraseDialog(requireConfirmation: true);
    if (passphrase == null || !mounted) {
      return;
    }

    final selectedDirectory = await FilePicker.platform.getDirectoryPath();
    final destinationDirectory =
        selectedDirectory ??
        await ref.read(backupServiceProvider).getDefaultBackupDirectory();

    await _runBusyOperation(AppStrings.backup.exportInProgress, () async {
      final path = await ref
          .read(backupServiceProvider)
          .exportDatabase(
            destinationPath: destinationDirectory,
            passphrase: passphrase,
          );
      await _loadBackups();
      if (!mounted) {
        return;
      }
      _showSnackBar('${AppStrings.backup.exportSuccess} $path');
    }, retry: _handleExport);
  }

  Future<void> _handleImport() async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['db'],
      withData: false,
    );
    final sourcePath = picked?.files.single.path;
    if (sourcePath == null || !mounted) {
      return;
    }

    final passphrase = await _showPassphraseDialog(requireConfirmation: false);
    if (passphrase == null || !mounted) {
      return;
    }

    final confirmed = await showConfirmDialog(
      context,
      title: AppStrings.backup.importConfirmTitle,
      content: AppStrings.backup.importConfirmMessage,
    );
    if (!confirmed || !mounted) {
      return;
    }

    await _runBusyOperation(AppStrings.backup.importInProgress, () async {
      await ref
          .read(backupServiceProvider)
          .importDatabase(sourcePath: sourcePath, passphrase: passphrase);
      await ref.read(repairOrphanedSegmentsProvider).call();
      await ref.read(generateRecurringTasksProvider).call();
      ref.invalidate(dailyTodoProvider(todayAsIso()));
      ref.invalidate(recurrenceRulesProvider);
      if (!mounted) {
        return;
      }
      _showSnackBar(AppStrings.backup.importSuccess);
      context.go(AppRoutes.dailyListPath(todayAsIso()));
    }, retry: _handleImport);
  }

  Future<void> _handleDelete(BackupFileInfo info) async {
    final confirmed = await showConfirmDialog(
      context,
      title: AppStrings.backup.deleteBackupConfirm,
      content: info.fileName,
    );
    if (!confirmed || !mounted) {
      return;
    }

    await _runBusyOperation(AppStrings.backup.label, () async {
      await ref.read(backupServiceProvider).deleteBackup(info.filePath);
      await _loadBackups();
      if (!mounted) {
        return;
      }
      _showSnackBar(AppStrings.backup.deleteSuccess);
    }, retry: () => _handleDelete(info));
  }

  Future<void> _runBusyOperation(
    String busyMessage,
    Future<void> Function() action, {
    Future<void> Function()? retry,
  }) async {
    setState(() => _busyMessage = busyMessage);
    try {
      await action();
    } on Exception catch (error) {
      if (!mounted) {
        return;
      }
      _showSnackBar(_messageForError(error), retry: retry);
    } finally {
      if (mounted) {
        setState(() => _busyMessage = null);
      }
    }
  }

  String _messageForError(Object error) {
    if (error is ArgumentError) {
      return AppStrings.backup.passphraseMinLength;
    }
    if (error is BackupVersionTooNewException) {
      return AppStrings.backup.importVersionTooNew;
    }
    if (error is BackupCorruptedException) {
      if (error.details == 'wrong_passphrase') {
        return AppStrings.backup.importWrongPassphrase;
      }
      return AppStrings.backup.importCorrupted;
    }
    if (error is FileSystemException) {
      return AppStrings.backup.importCorrupted;
    }
    return AppStrings.errors.retryableGeneric;
  }

  void _showSnackBar(String message, {Future<void> Function()? retry}) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        action: retry == null
            ? null
            : SnackBarAction(
                label: AppStrings.retry,
                onPressed: () {
                  retry();
                },
              ),
      ),
    );
  }

  Future<String?> _showPassphraseDialog({required bool requireConfirmation}) {
    return showDialog<String>(
      context: context,
      builder: (context) =>
          _PassphraseDialog(requireConfirmation: requireConfirmation),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ResponsiveScaffold(
      currentDestination: AppScaffoldDestination.backup,
      appBar: AppBar(
        title: Text(AppStrings.backup.label),
        actions: [
          IconButton(
            onPressed: _isBusy ? null : _loadBackups,
            icon: const Icon(Icons.refresh),
            tooltip: AppStrings.retry,
          ),
        ],
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  FilledButton.icon(
                    onPressed: _isBusy ? null : _handleExport,
                    icon: const Icon(Icons.upload_file_outlined),
                    label: Text(AppStrings.backup.exportTitle),
                  ),
                  FilledButton.tonalIcon(
                    onPressed: _isBusy ? null : _handleImport,
                    icon: const Icon(Icons.download_for_offline_outlined),
                    label: Text(AppStrings.backup.importTitle),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                AppStrings.backup.recentBackups,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              if (_backupDirectory != null)
                Text(
                  '${AppStrings.backupDirectory}: $_backupDirectory',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              const SizedBox(height: 12),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_backups.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: AppEmptyState(
                    icon: Icons.backup_outlined,
                    title: AppStrings.backup.noBackupsFound,
                    message: AppStrings.backup.noBackupsFoundDetailed,
                  ),
                )
              else
                ..._backups.map(
                  (info) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: BackupListTile(
                      info: info,
                      onDelete: _isBusy ? null : () => _handleDelete(info),
                    ),
                  ),
                ),
            ],
          ),
          if (_busyMessage != null)
            Positioned.fill(
              child: ColoredBox(
                color: theme.colorScheme.surface.withValues(alpha: 0.8),
                child: Center(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 16),
                          Text(_busyMessage!),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PassphraseDialog extends StatefulWidget {
  const _PassphraseDialog({required this.requireConfirmation});

  final bool requireConfirmation;

  @override
  State<_PassphraseDialog> createState() => _PassphraseDialogState();
}

class _PassphraseDialogState extends State<_PassphraseDialog> {
  final _passphraseController = TextEditingController();
  final _confirmController = TextEditingController();
  String? _errorText;
  bool _obscureText = true;

  @override
  void dispose() {
    _passphraseController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _submit() {
    final passphrase = _passphraseController.text;
    if (passphrase.length < 8) {
      setState(() => _errorText = AppStrings.backup.passphraseMinLength);
      return;
    }
    if (widget.requireConfirmation && passphrase != _confirmController.text) {
      setState(() => _errorText = AppStrings.backup.passphraseMismatch);
      return;
    }

    Navigator.of(context).pop(passphrase);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.requireConfirmation
            ? AppStrings.backup.exportTitle
            : AppStrings.backup.importTitle,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _passphraseController,
              obscureText: _obscureText,
              decoration: InputDecoration(
                labelText: AppStrings.backup.passphraseLabel,
                errorText: _errorText,
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() => _obscureText = !_obscureText);
                  },
                  icon: Icon(
                    _obscureText ? Icons.visibility : Icons.visibility_off,
                  ),
                ),
              ),
              onSubmitted: (_) {
                if (!widget.requireConfirmation) {
                  _submit();
                }
              },
            ),
            if (widget.requireConfirmation) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _confirmController,
                obscureText: _obscureText,
                decoration: InputDecoration(
                  labelText: AppStrings.backup.passphraseConfirmLabel,
                ),
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(Icons.warning_amber_rounded, size: 18),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(AppStrings.backup.passphraseWarning)),
                ],
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(AppStrings.cancel),
        ),
        FilledButton(onPressed: _submit, child: const Text(AppStrings.confirm)),
      ],
    );
  }
}
