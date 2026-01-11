import 'package:flutter/material.dart';

class AppTheme {
  // =========================
  // CORE BRAND COLORS
  // =========================

  // Deep Navy (Night)
  static const Color navyBg = Color(0xFF0A1D37);
  static const Color navyAccent = Color(0xFF00D4FF);

  // Sky (Day)
  static const Color skyTop = Color(0xFF40C4FF);
  static const Color skyBottom = Color(0xFF81D4FA);

  // =========================
  // PUBLIC THEME ACCESSORS
  // =========================

  static ThemeData skyTheme() => _lightTheme();
  static ThemeData navyTheme() => _darkTheme();

  // =========================
  // LIGHT (SKY) THEME
  // =========================

  static ThemeData _lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      colorScheme: ColorScheme.fromSeed(
        seedColor: skyTop,
        brightness: Brightness.light,
        surface: skyBottom,
      ),

      scaffoldBackgroundColor: skyBottom,

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Color(0xFF0A1D37),
        elevation: 0,
      ),

      cardTheme: CardTheme(
        color: glassFill(Brightness.light),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: glassStroke(Brightness.light)),
        ),
      ),
    );
  }

  // =========================
  // DARK (NAVY) THEME
  // =========================

  static ThemeData _darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      colorScheme: ColorScheme.fromSeed(
        seedColor: navyAccent,
        brightness: Brightness.dark,
        surface: navyBg,
      ),

      scaffoldBackgroundColor: navyBg,

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      cardTheme: CardTheme(
        color: glassFill(Brightness.dark),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: glassStroke(Brightness.dark)),
        ),
      ),
    );
  }

  // =========================
  // GLASSMORPHISM HELPERS
  // =========================

  static Color glassFill(Brightness b) {
    return (b == Brightness.dark)
        ? const Color(0x1AFFFFFF) // ~10%
        : const Color(0x26FFFFFF); // ~15%
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
        colors: [
          navyBg,
          Color(0xFF07162A),
        ],
      );
    }
    return const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        skyTop,
        skyBottom,
      ],
    );
  }

  // =========================
  // DOMAIN COLORS
  // =========================

  static Color statusColor(String status, Brightness b) {
    final s = status.trim().toLowerCase();

    switch (s) {
      case 'open':
      case 'recruiting':
        return (b == Brightness.dark)
            ? navyAccent
            : const Color(0xFF0A1D37);

      case 'in progress':
      case 'ongoing':
        return const Color(0xFFF1C40F);

      case 'live':
        return const Color(0xFFE74C3C);

      case 'completed':
      case 'finished':
        return const Color(0xFF2ECC71);

      case 'disputed':
        return const Color(0xFF9B59B6);

      case 'cancelled':
      case 'canceled':
        return Colors.grey;

      default:
        return (b == Brightness.dark)
            ? Colors.white
            : const Color(0xFF0A1D37);
    }
  }

  static List<Color> bubblePalette(Brightness b) {
    if (b == Brightness.dark) {
      return [
        navyBg,
        const Color(0xFF07162A),
        navyAccent.withOpacity(0.22),
        Colors.white.withOpacity(0.06),
      ];
    }
    return const [
      skyTop,
      skyBottom,
      Color(0xFFFFFFFF),
      Color(0xFFB3E5FC),
    ];
  }
}
