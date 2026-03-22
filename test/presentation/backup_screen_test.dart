import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sreerajp_todo/application/providers.dart';
import 'package:sreerajp_todo/core/constants/app_strings.dart';
import 'package:sreerajp_todo/data/backup/backup_service.dart';
import 'package:sreerajp_todo/presentation/screens/backup/backup_screen.dart';

import '../helpers/test_fixtures.dart';

class MockBackupService extends Mock implements BackupService {}

class FakeFilePicker extends FilePicker {
  FakeFilePicker({this.pickFilesResult, this.directoryPath});

  final FilePickerResult? pickFilesResult;
  final String? directoryPath;

  @override
  Future<bool?> clearTemporaryFiles() async => true;

  @override
  Future<String?> getDirectoryPath({
    String? dialogTitle,
    bool lockParentWindow = false,
    String? initialDirectory,
  }) async => directoryPath;

  @override
  Future<FilePickerResult?> pickFiles({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Function(FilePickerStatus)? onFileLoading,
    bool allowCompression = true,
    int compressionQuality = 30,
    bool allowMultiple = false,
    bool withData = false,
    bool withReadStream = false,
    bool lockParentWindow = false,
    bool readSequential = false,
  }) async => pickFilesResult;

  @override
  Future<String?> saveFile({
    String? dialogTitle,
    String? fileName,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Uint8List? bytes,
    bool lockParentWindow = false,
  }) async => null;
}

void main() {
  late MockBackupService backupService;
  FilePicker? originalFilePicker;

  setUp(() {
    backupService = MockBackupService();
    try {
      originalFilePicker = FilePicker.platform;
    } catch (_) {
      originalFilePicker = null;
    }
    FilePicker.platform = FakeFilePicker();

    when(
      () => backupService.getDefaultBackupDirectory(),
    ).thenAnswer((_) async => r'L:\Backups');
    when(() => backupService.listBackups(any())).thenAnswer(
      (_) async => [
        buildBackupInfo(
          filePath: r'L:\Backups\backup_a.db',
          fileName: 'backup_a.db',
          fileSizeBytes: 2048,
        ),
      ],
    );
  });

  tearDown(() {
    if (originalFilePicker != null) {
      FilePicker.platform = originalFilePicker!;
    }
  });

  Future<void> pumpBackupScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [backupServiceProvider.overrideWithValue(backupService)],
        child: const MaterialApp(home: BackupScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('renders export and import actions with backup list', (
    tester,
  ) async {
    await pumpBackupScreen(tester);

    expect(find.text(AppStrings.backup.exportTitle), findsOneWidget);
    expect(find.text(AppStrings.backup.importTitle), findsOneWidget);
    expect(find.text(AppStrings.backup.recentBackups), findsOneWidget);
    expect(find.text('backup_a.db'), findsOneWidget);
  });

  testWidgets('shows passphrase dialog when export is tapped', (tester) async {
    await pumpBackupScreen(tester);

    await tester.tap(find.text(AppStrings.backup.exportTitle));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.backup.passphraseLabel), findsOneWidget);
    expect(find.text(AppStrings.backup.passphraseConfirmLabel), findsOneWidget);
    expect(find.text(AppStrings.backup.passphraseWarning), findsOneWidget);
  });

  testWidgets('shows import confirmation dialog after passphrase entry', (
    tester,
  ) async {
    FilePicker.platform = FakeFilePicker(
      pickFilesResult: FilePickerResult([
        PlatformFile(path: r'L:\Backups\picked.db', name: 'picked.db', size: 1),
      ]),
    );

    await pumpBackupScreen(tester);

    await tester.tap(find.text(AppStrings.backup.importTitle));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'testpass123');
    await tester.tap(find.text(AppStrings.confirm));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.backup.importConfirmTitle), findsOneWidget);
    expect(find.text(AppStrings.backup.importConfirmMessage), findsOneWidget);
  });

  testWidgets('shows delete confirmation dialog for a listed backup', (
    tester,
  ) async {
    await pumpBackupScreen(tester);

    await tester.tap(find.byTooltip(AppStrings.delete));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.backup.deleteBackupConfirm), findsOneWidget);
    expect(find.text('backup_a.db'), findsWidgets);
  });
}
