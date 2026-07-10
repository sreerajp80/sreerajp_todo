import 'package:flutter/material.dart';
import 'package:sreerajp_todo/core/extensions/localization_extensions.dart';

Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String content,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(context.l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(context.l10n.confirm),
        ),
      ],
    ),
  );
  return result ?? false;
}
