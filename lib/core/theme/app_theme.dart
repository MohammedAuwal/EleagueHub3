import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData skyTheme() => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorSchemeSeed: Colors.blue,
  );

  static ThemeData navyTheme() => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorSchemeSeed: Colors.indigo,
  );

  static Color glassFill(Brightness b) => b == Brightness.light 
      ? Colors.white.withOpacity(0.2) 
      : Colors.black.withOpacity(0.2);

  static Color glassStroke(Brightness b) => b == Brightness.light 
      ? Colors.white.withOpacity(0.3) 
      : Colors.white.withOpacity(0.1);

  static Gradient backgroundGradient(Brightness b) => LinearGradient(
    colors: b == Brightness.light 
      ? [Colors.blue.shade50, Colors.white] 
      : [Colors.black, Colors.indigo.shade900],
  );
}
