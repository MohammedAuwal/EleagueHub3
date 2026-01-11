/// Defines the three competition structures in eSportlyic.
enum LeagueFormat { 
  classic, 
  uclGroup,
  uclSwiss
}

/// Extension to provide helper methods for all three LeagueFormats.
extension LeagueFormatX on LeagueFormat {
  static LeagueFormat fromInt(int v) {
    if (v < 0 || v >= LeagueFormat.values.length) {
      return LeagueFormat.classic; 
    }
    return LeagueFormat.values[v];
  }

  String get displayName {
    switch (this) {
      case LeagueFormat.classic:
        return 'Classic League (Round Robin)';
      case LeagueFormat.uclGroup:
        return 'UCL Group Stage';
      case LeagueFormat.uclSwiss:
        return 'UCL Swiss Model';
    }
  }

  String get description {
    switch (this) {
      case LeagueFormat.classic:
        return 'Everyone plays everyone else home and away.';
      case LeagueFormat.uclGroup:
        return 'Teams split into groups of 4; top teams advance.';
      case LeagueFormat.uclSwiss:
        return 'One big league table; play 8 different opponents.';
    }
  }
}

/// Needed for Match Review logic in the repository
enum MatchReviewDecision {
  approved,
  rejected,
  pending
}
