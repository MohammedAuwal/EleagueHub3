import '../models/league_format.dart';

/// Organizer match review decision
enum MatchReviewDecision {
  approve,
  reject,
}

/// Domain model representing a match proof review record.
class MatchReview {
  final String leagueId;
  final String matchId;
  final bool approved;
  final String reason;
  final String reviewedBy;
  final DateTime reviewedAt;

  const MatchReview({
    required this.leagueId,
    required this.matchId,
    required this.approved,
    this.reason = '',
    required this.reviewedBy,
    required this.reviewedAt,
  });
}

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

  // These getters fix the LeagueDetailScreen errors
  String get home => homeTeam;
  String get away => awayTeam;

  bool get canUploadProof => status == MatchStatus.pendingProof;
  bool get isReviewable => status == MatchStatus.underReview;
}

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
