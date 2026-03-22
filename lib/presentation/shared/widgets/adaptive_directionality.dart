import 'package:flutter/material.dart';
import 'package:sreerajp_todo/core/utils/unicode_utils.dart' as unicode_utils;

class AdaptiveDirectionality extends StatelessWidget {
  const AdaptiveDirectionality({
    super.key,
    required this.text,
    required this.child,
  });

  final String text;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final resolved = switch (unicode_utils.detectTextDirection(text)) {
      unicode_utils.TextDirection.rtl => TextDirection.rtl,
      unicode_utils.TextDirection.ltr => TextDirection.ltr,
      null => Directionality.of(context),
    };

    return Directionality(textDirection: resolved, child: child);
  }
}
