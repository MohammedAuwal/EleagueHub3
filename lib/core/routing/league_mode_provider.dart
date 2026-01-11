import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Enum representing the different league modes
enum LeagueType { 
  classic,    // Round Robin
  uclClassic, // 8 Groups of 4
  uclSwiss    // New 36-team League Phase
}

/// Riverpod StateProvider to hold the current selected league mode
final leagueModeProvider = StateProvider<LeagueType>(
  (ref) => LeagueType.classic,
);
