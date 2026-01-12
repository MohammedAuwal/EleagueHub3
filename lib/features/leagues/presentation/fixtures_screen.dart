import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/glass.dart';
import '../../../core/widgets/glass_scaffold.dart';
import '../../../core/widgets/section_header.dart';
import '../models/fixture_match.dart';
import '../models/enums.dart';

class FixturesScreen extends ConsumerStatefulWidget {
  final String leagueId;

  const FixturesScreen({
    super.key,
    required this.leagueId,
  });

  @override
  ConsumerState<FixturesScreen> createState() => _FixturesScreenState();
}

class _FixturesScreenState extends ConsumerState<FixturesScreen> {
  int _selectedRound = 1;

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      appBar: AppBar(
        title: const Text('Fixtures & Results'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          _buildRoundSelector(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: SectionHeader('Matchday Schedule'),
          ),
          Expanded(
            child: _buildMatchesList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRoundSelector() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 10, // Logic to be linked to repo.getTotalRounds()
        itemBuilder: (context, i) {
          final round = i + 1;
          final isSelected = _selectedRound == round;
          return GestureDetector(
            onTap: () => setState(() => _selectedRound = round),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: isSelected ? Colors.cyanAccent : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? Colors.cyanAccent : Colors.white10,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                'RD $round',
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.white70,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMatchesList() {
    // This is where you will eventually watch your FixturesProvider
    // For now, we show a user-friendly empty state
    final List<FixtureMatch> matches = []; 

    if (matches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.TableChartOutlined, size: 48, color: Colors.white24),
            ),
            const SizedBox(height: 16),
            const Text(
              'No matches scheduled for this round',
              style: TextStyle(color: Colors.white38, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: matches.length,
      itemBuilder: (context, index) {
        return _buildMatchCard(matches[index]);
      },
    );
  }

  Widget _buildMatchCard(FixtureMatch match) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Glass(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                match.homeTeamId,
                textAlign: TextAlign.right,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
            Container(
              width: 80,
              alignment: Alignment.center,
              child: match.status == MatchStatus.completed
                  ? Text(
                      '${match.homeScore} - ${match.awayScore}',
                      style: const TextStyle(
                        color: Colors.cyanAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    )
                  : const Text(
                      'VS',
                      style: TextStyle(color: Colors.white24, fontWeight: FontWeight.w900),
                    ),
            ),
            Expanded(
              child: Text(
                match.awayTeamId,
                textAlign: TextAlign.left,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
