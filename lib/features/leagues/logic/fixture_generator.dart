import 'package:uuid/uuid.dart';

import '../models/fixture_match.dart';

/// Generates league fixtures in a deterministic and offline-safe way.
///
/// Supported:
/// - Classic Round Robin
/// - UCL Group Stage (via groupId)
///
/// NOT supported here:
/// - Knockout logic
/// - Swiss pairing (separate engine)
class FixtureGenerator {
  static final _uuid = Uuid();

  /// Generates a full round-robin fixture list.
  ///
  /// - Does NOT mutate input
  /// - Supports odd number of teams (bye rounds)
  static List<FixtureMatch> generateRoundRobin({
    required String leagueId,
    required List<String> teamIds,
    String? groupId,
  }) {
    final teams = List<String>.from(teamIds);

    // Add BYE if odd
    if (teams.length.isOdd) {
      teams.add('__BYE__');
    }

    final int numTeams = teams.length;
    final int rounds = numTeams - 1;
    final List<FixtureMatch> fixtures = [];

    final rotation = List<String>.from(teams);

    for (int round = 1; round <= rounds; round++) {
      for (int i = 0; i < numTeams / 2; i++) {
        final home = rotation[i];
        final away = rotation[numTeams - 1 - i];

        if (home == '__BYE__' || away == '__BYE__') continue;

        fixtures.add(
          FixtureMatch(
            id: _uuid.v4(),
            leagueId: leagueId,
            groupId: groupId,
            roundNumber: round,
            homeTeamId: home,
            awayTeamId: away,
            homeScore: null,
            awayScore: null,
            status: MatchStatus.scheduled,
            sortIndex: i,
            updatedAtMs: DateTime.now().millisecondsSinceEpoch,
            version: 1,
          ),
        );
      }

      // Rotate teams (keep first fixed)
      final last = rotation.removeLast();
      rotation.insert(1, last);
    }

    return fixtures;
  }
}
