import '../../../core/database/db_helper.dart';

class AdminService {
  final db = DbHelper.instance;

  /// Update a match score locally
  Future<void> updateScore(int matchId, int hScore, int aScore, String leagueId) async {
    final database = await db.database;

    // 1. Update the Match Score locally and mark as unsynced
    await database.update(
      'matches',
      {'homeScore': hScore, 'awayScore': aScore, 'isSynced': 0},
      where: 'id = ?',
      whereArgs: [matchId],
    );

    // 2. Recalculate standings locally
    await _recalculateStandings(leagueId);
  }

  /// Recalculate standings based on all scored matches locally
  Future<void> _recalculateStandings(String leagueId) async {
    final database = await db.database;

    final matches = await database.query(
      'matches',
      where: 'leagueId = ? AND homeScore IS NOT NULL',
      whereArgs: [leagueId],
    );

    Map<int, Map<String, int>> stats = {};

    for (var m in matches) {
      int hId = m['homeTeamId'] as int;
      int aId = m['awayTeamId'] as int;
      int hG = m['homeScore'] as int;
      int aG = m['awayScore'] as int;

      stats.putIfAbsent(hId, () => {'p': 0, 'pts': 0, 'gf': 0, 'ga': 0});
      stats.putIfAbsent(aId, () => {'p': 0, 'pts': 0, 'gf': 0, 'ga': 0});

      stats[hId]!['gf'] = stats[hId]!['gf']! + hG;
      stats[hId]!['ga'] = stats[hId]!['ga']! + aG;
      stats[aId]!['gf'] = stats[aId]!['gf']! + aG;
      stats[aId]!['ga'] = stats[aId]!['ga']! + hG;
      stats[hId]!['p'] = stats[hId]!['p']! + 1;
      stats[aId]!['p'] = stats[aId]!['p']! + 1;

      if (hG > aG) {
        stats[hId]!['pts'] = stats[hId]!['pts']! + 3;
      } else if (hG < aG) {
        stats[aId]!['pts'] = stats[aId]!['pts']! + 3;
      } else {
        stats[hId]!['pts'] = stats[hId]!['pts']! + 1;
        stats[aId]!['pts'] = stats[aId]!['pts']! + 1;
      }
    }

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

  /// Get all unsynced matches
  Future<List<Map<String, dynamic>>> getUnsyncedMatches() async {
    final database = await db.database;
    return await database.query(
      'matches',
      where: 'isSynced = 0',
    );
  }

  /// Sync unsynced matches to server (placeholder for online API call)
  Future<void> syncScoresOnline(Future<bool> Function(Map<String, dynamic>) uploadMatch) async {
    final unsynced = await getUnsyncedMatches();

    for (var match in unsynced) {
      bool success = await uploadMatch(match); // Call your API here
      if (success) {
        // Mark as synced locally
        final database = await db.database;
        await database.update(
          'matches',
          {'isSynced': 1},
          where: 'id = ?',
          whereArgs: [match['id']],
        );
      }
    }
  }
}
