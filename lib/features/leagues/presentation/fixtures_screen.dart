import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/persistence/prefs_service.dart';
import '../../../core/widgets/glass.dart';
import '../../../core/widgets/glass_scaffold.dart';
import '../../../core/widgets/section_header.dart';
import '../data/leagues_repository_local.dart';
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
  late LocalLeaguesRepository _repo;
  Map<String, String> _teamNames = {};
  bool _isLoadingData = true;

  @override
  void initState() {
    super.initState();
    _repo = LocalLeaguesRepository(ref.read(prefsServiceProvider));
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final leagues = await _repo.listLeagues();
    
    
    if (mounted) {
      setState(() {
        final teams = await _repo.getTeams(widget.leagueId); _teamNames = { for (var t in teams) t.id : t.name };
        _isLoadingData = false;
      });
    }
  }

  Future<List<FixtureMatch>> _getMatches() async {
    final allMatches = await _repo.getMatches(widget.leagueId);
    return allMatches.where((m) => m.roundNumber == _selectedRound).toList();
  }

  Future<int> _getTotalRounds() async {
    final allMatches = await _repo.getMatches(widget.leagueId);
    if (allMatches.isEmpty) return 0;
    return allMatches.map((m) => m.roundNumber).reduce((a, b) => a > b ? a : b);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isTablet = width > 700;

    return GlassScaffold(
      appBar: AppBar(
        title: const Text('Fixtures & Results'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: _isLoadingData 
        ? const Center(child: CircularProgressIndicator(color: Colors.cyanAccent))
        : Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isTablet ? 800 : 600),
              child: FutureBuilder<int>(
                future: _getTotalRounds(),
                builder: (context, snapshot) {
                  final totalRounds = snapshot.data ?? 0;
                  
                  return Column(
                    children: [
                      if (totalRounds > 0) _buildRoundSelector(totalRounds),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: SectionHeader('Matchday Schedule'),
                      ),
                      Expanded(
                        child: _buildMatchesList(),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
    );
  }

  Widget _buildRoundSelector(int totalRounds) {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: totalRounds,
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
    return FutureBuilder<List<FixtureMatch>>(
      future: _getMatches(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.cyanAccent));
        }

        final matches = snapshot.data ?? [];

        if (matches.isEmpty) {
          return const Center(
            child: Text('No matches generated yet', style: TextStyle(color: Colors.white38)),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: matches.length,
          itemBuilder: (context, index) => _buildMatchCard(matches[index]),
        );
      },
    );
  }

  Widget _buildMatchCard(FixtureMatch match) {
    final hName = _teamNames[match.homeTeamId] ?? "TBD";
    final aName = _teamNames[match.awayTeamId] ?? "TBD";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Glass(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                hName,
                textAlign: TextAlign.right,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              width: 80,
              alignment: Alignment.center,
              child: (match.status == MatchStatus.completed || match.status == MatchStatus.played)
                  ? Text(
                      '${match.homeScore} - ${match.awayScore}',
                      style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold, fontSize: 18),
                    )
                  : const Text('VS', style: TextStyle(color: Colors.white24, fontWeight: FontWeight.w900)),
            ),
            Expanded(
              child: Text(
                aName,
                textAlign: TextAlign.left,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
