enum LeagueFormat {
  classic,
  uclGroup,
  uclSwiss,
}

enum LeaguePrivacy {
  public,
  private,
}

enum MatchStatus {
  scheduled,
  pendingProof,
  underReview,
  completed,
}

extension LeagueFormatX on LeagueFormat {
  static LeagueFormat fromInt(int v) {
    if (v < 0 || v >= LeagueFormat.values.length) return LeagueFormat.classic;
    return LeagueFormat.values[v];
  }
}

class MatchReviewDecision {
  final bool approved;
  final String reason;
  MatchReviewDecision({required this.approved, required this.reason});
}

class MatchReviewDecision {
  final bool approved;
  final String reason;
  MatchReviewDecision({required this.approved, required this.reason});
}
