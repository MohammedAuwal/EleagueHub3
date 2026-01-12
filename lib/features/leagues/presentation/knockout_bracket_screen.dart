import '../models/enums.dart';
import 'package:flutter/material.dart';
import '../models/fixture_match.dart';
import '../models/team.dart';

class KnockoutBracketScreen extends StatelessWidget {
  final List<FixtureMatch> matches;
  final Map<String, Team> teamsById; // teamId -> Team object

  const KnockoutBracketScreen({
    super.key,
    required this.matches,
    required this.teamsById,
  });

  @override
  Widget build(BuildContext context) {
    // Group matches by round
    final rounds = <int, List<FixtureMatch>>{};
    for (var m in matches) {
      rounds.putIfAbsent(m.roundNumber, () => []).add(m);
    }

    final roundNumbers = rounds.keys.toList()..sort();

    return Scaffold(
      backgroundColor: const Color(0xFF000428),
      appBar: AppBar(
        title: const Text('UCL Knockout Stage'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: InteractiveViewer(
        constrained: false,
        boundaryMargin: const EdgeInsets.all(100),
        minScale: 0.1,
        maxScale: 2.0,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < roundNumbers.length; i++) ...[
              _buildRoundColumn("Round ${roundNumbers[i]}", rounds[roundNumbers[i]]!),
              if (i < roundNumbers.length - 1) _buildBracketConnector(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRoundColumn(String title, List<FixtureMatch> roundMatches) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        ...roundMatches.map((m) => _buildMatchCard(m)).toList(),
      ],
    );
  }

  Widget _buildMatchCard(FixtureMatch match) {
    final homeTeam = teamsById[match.homeTeamId];
    final awayTeam = teamsById[match.awayTeamId];
    final homeScore = match.homeScore?.toString() ?? "-";
    final awayScore = match.awayScore?.toString() ?? "-";

    final isHomeWinner = match.homeScore != null &&
        match.awayScore != null &&
        match.homeScore! > match.awayScore!;
    final isAwayWinner = match.homeScore != null &&
        match.awayScore != null &&
        match.awayScore! > match.homeScore!;

    return Container(
      width: 200,
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        children: [
          _buildTeamRow(homeTeam?.name ?? "TBD", homeScore, isHomeWinner),
          const Divider(color: Colors.white24),
          _buildTeamRow(awayTeam?.name ?? "TBD", awayScore, isAwayWinner),
          const SizedBox(height: 8),
          Text(
            match.status == MatchStatus.completed
                ? "Played"
                : "Scheduled",
            style: const TextStyle(color: Colors.grey, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamRow(String name, String score, bool isWinner) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          name,
          style: TextStyle(
            color: isWinner ? Colors.blue : Colors.white,
            fontWeight: isWinner ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(score, style: const TextStyle(color: Colors.white)),
      ],
    );
  }

  Widget _buildBracketConnector() {
    return Container(width: 40, height: 2, color: Colors.white24);
  }
}
