import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/routing/league_mode_provider.dart';
import '../widgets/glass_search_bar.dart';
import '../widgets/league_flip_card.dart';

class LeaguesListScreen extends ConsumerWidget {
  const LeaguesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the global league mode (Classic, UCL, Swiss)
    final activeMode = ref.watch(leagueModeProvider);
    
    // In a real scenario, you would filter your list here
    // For now, we mock the data based on the selected mode
    final List<Map<String, String>> filteredLeagues = _getMockLeagues(activeMode);

    return Scaffold(
      backgroundColor: Colors.black, // Standard Deep Black
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(activeMode.name.toUpperCase()),
            const GlassSearchBar(),
            const SizedBox(height: 10),
            Expanded(
              child: filteredLeagues.isEmpty 
                ? _buildEmptyState(context) 
                : _buildLeaguesList(filteredLeagues),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String modeName) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Leagues',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              Text(
                'Filter: $modeName',
                style: const TextStyle(fontSize: 12, color: Colors.cyanAccent, letterSpacing: 1.2),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.tune, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.sports_soccer, size: 80, color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 20),
          const Text("No active matches found", style: TextStyle(color: Colors.white70, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildLeaguesList(List<Map<String, String>> items) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: LeagueFlipCard(
            leagueName: item['name']!,
            leagueCode: item['code']!,
            distribution: item['desc']!,
          ),
        );
      },
    );
  }

  List<Map<String, String>> _getMockLeagues(LeagueType type) {
    switch (type) {
      case LeagueType.classic:
        return [
          {'name': 'Premier League', 'code': 'PL2026', 'desc': 'Round Robin • 20 Teams'},
        ];
      case LeagueType.uclClassic:
        return [
          {'name': 'Champions League', 'code': 'UCL26', 'desc': 'Group Stage • 32 Teams'},
        ];
      case LeagueType.uclSwiss:
        return [
          {'name': 'New Era Swiss', 'code': 'SWISS_X', 'desc': 'Swiss Model • 36 Teams'},
        ];
    }
  }
}
