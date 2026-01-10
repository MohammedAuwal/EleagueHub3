import 'package:flutter_riverpod/flutter_riverpod.dart';

enum LeagueType { 
  classic,    // Round Robin
  uclClassic, // 8 Groups of 4
  uclSwiss    // New 36-team League Phase
}

final leagueModeProvider = StateProvider<LeagueType>((ref) => LeagueType.classic);
