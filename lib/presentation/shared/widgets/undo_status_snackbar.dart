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
        action: SnackBarAction(label: context.l10n.undo, onPressed: onUndo),
      ),
    );
}
