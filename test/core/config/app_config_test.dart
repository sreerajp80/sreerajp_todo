import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_todo/core/config/app_config.dart';

void main() {
  group('AppConfig', () {
    test('fallback returns expected default values', () {
      expect(AppConfig.fallback.appName, equals('SreerajP ToDo'));
      expect(AppConfig.fallback.version, equals('1.13.1'));
      expect(AppConfig.fallback.build, equals('32'));
      expect(AppConfig.fallback.details, isNotEmpty);
    });

    test('fromJson parses valid json object properly', () {
      final json = {
        'appName': 'Test App',
        'description': 'Test Description',
        'version': '2.0.0',
        'build': '42',
        'details': {'Author': 'Tester', 'License': 'MIT'},
      };

      final config = AppConfig.fromJson(json);

      expect(config.appName, equals('Test App'));
      expect(config.description, equals('Test Description'));
      expect(config.version, equals('2.0.0'));
      expect(config.build, equals('42'));
      expect(config.details['Author'], equals('Tester'));
      expect(config.details['License'], equals('MIT'));
    });

    test('fromJson falls back on missing or wrong type fields', () {
      final json = {'appName': 12345, 'details': 'not a map'};

      final config = AppConfig.fromJson(json);

      expect(config.appName, equals(AppConfig.fallback.appName));
      expect(config.description, equals(AppConfig.fallback.description));
      expect(config.version, equals(AppConfig.fallback.version));
      expect(config.build, equals(AppConfig.fallback.build));
      expect(config.details, isEmpty);
    });
  });
}
