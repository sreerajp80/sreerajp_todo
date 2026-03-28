// Generates lib/core/constants/app_version.g.dart from pubspec.yaml.
// Run before release builds:  dart run tool/generate_app_version.dart

// ignore_for_file: avoid_print

import 'dart:io';

void main() {
  final pubspec = File('pubspec.yaml').readAsStringSync();
  final match = RegExp(r'^version:\s*(\S+)', multiLine: true).firstMatch(pubspec);

  if (match == null) {
    stderr.writeln('ERROR: version field not found in pubspec.yaml');
    exit(1);
  }

  // Strip the build number (e.g. "1.4.0+1" → "1.4.0")
  final fullVersion = match.group(1)!;
  final versionName = fullVersion.split('+').first;

  final file = File('lib/core/constants/app_version.g.dart');
  file.writeAsStringSync(
    '// GENERATED FILE — DO NOT EDIT.\n'
    '// Run: dart run tool/generate_app_version.dart\n'
    '\n'
    "const String kAppVersion = '$versionName';\n",
  );

  print('app_version.g.dart updated → $versionName');
}
