import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_todo/data/database/database_key_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DatabaseKeyService', () {
    test('returns deterministic test key in test environment', () async {
      final keyService = DatabaseKeyService();
      final key = await keyService.getOrCreateDatabaseKey();

      expect(key, isA<String>());
      expect(key.length, equals(64));
      expect(
        key,
        equals(
          '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef',
        ),
      );
    });

    test('caches retrieved key on subsequent calls', () async {
      final keyService = DatabaseKeyService();
      final key1 = await keyService.getOrCreateDatabaseKey();
      final key2 = await keyService.getOrCreateDatabaseKey();

      expect(key1, equals(key2));
    });
  });
}
