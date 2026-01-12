import 'fixture_match.dart';

/// Represents a match in the Bracket stage (R16, QF, SF, Final).
///
/// Extends the basic match logic to include tournament progression.
class KnockoutMatch {
  final String id;
  final String leagueId;
  final String roundName; // R16, QF, SF, Final, 3rd Place
  final String? homeTeamId;
  final String? awayTeamId;
  final int? homeScore;
  final int? awayScore;
  final MatchStatus status;
  
  /// The ID of the match the winner will advance to.
  final String? nextMatchId;
  
  /// For 3rd place logic: where the loser goes.
  final String? loserGoesToMatchId;

  /// Identifying if this is a "Home" or "Away" leg (UCL Standard).
  final bool isSecondLeg;

  const KnockoutMatch({
    required this.id,
    required this.leagueId,
    required this.roundName,
    this.homeTeamId,
    this.awayTeamId,
    this.homeScore,
    this.awayScore,
    required this.status,
    this.nextMatchId,
    this.loserGoesToMatchId,
    this.isSecondLeg = false,
  });

  /// Logic to determine the winner (including aggregate/penalties if needed).
  String? get winnerId {
    if (status != MatchStatus.completed || homeScore == null || awayScore == null) return null;
    if (homeScore! > awayScore!) return homeTeamId;
    if (awayScore! > homeScore!) return awayTeamId;
    return null; // Draw (requires extra-time/penalties logic)
  }
}
