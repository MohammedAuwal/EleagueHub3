import 'package:flutter_riverpod/flutter_riverpod.dart';

enum LeagueType { 
  classic,    // Standard Round Robin
  uclClassic, // Group Stage + Knockout
  uclSwiss    // New 36-team League Phase
}

final leagueModeProvider = StateProvider<LeagueType>((ref) => LeagueType.classic);
