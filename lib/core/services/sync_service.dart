import 'dart:async';
import 'package:flutter/foundation.dart';

import '../database/db_helper.dart';
import 'connectivity_service.dart';

/// Handles bidirectional sync between local DB and cloud
/// Cloud layer is currently mocked (Supabase/Firebase-ready)
class SyncService {
  SyncService._internal();

  static final SyncService instance = SyncService._internal();

  final DbHelper _dbHelper = DbHelper.instance;
  final ConnectivityService _connectivity =
      ConnectivityService.instance;

  bool _isSyncing = false;

  /// Push local unsynced changes to the cloud
  Future<void> syncLocalToCloud() async {
    if (_isSyncing) return;
    if (!_connectivity.isConnected.value) return;

    _isSyncing = true;

    try {
      final db = await _dbHelper.database;

      // Fetch all unsynced matches
      final unsyncedMatches = await db.query(
        'matches',
        where: 'isSynced = ?',
        whereArgs: [0],
      );

      if (unsyncedMatches.isEmpty) return;

      for (final match in unsyncedMatches) {
        try {
          // TODO: Replace with real cloud upload
          // await Supabase.instance.client.from('matches').upsert(match);

          // Simulated upload
          debugPrint(
            'SyncService → Uploading match ${match['id']}',
          );

          // Mark match as synced locally
          await db.update(
            'matches',
            {'isSynced': 1},
            where: 'id = ?',
            whereArgs: [match['id']],
          );
        } catch (e) {
          debugPrint(
            'SyncService → Failed to sync match ${match['id']}: $e',
          );
        }
      }
    } finally {
      _isSyncing = false;
    }
  }

  /// Pull new cloud data into local database
  /// Stubbed for future implementation
  Future<void> syncCloudToLocal() async {
    if (!_connectivity.isConnected.value) return;

    try {
      // TODO: Replace with real cloud fetch
      // Example:
      // final data = await Supabase.instance.client.from('matches').select();

      debugPrint('SyncService → Pulling latest data from cloud');

      // Merge logic will go here
    } catch (e) {
      debugPrint('SyncService → Cloud pull failed: $e');
    }
  }

  /// Full sync helper (safe to call repeatedly)
  Future<void> syncAll() async {
    await syncLocalToCloud();
    await syncCloudToLocal();
  }
}
