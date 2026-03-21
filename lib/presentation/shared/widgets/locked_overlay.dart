import 'package:flutter/material.dart';

class LockedOverlay extends StatelessWidget {
  const LockedOverlay({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      children: [
        Opacity(opacity: 0.5, child: IgnorePointer(child: child)),
        Positioned(
          top: 8,
          right: 8,
          child: Icon(
            Icons.lock_outline,
            size: 16,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}
