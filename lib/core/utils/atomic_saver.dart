import 'dart:io';
import 'package:path/path.dart' as p;

/// Fail-safe atomic file saver utility that stages writes via temporary files
/// and provides automatic rollback protection if an operation fails.
class AtomicSaver {
  const AtomicSaver._();

  /// Atomically replaces [targetPath] with [sourcePath].
  ///
  /// Staging is done inside [targetPath]'s parent directory. If an error occurs
  /// during replacement, the pre-existing target file is automatically restored.
  static Future<void> replaceFileAtomically({
    required String sourcePath,
    required String targetPath,
    List<String> auxiliaryFilesToDelete = const [],
  }) async {
    final targetFile = File(targetPath);
    final targetDir = targetFile.parent;
    if (!await targetDir.exists()) {
      await targetDir.create(recursive: true);
    }

    final timestamp = DateTime.now().microsecondsSinceEpoch;
    final safetyBackupPath = p.join(
      targetDir.path,
      '${p.basename(targetPath)}.atomic_backup_$timestamp',
    );
    final tempStagingPath = p.join(
      targetDir.path,
      '${p.basename(targetPath)}.atomic_stage_$timestamp',
    );

    var safetyBackupCreated = false;

    try {
      // Step 1: Create a safety copy of the existing target file if present
      if (await targetFile.exists()) {
        await targetFile.copy(safetyBackupPath);
        safetyBackupCreated = true;
      }

      // Step 2: Copy source to temporary staging file in target directory
      final sourceFile = File(sourcePath);
      await sourceFile.copy(tempStagingPath);

      // Step 3: Delete target file and any auxiliary files (e.g., SQLite WAL/SHM)
      if (await targetFile.exists()) {
        await targetFile.delete();
      }
      for (final auxPath in auxiliaryFilesToDelete) {
        final auxFile = File(auxPath);
        if (await auxFile.exists()) {
          await auxFile.delete();
        }
      }

      // Step 4: Atomically move staging file to target location
      final stagingFile = File(tempStagingPath);
      await stagingFile.rename(targetPath);
    } catch (error) {
      // Rollback: Restore target file from safety copy if swap failed
      if (safetyBackupCreated) {
        final safetyFile = File(safetyBackupPath);
        if (await safetyFile.exists()) {
          if (await targetFile.exists()) {
            await targetFile.delete();
          }
          await safetyFile.copy(targetPath);
        }
      }
      rethrow;
    } finally {
      // Clean up temporary staging and safety backup files
      await _safeDeleteFile(tempStagingPath);
      if (safetyBackupCreated) {
        await _safeDeleteFile(safetyBackupPath);
      }
    }
  }

  static Future<void> _safeDeleteFile(String path) async {
    final file = File(path);
    if (await file.exists()) {
      try {
        await file.delete();
      } catch (_) {}
    }
  }
}
