import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_todo/core/config/app_config.dart';
import 'package:sreerajp_todo/core/config/config_service.dart';

void main() {
  group('ConfigService', () {
    test(
      'load returns AppConfig when valid JSON is returned by loader',
      () async {
        const mockJson = '''
      {
        "appName": "Mock App",
        "description": "Mock Description",
        "version": "1.0.0",
        "build": "10",
        "details": {"Key": "Value"}
      }
      ''';

        final service = ConfigService(loadAsset: (_) async => mockJson);
        final config = await service.load();

        expect(config.appName, equals('Mock App'));
        expect(config.description, equals('Mock Description'));
        expect(config.version, equals('1.0.0'));
        expect(config.build, equals('10'));
        expect(config.details['Key'], equals('Value'));
      },
    );

    test(
      'load returns AppConfig.fallback when asset loading throws exception',
      () async {
        final service = ConfigService(
          loadAsset: (_) async => throw Exception('Asset missing'),
        );
        final config = await service.load();

        expect(config.appName, equals(AppConfig.fallback.appName));
        expect(config.version, equals(AppConfig.fallback.version));
      },
    );

    test('load returns AppConfig.fallback when JSON is malformed', () async {
      final service = ConfigService(
        loadAsset: (_) async => 'invalid json payload',
      );
      final config = await service.load();

      expect(config.appName, equals(AppConfig.fallback.appName));
      expect(config.version, equals(AppConfig.fallback.version));
    });
  });
}
