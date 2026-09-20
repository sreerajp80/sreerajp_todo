import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_todo/core/l10n/sa_framework_localizations.dart';
import 'package:sreerajp_todo/l10n/app_localizations.dart';
import 'package:sreerajp_todo/widgets/made_with_love.dart';

void main() {
  group('MadeWithLove widget tests (lib/widgets/)', () {
    Widget buildTestApp({Locale locale = const Locale('en')}) {
      return MaterialApp(
        locale: locale,
        localizationsDelegates: const [
          SaMaterialLocalizationsDelegate(),
          SaCupertinoLocalizationsDelegate(),
          SaWidgetsLocalizationsDelegate(),
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(body: MadeWithLove()),
      );
    }

    testWidgets('renders red heart icon and correct semantics in English', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestApp(locale: const Locale('en')));
      await tester.pumpAndSettle();

      expect(find.byType(MadeWithLove), findsOneWidget);
      expect(find.byIcon(Icons.favorite), findsOneWidget);

      final icon = tester.widget<Icon>(find.byIcon(Icons.favorite));
      expect(icon.color, const Color(0xFFE53935));

      expect(
        find.bySemanticsLabel('Made with love from India'),
        findsOneWidget,
      );
    });

    testWidgets('renders in Malayalam with correct semantics', (tester) async {
      await tester.pumpWidget(buildTestApp(locale: const Locale('ml')));
      await tester.pumpAndSettle();

      expect(find.byType(MadeWithLove), findsOneWidget);
      expect(find.byIcon(Icons.favorite), findsOneWidget);
      expect(
        find.bySemanticsLabel('സ്നേഹത്തോടെ ഇന്ത്യയിൽ നിന്ന്'),
        findsOneWidget,
      );
    });

    testWidgets('renders in Sanskrit with correct semantics', (tester) async {
      await tester.pumpWidget(buildTestApp(locale: const Locale('sa')));
      await tester.pumpAndSettle();

      expect(find.byType(MadeWithLove), findsOneWidget);
      expect(find.byIcon(Icons.favorite), findsOneWidget);
      expect(find.bySemanticsLabel('सस्नेहं निर्मितम् भारततः'), findsOneWidget);
    });
  });
}
