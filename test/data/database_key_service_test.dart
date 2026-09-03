import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_todo/data/database/database_key_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DatabaseKeyService', () {
    test('returns a stable hex key in test environment', () async {
      final keyService = DatabaseKeyService();
      final key = await keyService.getOrCreateDatabaseKey();

      expect(key, isA<String>());
      expect(key.length, equals(64));
      expect(key, matches(RegExp(r'^[0-9a-f]{64}$')));
    });

    test('shares one key across instances in the same run', () async {
      final keyFromFirst = await DatabaseKeyService().getOrCreateDatabaseKey();
      final keyFromSecond = await DatabaseKeyService().getOrCreateDatabaseKey();

      expect(keyFromFirst, equals(keyFromSecond));
    });

    test('caches retrieved key on subsequent calls', () async {
      final keyService = DatabaseKeyService();
      final key1 = await keyService.getOrCreateDatabaseKey();
      final key2 = await keyService.getOrCreateDatabaseKey();

      expect(key1, equals(key2));
    });
  });
}
