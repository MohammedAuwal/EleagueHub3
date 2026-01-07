import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/widgets/glass.dart';
import '../../../core/widgets/status_badge.dart';
import '../data/leagues_repository_mock.dart';
import '../domain/models.dart';
import 'widgets/standings_table.dart';
import 'widgets/fixture_card.dart';

class LeagueDetailScreen extends StatefulWidget {
  const LeagueDetailScreen({super.key, required this.leagueId});

  final String leagueId;

  @override
  State<LeagueDetailScreen> createState() => _LeagueDetailScreenState();
}

class _LeagueDetailScreenState extends State<LeagueDetailScreen>
    with SingleTickerProviderStateMixin {
  final _repo = LeaguesRepositoryMock();
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final leagues = _repo.listLeagues();
    final league = leagues.firstWhere(
      (l) => l.id == widget.leagueId,
      orElse: () => League(
        id: widget.leagueId,
        name: 'Unknown League',
        format: 'N/A',
        privacy: 'N/A',
        region: 'N/A',
        maxTeams: 0,
        isPrivate: false,
      ),
    );

    final standings = _repo.standings(league.id);
    final fixtures = _repo.fixtures(league.id);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        children: [
          Glass(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  league.name,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _pill(context, league.id),
                    _pill(context, league.format),
                    _pill(context, league.region),
                    _pill(context, league.privacy),
                  ],
                ),
                const SizedBox(height: 12),
                TabBar(
                  controller: _tabs,
                  tabs: const [
                    Tab(text: 'Standings'),
                    Tab(text: 'Fixtures'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 760,
            child: TabBarView(
              controller: _tabs,
              children: [
                StandingsTable(rows: standings),
                _FixturesTab(
                  leagueId: league.id,
                  fixtures: fixtures,
                  onOpenMatch: (matchId) =>
                      context.push('/leagues/${league.id}/matches/$matchId'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _pill(BuildContext context, String text) {
    final c = Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: c.withValues(alpha: 0.12),
        border: Border.all(color: c.withValues(alpha: 0.22)),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}

class _FixturesTab extends StatelessWidget {
  const _FixturesTab({
    required this.leagueId,
    required this.fixtures,
    required this.onOpenMatch,
  });

  final String leagueId;
  final List<Fixture> fixtures;
  final void Function(String matchId) onOpenMatch;

  @override
  Widget build(BuildContext context) {
    if (fixtures.isEmpty) {
      return const Center(child: Text('No fixtures yet.'));
    }
    final df = DateFormat('EEE, MMM d • HH:mm');

    return ListView.builder(
      itemCount: fixtures.length,
      itemBuilder: (context, i) {
        final f = fixtures[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: FixtureCard(
            home: f.home,
            away: f.away,
            subtitle: df.format(f.scheduledAt),
            trailing: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                StatusBadge(f.status),
                const SizedBox(height: 8),
                _countdown(context, f.scheduledAt),
              ],
            ),
            onTap: () => onOpenMatch(f.matchId),
          ),
        );
      },
    );
  }

  Widget _countdown(BuildContext context, DateTime scheduledAt) {
    final now = DateTime.now();
    final diff = scheduledAt.difference(now);
    final abs = diff.abs();
    final h = abs.inHours;
    final m = abs.inMinutes % 60;

    final label = diff.isNegative
        ? 'Started ${h}h ${m}m ago'
        : 'In ${h}h ${m}m';

    return Text(
      label,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
    );
  }
}
