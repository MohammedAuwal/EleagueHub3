import '../../../core/database/db_helper.dart';

class AdminService {
  final db = DbHelper.instance;

  Future<void> updateScore(int matchId, int hScore, int aScore, String leagueId) async {
    final database = await db.database;
    
    // 1. Update the Match Score
    await database.update(
      'matches',
      {'homeScore': hScore, 'awayScore': aScore, 'isSynced': 0},
      where: 'id = ?',
      whereArgs: [matchId],
    );

    // 2. Trigger Automatic Standings Refresh
    await _recalculateStandings(leagueId);
  }

  Future<void> _recalculateStandings(String leagueId) async {
    final database = await db.database;
    
    // Get all matches for this league that have scores
    final matches = await database.query(
      'matches', 
      where: 'leagueId = ? AND homeScore IS NOT NULL', 
      whereArgs: [leagueId]
    );

    Map<int, Map<String, int>> stats = {};

    for (var m in matches) {
      int hId = m['homeTeamId'] as int;
      int aId = m['awayTeamId'] as int;
      int hG = m['homeScore'] as int;
      int aG = m['awayScore'] as int;

      // Initialize team stats if not exists
      stats.putIfAbsent(hId, () => {'p': 0, 'pts': 0, 'gf': 0, 'ga': 0});
      stats.putIfAbsent(aId, () => {'p': 0, 'pts': 0, 'gf': 0, 'ga': 0});

      // Update Goals
      stats[hId]!['gf'] = stats[hId]!['gf']! + hG;
      stats[hId]!['ga'] = stats[hId]!['ga']! + aG;
      stats[aId]!['gf'] = stats[aId]!['gf']! + aG;
      stats[aId]!['ga'] = stats[aId]!['ga']! + hG;
      stats[hId]!['p'] = stats[hId]!['p']! + 1;
      stats[aId]!['p'] = stats[aId]!['p']! + 1;

      // Update Points
      if (hG > aG) {
        stats[hId]!['pts'] = stats[hId]!['pts']! + 3;
      } else if (hG < aG) {
        stats[aId]!['pts'] = stats[aId]!['pts']! + 3;
      } else {
        stats[hId]!['pts'] = stats[hId]!['pts']! + 1;
        stats[aId]!['pts'] = stats[aId]!['pts']! + 1;
      }
    }

    // Save calculated stats back to Standings Table
    for (var teamId in stats.keys) {
      var s = stats[teamId]!;
      await database.insert(
        'standings',
        {
          'leagueId': leagueId,
          'teamId': teamId,
          'played': s['p'],
          'points': s['pts'],
          'goalsFor': s['gf'],
          'goalsAgainst': s['ga'],
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }
}
