enum LeagueFormat {
  classic,
  uclGroup,
  uclSwiss;

  String get displayName {
    switch (this) {
      case LeagueFormat.classic:
        return 'Classic League';
      case LeagueFormat.uclGroup:
        return 'UCL Group Stage';
      case LeagueFormat.uclSwiss:
        return 'UCL Swiss Model';
    }
  }
}

extension LeagueFormatX on LeagueFormat {
  static LeagueFormat fromInt(int v) {
    if (v < 0 || v >= LeagueFormat.values.length) return LeagueFormat.classic;
    return LeagueFormat.values[v];
  }
}
