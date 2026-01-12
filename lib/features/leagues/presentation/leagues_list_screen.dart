import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/persistence/prefs_service.dart';
import '../../../core/widgets/glass.dart';
import '../../../core/widgets/glass_scaffold.dart';
import '../../../core/widgets/glass_search_bar.dart';
import '../../../widgets/league_flip_card.dart';
import '../data/leagues_repository_local.dart';
import '../models/league.dart';

class LeaguesListScreen extends ConsumerStatefulWidget {
  const LeaguesListScreen({super.key});

  @override
  ConsumerState<LeaguesListScreen> createState() => _LeaguesListScreenState();
}

class _LeaguesListScreenState extends ConsumerState<LeaguesListScreen> {
  // Use late to initialize once ref is available in initState
  late LocalLeaguesRepository _localRepo;
  List<League> _leagues = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Initialize repo using the shared PreferencesService
    _localRepo = LocalLeaguesRepository(ref.read(prefsServiceProvider));
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
                ? const Center(child: CircularProgressIndicator(color: Colors.white))
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
                Icon(Icons.emoji_events_outlined, 
                  size: 72, 
                  color: Colors.white.withOpacity(0.3)
                ),
                const SizedBox(height: 16),
                Text('No active leagues', 
                  style: t.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800, 
                    color: Colors.white
                  )
                ),
                const SizedBox(height: 6),
                const Text(
                  'Tap + to create your first league offline.', 
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70),
                ),
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
              leading: const Icon(Icons.add_circle_outline, color: Colors.white),
              title: const Text('Create New League', 
                style: TextStyle(color: Colors.white)
              ),
              onTap: () async {
                context.pop();
                await context.push('/leagues/create');
                _refreshLeagues(); // Refresh data on return
              },
            ),
            ListTile(
              leading: const Icon(Icons.qr_code_scanner, color: Colors.white),
              title: const Text('Join Existing League', 
                style: TextStyle(color: Colors.white)
              ),
              onTap: () async {
                context.pop();
                final result = await context.push<String>('/leagues/join-scanner');
                if (result != null && mounted) {
                   ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Joined: $result'), 
                      behavior: SnackBarBehavior.floating
                    ),
                  );
                  _refreshLeagues();
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
