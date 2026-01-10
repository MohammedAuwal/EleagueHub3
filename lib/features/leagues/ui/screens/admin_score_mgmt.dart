import 'package:flutter/material.dart';
import '../../../widgets/admin_score_card.dart';
import '../../logic/admin_service.dart';

class AdminScoreMgmtScreen extends StatelessWidget {
  const AdminScoreMgmtScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final adminService = AdminService();

    return Scaffold(
      backgroundColor: const Color(0xFF4FC3F7),
      appBar: AppBar(title: const Text("Admin Score Entry"), backgroundColor: Colors.transparent),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5, // Replace with real match list from DB
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: AdminScoreCard(
              homeTeam: "Team ${index + 1}",
              awayTeam: "Team ${index + 2}",
              onSave: (hScore, aScore) async {
                await adminService.updateScore(index, hScore, aScore);
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
