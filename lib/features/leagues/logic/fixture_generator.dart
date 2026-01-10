import '../models/match.dart';

class FixtureGenerator {
  static List<Match> generateRoundRobin(List<int> teamIds, String leagueId) {
    List<Match> fixtures = [];
    if (teamIds.length % 2 != 0) teamIds.add(-1); // Add a "Bye" team if odd

    int numTeams = teamIds.length;
    int numRounds = numTeams - 1;

    for (int round = 0; round < numRounds; round++) {
      for (int i = 0; i < numTeams / 2; i++) {
        int home = teamIds[i];
        int away = teamIds[numTeams - 1 - i];

        if (home != -1 && away != -1) {
          fixtures.add(Match(
            id: DateTime.now().millisecondsSinceEpoch + fixtures.length,
            leagueId: leagueId,
            homeTeamId: home,
            awayTeamId: away,
          ));
        }
      }
      // Rotate teams for next round (keep first team fixed)
      teamIds.insert(1, teamIds.removeLast());
    }
    return fixtures;
  }
}
