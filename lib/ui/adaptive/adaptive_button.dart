import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'platform_style.dart';

enum AdaptiveButtonVariant { filled, tonal, text }

class AdaptiveButton extends StatelessWidget {
  const AdaptiveButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AdaptiveButtonVariant.filled,
  });

  final String label;
  final VoidCallback? onPressed;
  final AdaptiveButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    if (PlatformStyle.isCupertino(context)) {
      final scheme = Theme.of(context).colorScheme;

      switch (variant) {
        case AdaptiveButtonVariant.filled:
          return CupertinoButton.filled(
            onPressed: onPressed,
            child: Text(label),
          );
        case AdaptiveButtonVariant.tonal:
          return CupertinoButton(
            onPressed: onPressed,
            color: scheme.secondaryContainer,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: DefaultTextStyle.merge(
              style: TextStyle(color: scheme.onSecondaryContainer),
              child: Text(label),
            ),
          );
        case AdaptiveButtonVariant.text:
          return CupertinoButton(
            onPressed: onPressed,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Text(label),
          );
      }
    }

    switch (variant) {
      case AdaptiveButtonVariant.filled:
        return FilledButton(onPressed: onPressed, child: Text(label));
      case AdaptiveButtonVariant.tonal:
        return FilledButton.tonal(onPressed: onPressed, child: Text(label));
      case AdaptiveButtonVariant.text:
        return TextButton(onPressed: onPressed, child: Text(label));
    }
  }
}
