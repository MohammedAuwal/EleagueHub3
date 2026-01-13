import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/persistence/prefs_service.dart';
import '../../../core/widgets/glass.dart';
import '../../../core/widgets/glass_scaffold.dart';
import '../data/leagues_repository_local.dart';
import '../models/fixture_match.dart';
import '../models/league.dart';
import '../models/league_format.dart';
import '../models/league_settings.dart';
import '../models/enums.dart';

class LeagueDetailScreen extends ConsumerStatefulWidget {
  final String leagueId;

  const LeagueDetailScreen({
    super.key,
    required this.leagueId,
  });

  @override
  ConsumerState<LeagueDetailScreen> createState() => _LeagueDetailScreenState();
}

class _LeagueDetailScreenState extends ConsumerState<LeagueDetailScreen> {
  late LocalLeaguesRepository _repo;

  @override
  void initState() {
    super.initState();
    _repo = LocalLeaguesRepository(ref.read(prefsServiceProvider));
  }

  Future<Map<String, dynamic>> _loadData() async {
    final leagues = await _repo.listLeagues();
    final league = leagues.firstWhere(
      (l) => l.id == widget.leagueId,
      orElse: () => League(
        id: widget.leagueId,
        name: 'Unknown League',
        format: LeagueFormat.classic,
        privacy: LeaguePrivacy.public,
        region: 'Global',
        maxTeams: 0,
        season: '2026',
        organizerUserId: '',
        code: '',
        settings: LeagueSettings.defaultSettings(),
        updatedAtMs: 0,
        version: 1,
      ),
    );
    
    final fixtures = await _repo.getMatches(widget.leagueId);
    
    // FIX: Fetch teams from repository instead of league model getter
    final teams = await _repo.getTeams(widget.leagueId);
    final Map<String, String> teamNames = {
      for (var team in teams) team.id: team.name
    };

    return {
      'league': league, 
      'fixtures': fixtures,
      'teamNames': teamNames,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return GlassScaffold(
      appBar: AppBar(
        title: const Text('League Details'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: FutureBuilder<Map<String, dynamic>>(
            future: _loadData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final league = snapshot.data!['league'] as League;
              final fixtures = snapshot.data!['fixtures'] as List<FixtureMatch>;
              final teamNames = snapshot.data!['teamNames'] as Map<String, String>;
              final nextFixture = fixtures.isNotEmpty ? fixtures.first : null;

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _overviewCard(context, primary, league),
                  const SizedBox(height: 12),
                  _quickActions(context),
                  const SizedBox(height: 12),
                  _nextFixture(context, nextFixture, teamNames),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _overviewCard(BuildContext context, Color c, League league) {
    return Glass(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            league.name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            '${league.format.displayName} • Auto standings',
            style: TextStyle(color: Theme.of(context).hintColor),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _pill(league.isPrivate ? 'Private' : 'Public', c),
              _pill('${league.maxTeams} Teams', c),
              _pill('Region: ${league.region}', c),
            ],
          ),
        ],
      ),
    );
  }

  Widget _quickActions(BuildContext context) {
    return Glass(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Actions',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  icon: const Icon(Icons.list_alt),
                  label: const Text('Fixtures'),
                  onPressed: () => context.push('/leagues/${widget.leagueId}/fixtures'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.leaderboard),
                  label: const Text('Standings'),
                  onPressed: () => context.push('/leagues/${widget.leagueId}/standings'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.cyanAccent.withOpacity(0.1),
                foregroundColor: Colors.cyanAccent,
              ),
              icon: const Icon(Icons.edit_note),
              label: const Text('Manage Scores (Admin)'),
              onPressed: () => context.push('/leagues/${widget.leagueId}/admin-scores'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _nextFixture(BuildContext context, FixtureMatch? fixture, Map<String, String> names) {
    final homeName = names[fixture?.homeTeamId] ?? fixture?.homeTeamId ?? 'TBD';
    final awayName = names[fixture?.awayTeamId] ?? fixture?.awayTeamId ?? 'TBD';

    return Glass(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Next Fixture',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          if (fixture != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '$homeName vs $awayName',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  'Round ${fixture.roundNumber}',
                  style: TextStyle(color: Theme.of(context).hintColor),
                ),
              ],
            )
          else
            const Text('No fixtures yet.', style: TextStyle(color: Colors.white38)),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: fixture != null
                  ? () => context.push('/leagues/${widget.leagueId}/matches/${fixture.id}')
                  : null,
              child: const Text('View match'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pill(String text, Color c) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: c.withOpacity(0.12),
        border: Border.all(color: c.withOpacity(0.22)),
      ),
      child: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.w800, color: c, fontSize: 12),
      ),
    );
  }
}
