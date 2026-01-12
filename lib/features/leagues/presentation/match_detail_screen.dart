import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/persistence/prefs_service.dart';
import '../../../core/widgets/glass.dart';
import '../../../core/widgets/glass_scaffold.dart';
import '../../../core/widgets/status_badge.dart';
import "../data/leagues_repository_local.dart";
import '../models/fixture_match.dart';

class MatchDetailScreen extends ConsumerStatefulWidget {
  const MatchDetailScreen({
    super.key,
    required this.leagueId,
    required this.matchId,
  });

  final String leagueId;
  final String matchId;

  @override
  ConsumerState<MatchDetailScreen> createState() => _MatchDetailScreenState();
}

class _MatchDetailScreenState extends ConsumerState<MatchDetailScreen> {
  late LocalLeaguesRepository _repo;
  FixtureMatch? _match;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _repo = LocalLeaguesRepository(ref.read(prefsServiceProvider));
    _loadData();
  }

  Future<void> _loadData() async {
    final matches = await _repo.getMatches(widget.leagueId);
    if (mounted) {
      setState(() {
        try {
          _match = matches.firstWhere((m) => m.id == widget.matchId);
        } catch (_) {
          _match = null;
        }
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const GlassScaffold(body: Center(child: CircularProgressIndicator()));
    if (_match == null) return const GlassScaffold(body: Center(child: Text("Match not found")));

    return GlassScaffold(
      appBar: AppBar(title: const Text('Match Details')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Glass(
            child: Column(
              children: [
                Text("${_match!.homeTeamId} vs ${_match!.awayTeamId}", 
                  style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 10),
                StatusBadge(_match!.status.name),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Center(child: Text("Score updates are managed in Admin Panel", 
            style: TextStyle(color: Colors.white38))),
        ],
      ),
    );
  }
}
