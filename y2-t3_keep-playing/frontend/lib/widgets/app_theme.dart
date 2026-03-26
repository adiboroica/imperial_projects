import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Colors.blue;
  static const Color navBarColor = Colors.lightBlueAccent;
  static const Color cancelColor = Colors.red;
  static const Color successColor = Colors.green;
  static const Color scheduledColor = Colors.purple;
  static const Color mutedColor = Colors.black12;

  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double buttonFontSize = 16.0;

  static ThemeData get themeData => ThemeData(
        colorSchemeSeed: primaryColor,
        useMaterial3: true,
      );
}
