/// Defines the three competition structures in eSportlyic.
/// 
/// - classic: Standard Round Robin (Domestic league style).
/// - uclGroup: The classic Champions League Group Stage format.
/// - uclSwiss: The new UCL Swiss Model (League phase).
enum LeagueFormat { 
  classic, 
  uclGroup,
  uclSwiss
}

/// Extension to provide helper methods for all three LeagueFormats.
extension LeagueFormatX on LeagueFormat {
  /// Converts an integer from the database back into a LeagueFormat.
  /// 0 = classic, 1 = uclGroup, 2 = uclSwiss.
  static LeagueFormat fromInt(int v) {
    if (v < 0 || v >= LeagueFormat.values.length) {
      return LeagueFormat.classic; 
    }
    return LeagueFormat.values[v];
  }

  /// Returns a display name for the UI menus.
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

  /// Returns a description of how matches are generated for this format.
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
