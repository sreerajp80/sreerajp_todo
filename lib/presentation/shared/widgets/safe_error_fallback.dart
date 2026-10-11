import 'package:flutter/material.dart';

/// Shown in release builds in place of a widget that failed to build.
///
/// It is set as `ErrorWidget.builder` in `main.dart`. Flutter builds it with
/// no `BuildContext` of its own, so it shows no text (text would need
/// localization) and never shows error details. It is a small neutral box with
/// a warning icon.
class SafeErrorFallback extends StatelessWidget {
  const SafeErrorFallback({super.key});

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Color(0x14808080),
      child: Center(
        child: Icon(
          Icons.warning_amber_rounded,
          color: Color(0xFF9E9E9E),
          textDirection: TextDirection.ltr,
        ),
      ),
    );
  }
}
