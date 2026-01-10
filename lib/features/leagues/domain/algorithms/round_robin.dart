import 'package:collection/collection.dart';
import 'package:uuid/uuid.dart';

import '../../models/fixture_match.dart';

/// The logic engine for generating league schedules in eSportlyic.
///
/// Uses the Circle Method to ensure balanced match-ups. 
/// Handles BYE weeks for odd numbers of teams and supports 
/// double round-robin (Home & Away) for the UCL and Classic formats.
class RoundRobinGenerator {
  /// Generates fixtures using the circle method.
  ///
  /// - Balances home/away by alternating per round and flipping second leg.
  /// - Supports odd team counts via a BYE (no fixture generated for BYE).
  static List<FixtureMatch> generate({
    required String leagueId,
    required List<String> teamIds,
    required bool doubleRoundRobin,
    String? groupId,
    required int startRoundNumber,
  }) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final uuid = const Uuid();

    final ids = [...teamIds];
    ids.sort(); // ensures deterministic schedule generation.

    // Add bye slot if the number of teams is odd.
    String? bye;
    if (ids.length.isOdd) {
      bye = '__BYE__';
      ids.add(bye);
    }

    final n = ids.length;
    if (n < 2) return [];

    // Circle method: fix first team position, rotate all others.
    var rotation = [...ids];

    final rounds = n - 1;
    final fixtures = <FixtureMatch>[];

    for (var r = 0; r < rounds; r++) {
      final pairs = <(String, String)>{};
      for (var i = 0; i < n ~/ 2; i++) {
        final a = rotation[i];
        final b = rotation[n - 1 - i];
        if (a == bye || b == bye) continue;
        pairs.add((a, b));
      }

      // Home/away balancing heuristic to reduce consecutive streaks
      final swapRound = r.isOdd;

      final roundPairsList = pairs.toList();
      for (var i = 0; i < roundPairsList.length; i++) {
        final (a, b) = roundPairsList[i];
        final swapPair = i.isOdd;
        final swap = swapRound ^ swapPair;
        final home = swap ? b : a;
        final away = swap ? a : b;

        fixtures.add(
          FixtureMatch(
            id: uuid.v4(),
            leagueId: leagueId,
            groupId: groupId,
            roundNumber: startRoundNumber + r,
            homeTeamId: home,
            awayTeamId: away,
            homeScore: null,
            awayScore: null,
            status: MatchStatus.scheduled,
            sortIndex: i,
            updatedAtMs: now,
            version: 1,
          ),
        );
      }

      rotation = _rotate(rotation);
    }

    if (!doubleRoundRobin) return fixtures;

    // Second leg: mirror home/away and continue round numbering for double round-robin.
    final secondLeg = fixtures.mapIndexed((idx, m) {
      return FixtureMatch(
        id: uuid.v4(),
        leagueId: leagueId,
        groupId: groupId,
        roundNumber: m.roundNumber + rounds,
        homeTeamId: m.awayTeamId, // Swap Home/Away for the return leg
        awayTeamId: m.homeTeamId,
        homeScore: null,
        awayScore: null,
        status: MatchStatus.scheduled,
        sortIndex: m.sortIndex,
        updatedAtMs: now,
        version: 1,
      );
    }).toList();

    return [...fixtures, ...secondLeg];
  }

  /// Rotates the list while keeping the first element fixed (Circle Method).
  static List<String> _rotate(List<String> list) {
    if (list.length < 2) return list;
    final result = List<String>.from(list);
    final last = result.removeLast();
    result.insert(1, last);
    return result;
  }
}
