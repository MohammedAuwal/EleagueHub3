import '../../../core/database/db_helper.dart';

class AdminService {
  final db = DbHelper.instance;

  Future<void> updateScore(int matchId, int hScore, int aScore) async {
    final database = await db.database;
    await database.update(
      'matches',
      {'homeScore': hScore, 'awayScore': aScore, 'isSynced': 0},
      where: 'id = ?',
      whereArgs: [matchId],
    );
    print("Score saved locally for Match $matchId");
  }
}
