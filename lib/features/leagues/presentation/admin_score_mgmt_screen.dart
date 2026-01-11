import 'package:flutter/material.dart';
import '../../../widgets/admin_score_card.dart';
import '../../logic/admin_service.dart';
import '../../models/match.dart';

class AdminScoreMgmtScreen extends StatelessWidget {
  const AdminScoreMgmtScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final adminService = AdminService();

    // TODO: Replace with real matches from Provider / backend
    final List<Match> matches = List.generate(
      5,
      (i) => Match(
        id: 'M-$i',
        leagueId: 'L-1',
        homeTeamId: 'T-${i + 1}',
        awayTeamId: 'T-${i + 2}',
        homeTeamName: 'Team ${i + 1}',
        awayTeamName: 'Team ${i + 2}',
        homeScore: null,
        awayScore: null,
        isPlayed: false,
        isMyMatch: false,
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFF4FC3F7),
      appBar: AppBar(
        title: const Text("Admin Score Entry"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: matches.length,
        itemBuilder: (context, index) {
          final match = matches[index];

          return Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: AdminScoreCard(
              homeTeam: match.homeTeamName,
              awayTeam: match.awayTeamName,
              homeScore: match.homeScore,
              awayScore: match.awayScore,
              onSave: (hScore, aScore) async {
                await adminService.updateScore(match.id, hScore, aScore);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Score Updated Successfully!")),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
