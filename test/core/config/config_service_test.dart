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
        "details": {"key": "Value"}
      }
      ''';

        final service = ConfigService(loadAsset: (_) async => mockJson);
        final config = await service.load();

        expect(config.appName.resolve('en'), equals('Mock App'));
        expect(config.description.resolve('en'), equals('Mock Description'));
        expect(config.version, equals('1.0.0'));
        expect(config.build, equals('10'));
        expect(config.details['key']?.resolve('en'), equals('Value'));
      },
    );

    test(
      'load returns AppConfig.fallback when asset loading throws exception',
      () async {
        final service = ConfigService(
          loadAsset: (_) async => throw Exception('Asset missing'),
        );
        final config = await service.load();

        expect(
          config.appName.resolve('en'),
          equals(AppConfig.fallback.appName.resolve('en')),
        );
        expect(config.version, equals(AppConfig.fallback.version));
      },
    );

    test('load returns AppConfig.fallback when JSON is malformed', () async {
      final service = ConfigService(
        loadAsset: (_) async => 'invalid json payload',
      );
      final config = await service.load();

      expect(
        config.appName.resolve('en'),
        equals(AppConfig.fallback.appName.resolve('en')),
      );
      expect(config.version, equals(AppConfig.fallback.version));
    });

    test(
      'loadAndVerify returns loaded config and handles version check',
      () async {
        const mockJson = '''
      {
        "appName": "Mock App",
        "description": "Mock Description",
        "version": "1.0.0",
        "build": "10",
        "details": {}
      }
      ''';

        final service = ConfigService(loadAsset: (_) async => mockJson);
        final config = await service.loadAndVerify(
          packageVersion: '1.0.0',
          packageBuild: '10',
        );

        expect(config.version, equals('1.0.0'));
        expect(config.build, equals('10'));
      },
    );
  });
}
