import '../../../core/database/db_helper.dart';
import 'package:sqflite/sqflite.dart';

class SyncService {
  final dbHelper = DbHelper.instance;

  // This function pushes local changes to the Cloud
  Future<void> syncLocalToCloud() async {
    final db = await dbHelper.database;
    
    // 1. Fetch all unsynced matches
    final List<Map<String, dynamic>> unsyncedMatches = await db.query(
      'matches',
      where: 'isSynced = ?',
      whereArgs: [0],
    );

    if (unsyncedMatches.isEmpty) return;

    for (var match in unsyncedMatches) {
      try {
        // 2. SIMULATED CLOUD UPLOAD (Replace with Supabase/Firebase call)
        // await Supabase.instance.client.from('matches').upsert(match);
        print("Uploading Match ID: ${match['id']} to Cloud...");

        // 3. Mark as Synced in Local DB
        await db.update(
          'matches',
          {'isSynced': 1},
          where: 'id = ?',
          whereArgs: [match['id']],
        );
      } catch (e) {
        print("Sync failed for Match ${match['id']}: $e");
      }
    }
  }

  // This function pulls new data from the Cloud to Local
  Future<void> syncCloudToLocal() async {
    // Logic to fetch latest scores from other admins
    print("Pulling latest data from Cloud...");
  }
}
