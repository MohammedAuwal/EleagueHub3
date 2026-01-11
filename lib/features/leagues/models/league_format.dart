enum LeagueFormat { 
  classic, 
  uclGroup,
  uclSwiss
}

extension LeagueFormatX on LeagueFormat {
  /// This must be static to be called as LeagueFormat.fromInt
  static LeagueFormat fromInt(int v) {
    if (v < 0 || v >= LeagueFormat.values.length) {
      return LeagueFormat.classic; 
    }
    return LeagueFormat.values[v];
  }

  String get displayName {
    switch (this) {
      case LeagueFormat.classic: return 'Classic League (Round Robin)';
      case LeagueFormat.uclGroup: return 'UCL Group Stage';
      case LeagueFormat.uclSwiss: return 'UCL Swiss Model';
    }
  }
}

enum MatchReviewDecision { approved, rejected, pending }
