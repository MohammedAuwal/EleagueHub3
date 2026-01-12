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
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
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

  Widget _buildLeagueList(BuildContext context, List<League> leagues) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
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
    final t = Theme.of(context).textTheme;

    return Center(
      child: Glass(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.emoji_events_outlined,
                size: 72,
                color: Theme.of(context).hintColor,
              ),
              const SizedBox(height: 16),
              Text(
                'No active leagues',
                style: t.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Text(
                'Create or join a league to get started',
                style: t.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _actionButton(
                    context,
                    label: 'Create',
                    icon: Icons.add_circle_outline,
                    onTap: () => context.push('/leagues/create'),
                  ),
                  const SizedBox(width: 12),
                  _actionButton(
                    context,
                    label: 'Join',
                    icon: Icons.qr_code_scanner,
                    onTap: () => context.push('/leagues/join'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return FilledButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(label),
    );
  }
}
