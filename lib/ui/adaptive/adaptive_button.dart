import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'platform_style.dart';

enum AdaptiveButtonVariant { filled, tonal, text }

class AdaptiveButton extends StatelessWidget {
  const AdaptiveButton({
    super.key,
    this.label,
    this.child,
    required this.onPressed,
    this.variant = AdaptiveButtonVariant.filled,
  })  : assert(label != null || child != null,
            'Either label or child must be provided.'),
        assert(!(label != null && child != null),
            'Provide only one of label or child.');

  final String? label;
  final Widget? child;
  final VoidCallback? onPressed;
  final AdaptiveButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    final content = child ?? Text(label!);

    if (PlatformStyle.isCupertino(context)) {
      final scheme = Theme.of(context).colorScheme;

      switch (variant) {
        case AdaptiveButtonVariant.filled:
          return CupertinoButton.filled(
            onPressed: onPressed,
            child: content,
          );
        case AdaptiveButtonVariant.tonal:
          return CupertinoButton(
            onPressed: onPressed,
            color: scheme.secondaryContainer,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: DefaultTextStyle.merge(
              style: TextStyle(color: scheme.onSecondaryContainer),
              child: content,
            ),
          );
        case AdaptiveButtonVariant.text:
          return CupertinoButton(
            onPressed: onPressed,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: content,
          );
      }
    }

    switch (variant) {
      case AdaptiveButtonVariant.filled:
        return FilledButton(onPressed: onPressed, child: content);
      case AdaptiveButtonVariant.tonal:
        return FilledButton.tonal(onPressed: onPressed, child: content);
      case AdaptiveButtonVariant.text:
        return TextButton(onPressed: onPressed, child: content);
    }
  }
}
