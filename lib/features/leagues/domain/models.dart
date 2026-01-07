class League {
  League({
    required this.id,
    required this.name,
    required this.format,
    required this.privacy,
    required this.region,
    required this.maxTeams,
    required this.isPrivate,
  });

  final String id;
  final String name;
  final String format;
  final String privacy;
  final String region;
  final int maxTeams;
  final bool isPrivate;
}

class StandingRow {
  StandingRow({
    required this.team,
    required this.played,
    required this.wins,
    required this.draws,
    required this.losses,
    required this.gf,
    required this.ga,
    required this.points,
  });

  final String team;
  final int played;
  final int wins;
  final int draws;
  final int losses;
  final int gf;
  final int ga;
  final int points;

  int get gd => gf - ga;
}

class Fixture {
  Fixture({
    required this.id,
    required this.home,
    required this.away,
    required this.scheduledAt,
    required this.status,
    required this.matchId,
  });

  final String id;
  final String home;
  final String away;
  final DateTime scheduledAt;
  final String status; // Scheduled, Pending Proof, Under Review, Completed
  final String matchId;
}

class MatchReviewDecision {
  MatchReviewDecision({required this.approved, required this.reason});
  final bool approved;
  final String reason;
}
