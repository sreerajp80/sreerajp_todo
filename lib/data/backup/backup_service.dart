import 'dart:io';

// ignore_for_file: depend_on_referenced_packages

import 'package:archive/archive.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sreerajp_todo/core/constants/app_constants.dart';
import 'package:sreerajp_todo/core/errors/exceptions.dart';
import 'package:sreerajp_todo/data/backup/backup_file_info.dart';
import 'package:sreerajp_todo/data/database/database_service.dart';

const _wrongPassphraseDetails = 'wrong_passphrase';
const _invalidArchiveDetails = 'invalid_archive';
const _integrityCheckFailedDetails = 'integrity_check_failed';

class BackupService {
  BackupService(this._dbService, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final DatabaseService _dbService;
  final DateTime Function() _now;

  Future<String> exportDatabase({
    required String destinationPath,
    required String passphrase,
  }) async {
    _validatePassphrase(passphrase);

    final destinationDir = Directory(destinationPath);
    await destinationDir.create(recursive: true);

    final liveDatabasePath = await _dbService.databasePath;
    await _dbService.database;
    await _dbService.checkpoint();
    await _dbService.close();

    final tempDir = await Directory.systemTemp.createTemp(
      'sreerajp_backup_export_',
    );

    try {
      final dbCopyPath = p.join(tempDir.path, p.basename(liveDatabasePath));
      await File(liveDatabasePath).copy(dbCopyPath);

      final backupFilePath = p.join(
        destinationDir.path,
        _buildBackupFileName(_now()),
      );

      await _writeEncryptedArchive(
        databasePath: dbCopyPath,
        outputPath: backupFilePath,
        passphrase: passphrase,
      );
      await _verifyBackupArchive(backupFilePath, passphrase);

      return backupFilePath;
    } finally {
      await _safeDeleteDirectory(tempDir);
      await _dbService.database;
    }
  }

  Future<void> importDatabase({
    required String sourcePath,
    required String passphrase,
  }) async {
    _validatePassphrase(passphrase);

    final sourceFile = File(sourcePath);
    if (!await sourceFile.exists()) {
      throw const BackupCorruptedException(_invalidArchiveDetails);
    }

    final tempDir = await Directory.systemTemp.createTemp(
      'sreerajp_backup_import_',
    );

    final liveDatabasePath = await _dbService.databasePath;
    String? currentDatabaseBackupPath;
    var databaseClosed = false;

    try {
      final extractedDatabasePath = await _extractBackupArchive(
        sourcePath: sourcePath,
        passphrase: passphrase,
        destinationDirectory: tempDir.path,
      );

      final backupVersion = await _readUserVersion(extractedDatabasePath);
      if (backupVersion > kDatabaseVersion) {
        throw BackupVersionTooNewException(backupVersion, kDatabaseVersion);
      }

      if (backupVersion < kDatabaseVersion) {
        await _dbService.migrateExternalDatabase(
          extractedDatabasePath,
          fromVersion: backupVersion,
        );
      }

      await _verifyDatabaseIntegrity(extractedDatabasePath);

      await _dbService.database;
      await _dbService.checkpoint();
      await _dbService.close();
      databaseClosed = true;

      currentDatabaseBackupPath = p.join(
        tempDir.path,
        'current_live_database.db',
      );
      await File(liveDatabasePath).copy(currentDatabaseBackupPath);

      await _deleteDatabaseFiles(liveDatabasePath);
      await File(extractedDatabasePath).copy(liveDatabasePath);
    } catch (error) {
      if (databaseClosed && currentDatabaseBackupPath != null) {
        final safetyCopy = File(currentDatabaseBackupPath);
        if (await safetyCopy.exists()) {
          await _deleteDatabaseFiles(liveDatabasePath);
          await safetyCopy.copy(liveDatabasePath);
        }
      }
      rethrow;
    } finally {
      if (databaseClosed) {
        await _dbService.database;
      }
      await _safeDeleteDirectory(tempDir);
    }
  }

  Future<List<BackupFileInfo>> listBackups(String directory) async {
    final backupDirectory = Directory(directory);
    if (!await backupDirectory.exists()) {
      return const [];
    }

    final files = await backupDirectory
        .list()
        .where(
          (entity) =>
              entity is File && entity.path.toLowerCase().endsWith('.db'),
        )
        .cast<File>()
        .toList();

    final infos = <BackupFileInfo>[];
    for (final file in files) {
      final stat = await file.stat();
      infos.add(
        BackupFileInfo(
          filePath: file.path,
          fileName: p.basename(file.path),
          createdAt: stat.modified,
          fileSizeBytes: stat.size,
        ),
      );
    }

    infos.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return infos;
  }

  Future<void> deleteBackup(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<String> getDefaultBackupDirectory() async {
    Directory? baseDirectory;
    try {
      baseDirectory = await getDownloadsDirectory();
    } catch (_) {
      baseDirectory = null;
    }

    baseDirectory ??= await getApplicationDocumentsDirectory();

    final backupDirectory = Directory(
      p.join(baseDirectory.path, 'SreerajP ToDo', 'Backups'),
    );
    await backupDirectory.create(recursive: true);
    return backupDirectory.path;
  }

  Future<void> _writeEncryptedArchive({
    required String databasePath,
    required String outputPath,
    required String passphrase,
  }) async {
    final archive = Archive();
    archive.addFile(
      ArchiveFile.bytes(
        p.basename(databasePath),
        await File(databasePath).readAsBytes(),
      ),
    );

    final encodedBytes = ZipEncoder(password: passphrase).encodeBytes(archive);
    await File(outputPath).writeAsBytes(encodedBytes, flush: true);
  }

  Future<void> _verifyBackupArchive(
    String backupPath,
    String passphrase,
  ) async {
    final tempDir = await Directory.systemTemp.createTemp(
      'sreerajp_backup_verify_',
    );

    try {
      final extractedPath = await _extractBackupArchive(
        sourcePath: backupPath,
        passphrase: passphrase,
        destinationDirectory: tempDir.path,
      );
      await _verifyDatabaseIntegrity(extractedPath);
    } finally {
      await _safeDeleteDirectory(tempDir);
    }
  }

  Future<String> _extractBackupArchive({
    required String sourcePath,
    required String passphrase,
    required String destinationDirectory,
  }) async {
    try {
      final encodedBytes = await File(sourcePath).readAsBytes();
      final archive = ZipDecoder().decodeBytes(
        encodedBytes,
        verify: true,
        password: passphrase,
      );

      final files = archive.files.where((file) => file.isFile).toList();
      if (files.length != 1) {
        throw const BackupCorruptedException(_invalidArchiveDetails);
      }

      final archiveFile = files.first;
      final bytes = archiveFile.readBytes();
      if (bytes == null) {
        throw const BackupCorruptedException(_invalidArchiveDetails);
      }

      final outputPath = p.join(destinationDirectory, kDatabaseName);
      await File(outputPath).writeAsBytes(bytes, flush: true);
      return outputPath;
    } on BackupCorruptedException {
      rethrow;
    } on Exception catch (error) {
      final details = error.toString().toLowerCase().contains('password')
          ? _wrongPassphraseDetails
          : _invalidArchiveDetails;
      throw BackupCorruptedException(details);
    }
  }

  Future<void> _verifyDatabaseIntegrity(String databasePath) async {
    final db = await _dbService.openDatabaseAt(
      databasePath,
      readOnly: true,
      singleInstance: false,
    );

    try {
      final result = await db.rawQuery('PRAGMA integrity_check');
      final status = result.isEmpty ? null : result.first.values.first;
      if (status != 'ok') {
        throw const BackupCorruptedException(_integrityCheckFailedDetails);
      }
    } finally {
      await db.close();
    }
  }

  Future<int> _readUserVersion(String databasePath) async {
    final db = await _dbService.openDatabaseAt(
      databasePath,
      readOnly: true,
      singleInstance: false,
    );

    try {
      final result = await db.rawQuery('PRAGMA user_version');
      final version = result.isEmpty ? 0 : result.first.values.first;
      if (version is int) {
        return version;
      }
      if (version is num) {
        return version.toInt();
      }
      return 0;
    } finally {
      await db.close();
    }
  }

  Future<void> _deleteDatabaseFiles(String databasePath) async {
    await _deleteFileIfExists(databasePath);
    await _deleteFileIfExists('$databasePath-shm');
    await _deleteFileIfExists('$databasePath-wal');
  }

  Future<void> _deleteFileIfExists(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<void> _safeDeleteDirectory(Directory directory) async {
    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
  }

  void _validatePassphrase(String passphrase) {
    if (passphrase.length < 8) {
      throw ArgumentError(
        'Backup passphrase must be at least 8 characters long.',
      );
    }
  }

  String _buildBackupFileName(DateTime timestamp) {
    final formatter = DateFormat('yyyyMMdd_HHmmss');
    return 'sreerajp_todo_backup_${formatter.format(timestamp)}.db';
  }
}
