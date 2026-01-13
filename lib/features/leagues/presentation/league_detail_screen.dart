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
    final league = await _repo.getLeagueById(widget.leagueId);
    if (league == null) {
      throw Exception("League not found in local storage");
    }
    final fixtures = await _repo.getMatches(widget.leagueId);
    final teams = await _repo.getTeams(widget.leagueId);

    final Map<String, String> teamNames = { for (var t in teams) t.id: t.name };
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 600;
    const String currentUserId = 'admin_user';

    return GlassScaffold(
      appBar: AppBar(
        title: const Text('League Details'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: FutureBuilder<Map<String, dynamic>>(
            future: _loadData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Colors.cyanAccent));
              }

              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
                        const SizedBox(height: 16),
                        Text(
                          "Error: ${snapshot.error}",
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () => setState(() {}),
                          child: const Text('Retry', style: TextStyle(color: Colors.cyanAccent)),
                        )
                      ],
                    ),
                  ),
                );
              }

              if (!snapshot.hasData) return const SizedBox.shrink();

              final league = snapshot.data!['league'] as League;
              final fixtures = snapshot.data!['fixtures'] as List<FixtureMatch>;
              final teamNames = snapshot.data!['teamNames'] as Map<String, String>;
              final nextFixture = fixtures.isNotEmpty ? fixtures.first : null;
              final bool isOwner = league.organizerUserId == currentUserId;

              return ConstrainedBox(
                constraints: BoxConstraints(maxWidth: isWide ? 600 : 500),
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  children: [
                    _overviewCard(context, primary, league, isOwner),
                    const SizedBox(height: 16),
                    _quickActions(context, isOwner),
                    const SizedBox(height: 16),
                    _nextFixture(context, nextFixture, teamNames),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _overviewCard(BuildContext context, Color c, League league, bool isOwner) {
    return Glass(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  league.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              if (isOwner)
                Tooltip(
                  message: 'Organiser',
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.cyanAccent.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.verified_user, color: Colors.cyanAccent, size: 20),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${league.format.displayName} • ${league.season}',
            style: const TextStyle(color: Colors.white60, fontSize: 14),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _pill(league.isPrivate ? 'Private' : 'Public', Colors.cyanAccent),
              _pill('${league.maxTeams} Teams Max', Colors.orangeAccent),
              _pill(league.region, Colors.purpleAccent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _quickActions(BuildContext context, bool isOwner) {
    return Glass(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'League Menu',
            style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _actionButton(
                  icon: Icons.list_alt,
                  label: 'Fixtures',
                  onTap: () => context.push('/leagues/${widget.leagueId}/fixtures'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _actionButton(
                  icon: Icons.leaderboard,
                  label: 'Standings',
                  onTap: () => context.push('/leagues/${widget.leagueId}/standings'),
                ),
              ),
            ],
          ),
          if (isOwner) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.cyanAccent,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.edit_note),
                label: const Text(
                  'MANAGE LEAGUE SCORES',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: () => context.push('/leagues/${widget.leagueId}/admin-scores'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _actionButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white70),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _nextFixture(BuildContext context, FixtureMatch? fixture, Map<String, String> names) {
    final homeName = names[fixture?.homeTeamId] ?? fixture?.homeTeamId ?? 'TBD';
    final awayName = names[fixture?.awayTeamId] ?? fixture?.awayTeamId ?? 'TBD';

    return Glass(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Coming Up Next',
                style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 16),
              ),
              if (fixture != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Round ${fixture.roundNumber}',
                    style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          if (fixture != null)
            Row(
              children: [
                Expanded(
                  child: Text(
                    homeName,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                    textAlign: TextAlign.right,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text('VS', style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.w900, fontSize: 14)),
                ),
                Expanded(
                  child: Text(
                    awayName,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ],
            )
          else
            const Center(child: Text('No upcoming fixtures.', style: TextStyle(color: Colors.white38))),
          const SizedBox(height: 20),
          const Divider(color: Colors.white10),
          Align(
            alignment: Alignment.center,
            child: TextButton(
              onPressed: fixture != null
                  ? () => context.push('/leagues/${widget.leagueId}/matches/${fixture.id}')
                  : null,
              child: const Text('FULL MATCH PREVIEW', style: TextStyle(color: Colors.cyanAccent, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pill(String text, Color c) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: c.withOpacity(0.1),
        border: Border.all(color: c.withOpacity(0.2)),
      ),
      child: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.bold, color: c, fontSize: 11),
      ),
    );
  }
}
