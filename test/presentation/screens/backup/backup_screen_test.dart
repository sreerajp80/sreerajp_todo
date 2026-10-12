import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:sreerajp_todo/application/providers.dart';
import 'package:sreerajp_todo/data/backup/backup_service.dart';
import 'package:sreerajp_todo/l10n/app_localizations.dart';
import 'package:sreerajp_todo/presentation/screens/backup/backup_screen.dart';

import '../../../helpers/test_fixtures.dart';
import '../../../helpers/test_l10n.dart';

class MockBackupService extends Mock implements BackupService {}

class FakeFilePicker extends FilePickerPlatform
    with MockPlatformInterfaceMixin {
  FakeFilePicker({this.pickedFile, this.directoryPath});

  final PlatformFile? pickedFile;
  final String? directoryPath;

  @override
  Future<String?> getDirectoryPath({
    String? dialogTitle,
    String? initialDirectory,
    AndroidOptions androidOptions = const AndroidOptions(),
    WindowsOptions windowsOptions = const WindowsOptions(),
    LinuxOptions linuxOptions = const LinuxOptions(),
    WebOptions webOptions = const WebOptions(),
  }) async => directoryPath;

  @override
  Future<PlatformFile?> pickFile({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Function(FilePickerStatus)? onFileLoading,
    int compressionQuality = 0,
    AndroidOptions androidOptions = const AndroidOptions(),
    DarwinOptions darwinOptions = const DarwinOptions(),
    WindowsOptions windowsOptions = const WindowsOptions(),
    LinuxOptions linuxOptions = const LinuxOptions(),
    WebOptions webOptions = const WebOptions(),
  }) async => pickedFile;
}

final class FakePlatformFile extends PlatformFile {
  FakePlatformFile({required this.name, required this.uri});

  @override
  final String name;

  @override
  final Uri uri;

  @override
  get xFile => throw UnimplementedError();

  @override
  int? lengthSync() => 1;

  @override
  Future<int?> length() async => 1;

  @override
  Future<Uint8List> readAsBytes() async => Uint8List(1);

  @override
  Stream<Uint8List> readAsByteStream() => Stream.value(Uint8List(1));
}

void main() {
  late MockBackupService backupService;
  late FilePickerPlatform originalFilePicker;

  setUp(() {
    backupService = MockBackupService();
    originalFilePicker = FilePickerPlatform.instance;
    FilePickerPlatform.instance = FakeFilePicker();

    when(() => backupService.getDefaultBackupDirectory())
        .thenAnswer((_) async => r'L:\Backups');
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
    FilePickerPlatform.instance = originalFilePicker;
  });

  Future<void> pumpBackupScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          backupServiceProvider.overrideWithValue(backupService),
          backupHealthLogsProvider.overrideWith((ref) async => []),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: BackupScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('renders export and import actions with backup list', (
    tester,
  ) async {
    await pumpBackupScreen(tester);

    expect(find.text(testL10n.backupExportTitle), findsOneWidget);
    expect(find.text(testL10n.backupImportTitle), findsOneWidget);
    expect(find.text(testL10n.backupRecentBackups), findsOneWidget);
    expect(find.text('backup_a.db'), findsOneWidget);
  });

  testWidgets('shows passphrase dialog when export is tapped', (tester) async {
    await pumpBackupScreen(tester);

    await tester.tap(find.text(testL10n.backupExportTitle));
    await tester.pumpAndSettle();

    expect(find.text(testL10n.backupPassphraseLabel), findsOneWidget);
    expect(find.text(testL10n.backupPassphraseConfirmLabel), findsOneWidget);
    expect(find.text(testL10n.backupPassphraseWarning), findsOneWidget);
  });

  testWidgets('shows import confirmation dialog after passphrase entry', (
    tester,
  ) async {
    FilePickerPlatform.instance = FakeFilePicker(
      pickedFile: FakePlatformFile(
        name: 'picked.db',
        uri: Uri.file(r'L:\Backups\picked.db', windows: true),
      ),
    );

    await pumpBackupScreen(tester);

    await tester.tap(find.text(testL10n.backupImportTitle));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'testpass123');
    await tester.tap(find.text(testL10n.confirm));
    await tester.pumpAndSettle();

    expect(find.text(testL10n.backupImportConfirmTitle), findsOneWidget);
    expect(find.text(testL10n.backupImportConfirmMessage), findsOneWidget);
  });

  testWidgets('shows delete confirmation dialog for a listed backup', (
    tester,
  ) async {
    await pumpBackupScreen(tester);

    await tester.tap(find.byTooltip(testL10n.delete));
    await tester.pumpAndSettle();

    expect(find.text(testL10n.backupDeleteBackupConfirm), findsOneWidget);
    expect(find.text('backup_a.db'), findsWidgets);
  });
}
