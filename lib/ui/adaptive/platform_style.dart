import 'package:flutter/material.dart';

class PlatformStyle {
  const PlatformStyle._();

  static bool isCupertino(BuildContext context) {
    final platform = Theme.of(context).platform;
    return platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;
  }
}
