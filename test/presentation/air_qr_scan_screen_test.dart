import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_todo/l10n/app_localizations.dart';
import 'package:sreerajp_todo/presentation/screens/air_qr_scan_screen.dart';

import '../helpers/test_l10n.dart';

void main() {
  // Host tests never run on Android, so the screen must say that live QR
  // scanning is not available here instead of trying to open a camera.
  testWidgets('shows the Android-only message off Android', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: AirQrScanScreen(),
        ),
      ),
    );
    await tester.pump();

    expect(find.text(testL10n.airQrScanTitle), findsOneWidget);
    expect(find.text(testL10n.airQrScanUnavailable), findsOneWidget);
    expect(find.byTooltip(testL10n.airQrScanTorchOn), findsNothing);
  });
}
