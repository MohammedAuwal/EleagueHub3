enum LeagueFormat {
  classic,
  uclGroup,
  uclSwiss;

  String get displayName {
    switch (this) {
      case LeagueFormat.classic: return 'Classic League';
      case LeagueFormat.uclGroup: return 'UCL Group Stage';
      case LeagueFormat.uclSwiss: return 'UCL Swiss Model';
    }
  }
}

enum LeaguePrivacy { public, private }

enum MatchStatus { 
  scheduled, 
  pendingProof, 
  underReview, // Standardized name
  played       // Standardized name
}

}

extension MatchStatusX on MatchStatus {
  static MatchStatus fromInt(int v) {
    if (v < 0 || v >= MatchStatus.values.length) return MatchStatus.scheduled;
    return MatchStatus.values[v];
  }
}

extension LeagueFormatX on LeagueFormat {
  static LeagueFormat fromInt(int v) {
    if (v < 0 || v >= LeagueFormat.values.length) return LeagueFormat.classic;
    return LeagueFormat.values[v];
  }
}
