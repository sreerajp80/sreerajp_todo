import 'dart:io';
import 'dart:typed_data';

// ignore_for_file: depend_on_referenced_packages

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sreerajp_todo/core/constants/app_constants.dart';
import 'package:sreerajp_todo/core/errors/exceptions.dart';
import 'package:sreerajp_todo/data/backup/backup_service.dart';
import 'package:sreerajp_todo/data/database/database_service.dart';
import '../helpers/test_database.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late DatabaseService databaseService;
  late BackupService backupService;

  setUp(() async {
    initFfi();
    tempDir = await Directory.systemTemp.createTemp('phase5b_backup_test_');
    databaseService = await createFileBackedTestDatabaseService(tempDir);
    backupService = BackupService(
      databaseService,
      now: () => DateTime(2026, 3, 22, 10, 30, 45),
    );
  });

  tearDown(() async {
    await databaseService.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('export creates a valid backup file at the specified path', () async {
    await _insertTodo(databaseService, title: 'Exported task');

    final backupDirectory = Directory(p.join(tempDir.path, 'backups'));
    final backupPath = await backupService.exportDatabase(
      destinationPath: backupDirectory.path,
      passphrase: 'correct horse battery staple',
    );

    expect(backupPath, endsWith('sreerajp_todo_backup_20260322_103045.db'));
    expect(await File(backupPath).exists(), isTrue);
  });

  test('export leaves the original database unchanged', () async {
    await _insertTodo(databaseService, title: 'Original task');

    final backupDirectory = Directory(p.join(tempDir.path, 'backups'));
    await backupService.exportDatabase(
      destinationPath: backupDirectory.path,
      passphrase: 'correct horse battery staple',
    );

    final db = await databaseService.database;
    final rows = await db.rawQuery('SELECT title FROM todos ORDER BY title');
    expect(rows, hasLength(1));
    expect(rows.first['title'], 'Original task');
  });

  test('exported file can be opened with the passphrase', () async {
    await _insertTodo(databaseService, title: 'Protected task');

    final backupDirectory = Directory(p.join(tempDir.path, 'backups'));
    final backupPath = await backupService.exportDatabase(
      destinationPath: backupDirectory.path,
      passphrase: 'correct horse battery staple',
    );

    final archive = ZipDecoder().decodeBytes(
      await File(backupPath).readAsBytes(),
      password: 'correct horse battery staple',
      verify: true,
    );

    expect(archive.files.where((file) => file.isFile), hasLength(1));
  });

  test('exported file fails to open with the wrong passphrase', () async {
    await _insertTodo(databaseService, title: 'Protected task');

    final backupDirectory = Directory(p.join(tempDir.path, 'backups'));
    final backupPath = await backupService.exportDatabase(
      destinationPath: backupDirectory.path,
      passphrase: 'correct horse battery staple',
    );

    final archive = ZipDecoder().decodeBytes(
      File(backupPath).readAsBytesSync(),
      password: 'wrong passphrase',
      verify: true,
    );

    expect(
      () => archive.files.singleWhere((file) => file.isFile).readBytes(),
      throwsException,
    );
  });

  test('import with correct passphrase restores data', () async {
    await _insertTodo(databaseService, title: 'Restorable task');

    final backupDirectory = Directory(p.join(tempDir.path, 'backups'));
    final backupPath = await backupService.exportDatabase(
      destinationPath: backupDirectory.path,
      passphrase: 'correct horse battery staple',
    );

    await _replaceTodosWith(databaseService, ['Current task only']);

    await backupService.importDatabase(
      sourcePath: backupPath,
      passphrase: 'correct horse battery staple',
    );

    final titles = await _loadTitles(databaseService);
    expect(titles, ['Restorable task']);
  });

  test(
    'import with older schema version migrates to current version',
    () async {
      await _insertTodo(databaseService, title: 'Migrated task');

      final backupDirectory = Directory(p.join(tempDir.path, 'backups'));
      final backupPath = await backupService.exportDatabase(
        destinationPath: backupDirectory.path,
        passphrase: 'correct horse battery staple',
      );
      await _rewriteBackupUserVersion(
        backupPath,
        'correct horse battery staple',
        0,
      );

      await _replaceTodosWith(databaseService, ['Different current task']);

      await backupService.importDatabase(
        sourcePath: backupPath,
        passphrase: 'correct horse battery staple',
      );

      final db = await databaseService.database;
      final versionResult = await db.rawQuery('PRAGMA user_version');
      expect(versionResult.first.values.first, kDatabaseVersion);
      expect(await _loadTitles(databaseService), ['Migrated task']);
    },
  );

  test(
    'import with newer schema version throws BackupVersionTooNewException',
    () async {
      await _insertTodo(databaseService, title: 'Future task');

      final backupDirectory = Directory(p.join(tempDir.path, 'backups'));
      final backupPath = await backupService.exportDatabase(
        destinationPath: backupDirectory.path,
        passphrase: 'correct horse battery staple',
      );
      await _rewriteBackupUserVersion(
        backupPath,
        'correct horse battery staple',
        99,
      );

      expect(
        () => backupService.importDatabase(
          sourcePath: backupPath,
          passphrase: 'correct horse battery staple',
        ),
        throwsA(
          isA<BackupVersionTooNewException>()
              .having((e) => e.backupVersion, 'backupVersion', 99)
              .having((e) => e.appVersion, 'appVersion', kDatabaseVersion),
        ),
      );
    },
  );

  test('import with corrupted file throws BackupCorruptedException', () async {
    final corruptedFile = File(p.join(tempDir.path, 'corrupted.db'));
    await corruptedFile.writeAsBytes(Uint8List.fromList([1, 2, 3, 4, 5]));

    expect(
      () => backupService.importDatabase(
        sourcePath: corruptedFile.path,
        passphrase: 'correct horse battery staple',
      ),
      throwsA(isA<BackupCorruptedException>()),
    );
  });

  test(
    'import with wrong passphrase throws a backup corruption error',
    () async {
      await _insertTodo(databaseService, title: 'Locked task');

      final backupDirectory = Directory(p.join(tempDir.path, 'backups'));
      final backupPath = await backupService.exportDatabase(
        destinationPath: backupDirectory.path,
        passphrase: 'correct horse battery staple',
      );

      expect(
        () => backupService.importDatabase(
          sourcePath: backupPath,
          passphrase: 'wrong passphrase',
        ),
        throwsA(
          isA<BackupCorruptedException>().having(
            (e) => e.details,
            'details',
            'wrong_passphrase',
          ),
        ),
      );
    },
  );

  test('listBackups returns files sorted newest first', () async {
    final backupDir = Directory(p.join(tempDir.path, 'sorted_backups'));
    await backupDir.create(recursive: true);

    final older = File(p.join(backupDir.path, 'older.db'));
    final newer = File(p.join(backupDir.path, 'newer.db'));
    await older.writeAsString('older');
    await newer.writeAsString('newer');
    await older.setLastModified(DateTime(2026, 3, 20, 8));
    await newer.setLastModified(DateTime(2026, 3, 21, 8));

    final backups = await backupService.listBackups(backupDir.path);

    expect(backups.map((backup) => backup.fileName).toList(), [
      'newer.db',
      'older.db',
    ]);
  });

  test('deleteBackup removes the file', () async {
    final backupDir = Directory(p.join(tempDir.path, 'delete_backups'));
    await backupDir.create(recursive: true);
    final file = File(p.join(backupDir.path, 'remove_me.db'));
    await file.writeAsString('content');

    await backupService.deleteBackup(file.path);

    expect(await file.exists(), isFalse);
  });
}

Future<void> _insertTodo(
  DatabaseService databaseService, {
  required String title,
}) async {
  final db = await databaseService.database;
  final now = DateTime.utc(2026, 3, 22, 10, 0, 0).toIso8601String();
  await db.insert('todos', {
    'id': '${title}_id',
    'date': '2026-03-22',
    'title': title,
    'description': null,
    'status': 'pending',
    'ported_to': null,
    'source_date': null,
    'recurrence_rule_id': null,
    'sort_order': 0,
    'created_at': now,
    'updated_at': now,
  });
}

Future<void> _replaceTodosWith(
  DatabaseService databaseService,
  List<String> titles,
) async {
  final db = await databaseService.database;
  await db.delete('time_segments');
  await db.delete('todos');
  for (final title in titles) {
    await _insertTodo(databaseService, title: title);
  }
}

Future<List<String>> _loadTitles(DatabaseService databaseService) async {
  final db = await databaseService.database;
  final rows = await db.rawQuery('SELECT title FROM todos ORDER BY title');
  return rows.map((row) => row['title']! as String).toList();
}

Future<void> _rewriteBackupUserVersion(
  String backupPath,
  String passphrase,
  int version,
) async {
  final archive = ZipDecoder().decodeBytes(
    await File(backupPath).readAsBytes(),
    password: passphrase,
    verify: true,
  );
  final file = archive.files.singleWhere((entry) => entry.isFile);
  final tempDir = await Directory.systemTemp.createTemp('backup_rewrite_');

  try {
    final dbPath = p.join(tempDir.path, kDatabaseName);
    await File(dbPath).writeAsBytes(file.readBytes()!, flush: true);

    final db = await databaseFactoryFfi.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(singleInstance: false),
    );
    try {
      await db.execute('PRAGMA user_version = $version');
    } finally {
      await db.close();
    }

    final rewrittenArchive = Archive()
      ..addFile(
        ArchiveFile.bytes(kDatabaseName, await File(dbPath).readAsBytes()),
      );
    final encoded = ZipEncoder(
      password: passphrase,
    ).encodeBytes(rewrittenArchive);
    await File(backupPath).writeAsBytes(encoded, flush: true);
  } finally {
    await tempDir.delete(recursive: true);
  }
}
