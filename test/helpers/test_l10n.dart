import 'package:sreerajp_todo/l10n/app_localizations.dart';
import 'package:sreerajp_todo/l10n/app_localizations_en.dart';

/// English localizations instance for asserting on UI text in widget tests.
///
/// Widget trees under test must be wrapped in a [MaterialApp] (or
/// `MaterialApp.router`) configured with
/// [AppLocalizations.localizationsDelegates] and
/// [AppLocalizations.supportedLocales] so that `context.l10n` resolves. The
/// default test locale is `en`, so assertions against [testL10n] match the
/// rendered text.
final AppLocalizations testL10n = AppLocalizationsEn();
