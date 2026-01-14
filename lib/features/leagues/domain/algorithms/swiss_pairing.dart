import 'dart:math';

import 'package:uuid/uuid.dart';

import '../../models/team.dart';
import '../../models/fixture_match.dart';
import '../../models/enums.dart';
import '../../models/team_stats.dart';

/// Simple Swiss-pairing engine for league phase:
/// - Round 1: random (seeded) pairings
/// - Later rounds: pair teams with similar points, avoid rematches where possible
class SwissPairingEngine {
  static final _uuid = const Uuid();

  /// Generate Round 1 pairings (Swiss style: random but deterministic per league).
  static List<FixtureMatch> generateInitialRound({
    required String leagueId,
    required List<Team> teams,
    required int roundNumber,
  }) {
    if (teams.length < 2) return [];

    final rand = Random(leagueId.hashCode ^ roundNumber);
    final shuffled = List<Team>.from(teams)..shuffle(rand);

    final now = DateTime.now().millisecondsSinceEpoch;
    final fixtures = <FixtureMatch>[];

    for (var i = 0; i + 1 < shuffled.length; i += 2) {
      final home = shuffled[i];
      final away = shuffled[i + 1];

      fixtures.add(
        FixtureMatch(
          id: _uuid.v4(),
          leagueId: leagueId,
          groupId: null, // Swiss is a single global league phase
          roundNumber: roundNumber,
          homeTeamId: home.id,
          awayTeamId: away.id,
          homeScore: null,
          awayScore: null,
          status: MatchStatus.scheduled,
          sortIndex: i ~/ 2,
          updatedAtMs: now,
          version: 1,
        ),
      );
    }

    // If odd number of teams, last one gets a BYE (no fixture created).
    return fixtures;
  }

  /// Generate the next Swiss round pairings.
  ///
  /// - Uses all *played* matches from previous rounds to compute TeamStats.
  /// - Sorts teams by points, goal difference, goals for, teamId.
  /// - Pairs neighbors while trying to avoid rematches.
  static List<FixtureMatch> generateNextRound({
    required String leagueId,
    required List<Team> teams,
    required List<FixtureMatch> existingMatches,
    required int nextRoundNumber,
  }) {
    if (teams.length < 2) return [];

    final now = DateTime.now().millisecondsSinceEpoch;
    final rand = Random(leagueId.hashCode ^ nextRoundNumber);

    // Consider only matches that are already played and before this round.
    final played = existingMatches
        .where((m) => m.isPlayed && m.roundNumber < nextRoundNumber)
        .toList();

    // Build base stats for all teams.
    final stats = <String, TeamStats>{
      for (final t in teams)
        t.id: TeamStats.empty(teamId: t.id, leagueId: leagueId),
    };

    for (final m in played) {
      final hs = m.homeScore!;
      final as = m.awayScore!;

      final homeStats = stats[m.homeTeamId]!;
      final awayStats = stats[m.awayTeamId]!;

      stats[m.homeTeamId] = homeStats.applyMatch(
        scored: hs,
        conceded: as,
      );
      stats[m.awayTeamId] = awayStats.applyMatch(
        scored: as,
        conceded: hs,
      );
    }

    // Order teams by Swiss ranking tie-breakers.
    final ordered = stats.values.toList()
      ..sort((a, b) {
        // 1. Points (desc)
        final p = b.points.compareTo(a.points);
        if (p != 0) return p;

        // 2. Goal difference (desc)
        final gd = b.goalDifference.compareTo(a.goalDifference);
        if (gd != 0) return gd;

        // 3. Goals scored (desc)
        final gf = b.goalsFor.compareTo(a.goalsFor);
        if (gf != 0) return gf;

        // 4. Stable by teamId
        return a.teamId.compareTo(b.teamId);
      });

    // Build set of previous pairs to avoid rematches.
    String pairKey(String a, String b) {
      return (a.compareTo(b) < 0) ? '$a|$b' : '$b|$a';
    }

    final previousPairs = <String>{};
    for (final m in existingMatches) {
      previousPairs.add(pairKey(m.homeTeamId, m.awayTeamId));
    }

    final unpaired = <String>[
      for (final s in ordered) s.teamId,
    ];

    final fixtures = <FixtureMatch>[];
    var pairIndex = 0;

    while (unpaired.length > 1) {
      final a = unpaired.removeAt(0);

      int? chosenIdx;
      // Try to find the closest opponent without rematch.
      for (var i = 0; i < unpaired.length; i++) {
        final b = unpaired[i];
        if (!previousPairs.contains(pairKey(a, b))) {
          chosenIdx = i;
          break;
        }
      }

      // If all have been played already, pick a random opponent.
      chosenIdx ??= rand.nextInt(unpaired.length);

      final b = unpaired.removeAt(chosenIdx);

      fixtures.add(
        FixtureMatch(
          id: _uuid.v4(),
          leagueId: leagueId,
          groupId: null,
          roundNumber: nextRoundNumber,
          homeTeamId: a,
          awayTeamId: b,
          homeScore: null,
          awayScore: null,
          status: MatchStatus.scheduled,
          sortIndex: pairIndex++,
          updatedAtMs: now,
          version: 1,
        ),
      );
    }

    // If odd, last remaining team gets a BYE (no fixture created).
    return fixtures;
  }
}
