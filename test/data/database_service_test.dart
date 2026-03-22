import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite_sqlcipher/sqlite_api.dart';
import 'package:sreerajp_todo/data/database/database_service.dart';

class MockDatabase extends Mock implements Database {}

class TestDatabaseService extends DatabaseService {
  TestDatabaseService(this.testDatabase);

  final Database testDatabase;

  @override
  Future<String> get databasePath async => 'test.db';

  @override
  Future<Database> openDatabaseAt(
    String path, {
    int? version,
    OnDatabaseConfigureFn? onConfigure,
    OnDatabaseCreateFn? onCreate,
    OnDatabaseVersionChangeFn? onUpgrade,
    OnDatabaseVersionChangeFn? onDowngrade,
    OnDatabaseOpenFn? onOpen,
    bool readOnly = false,
    bool singleInstance = false,
    String? password,
  }) async {
    if (onOpen != null) {
      await onOpen(testDatabase);
    }

    return testDatabase;
  }
}

void main() {
  late MockDatabase database;
  late TestDatabaseService databaseService;

  setUp(() {
    database = MockDatabase();
    when(
      () => database.rawQuery(any()),
    ).thenAnswer((_) async => <Map<String, Object?>>[]);
    databaseService = TestDatabaseService(database);
  });

  test('uses rawQuery for open-time pragma statements', () async {
    final openedDatabase = await databaseService.database;

    expect(openedDatabase, same(database));
    verifyInOrder([
      () => database.rawQuery('PRAGMA journal_mode=WAL'),
      () => database.rawQuery('PRAGMA foreign_keys=ON'),
    ]);
    verifyNever(() => database.execute(any()));
  });
}
