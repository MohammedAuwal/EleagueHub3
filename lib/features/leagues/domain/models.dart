import '../models/league_format.dart';


/// Organizer match review decision
enum MatchReviewDecision {
  approve,
  reject,
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


/// Organizer match review decision

  final String id;
  final String homeTeam;
  final String awayTeam;
  final DateTime scheduledAt;
  final MatchStatus status;
  final String matchId;


/// Organizer match review decision

  // These getters fix the LeagueDetailScreen errors
  String get home => homeTeam;
  String get away => awayTeam;


/// Organizer match review decision

// bool get canUploadProof => status == MatchStatus.pendingProof;
// bool get isReviewable => status == MatchStatus.underReview;
}


/// Organizer match review decision

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


/// Organizer match review decision

  final String teamId;
  final String teamName;
  final int played;
  final int wins;
  final int draws;
  final int losses;
  final int gf;
  final int ga;


/// Organizer match review decision

  int get points => (wins * 3) + draws;
  int get gd => gf - ga;
}


/// Organizer match review decision



/// Organizer match review decision

  final bool approved;
  final String reason;
  final String reviewedBy;
  final DateTime reviewedAt;
}
