import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../logic/match_sheet_service.dart';

class ShareMatchButton extends StatelessWidget {
  final String leagueName;
  final String homeTeam;
  final String awayTeam;
  final int homeScore;
  final int awayScore;

  const ShareMatchButton({
    super.key,
    required this.leagueName,
    required this.homeTeam,
    required this.awayTeam,
    required this.homeScore,
    required this.awayScore,
  });

  void _handleShare(BuildContext context) {
    final report = MatchSheetService.generateTextReport(
      leagueName: leagueName,
      homeTeam: homeTeam,
      awayTeam: awayTeam,
      homeScore: homeScore,
      awayScore: awayScore,
    );

    // Trigger native share sheet
    Share.share(report, subject: 'Match Result: $homeTeam vs $awayTeam');
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _handleShare(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.greenAccent.withOpacity(0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.share, color: Colors.greenAccent),
            SizedBox(width: 10),
            Text(
              "SHARE TO WHATSAPP",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
