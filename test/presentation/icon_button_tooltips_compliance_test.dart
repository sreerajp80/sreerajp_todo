import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Helper matching engineering standard §7.8 verification function.
void expectAllIconButtonsHaveTooltips(WidgetTester tester) {
  final buttons = tester.widgetList<IconButton>(find.byType(IconButton));
  for (final button in buttons) {
    expect(
      button.tooltip != null && button.tooltip!.trim().isNotEmpty,
      isTrue,
      reason: 'IconButton with icon ${button.icon} has no tooltip',
    );
  }
  final fabs = tester.widgetList<FloatingActionButton>(
    find.byType(FloatingActionButton),
  );
  for (final fab in fabs) {
    expect(
      fab.tooltip?.trim().isNotEmpty ?? false,
      isTrue,
      reason: 'FloatingActionButton has no tooltip',
    );
  }
}

void main() {
  group('Codebase Guidelines Compliance (§7.8, §8.1, §8.7)', () {
    test(
      'build.gradle.kts disables Android language bundle splitting (§8.1)',
      () {
        final gradleFile = File('android/app/build.gradle.kts');
        expect(gradleFile.existsSync(), isTrue);
        final content = gradleFile.readAsStringSync();
        expect(content, contains('enableSplit = false'));
      },
    );

    test(
      'All IconButton declarations in lib/presentation specify tooltip (§7.8)',
      () {
        final dir = Directory('lib/presentation');
        expect(dir.existsSync(), isTrue);

        final files = dir
            .listSync(recursive: true)
            .whereType<File>()
            .where((f) => f.path.endsWith('.dart'));

        final violations = <String>[];

        for (final file in files) {
          final lines = file.readAsLinesSync();
          for (var i = 0; i < lines.length; i++) {
            final line = lines[i];
            if (line.contains('IconButton(')) {
              // Read next 25 lines to locate tooltip
              final maxEnd = (i + 25 < lines.length) ? i + 25 : lines.length;
              final chunk = lines.sublist(i, maxEnd).join(' ');
              if (!chunk.contains('tooltip:')) {
                violations.add('${file.path}:${i + 1}');
              }
            }
          }
        }

        expect(
          violations,
          isEmpty,
          reason:
              'All IconButtons must specify a localized tooltip (§7.8):\n${violations.join('\n')}',
        );
      },
    );

    test(
      'All FloatingActionButton declarations in lib/presentation specify tooltip (§7.8)',
      () {
        final dir = Directory('lib/presentation');
        final files = dir
            .listSync(recursive: true)
            .whereType<File>()
            .where((f) => f.path.endsWith('.dart'));

        final violations = <String>[];

        for (final file in files) {
          final lines = file.readAsLinesSync();
          for (var i = 0; i < lines.length; i++) {
            final line = lines[i];
            // Skip FloatingActionButton.extended as it has a visible text label
            if (line.contains('FloatingActionButton(') ||
                line.contains('FloatingActionButton.small(') ||
                line.contains('FloatingActionButton.large(')) {
              final maxEnd = (i + 20 < lines.length) ? i + 20 : lines.length;
              final chunk = lines.sublist(i, maxEnd).join(' ');
              if (!chunk.contains('tooltip:')) {
                violations.add('${file.path}:${i + 1}');
              }
            }
          }
        }

        expect(
          violations,
          isEmpty,
          reason:
              'All FloatingActionButtons must specify a localized tooltip (§7.8):\n${violations.join('\n')}',
        );
      },
    );

    testWidgets(
      'expectAllIconButtonsHaveTooltips correctly detects icon buttons and FABs (§7.8)',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              appBar: AppBar(
                actions: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    tooltip: 'Close',
                    onPressed: () {},
                  ),
                ],
              ),
              floatingActionButton: FloatingActionButton(
                tooltip: 'Add',
                onPressed: () {},
                child: const Icon(Icons.add),
              ),
            ),
          ),
        );

        expectAllIconButtonsHaveTooltips(tester);
      },
    );
  });
}
