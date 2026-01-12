import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/glass.dart';
import '../../../core/widgets/glass_scaffold.dart';
import '../data/leagues_repository_mock.dart';
import '../models/enums.dart';
import '../models/fixture_match.dart';
import '../models/league.dart';
import '../models/league_format.dart';
import '../models/league_settings.dart';

class LeagueDetailScreen extends StatelessWidget {
  final String leagueId;

  const LeagueDetailScreen({
    super.key,
    required this.leagueId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final repo = LeaguesRepositoryMock();

    final fixturesList = repo.fixtures(leagueId);
    final nextFixture = fixturesList.isNotEmpty ? fixturesList.first : null;

    return GlassScaffold(
      appBar: AppBar(
        title: const Text('League Details'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _overviewCard(context, primary, repo),
          const SizedBox(height: 12),
          _quickActions(context),
          const SizedBox(height: 12),
          _nextFixture(context, nextFixture),
        ],
      ),
    );
  }

  Widget _overviewCard(BuildContext context, Color c, LeaguesRepositoryMock repo) {
    final league = repo.listLeagues().firstWhere(
      (l) => l.id == leagueId,
      orElse: () => League(
        id: leagueId,
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
            '${league.format.displayName} • Proof required • Auto standings',
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
                  onPressed: () => context.push('/leagues/$leagueId/fixtures'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.leaderboard),
                  label: const Text('Standings'),
                  onPressed: () => context.push('/leagues/$leagueId/standings'),
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
              onPressed: () => context.push('/leagues/$leagueId/admin-scores'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _nextFixture(BuildContext context, FixtureMatch? fixture) {
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
                    '${fixture.homeTeamId} vs ${fixture.awayTeamId}',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  'Round ${fixture.roundNumber}',
                  style: TextStyle(color: Theme.of(context).hintColor),
                ),
              ],
            )
          else
            const Text('No fixtures yet.'),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: fixture != null
                  ? () => context.push('/leagues/$leagueId/matches/${fixture.id}')
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
        style: TextStyle(
          fontWeight: FontWeight.w800,
          color: c,
          fontSize: 12,
        ),
      ),
    );
  }
}
