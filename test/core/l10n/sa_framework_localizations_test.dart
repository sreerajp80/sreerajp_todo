import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_todo/core/l10n/sa_framework_localizations.dart';

void main() {
  group('SaFrameworkLocalizationsDelegates', () {
    test('SaMaterialLocalizationsDelegate supports sa only and loads en', () async {
      const delegate = SaMaterialLocalizationsDelegate();

      expect(delegate.isSupported(const Locale('sa')), isTrue);
      expect(delegate.isSupported(const Locale('en')), isFalse);
      expect(delegate.isSupported(const Locale('ml')), isFalse);

      final localizations = await delegate.load(const Locale('sa'));
      expect(localizations, isNotNull);
      expect(localizations.okButtonLabel, 'OK');
      expect(delegate.shouldReload(delegate), isFalse);
    });

    test('SaCupertinoLocalizationsDelegate supports sa only and loads en', () async {
      const delegate = SaCupertinoLocalizationsDelegate();

      expect(delegate.isSupported(const Locale('sa')), isTrue);
      expect(delegate.isSupported(const Locale('en')), isFalse);
      expect(delegate.isSupported(const Locale('ml')), isFalse);

      final localizations = await delegate.load(const Locale('sa'));
      expect(localizations, isNotNull);
      expect(localizations.alertDialogLabel, 'Alert');
      expect(delegate.shouldReload(delegate), isFalse);
    });

    test('SaWidgetsLocalizationsDelegate supports sa only and loads en', () async {
      const delegate = SaWidgetsLocalizationsDelegate();

      expect(delegate.isSupported(const Locale('sa')), isTrue);
      expect(delegate.isSupported(const Locale('en')), isFalse);
      expect(delegate.isSupported(const Locale('ml')), isFalse);

      final localizations = await delegate.load(const Locale('sa'));
      expect(localizations, isNotNull);
      expect(localizations.textDirection, TextDirection.ltr);
      expect(delegate.shouldReload(delegate), isFalse);
    });
  });
}
