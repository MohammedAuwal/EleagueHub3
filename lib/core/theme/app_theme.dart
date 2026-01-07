import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData skyTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorSchemeSeed: Colors.blue,
      scaffoldBackgroundColor: const Color(0xFFF0F2F5),
    );
  }

  static ThemeData navyTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorSchemeSeed: Colors.indigo,
      scaffoldBackgroundColor: const Color(0xFF0A0E21),
    );
  }
}
