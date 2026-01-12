enum LeaguePrivacy { public, private }

enum MatchStatus {
  scheduled,
  pendingProof,
  underReview,
  played,
  // Backward-compatible alias (if old code uses "completed")
  completed,
}

extension MatchStatusX on MatchStatus {
  static MatchStatus fromInt(int v) {
    if (v < 0 || v >= MatchStatus.values.length) return MatchStatus.scheduled;
    return MatchStatus.values[v];
  }
}
