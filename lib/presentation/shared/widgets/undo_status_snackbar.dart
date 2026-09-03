import 'package:flutter/material.dart';
import 'package:sreerajp_todo/core/constants/app_constants.dart';
import 'package:sreerajp_todo/core/extensions/localization_extensions.dart';

void showUndoSnackBar(
  BuildContext context, {
  required String message,
  required VoidCallback onUndo,
}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: kUndoTimeoutSeconds),
        // Keep the undo button beside the message instead of letting a long
        // translated label push it onto a second line.
        actionOverflowThreshold: 1.0,
        showCloseIcon: false,
        padding: const EdgeInsets.only(left: 16, right: 8),
        action: SnackBarAction(label: context.l10n.undo, onPressed: onUndo),
      ),
    );
}
