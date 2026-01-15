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
  /// This method seeds:
  /// - 8 Play-off matches          (roundName = "Play-off")
  /// - 8 Round of 16 matches       (roundName = "Round of 16")
  /// - 4 Quarter-finals            (roundName = "Quarter Finals")
  /// - 2 Semi-finals               (roundName = "Semi Finals")
  /// - 1 Final                     (roundName = "Final")
  /// - 1 Third-place match         (roundName = "3rd Place")
  ///
  /// Wiring of [nextMatchId]:
  ///   Play-off -> Round of 16 -> Quarter Finals -> Semi Finals -> Final
  /// Semi-finals losers go to the single "3rd Place" match (handled by [processMatchResult]).
  static List<KnockoutMatch> seedSwissKnockouts({
    required String leagueId,
    required List<StandingsRow> swissStandings,
  }) {
    if (swissStandings.length < 16) {
      // Need at least 16 teams to have a meaningful Play-off + full KO tree.
      return [];
    }

    final now = DateTime.now().millisecondsSinceEpoch;

    String _id(String prefix, int index) =>
        '$leagueId-$prefix-${now}_$index';

    // 1–8: auto qualifiers for Round of 16
    final autoQualifiers = swissStandings.take(8).toList();

    // 9–24: playoff pool (may be smaller if not enough teams, but we cap at 16).
    final playoffSeeds = swissStandings.skip(8).take(16).toList();

    // --- Create Round of 16 skeleton: 8 matches, home team = top 8 (where available) ---
    final r16Matches = <KnockoutMatch>[];
    for (var i = 0; i < 8; i++) {
      final homeTeamId = i < autoQualifiers.length
          ? autoQualifiers[i].teamId
          : null;

      r16Matches.add(
        KnockoutMatch(
          id: _id('R16', i + 1),
          leagueId: leagueId,
          roundName: 'Round of 16',
          homeTeamId: homeTeamId,
          awayTeamId: null,
          homeScore: null,
          awayScore: null,
          status: MatchStatus.scheduled,
          nextMatchId: null, // will be wired to QF below
          loserGoesToMatchId: null,
          isSecondLeg: false,
        ),
      );
    }

    // --- Create Quarter-finals: 4 matches ---
    // QF1: winners of R16-1 & R16-2
    // QF2: winners of R16-3 & R16-4
    // QF3: winners of R16-5 & R16-6
    // QF4: winners of R16-7 & R16-8
    final qfMatches = <KnockoutMatch>[];
    for (var i = 0; i < 4; i++) {
      qfMatches.add(
        KnockoutMatch(
          id: _id('QF', i + 1),
          leagueId: leagueId,
          roundName: 'Quarter Finals',
          homeTeamId: null,
          awayTeamId: null,
          homeScore: null,
          awayScore: null,
          status: MatchStatus.scheduled,
          nextMatchId: null, // will be wired to SF below
          loserGoesToMatchId: null,
          isSecondLeg: false,
        ),
      );
    }

    // --- Create Semi-finals: 2 matches ---
    // SF1: winners of QF1 & QF2
    // SF2: winners of QF3 & QF4
    final sfMatches = <KnockoutMatch>[];
    for (var i = 0; i < 2; i++) {
      sfMatches.add(
        KnockoutMatch(
          id: _id('SF', i + 1),
          leagueId: leagueId,
          roundName: 'Semi Finals',
          homeTeamId: null,
          awayTeamId: null,
          homeScore: null,
          awayScore: null,
          status: MatchStatus.scheduled,
          nextMatchId: null, // will be wired to Final below
          loserGoesToMatchId: null,
          isSecondLeg: false,
        ),
      );
    }

    // --- Create Final & 3rd Place ---
    final finalMatch = KnockoutMatch(
      id: _id('F', 1),
      leagueId: leagueId,
      roundName: 'Final',
      homeTeamId: null,
      awayTeamId: null,
      homeScore: null,
      awayScore: null,
      status: MatchStatus.scheduled,
      nextMatchId: null,
      loserGoesToMatchId: null,
      isSecondLeg: false,
    );

    final thirdPlace = KnockoutMatch(
      id: _id('3P', 1),
      leagueId: leagueId,
      roundName: '3rd Place',
      homeTeamId: null,
      awayTeamId: null,
      homeScore: null,
      awayScore: null,
      status: MatchStatus.scheduled,
      nextMatchId: null,
      loserGoesToMatchId: null,
      isSecondLeg: false,
    );

    // --- Wire R16 -> QF ---
    // R16[0,1] -> QF[0], R16[2,3] -> QF[1], R16[4,5] -> QF[2], R16[6,7] -> QF[3]
    void wireR16ToQF(int r16Index, int qfIndex) {
      final m = r16Matches[r16Index];
      r16Matches[r16Index] =
          m.copyWith(nextMatchId: qfMatches[qfIndex].id);
    }

    wireR16ToQF(0, 0);
    wireR16ToQF(1, 0);
    wireR16ToQF(2, 1);
    wireR16ToQF(3, 1);
    wireR16ToQF(4, 2);
    wireR16ToQF(5, 2);
    wireR16ToQF(6, 3);
    wireR16ToQF(7, 3);

    // --- Wire QF -> SF ---
    // QF[0,1] -> SF[0], QF[2,3] -> SF[1]
    void wireQFToSF(int qfIndex, int sfIndex) {
      final m = qfMatches[qfIndex];
      qfMatches[qfIndex] =
          m.copyWith(nextMatchId: sfMatches[sfIndex].id);
    }

    wireQFToSF(0, 0);
    wireQFToSF(1, 0);
    wireQFToSF(2, 1);
    wireQFToSF(3, 1);

    // --- Wire SF -> Final ---
    // Both SF winners go to the same Final match.
    for (var i = 0; i < sfMatches.length; i++) {
      final m = sfMatches[i];
      sfMatches[i] = m.copyWith(nextMatchId: finalMatch.id);
    }
    // SF losers automatically go to the 3rd place match via [processMatchResult]
    // which checks: completedMatch.roundName == "Semi Finals" && m.roundName == "3rd Place".

    // --- Create Play-off matches: pair 9 vs 24, 10 vs 23, ... ---
    final playoffMatches = <KnockoutMatch>[];

    if (playoffSeeds.length >= 2) {
      int start = 0;
      int end = playoffSeeds.length - 1;
      int pairIndex = 0;

      while (start < end && pairIndex < 8) {
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
      ...qfMatches,
      ...sfMatches,
      finalMatch,
      thirdPlace,
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
