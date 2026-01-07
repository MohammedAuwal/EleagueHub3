import 'package:flutter/material.dart';

class AppTheme {
  // Deep Navy background base
  static const Color navyBg = Color(0xFF0A1D37);
  static const Color navyAccent = Color(0xFF00D4FF);

  // Sky theme gradient
  static const Color skyTop = Color(0xFF40C4FF);
  static const Color skyBottom = Color(0xFF81D4FA);

  // Aliases for compatibility with your existing App widget
  static ThemeData skyTheme() => light();
  static ThemeData navyTheme() => dark();

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: skyTop,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: Colors.white,
    );
  }

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: navyAccent,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: navyBg,
    );
  }

  static Color glassFill(Brightness b) {
    return (b == Brightness.dark)
        ? const Color(0x1AFFFFFF) 
        : const Color(0x26FFFFFF);
  }

  static Color glassStroke(Brightness b) {
    return (b == Brightness.dark)
        ? const Color(0x2EFFFFFF)
        : const Color(0x33FFFFFF);
  }

  static Gradient backgroundGradient(Brightness b) {
    if (b == Brightness.dark) {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [navyBg, Color(0xFF07162A)],
      );
    }
    return const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [skyTop, skyBottom],
    );
  }
}
