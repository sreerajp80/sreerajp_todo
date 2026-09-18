import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:sreerajp_todo/core/config/app_config.dart';

class ConfigService {
  static const String assetPath = 'assets/config/app_config.json';

  final Future<String> Function(String path) _loadAsset;

  ConfigService({Future<String> Function(String path)? loadAsset})
    : _loadAsset = loadAsset ?? rootBundle.loadString;

  Future<AppConfig> load() async {
    try {
      final text = await _loadAsset(assetPath);
      final decoded = jsonDecode(text);
      if (decoded is! Map<String, dynamic>) return AppConfig.fallback;
      return AppConfig.fromJson(decoded);
    } catch (_) {
      return AppConfig.fallback;
    }
  }

  Future<AppConfig> loadAndVerify({
    String? packageVersion,
    String? packageBuild,
  }) async {
    final config = await load();
    try {
      if (packageVersion != null && packageBuild != null) {
        final mismatch =
            packageVersion != config.version || packageBuild != config.build;
        if (mismatch && kDebugMode) {
          debugPrint(
            'ConfigService: version/build in app_config.json '
            '(${config.version}+${config.build}) does not match the build '
            '($packageVersion+$packageBuild).',
          );
        }
      }
    } catch (_) {
      // Package info unavailable (e.g. plain unit test) — ignore.
    }
    return config;
  }
}
