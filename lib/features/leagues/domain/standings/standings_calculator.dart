import '../../models/fixture_match.dart';
import '../../models/team.dart';
import 'standings.dart';

/// The logic engine that computes league tables for eSportlyic.
///
/// It processes a list of teams and matches to generate a sorted
/// list of StandingsRow objects based on competitive results.
class StandingsCalculator {
  /// Calculates standings from played matches.
  ///
  /// Tie-breakers applied:
  /// 1) Points (descending)
  /// 2) Goal Difference (descending)
  /// 3) Goals For (descending)
  /// 4) Alphabetical team name (ascending)
  ///
  /// Note: Head-to-head logic is a future TODO.
  static List<StandingsRow> calculate({
    required List<Team> teams,
    required List<FixtureMatch> matches,
  }) {
    final byId = {for (final t in teams) t.id: t};
    final rows = {
      for (final t in teams) t.id: StandingsRow.empty(teamId: t.id, teamName: t.name),
    };

    // Process every match to update the rows
    for (final m in matches) {
      if (!m.isPlayed) continue;
      final home = rows[m.homeTeamId];
      final away = rows[m.awayTeamId];
      if (home == null || away == null) continue;

      final hs = m.homeScore!;
      final as = m.awayScore!;

      // Update basic stats: Played, Goals For, Goals Against
      var h = home.copyWith(mp: home.mp + 1, gf: home.gf + hs, ga: home.ga + as);
      var a = away.copyWith(mp: away.mp + 1, gf: away.gf + as, ga: away.ga + hs);

      // Assign Wins, Losses, or Draws
      if (hs > as) {
        h = h.copyWith(w: h.w + 1);
        a = a.copyWith(l: a.l + 1);
      } else if (hs < as) {
        h = h.copyWith(l: h.l + 1);
        a = a.copyWith(w: a.w + 1);
      } else {
        h = h.copyWith(d: h.d + 1);
        a = a.copyWith(d: a.d + 1);
      }

      rows[m.homeTeamId] = h;
      rows[m.awayTeamId] = a;
    }

    final list = rows.values.toList();

    // Sort the list based on league tie-breaker rules
    list.sort((a, b) {
      final pts = b.pts.compareTo(a.pts);
      if (pts != 0) return pts;
      final gd = b.gd.compareTo(a.gd);
      if (gd != 0) return gd;
      final gf = b.gf.compareTo(a.gf);
      if (gf != 0) return gf;
      final an = (byId[a.teamId]?.name ?? a.teamName).toLowerCase();
      final bn = (byId[b.teamId]?.name ?? b.teamName).toLowerCase();
      return an.compareTo(bn);
    });

    return list;
  }
}
