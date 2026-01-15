import 'dart:math';

import '../../models/enums.dart';
import '../../models/knockout_match.dart';
import '../../models/fixture_match.dart';
import '../standings/standings.dart';

class TournamentController {
  /// Group-based UCL seeding:
  ///
  /// Input: groupStandings[groupId] = List<StandingsRow> sorted best→worst.
  ///
  /// - For each group, we take:
  ///   - Winner  (index 0)
  ///   - Runner-up (index 1)
  ///
  /// - From all groups (sorted by groupId), we build:
  ///   - Winners list: [A1, B1, C1, ...]
  ///   - Runners list: [A2, B2, C2, ...]
  ///
  /// - Round of 16 pairings (for pairs of groups):
  ///   - A1 vs B2
  ///   - B1 vs A2
  ///   - C1 vs D2
  ///   - D1 vs C2
  ///   - ...
  ///
  /// Then we build the tree:
  ///   - 8 Round of 16 matches
  ///   - 4 Quarter Finals
  ///   - 2 Semi Finals
  ///   - 1 Final
  ///   - 1 Third Place
  static List<KnockoutMatch> seedKnockoutsFromGroups({
    required String leagueId,
    required Map<String, List<StandingsRow>> groupStandings,
  }) {
    if (groupStandings.isEmpty) return [];

    final now = DateTime.now().millisecondsSinceEpoch;
    String _id(String prefix, int index) =>
        '$leagueId-$prefix-${now}_$index';

    // Sort groups by name (e.g. "Group A", "Group B", ...)
    final groupKeys = groupStandings.keys.toList()..sort();

    // Collect winners and runners-up
    final winners = <StandingsRow>[];
    final runners = <StandingsRow>[];

    for (final g in groupKeys) {
      final rows = groupStandings[g] ?? [];
      if (rows.isEmpty) continue;
      winners.add(rows[0]);
      if (rows.length > 1) runners.add(rows[1]);
    }

    if (winners.isEmpty || runners.isEmpty) {
      return [];
    }

    // --- Create Round of 16 matches ---
    final r16Matches = <KnockoutMatch>[];

    // Pair groups in twos: (A,B), (C,D), ...
    int r16Index = 0;
    for (var i = 0; i + 1 < winners.length && i + 1 < runners.length; i += 2) {
      if (r16Index >= 8) break;

      final g1Winner = winners[i];
      final g2Winner = winners[i + 1];

      final g1Runner = runners[i];
      final g2Runner = runners[i + 1];

      // Match 1: g1Winner vs g2Runner
      r16Matches.add(
        KnockoutMatch(
          id: _id('R16', r16Index + 1),
          leagueId: leagueId,
          roundName: 'Round of 16',
          homeTeamId: g1Winner.teamId,
          awayTeamId: g2Runner.teamId,
          homeScore: null,
          awayScore: null,
          status: MatchStatus.scheduled,
          nextMatchId: null,
          loserGoesToMatchId: null,
          isSecondLeg: false,
        ),
      );
      r16Index++;
      if (r16Index >= 8) break;

      // Match 2: g2Winner vs g1Runner
      r16Matches.add(
        KnockoutMatch(
          id: _id('R16', r16Index + 1),
          leagueId: leagueId,
          roundName: 'Round of 16',
          homeTeamId: g2Winner.teamId,
          awayTeamId: g1Runner.teamId,
          homeScore: null,
          awayScore: null,
          status: MatchStatus.scheduled,
          nextMatchId: null,
          loserGoesToMatchId: null,
          isSecondLeg: false,
        ),
      );
      r16Index++;
    }

    // Pad to 8 matches if fewer were created.
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

    // Build QF, SF, Final, 3rd Place exactly like Swiss.
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
          nextMatchId: null,
          loserGoesToMatchId: null,
          isSecondLeg: false,
        ),
      );
    }

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
          nextMatchId: null,
          loserGoesToMatchId: null,
          isSecondLeg: false,
        ),
      );
    }

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

    // Wire R16 -> QF (same pattern as Swiss)
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

    // Wire QF -> SF
    void wireQFToSF(int qfIndex, int sfIndex) {
      final m = qfMatches[qfIndex];
      qfMatches[qfIndex] =
          m.copyWith(nextMatchId: sfMatches[sfIndex].id);
    }

    wireQFToSF(0, 0);
    wireQFToSF(1, 0);
    wireQFToSF(2, 1);
    wireQFToSF(3, 1);

    // Wire SF -> Final
    for (var i = 0; i < sfMatches.length; i++) {
      final m = sfMatches[i];
      sfMatches[i] = m.copyWith(nextMatchId: finalMatch.id);
    }
    // SF losers go to 3rd place via processMatchResult.

    return [
      ...r16Matches,
      ...qfMatches,
      ...sfMatches,
      finalMatch,
      thirdPlace,
    ];
  }

  /// Swiss-specific seeding:
  ///
  /// - Top 1–8: go directly to Round of 16 (automatic qualifiers).
  /// - 9–24: go into a Play-off round (16 teams, 8 matches).
  /// - Winners of Play-off matches advance into the remaining 8 R16 slots.
  ///
  /// This seeds:
  /// - 8 Play-off matches
  /// - 8 Round of 16 matches
  /// - 4 Quarter Finals
  /// - 2 Semi Finals
  /// - 1 Final
  /// - 1 Third Place
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

    // 1–8: auto qualifiers
    final autoQualifiers = swissStandings.take(8).toList();

    // 9–24: playoff pool (cap at 16)
    final playoffSeeds =
        swissStandings.skip(8).take(16).toList();

    // --- Create Round of 16 skeleton: 8 matches ---
    final r16Matches = <KnockoutMatch>[];
    for (var i = 0; i < 8; i++) {
      final homeTeamId =
          i < autoQualifiers.length ? autoQualifiers[i].teamId : null;

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
          nextMatchId: null,
          loserGoesToMatchId: null,
          isSecondLeg: false,
        ),
      );
    }

    // --- Create QF, SF, Final, 3rd Place (same as groups) ---
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
          nextMatchId: null,
          loserGoesToMatchId: null,
          isSecondLeg: false,
        ),
      );
    }

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
          nextMatchId: null,
          loserGoesToMatchId: null,
          isSecondLeg: false,
        ),
      );
    }

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

    // Wire R16 -> QF
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

    // Wire QF -> SF
    void wireQFToSF(int qfIndex, int sfIndex) {
      final m = qfMatches[qfIndex];
      qfMatches[qfIndex] =
          m.copyWith(nextMatchId: sfMatches[sfIndex].id);
    }

    wireQFToSF(0, 0);
    wireQFToSF(1, 0);
    wireQFToSF(2, 1);
    wireQFToSF(3, 1);

    // Wire SF -> Final
    for (var i = 0; i < sfMatches.length; i++) {
      final m = sfMatches[i];
      sfMatches[i] = m.copyWith(nextMatchId: finalMatch.id);
    }

    // --- Create Play-off matches: pair 9 vs 24, 10 vs 23, ... ---
    final playoffMatches = <KnockoutMatch>[];

    if (playoffSeeds.length >= 2) {
      int start = 0;
      int end = playoffSeeds.length - 1;
      int pairIndex = 0;

      while (start < end && pairIndex < 8) {
        final a = playoffSeeds[start];
        final b = playoffSeeds[end];

        // Map pairIndex to an R16 slot (reverse order).
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
