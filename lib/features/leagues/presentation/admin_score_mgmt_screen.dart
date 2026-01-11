import 'package:flutter/material.dart';
import '../../../widgets/admin_score_card.dart';
import '../../logic/admin_service.dart';
import '../../../core/database/db_helper.dart';

class AdminScoreMgmtScreen extends StatefulWidget {
  const AdminScoreMgmtScreen({super.key});

  @override
  State<AdminScoreMgmtScreen> createState() => _AdminScoreMgmtScreenState();
}

class _AdminScoreMgmtScreenState extends State<AdminScoreMgmtScreen> {
  final adminService = AdminService();
  final db = DbHelper.instance;

  List<Map<String, dynamic>> _matches = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMatches();
  }

  Future<void> _loadMatches() async {
    setState(() => _isLoading = true);
    final database = await db.database;
    final matches = await database.query('matches', orderBy: 'id ASC');
    setState(() {
      _matches = matches;
      _isLoading = false;
    });
  }

  Future<void> _updateScore(Map<String, dynamic> match, int hScore, int aScore) async {
    await adminService.updateScore(match['id'], hScore, aScore, match['leagueId']);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Score Updated Successfully!")),
    );
    _loadMatches();
  }

  Future<void> _syncOffline() async {
    await adminService.syncOfflineMatchesOnline((match) async {
      // Replace this with your API call
      await Future.delayed(const Duration(milliseconds: 500));
      return true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Offline scores synced online!")),
    );
    _loadMatches();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4FC3F7),
      appBar: AppBar(
        title: const Text("Admin Score Entry"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_matches.any((m) => m['isSynced'] == 0))
            IconButton(
              icon: const Icon(Icons.cloud_upload),
              onPressed: _syncOffline,
              tooltip: "Sync Offline Scores",
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : _matches.isEmpty
              ? const Center(
                  child: Text(
                    "No matches available.",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _matches.length,
                  itemBuilder: (context, index) {
                    final match = _matches[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: AdminScoreCard(
                        homeTeam: "Team ${match['homeTeamId']}",
                        awayTeam: "Team ${match['awayTeamId']}",
                        homeScore: match['homeScore'],
                        awayScore: match['awayScore'],
                        onSave: (hScore, aScore) => _updateScore(match, hScore, aScore),
                      ),
                    );
                  },
                ),
    );
  }
}
