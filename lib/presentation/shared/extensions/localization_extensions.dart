import 'package:flutter/widgets.dart';
import 'package:sreerajp_todo/l10n/app_localizations.dart';

/// Terse access to the localized strings for the current [BuildContext].
///
/// Usage: `context.l10n.dailyList`.
extension LocalizationExtensions on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
