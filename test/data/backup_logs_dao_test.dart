import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_todo/data/dao/backup_logs_dao.dart';
import 'package:sreerajp_todo/data/database/database_service.dart';
import 'package:sreerajp_todo/data/models/backup_log_entity.dart';
import '../helpers/test_database.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late DatabaseService databaseService;
  late BackupLogsDao dao;

  setUp(() async {
    initFfi();
    tempDir = await Directory.systemTemp.createTemp('backup_logs_dao_test_');
    databaseService = await createFileBackedTestDatabaseService(tempDir);
    dao = BackupLogsDao(databaseService);
  });

  tearDown(() async {
    await databaseService.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test(
    'insertLog and getAllLogs return logs ordered by timestamp DESC',
    () async {
      const log1 = BackupLogEntity(
        id: 'log-1',
        timestamp: '2026-08-10T10:00:00.000Z',
        status: 'success',
        filePath: '/path/backup1.db.aes',
        fileSizeBytes: 1024,
        triggerType: 'manual',
        diagnosticMessage: 'Success log 1',
        createdAt: '2026-08-10T10:00:00.000Z',
      );

      const log2 = BackupLogEntity(
        id: 'log-2',
        timestamp: '2026-08-10T12:00:00.000Z',
        status: 'success',
        filePath: '/path/backup2.db.aes',
        fileSizeBytes: 2048,
        triggerType: 'scheduled',
        diagnosticMessage: 'Success log 2',
        createdAt: '2026-08-10T12:00:00.000Z',
      );

      await dao.insertLog(log1);
      await dao.insertLog(log2);

      final logs = await dao.getAllLogs();
      expect(logs, hasLength(2));
      expect(logs.first.id, equals('log-2'));
      expect(logs.last.id, equals('log-1'));
    },
  );

  test('getLatestLog returns the most recent log entry', () async {
    const log1 = BackupLogEntity(
      id: 'log-1',
      timestamp: '2026-08-10T10:00:00.000Z',
      status: 'failed',
      filePath: '/path/backup1.db.aes',
      fileSizeBytes: 0,
      triggerType: 'manual',
      diagnosticMessage: 'Error details',
      createdAt: '2026-08-10T10:00:00.000Z',
    );

    const log2 = BackupLogEntity(
      id: 'log-2',
      timestamp: '2026-08-10T14:00:00.000Z',
      status: 'success',
      filePath: '/path/backup2.db.aes',
      fileSizeBytes: 4096,
      triggerType: 'manual',
      diagnosticMessage: 'Verified',
      createdAt: '2026-08-10T14:00:00.000Z',
    );

    await dao.insertLog(log1);
    await dao.insertLog(log2);

    final latest = await dao.getLatestLog();
    expect(latest, isNotNull);
    expect(latest!.id, equals('log-2'));
    expect(latest.status, equals('success'));
  });

  test('clearLogs removes all log entries', () async {
    const log = BackupLogEntity(
      id: 'log-1',
      timestamp: '2026-08-10T10:00:00.000Z',
      status: 'success',
      filePath: '/path/backup1.db.aes',
      fileSizeBytes: 1024,
      triggerType: 'manual',
      diagnosticMessage: 'Success',
      createdAt: '2026-08-10T10:00:00.000Z',
    );

    await dao.insertLog(log);
    expect(await dao.getAllLogs(), hasLength(1));

    await dao.clearLogs();
    expect(await dao.getAllLogs(), isEmpty);
  });
}
