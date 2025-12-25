import 'package:flutter/material.dart';

class AppFontSize {
  const AppFontSize._();

  static const double font10 = 10;
  static const double font12 = 12;
  static const double font14 = 14;
  static const double font16 = 16;
  static const double font20 = 20;
  static const double font24 = 24;
  static const double font28 = 28;
  static const double font32 = 32;
}

class AppTypography {
  const AppTypography._();

  static TextTheme textTheme({String? fontFamily}) {
    TextStyle baseStyle(double size, FontWeight weight, double height) {
      return TextStyle(
        fontFamily: fontFamily,
        fontSize: size,
        fontWeight: weight,
        height: height,
      );
    }

    return TextTheme(
      displaySmall: baseStyle(AppFontSize.font32, FontWeight.w600, 1.15),
      headlineSmall: baseStyle(AppFontSize.font28, FontWeight.w600, 1.2),
      titleLarge: baseStyle(AppFontSize.font24, FontWeight.w600, 1.25),
      titleMedium: baseStyle(AppFontSize.font20, FontWeight.w600, 1.3),
      titleSmall: baseStyle(AppFontSize.font16, FontWeight.w600, 1.35),
      bodyLarge: baseStyle(AppFontSize.font16, FontWeight.w400, 1.5),
      bodyMedium: baseStyle(AppFontSize.font14, FontWeight.w400, 1.5),
      bodySmall: baseStyle(AppFontSize.font12, FontWeight.w400, 1.45),
      labelLarge: baseStyle(AppFontSize.font14, FontWeight.w600, 1.3),
      labelMedium: baseStyle(AppFontSize.font12, FontWeight.w600, 1.25),
      labelSmall: baseStyle(AppFontSize.font10, FontWeight.w600, 1.2),
    );
  }
}
