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

  // Added missing members
  static Color statusColor(String status, Brightness brightness) {
    if (status == 'live') return Colors.red;
    if (status == 'finished') return Colors.grey;
    return brightness == Brightness.light ? Colors.blue : Colors.blueAccent;
  }

  static List<Color> bubblePalette(Brightness brightness) {
    return brightness == Brightness.light 
      ? [Colors.blue.withOpacity(0.3), Colors.lightBlue.withOpacity(0.2)]
      : [Colors.indigo.withOpacity(0.4), Colors.blueGrey.withOpacity(0.3)];
  }
}
