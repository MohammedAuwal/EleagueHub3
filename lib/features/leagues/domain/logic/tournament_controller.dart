import 'dart:math';

import '../../models/enums.dart';
import '../../models/knockout_match.dart';
import '../../models/fixture_match.dart';
import '../standings/standings.dart';

class TournamentController {
  /// Takes completed Group/Swiss standings and fills the R16 bracket.
  ///
  /// Existing stub – currently unused in the new flow.
  static List<KnockoutMatch> seedKnockoutsFromGroups({
    required String leagueId,
    required Map<String, List<StandingsRow>> groupStandings,
  }) {
    // TODO: Implement classic UCL group seeding (Group A winner vs Group B runner-up, etc.)
    return [];
  }

  /// Swiss-specific seeding:
  ///
  /// - Top 1–8: go directly to Round of 16 (automatic qualifiers).
  /// - 9–24: go into a Play-off round (16 teams, 8 matches).
  /// - Winners of Play-off matches advance into the remaining 8 R16 slots.
  ///
  /// This method only seeds:
  /// - 8 Play-off matches (roundName = "Play-off")
  /// - 8 Round of 16 matches (roundName = "Round of 16")
  ///
  /// It does NOT create QF/SF/Final yet; those can be added later.
  static List<KnockoutMatch> seedSwissKnockouts({
    required String leagueId,
    required List<StandingsRow> swissStandings,
  }) {
    if (swissStandings.length < 16) {
      // Need at least 16 teams to have a meaningful Play-off + R16.
      return [];
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    final rand = Random(leagueId.hashCode ^ now);

    String _id(String prefix, int index) =>
        '$leagueId-$prefix-${now}_$index';

    // 1–8: auto qualifiers
    final autoQualifiers = swissStandings.take(8).toList();

    // 9–24: playoff pool (may be smaller if not enough teams)
    final playoffSeeds = swissStandings
        .skip(8)
        .take(16)
        .toList(); // 9..24 if available

    // --- Create Round of 16 skeleton: 8 matches, home team = top 8 ---
    final r16Matches = <KnockoutMatch>[];
    for (var i = 0; i < autoQualifiers.length && i < 8; i++) {
      final r = autoQualifiers[i];
      r16Matches.add(
        KnockoutMatch(
          id: _id('R16', i + 1),
          leagueId: leagueId,
          roundName: 'Round of 16',
          homeTeamId: r.teamId,
          awayTeamId: null,
          homeScore: null,
          awayScore: null,
          status: MatchStatus.scheduled,
          nextMatchId: null,
          loserGoesToMatchId: null,
          isSecondLeg: false,
        ),
      );
    }

    // If less than 8 auto qualifiers (very small Swiss), pad empty R16 slots.
    while (r16Matches.length < 8) {
      final i = r16Matches.length;
      r16Matches.add(
        KnockoutMatch(
          id: _id('R16', i + 1),
          leagueId: leagueId,
          roundName: 'Round of 16',
          homeTeamId: null,
          awayTeamId: null,
          homeScore: null,
          awayScore: null,
          status: MatchStatus.scheduled,
          nextMatchId: null,
          loserGoesToMatchId: null,
          isSecondLeg: false,
        ),
      );
    }

    // --- Create Play-off matches: pair 9 vs 24, 10 vs 23, ... ---
    final playoffMatches = <KnockoutMatch>[];

    if (playoffSeeds.length >= 2) {
      int start = 0;
      int end = playoffSeeds.length - 1;
      int pairIndex = 0;

      while (start < end) {
        final a = playoffSeeds[start];
        final b = playoffSeeds[end];

        // Map pairIndex to an R16 slot.
        // Example mapping (reverse order):
        //  pair 0 -> R16[7], pair 1 -> R16[6], ..., pair 7 -> R16[0]
        final r16Index =
            max(0, 7 - pairIndex).clamp(0, r16Matches.length - 1);

        playoffMatches.add(
          KnockoutMatch(
            id: _id('PO', pairIndex + 1),
            leagueId: leagueId,
            roundName: 'Play-off',
            homeTeamId: a.teamId,
            awayTeamId: b.teamId,
            homeScore: null,
            awayScore: null,
            status: MatchStatus.scheduled,
            nextMatchId: r16Matches[r16Index].id,
            loserGoesToMatchId: null,
            isSecondLeg: false,
          ),
        );

        pairIndex++;
        start++;
        end--;
      }
    }

    return [
      ...playoffMatches,
      ...r16Matches,
    ];
  }

  /// The "Automatic Advancement" engine.
  /// Called every time a score is confirmed.
  static List<KnockoutMatch> processMatchResult({
    required KnockoutMatch completedMatch,
    required List<KnockoutMatch> allMatches,
  }) {
    if (completedMatch.status != MatchStatus.completed) return allMatches;

    final winnerId = completedMatch.winnerTeamId;
    if (winnerId == null) return allMatches;

    final loserId = (winnerId == completedMatch.homeTeamId)
        ? completedMatch.awayTeamId
        : completedMatch.homeTeamId;

    return allMatches.map((m) {
      var updated = m;

      // 1. Logic for Winners: advance to next match slot
      if (m.id == completedMatch.nextMatchId) {
        if (m.homeTeamId == null) {
          updated = m.copyWith(homeTeamId: winnerId);
        } else if (m.awayTeamId == null) {
          updated = m.copyWith(awayTeamId: winnerId);
        }
      }

      // 2. Logic for SF Losers (Move to 3rd Place Match)
      if (completedMatch.roundName == "Semi Finals" &&
          m.roundName == "3rd Place") {
        if (m.homeTeamId == null) {
          updated = m.copyWith(homeTeamId: loserId);
        } else if (m.awayTeamId == null) {
          updated = m.copyWith(awayTeamId: loserId);
        }
      }

      return updated;
    }).toList();
  }
}
