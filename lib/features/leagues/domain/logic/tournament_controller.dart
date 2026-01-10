import '../../models/knockout_match.dart';
import '../../models/fixture_match.dart';
import '../standings/standings.dart';

class TournamentController {
  /// Takes completed Group/Swiss standings and fills the R16 bracket.
  /// 
  /// Logic: Group A Winner vs Group B Runner-up, etc.
  static List<KnockoutMatch> seedKnockoutsFromGroups({
    required String leagueId,
    required Map<String, List<StandingsRow>> groupStandings,
  }) {
    // This is where you map "1st Place Group A" to Match 1, etc.
    // Logic for seeding goes here.
    return []; 
  }

  /// The "Automatic Advancement" engine.
  /// Called every time a score is confirmed.
  static List<KnockoutMatch> processMatchResult({
    required KnockoutMatch completedMatch,
    required List<KnockoutMatch> allMatches,
  }) {
    if (completedMatch.status != MatchStatus.played) return allMatches;

    final winnerId = completedMatch.winnerId;
    final loserId = (winnerId == completedMatch.homeTeamId) 
        ? completedMatch.awayTeamId 
        : completedMatch.homeTeamId;

    return allMatches.map((m) {
      var updated = m;
      
      // 1. Logic for Winners (W37 -> Next Round)
      if (m.id == completedMatch.nextMatchId) {
        if (m.homeTeamId == null) {
          updated = m.copyWith(homeTeamId: winnerId);
        } else {
          updated = m.copyWith(awayTeamId: winnerId);
        }
      }

      // 2. Logic for SF Losers (Move to 3rd Place Match)
      if (completedMatch.roundName == "Semi Finals" && m.roundName == "3rd Place") {
         if (m.homeTeamId == null) {
          updated = m.copyWith(homeTeamId: loserId);
        } else {
          updated = m.copyWith(awayTeamId: loserId);
        }
      }

      return updated;
    }).toList();
  }
}
