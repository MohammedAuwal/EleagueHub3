import 'dart:ui';
import 'package:flutter/material.dart';

class AppTheme {
  static const navyBg = Color(0xFF0A1D37);
  static const navyAccent = Color(0xFF00D4FF);

  static const skyA = Color(0xFF40C4FF);
  static const skyB = Color(0xFF81D4FA);
  static const skyAccent = navyBg;

  static const coral = Color(0xFFFF6B6B);

  static ThemeData navyTheme() {
    final base = ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: navyAccent,
        brightness: Brightness.dark,
      ).copyWith(
        primary: navyAccent,
        secondary: navyAccent,
        surface: const Color(0xFF0B2547),
        background: navyBg,
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor: navyBg,
      textTheme: base.textTheme.apply(
        bodyColor: Colors.white.withValues(alpha: 0.92),
        displayColor: Colors.white.withValues(alpha: 0.92),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white.withValues(alpha: 0.92),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: const CardTheme(
        color: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
      ),
      dividerColor: Colors.white.withValues(alpha: 0.12),
    );
  }

  static ThemeData skyTheme() {
    final base = ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: skyA,
        brightness: Brightness.light,
      ).copyWith(
        primary: skyAccent,
        secondary: skyA,
        surface: Colors.white,
        background: skyB,
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor: skyB,
      textTheme: base.textTheme.apply(
        bodyColor: Colors.black.withValues(alpha: 0.86),
        displayColor: Colors.black.withValues(alpha: 0.86),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black.withValues(alpha: 0.86),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: const CardTheme(
        color: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
      ),
      dividerColor: Colors.black.withValues(alpha: 0.10),
    );
  }

  static LinearGradient backgroundGradient(Brightness brightness) {
    if (brightness == Brightness.dark) {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF061426),
          Color(0xFF0A1D37),
          Color(0xFF04101F),
        ],
      );
    }
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [skyA, skyB],
    );
  }

  static Color glassFill(Brightness brightness) =>
      brightness == Brightness.dark
          ? Colors.white.withValues(alpha: 0.08)
          : Colors.white.withValues(alpha: 0.28);

  static Color glassStroke(Brightness brightness) =>
      brightness == Brightness.dark
          ? Colors.white.withValues(alpha: 0.14)
          : Colors.white.withValues(alpha: 0.22);

  static List<Color> bubblePalette(Brightness brightness) {
    if (brightness == Brightness.dark) {
      return [
        navyAccent.withValues(alpha: 0.18),
        const Color(0xFFB7F3FF).withValues(alpha: 0.10),
        const Color(0xFF6AE4FF).withValues(alpha: 0.10),
      ];
    }
    return [
      Colors.white.withValues(alpha: 0.20),
      const Color(0xFFB3E5FC).withValues(alpha: 0.20),
      const Color(0xFF4FC3F7).withValues(alpha: 0.14),
    ];
  }

  static Color statusColor(String status, Brightness b) {
    final isDark = b == Brightness.dark;
    switch (status) {
      case 'Scheduled':
        return (isDark ? navyAccent : skyAccent).withValues(alpha: 0.85);
      case 'Pending Proof':
        return (isDark ? coral : coral).withValues(alpha: 0.85);
      case 'Under Review':
        return Colors.amber.withValues(alpha: 0.85);
      case 'Completed':
        return Colors.green.withValues(alpha: 0.85);
      default:
        return (isDark ? Colors.white : Colors.black).withValues(alpha: 0.4);
    }
  }
}
