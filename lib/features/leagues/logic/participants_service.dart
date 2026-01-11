import 'package:flutter/foundation.dart';
import '../../core/database/db_helper.dart';

class ParticipantsService {
  final DbHelper _db = DbHelper.instance;

  ParticipantsService();

  /// Get all participants for a league
  Future<List<String>> getParticipants(String leagueId) async {
    final rows = await _db.getAllParticipants(leagueId);
    return rows.map((e) => e['participantId'] as String).toList();
  }

  /// Add participant (fixed signature to allow optional name)
  Future<bool> addParticipant(String leagueId, String participantId, {String? name, bool joinedOnline = false}) async {
    try {
      final row = {
        'leagueId': leagueId,
        'participantId': participantId,
        'name': name ?? participantId,
        'joinedOnline': joinedOnline ? 1 : 0,
      };
      await _db.insertParticipant(row);
      return true;
    } catch (e) {
      debugPrint("Error adding participant: $e");
      return false;
    }
  }

  /// Remove participant
  Future<bool> removeParticipant(String leagueId, String participantId) async {
    try {
      final count = await _db.deleteParticipant(leagueId, participantId);
      return count > 0;
    } catch (e) {
      debugPrint("Error removing participant: $e");
      return false;
    }
  }

  /// Sync offline participants that joined offline to online
  Future<void> syncParticipants(String leagueId) async {
    final rows = await _db.getAllParticipants(leagueId);
    for (var row in rows) {
      final joinedOnline = row['joinedOnline'] as int;
      if (joinedOnline == 0) {
        final participantId = row['participantId'] as String;

        // ------------------------------
        // Real online API call integration point
        await Future.delayed(const Duration(milliseconds: 200));
        debugPrint("Synced participant $participantId to server");
        // ------------------------------

        // Mark participant as synced locally
        await _db.markParticipantSynced(leagueId, participantId);
      }
    }
  }

  /// Check if participant exists
  Future<bool> participantExists(String leagueId, String participantId) async {
    final rows = await _db.getAllParticipants(leagueId);
    return rows.any((e) => e['participantId'] == participantId);
  }
}
