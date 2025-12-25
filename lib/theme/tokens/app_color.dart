import 'package:flutter/material.dart';

class AppColor {
  const AppColor._();

  /// iOS 偏好：整体更轻、更干净。这里先用 seed 生成 M3 ColorScheme。
  /// 业务色值后续只改这里，不允许页面硬编码。
  static const Color seed = Color(0xFF007AFF); // iOS 蓝

  static ColorScheme lightScheme() {
    return ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.light);
  }

  static ColorScheme darkScheme() {
    return ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark);
  }
}
