/// --------------------
/// ENUMS
/// --------------------

enum LeagueFormat {
  roundRobin,
  swissModel,
  knockout,
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

/// --------------------
/// LEAGUE
/// --------------------

class League {
  const League({
    required this.id,
    required this.name,
    required this.format,
    required this.privacy,
    required this.region,
    required this.maxTeams,
    required this.season,
    required this.ownerId,
  });

  final String id;
  final String name;
  final LeagueFormat format;
  final LeaguePrivacy privacy;
  final String region;
  final int maxTeams;
  final String season;
  final String ownerId;

  bool get isPrivate => privacy == LeaguePrivacy.private;
}

/// --------------------
/// STANDINGS
/// --------------------

class StandingRow {
  const StandingRow({
    required this.teamId,
    required this.teamName,
    required this.played,
    required this.wins,
    required this.draws,
    required this.losses,
    required this.gf,
    required this.ga,
  });

  final String teamId;
  final String teamName;
  final int played;
  final int wins;
  final int draws;
  final int losses;
  final int gf;
  final int ga;

  int get points => (wins * 3) + draws;
  int get gd => gf - ga;
}

/// --------------------
/// FIXTURE / MATCH
/// --------------------

class Fixture {
  const Fixture({
    required this.id,
    required this.homeTeam,
    required this.awayTeam,
    required this.scheduledAt,
    required this.status,
    required this.matchId,
  });

  final String id;
  final String homeTeam;
  final String awayTeam;
  final DateTime scheduledAt;
  final MatchStatus status;
  final String matchId;

  bool get canUploadProof => status == MatchStatus.pendingProof;
  bool get isReviewable => status == MatchStatus.underReview;
}

/// --------------------
/// REVIEW DECISION
/// --------------------

class MatchReviewDecision {
  const MatchReviewDecision({
    required this.approved,
    required this.reason,
    this.reviewedBy = 'Organizer',
    DateTime? reviewedAt,
  }) : reviewedAt = reviewedAt ?? const DateTime(2026, 1, 11);

  final bool approved;
  final String reason;
  final String reviewedBy;
  final DateTime reviewedAt;
}
