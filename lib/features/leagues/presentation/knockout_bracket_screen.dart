import 'package:flutter/material.dart';

/// Modern Bracket UI for eSportlyic UCL Version.
/// Displays matches in a scrollable horizontal tree.
class KnockoutBracketScreen extends StatelessWidget {
  const KnockoutBracketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000428), // Deep Navy
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
          children: [
            _buildRoundColumn("Round of 16", 8),
            _buildBracketConnector(),
            _buildRoundColumn("Quarter Finals", 4),
            _buildBracketConnector(),
            _buildRoundColumn("Semi Finals", 2),
            _buildBracketConnector(),
            _buildFinalsColumn(),
          ],
        ),
      ),
    );
  }

  Widget _buildRoundColumn(String title, int matchCount) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        ...List.generate(matchCount, (index) => _buildMatchCard()),
      ],
    );
  }

  Widget _buildMatchCard() {
    return Container(
      width: 200,
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1), // Glassmorphism
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        children: [
          _buildTeamRow("Team A", "3", true),
          const Divider(color: Colors.white24),
          _buildTeamRow("Team B", "1", false),
          const SizedBox(height: 8),
          const Text("20:00 - 15 MAR", style: TextStyle(color: Colors.grey, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildTeamRow(String name, String score, bool isWinner) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(name, style: TextStyle(color: isWinner ? Colors.blue : Colors.white, fontWeight: isWinner ? FontWeight.bold : FontWeight.normal)),
        Text(score, style: const TextStyle(color: Colors.white)),
      ],
    );
  }

  Widget _buildBracketConnector() {
    return Container(width: 40, height: 2, color: Colors.white24);
  }

  Widget _buildFinalsColumn() {
    return Column(
      children: [
        const Icon(Icons.emoji_events, color: Colors.amber, size: 50),
        const Text("FINAL", style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
        _buildMatchCard(),
        const SizedBox(height: 50),
        const Text("3RD PLACE", style: TextStyle(color: Colors.grey)),
        _buildMatchCard(),
      ],
    );
  }
}
