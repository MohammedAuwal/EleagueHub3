import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/leagues_repository_local.dart';
import '../models/league.dart';
import '../../../core/widgets/glass.dart';
import '../../../core/widgets/glass_scaffold.dart';
import '../../../core/widgets/glass_search_bar.dart';
import '../../../widgets/league_flip_card.dart';

class LeaguesListScreen extends StatefulWidget {
  const LeaguesListScreen({super.key});

  @override
  State<LeaguesListScreen> createState() => _LeaguesListScreenState();
}

class _LeaguesListScreenState extends State<LeaguesListScreen> {
  final _localRepo = LocalLeaguesRepository();
  List<League> _leagues = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshLeagues();
  }

  Future<void> _refreshLeagues() async {
    final data = await _localRepo.listLeagues();
    if (mounted) {
      setState(() {
        _leagues = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
            child: _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : _leagues.isEmpty
                    ? _buildEmptyState(context)
                    : _buildLeagueList(context, _leagues),
          ),
        ],
      ),
    );
  }

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
    final t = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Glass(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.emoji_events_outlined, size: 72, color: Colors.white.withOpacity(0.3)),
                const SizedBox(height: 16),
                Text('No active leagues', style: t.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                const Text('Tap + to create your first league offline.', textAlign: TextAlign.center),
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
              onTap: () async {
                context.pop();
                await context.push('/leagues/create');
                _refreshLeagues(); // Reload from storage when coming back
              },
            ),
            ListTile(
              leading: const Icon(Icons.qr_code_scanner),
              title: const Text('Join Existing League'),
              onTap: () async {
                context.pop();
                final result = await context.push<String>('/leagues/join-scanner');
                if (result != null && context.mounted) {
                   // logic to save joined league id could go here
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
