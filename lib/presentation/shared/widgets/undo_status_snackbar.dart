import 'package:flutter/material.dart';
import 'package:sreerajp_todo/core/constants/app_constants.dart';
import 'package:sreerajp_todo/presentation/shared/extensions/localization_extensions.dart';

void showUndoSnackBar(
  BuildContext context, {
  required String message,
  required VoidCallback onUndo,
}) {
  ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: kUndoTimeoutSeconds),
        // Keep the undo button beside the message instead of letting a long
        // translated label push it onto a second line.
        actionOverflowThreshold: 1.0,
        // Flutter keeps a SnackBar with an action on screen until it is
        // closed. Undo must still time out after kUndoTimeoutSeconds.
        persist: false,
        showCloseIcon: true,
        padding: const EdgeInsets.only(left: 16),
        action: SnackBarAction(label: context.l10n.undo, onPressed: onUndo),
      ),
    );
}

/// Shows an immediate informational feedback SnackBar.
///
/// Clears any previously queued SnackBars so old messages are never shown
/// after the user has moved on to another task or action.
void showAppSnackBar(
  BuildContext context, {
  required String message,
  Duration duration = const Duration(seconds: 2),
  SnackBarAction? action,
  Color? backgroundColor,
}) {
  ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        action: action,
        persist: false,
        showCloseIcon: action != null,
        backgroundColor: backgroundColor,
      ),
    );
}

/// Removes any visible or queued SnackBar.
///
/// Screens call this when they open so a message about an earlier screen
/// (for example "Status changed to Completed") never follows the user.
void hideAppSnackBars(BuildContext context) {
  ScaffoldMessenger.maybeOf(context)?.clearSnackBars();
}
