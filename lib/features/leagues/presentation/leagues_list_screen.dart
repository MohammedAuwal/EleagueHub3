import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/glass.dart';
import '../../../core/widgets/glass_scaffold.dart';
import '../../../core/widgets/glass_search_bar.dart';
import '../../../widgets/league_flip_card.dart';
import '../data/leagues_repository_mock.dart';
import '../models/league.dart';

class LeaguesListScreen extends StatelessWidget {
  const LeaguesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = LeaguesRepositoryMock();
    final List<League> leagues = repo.listLeagues();

    return GlassScaffold(
      appBar: AppBar(
        title: const Text('Leagues'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80.0),
        child: FloatingActionButton(
          onPressed: () => _showOptions(context),
          child: const Icon(Icons.add),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const GlassSearchBar(),
          const SizedBox(height: 12),
          Expanded(
            child: leagues.isEmpty
                ? _buildEmptyState(context)
                : _buildLeagueList(context, leagues),
          ),
        ],
      ),
    );
  }

  // ... (keep _buildLeagueList and _buildEmptyState same as your previous version)
  Widget _buildLeagueList(BuildContext context, List<League> leagues) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 140),
      itemCount: leagues.length,
      itemBuilder: (context, index) {
        final league = leagues[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: GestureDetector(
            onDoubleTap: () => context.push('/leagues/${league.id}'),
            child: LeagueFlipCard(
              leagueName: league.name,
              leagueCode: league.id,
              distribution: league.format.displayName,
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(left: 24, right: 24, bottom: 40),
        child: Glass(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.emoji_events_outlined, size: 72, color: Theme.of(context).hintColor.withOpacity(0.5)),
                const SizedBox(height: 16),
                const Text('No active leagues', style: TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Glass(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.add_circle_outline),
              title: const Text('Create New League'),
              onTap: () {
                context.pop();
                context.push('/leagues/create');
              },
            ),
            ListTile(
              leading: const Icon(Icons.qr_code_scanner),
              title: const Text('Join Existing League'),
              onTap: () async {
                context.pop(); // Close bottom sheet
                final result = await context.push<String>('/leagues/join');
                if (result != null && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Joining league: $result')),
                  );
                }
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
