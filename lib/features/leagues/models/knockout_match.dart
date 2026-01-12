import 'enums.dart';

/// Represents a match in the Bracket stage (R16, QF, SF, Final).
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

  bool get isFinished =>
      status == MatchStatus.played || status == MatchStatus.completed;

  /// Determine winner (draw returns null; add penalties/aggregate logic later)
  String? get winnerTeamId {
    if (!isFinished || homeScore == null || awayScore == null) return null;
    if (homeScore! > awayScore!) return homeTeamId;
    if (awayScore! > homeScore!) return awayTeamId;
    return null;
  }

  KnockoutMatch copyWith({
    String? id,
    String? leagueId,
    String? roundName,
    String? homeTeamId,
    String? awayTeamId,
    int? homeScore,
    int? awayScore,
    MatchStatus? status,
    String? nextMatchId,
    String? loserGoesToMatchId,
    bool? isSecondLeg,
  }) {
    return KnockoutMatch(
      id: id ?? this.id,
      leagueId: leagueId ?? this.leagueId,
      roundName: roundName ?? this.roundName,
      homeTeamId: homeTeamId ?? this.homeTeamId,
      awayTeamId: awayTeamId ?? this.awayTeamId,
      homeScore: homeScore ?? this.homeScore,
      awayScore: awayScore ?? this.awayScore,
      status: status ?? this.status,
      nextMatchId: nextMatchId ?? this.nextMatchId,
      loserGoesToMatchId: loserGoesToMatchId ?? this.loserGoesToMatchId,
      isSecondLeg: isSecondLeg ?? this.isSecondLeg,
    );
  }
}
