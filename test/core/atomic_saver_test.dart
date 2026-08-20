import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sreerajp_todo/core/utils/atomic_saver.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('atomic_saver_test_');
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test(
    'replaceFileAtomically replaces target file when target exists',
    () async {
      final targetPath = p.join(tempDir.path, 'live.db');
      final sourcePath = p.join(tempDir.path, 'new.db');

      await File(targetPath).writeAsString('old_data');
      await File(sourcePath).writeAsString('new_data');

      await AtomicSaver.replaceFileAtomically(
        sourcePath: sourcePath,
        targetPath: targetPath,
      );

      expect(await File(targetPath).readAsString(), equals('new_data'));
    },
  );

  test(
    'replaceFileAtomically creates target file when target does not exist',
    () async {
      final targetPath = p.join(tempDir.path, 'live.db');
      final sourcePath = p.join(tempDir.path, 'new.db');

      await File(sourcePath).writeAsString('new_data');

      await AtomicSaver.replaceFileAtomically(
        sourcePath: sourcePath,
        targetPath: targetPath,
      );

      expect(await File(targetPath).readAsString(), equals('new_data'));
    },
  );

  test('replaceFileAtomically deletes auxiliary files', () async {
    final targetPath = p.join(tempDir.path, 'live.db');
    final walPath = p.join(tempDir.path, 'live.db-wal');
    final shmPath = p.join(tempDir.path, 'live.db-shm');
    final sourcePath = p.join(tempDir.path, 'new.db');

    await File(targetPath).writeAsString('old_data');
    await File(walPath).writeAsString('wal_data');
    await File(shmPath).writeAsString('shm_data');
    await File(sourcePath).writeAsString('new_data');

    await AtomicSaver.replaceFileAtomically(
      sourcePath: sourcePath,
      targetPath: targetPath,
      auxiliaryFilesToDelete: [walPath, shmPath],
    );

    expect(await File(targetPath).readAsString(), equals('new_data'));
    expect(await File(walPath).exists(), isFalse);
    expect(await File(shmPath).exists(), isFalse);
  });
}
