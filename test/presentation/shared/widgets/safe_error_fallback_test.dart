import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_todo/presentation/shared/widgets/safe_error_fallback.dart';

void main() {
  testWidgets('shows only a warning icon and no text', (tester) async {
    await tester.pumpWidget(const SafeErrorFallback());

    expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    expect(find.byType(Text), findsNothing);
  });
}
