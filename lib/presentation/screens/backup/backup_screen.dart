import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sreerajp_todo/application/providers.dart';
import 'package:sreerajp_todo/core/constants/app_routes.dart';
import 'package:sreerajp_todo/core/errors/exceptions.dart';
import 'package:sreerajp_todo/core/extensions/localization_extensions.dart';
import 'package:sreerajp_todo/core/utils/date_utils.dart';
import 'package:sreerajp_todo/data/backup/backup_file_info.dart';
import 'package:sreerajp_todo/presentation/screens/backup/widgets/backup_health_dashboard.dart';
import 'package:sreerajp_todo/presentation/screens/backup/widgets/backup_list_tile.dart';
import 'package:sreerajp_todo/presentation/shared/widgets/app_empty_state.dart';
import 'package:sreerajp_todo/presentation/shared/widgets/app_section_card.dart';
import 'package:sreerajp_todo/presentation/shared/widgets/confirm_dialog.dart';
import 'package:sreerajp_todo/data/models/todo_entity.dart';
import 'package:sreerajp_todo/presentation/widgets/air_qr_share_dialog.dart';
import 'package:sreerajp_todo/data/services/air_qr_payload_service.dart';
import 'package:sreerajp_todo/presentation/widgets/air_qr_preview_sheet.dart';

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
    final l10n = context.l10n;
    final passphrase = await _showPassphraseDialog(requireConfirmation: true);
    if (passphrase == null || !mounted) {
      return;
    }

    final selectedDirectory = await FilePicker.platform.getDirectoryPath();
    final destinationDirectory =
        selectedDirectory ??
        await ref.read(backupServiceProvider).getDefaultBackupDirectory();

    await _runBusyOperation(l10n.backupExportInProgress, () async {
      final path = await ref
          .read(backupServiceProvider)
          .exportDatabase(
            destinationPath: destinationDirectory,
            passphrase: passphrase,
          );
      await _loadBackups();
      ref.invalidate(backupHealthLogsProvider);
      if (!mounted) {
        return;
      }
      _showSnackBar('${l10n.backupExportSuccess} $path');
    }, retry: _handleExport);
  }

  Future<void> _handleImport() async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['db', 'aes'],
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
      title: context.l10n.backupImportConfirmTitle,
      content: context.l10n.backupImportConfirmMessage,
    );
    if (!confirmed || !mounted) {
      return;
    }

    await _runBusyOperation(context.l10n.backupImportInProgress, () async {
      await ref
          .read(backupServiceProvider)
          .importDatabase(sourcePath: sourcePath, passphrase: passphrase);
      await ref.read(repairOrphanedSegmentsProvider).call();
      await ref.read(generateRecurringTasksProvider).call();
      ref.invalidate(dailyTodoProvider(todayAsIso()));
      ref.invalidate(recurrenceRulesProvider);
      ref.invalidate(backupHealthLogsProvider);
      if (!mounted) {
        return;
      }
      _showSnackBar(context.l10n.backupImportSuccess);
      context.go(AppRoutes.dailyListPath(todayAsIso()));
    }, retry: _handleImport);
  }

  Future<void> _handleDelete(BackupFileInfo info) async {
    final confirmed = await showConfirmDialog(
      context,
      title: context.l10n.backupDeleteBackupConfirm,
      content: info.fileName,
    );
    if (!confirmed || !mounted) {
      return;
    }

    await _runBusyOperation(context.l10n.backupLabel, () async {
      await ref.read(backupServiceProvider).deleteBackup(info.filePath);
      await _loadBackups();
      ref.invalidate(backupHealthLogsProvider);
      if (!mounted) {
        return;
      }
      _showSnackBar(context.l10n.backupDeleteSuccess);
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
      return context.l10n.backupPassphraseMinLength;
    }
    if (error is BackupVersionTooNewException) {
      return context.l10n.backupImportVersionTooNew;
    }
    if (error is BackupCorruptedException) {
      if (error.details == 'wrong_passphrase') {
        return context.l10n.backupImportWrongPassphrase;
      }
      return context.l10n.backupImportCorrupted;
    }
    if (error is FileSystemException) {
      return context.l10n.backupImportCorrupted;
    }
    return context.l10n.errorRetryableGeneric;
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
                label: context.l10n.retry,
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

  void _showAirQrDialog(List<TodoEntity> todos) {
    showAirQrShareDialog(
      context,
      title: 'AirQR Backup Share',
      todos: todos,
      date: todayAsIso(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.backupLabel),
        actions: [
          IconButton(
            onPressed: () async {
              final repository = ref.read(todoRepositoryProvider);
              final todos = await repository.getTodosByDate(todayAsIso());
              if (!mounted) return;
              _showAirQrDialog(todos);
            },
            icon: const Icon(Icons.qr_code_2),
            tooltip: 'AirQR Share Stream',
          ),
          IconButton(
            onPressed: () async {
              final result = await context.push<Map<String, dynamic>>(
                AppRoutes.airQrScan,
              );
              if (result != null && mounted) {
                final payload = result['payload'] as AirQrParsedPayload?;
                final decision = result['decision'] as AirQrMergeDecision?;
                if (payload != null &&
                    decision != null &&
                    decision != AirQrMergeDecision.cancel) {
                  _showSnackBar(
                    'AirQR backup payload received (${payload.todos.length} tasks).',
                  );
                }
              }
            },
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: 'AirQR Scan Camera',
          ),
          IconButton(
            onPressed: _isBusy
                ? null
                : () {
                    _loadBackups();
                    ref.invalidate(backupHealthLogsProvider);
                  },
            icon: const Icon(Icons.refresh),
            tooltip: context.l10n.retry,
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                const BackupHealthDashboard(),
                const SizedBox(height: 16),
                AppSectionCard(
                  title: context.l10n.backupLabel,
                  subtitle: _backupDirectory == null
                      ? null
                      : '${context.l10n.backupDirectory}: $_backupDirectory',
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final compact = constraints.maxWidth < 420;
                      final exportButton = FilledButton.icon(
                        onPressed: _isBusy ? null : _handleExport,
                        icon: const Icon(Icons.upload_file_outlined),
                        label: Text(context.l10n.backupExportTitle),
                      );
                      final importButton = ElevatedButton.icon(
                        onPressed: _isBusy ? null : _handleImport,
                        icon: const Icon(Icons.download_for_offline_outlined),
                        label: Text(context.l10n.backupImportTitle),
                      );

                      if (compact) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            exportButton,
                            const SizedBox(height: 12),
                            importButton,
                          ],
                        );
                      }

                      return Row(
                        children: [
                          Expanded(child: exportButton),
                          const SizedBox(width: 12),
                          Expanded(child: importButton),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                if (_isLoading)
                  const AppSectionCard(
                    child: SizedBox(
                      height: 220,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  )
                else if (_backups.isEmpty)
                  AppSectionCard(
                    title: context.l10n.backupRecentBackups,
                    child: AppEmptyState(
                      icon: Icons.backup_outlined,
                      title: context.l10n.backupNoBackupsFound,
                      message: context.l10n.backupNoBackupsFoundDetailed,
                    ),
                  )
                else
                  AppSectionCard(
                    title: context.l10n.backupRecentBackups,
                    child: Column(
                      children: [
                        for (var i = 0; i < _backups.length; i++) ...[
                          BackupListTile(
                            info: _backups[i],
                            onDelete: _isBusy
                                ? null
                                : () => _handleDelete(_backups[i]),
                          ),
                          if (i != _backups.length - 1)
                            const SizedBox(height: 12),
                        ],
                      ],
                    ),
                  ),
              ],
            ),
            if (_busyMessage != null)
              Positioned.fill(
                child: ColoredBox(
                  color: theme.colorScheme.surface.withValues(alpha: 0.8),
                  child: Center(
                    child: SizedBox(
                      width: 280,
                      child: AppSectionCard(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircularProgressIndicator(),
                            const SizedBox(height: 16),
                            Text(_busyMessage!, textAlign: TextAlign.center),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
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
      setState(() => _errorText = context.l10n.backupPassphraseMinLength);
      return;
    }
    if (widget.requireConfirmation && passphrase != _confirmController.text) {
      setState(() => _errorText = context.l10n.backupPassphraseMismatch);
      return;
    }

    Navigator.of(context).pop(passphrase);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.requireConfirmation
            ? context.l10n.backupExportTitle
            : context.l10n.backupImportTitle,
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
                labelText: context.l10n.backupPassphraseLabel,
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
                  labelText: context.l10n.backupPassphraseConfirmLabel,
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
                  Expanded(child: Text(context.l10n.backupPassphraseWarning)),
                ],
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.l10n.cancel),
        ),
        FilledButton(onPressed: _submit, child: Text(context.l10n.confirm)),
      ],
    );
  }
}
