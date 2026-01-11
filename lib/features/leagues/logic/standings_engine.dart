import '../models/team_stats.dart';
import '../models/fixture_match.dart';

/// Responsible for sorting teams into a correct league table.
///
/// This engine:
/// - Never mutates TeamStats
/// - Applies FIFA-style ranking rules
/// - Is deterministic and replayable
///
/// Order of ranking:
/// 1. Points
/// 2. Head-to-head points
/// 3. Goal difference
/// 4. Goals scored
class StandingsEngine {
  static List<TeamStats> compute(
    List<TeamStats> teams,
    List<FixtureMatch> matches,
  ) {
    final sorted = List<TeamStats>.from(teams);

    sorted.sort((a, b) {
      // 1. Points
      if (a.points != b.points) {
        return b.points.compareTo(a.points);
      }

      // 2. Head-to-head
      final h2h = _headToHeadCompare(a, b, matches);
      if (h2h != 0) return h2h;

      // 3. Goal difference
      if (a.goalDifference != b.goalDifference) {
        return b.goalDifference.compareTo(a.goalDifference);
      }

      // 4. Goals scored
      if (a.goalsFor != b.goalsFor) {
        return b.goalsFor.compareTo(a.goalsFor);
      }

      return 0;
    });

    return sorted;
  }

  /// Head-to-head comparison between two teams
  static int _headToHeadCompare(
    TeamStats a,
    TeamStats b,
    List<FixtureMatch> matches,
  ) {
    int aPoints = 0;
    int bPoints = 0;

    final relevantMatches = matches.where((m) {
      if (!m.isPlayed) return false;

      return (m.homeTeamId == a.teamId && m.awayTeamId == b.teamId) ||
          (m.homeTeamId == b.teamId && m.awayTeamId == a.teamId);
    });

    for (final m in relevantMatches) {
      final homeGoals = m.homeScore!;
      final awayGoals = m.awayScore!;

      if (homeGoals == awayGoals) {
        aPoints += 1;
        bPoints += 1;
      } else if (homeGoals > awayGoals) {
        m.homeTeamId == a.teamId ? aPoints += 3 : bPoints += 3;
      } else {
        m.awayTeamId == a.teamId ? aPoints += 3 : bPoints += 3;
      }
    }

    return bPoints.compareTo(aPoints);
  }
}
