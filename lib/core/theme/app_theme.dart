import 'package:flutter/material.dart';

class AppTheme {
  // Deep Navy (Night)
  static const Color navyBg = Color(0xFF0A1D37);
  static const Color navyAccent = Color(0xFF00D4FF);

  // Sky (Day)
  static const Color skyTop = Color(0xFF40C4FF);
  static const Color skyBottom = Color(0xFF81D4FA);

  // Aliases for compatibility with your existing App and main.dart
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

  // Glass helpers
  static Color glassFill(Brightness b) {
    return (b == Brightness.dark)
        ? const Color(0x1AFFFFFF) // ~0.10
        : const Color(0x26FFFFFF); // ~0.15
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
      colors: [skyTop, skyBottom],
    );
  }

  /// Used by status_badge.dart
  static Color statusColor(String status, Brightness b) {
    final s = status.trim().toLowerCase();
    switch (s) {
      case 'open':
      case 'recruiting':
        return (b == Brightness.dark)
            ? const Color(0xFF00D4FF)
            : const Color(0xFF0A1D37);
      case 'in progress':
      case 'ongoing':
        return const Color(0xFFF1C40F); // yellow
      case 'live':
        return const Color(0xFFE74C3C); // red-ish live
      case 'completed':
      case 'finished':
        return const Color(0xFF2ECC71); // green
      case 'disputed':
        return const Color(0xFF9B59B6); // purple
      case 'cancelled':
      case 'canceled':
        return Colors.grey;
      default:
        return (b == Brightness.dark) ? Colors.white : const Color(0xFF0A1D37);
    }
  }

  /// Used by animated_bubble_background.dart
  static List<Color> bubblePalette(Brightness b) {
    if (b == Brightness.dark) {
      return [
        const Color(0xFF0A1D37),
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
