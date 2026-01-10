import '../models/team_stats.dart';
import '../models/match.dart';

class StandingsEngine {
  static List<TeamStats> compute(List<TeamStats> teams, List<Match> matches) {
    List<TeamStats> sortedTeams = List.from(teams);

    sortedTeams.sort((a, b) {
      // 1. Primary: Points
      if (b.points != a.points) return b.points.compareTo(a.points);

      // 2. Secondary: Head-to-Head (Reggie Standard)
      int h2h = _compareHeadToHead(a, b, matches);
      if (h2h != 0) return h2h;

      // 3. Tertiary: Overall Goal Difference
      if (b.goalDifference != a.goalDifference) {
        return b.goalDifference.compareTo(a.goalDifference);
      }

      // 4. Quaternary: Goals For
      return b.goalsFor.compareTo(a.goalsFor);
    });

    return sortedTeams;
  }

  static int _compareHeadToHead(TeamStats a, TeamStats b, List<Match> matches) {
    var h2hMatches = matches.where((m) =>
        (m.homeTeamId == a.id && m.awayTeamId == b.id) ||
        (m.homeTeamId == b.id && m.awayTeamId == a.id));

    int aPoints = 0;
    int bPoints = 0;

    for (var m in h2hMatches) {
      if (m.homeScore == null || m.awayScore == null) continue;
      
      if (m.homeScore! > m.awayScore!) {
        m.homeTeamId == a.id ? aPoints += 3 : bPoints += 3;
      } else if (m.homeScore! < m.awayScore!) {
        m.awayTeamId == a.id ? aPoints += 3 : bPoints += 3;
      } else {
        aPoints += 1;
        bPoints += 1;
      }
    }
    return bPoints.compareTo(aPoints);
  }
}
