import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/persistence/prefs_service.dart';
import '../../../core/widgets/glass.dart';
import '../../../core/widgets/glass_scaffold.dart';
import '../data/leagues_repository_local.dart';
import '../domain/standings/standings.dart';
import '../domain/standings/standings_calculator.dart';
import '../domain/logic/tournament_controller.dart';
import '../models/fixture_match.dart';
import '../models/league.dart';
import '../models/league_format.dart';
import '../models/membership.dart';
import '../models/team.dart';

class LeagueDetailScreen extends ConsumerStatefulWidget {
  final String leagueId;

  const LeagueDetailScreen({
    super.key,
    required this.leagueId,
  });

  @override
  ConsumerState<LeagueDetailScreen> createState() =>
      _LeagueDetailScreenState();
}

class _LeagueDetailScreenState
    extends ConsumerState<LeagueDetailScreen> {
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

    final prefs = ref.read(prefsServiceProvider);
    final currentUserId =
        prefs.getCurrentUserId() ??
        prefs.getString(PreferencesService.kCurrentUserIdKey) ??
        'admin_user';

    final membership = await _repo.getMembership(
      leagueId: widget.leagueId,
      userId: currentUserId,
    );

    final Map<String, String> teamNames = {
      for (var t in teams) t.id: t.name
    };

    return {
      'league': league,
      'fixtures': fixtures,
      'teams': teams,
      'teamNames': teamNames,
      'currentUserId': currentUserId,
      'membership': membership,
    };
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 600;

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
              if (snapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Colors.cyanAccent,
                  ),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.redAccent,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Error: ${snapshot.error}",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () => setState(() {}),
                          child: const Text(
                            'Retry',
                            style: TextStyle(
                              color: Colors.cyanAccent,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (!snapshot.hasData) {
                return const SizedBox.shrink();
              }

              final league =
                  snapshot.data!['league'] as League;
              final fixtures = snapshot
                  .data!['fixtures'] as List<FixtureMatch>;
              final teams =
                  snapshot.data!['teams'] as List<Team>;
              final teamNames =
                  snapshot.data!['teamNames']
                      as Map<String, String>;
              final membership =
                  snapshot.data!['membership']
                      as Membership?;

              final nextFixture =
                  fixtures.isNotEmpty ? fixtures.first : null;

              final bool isOwnerByLeague =
                  membership?.role == LeagueRole.organizer;
              final bool isOwnerFallback =
                  league.organizerUserId ==
                      (snapshot.data!['currentUserId']
                          as String);

              final bool isOwner =
                  isOwnerByLeague || isOwnerFallback;

              return ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isWide ? 600 : 500,
                ),
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  children: [
                    _overviewCard(
                      context,
                      primary,
                      league,
                      isOwner,
                    ),
                    const SizedBox(height: 16),
                    _quickActions(
                      context,
                      league,
                      isOwner,
                      fixtures,
                      teams,
                    ),
                    const SizedBox(height: 16),
                    _nextFixture(
                      context,
                      nextFixture,
                      teamNames,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _overviewCard(
    BuildContext context,
    Color c,
    League league,
    bool isOwner,
  ) {
    return Glass(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  league.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
              if (isOwner)
                Tooltip(
                  message: 'Organiser',
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.cyanAccent
                          .withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.verified_user,
                      color: Colors.cyanAccent,
                      size: 20,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${league.format.displayName} • ${league.season}',
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _pill(
                league.isPrivate ? 'Private' : 'Public',
                Colors.cyanAccent,
              ),
              _pill(
                '${league.maxTeams} Teams Max',
                Colors.orangeAccent,
              ),
              _pill(
                league.region,
                Colors.purpleAccent,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _quickActions(
    BuildContext context,
    League league,
    bool isOwner,
    List<FixtureMatch> fixtures,
    List<Team> teams,
  ) {
    final isSwiss = league.format == LeagueFormat.uclSwiss;
    final isGroup = league.format == LeagueFormat.uclGroup;

    return Glass(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'League Menu',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _actionButton(
                  icon: Icons.list_alt,
                  label: 'Fixtures',
                  onTap: () => context.push(
                    '/leagues/${widget.leagueId}/fixtures',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _actionButton(
                  icon: Icons.leaderboard,
                  label: 'Standings',
                  onTap: () => context.push(
                    '/leagues/${widget.leagueId}/standings',
                  ),
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
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.edit_note),
                label: const Text(
                  'MANAGE LEAGUE SCORES',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () => context.push(
                  '/leagues/${widget.leagueId}/admin-scores',
                ),
              ),
            ),
            if (isSwiss) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: Colors.cyanAccent,
                    ),
                    foregroundColor: Colors.cyanAccent,
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.emoji_events),
                  label: const Text(
                    'GENERATE KNOCKOUT BRACKET (SWISS)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  onPressed: () => _generateSwissKnockouts(
                    context,
                    league,
                    teams,
                    fixtures,
                  ),
                ),
              ),
            ],
            if (isGroup) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: Colors.cyanAccent,
                    ),
                    foregroundColor: Colors.cyanAccent,
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.emoji_events_outlined),
                  label: const Text(
                    'GENERATE KNOCKOUT BRACKET (GROUPS)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  onPressed: () => _generateGroupKnockouts(
                    context,
                    league,
                  ),
                ),
              ),
            ],
            if (isSwiss || isGroup) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.cyanAccent,
                      ),
                      onPressed: () => context.push(
                        '/leagues/${widget.leagueId}/knockout',
                      ),
                      icon: const Icon(
                        Icons.account_tree_outlined,
                        size: 18,
                      ),
                      label: const Text(
                        'VIEW KNOCKOUT BRACKET',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.cyanAccent,
                      ),
                      onPressed: () => context.push(
                        '/leagues/${widget.leagueId}/knockout-admin',
                      ),
                      icon: const Icon(
                        Icons.sports_score,
                        size: 18,
                      ),
                      label: const Text(
                        'MANAGE KO SCORES',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ] else ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                vertical: 14,
                horizontal: 12,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: const Text(
                'View-only: You are a participant in this league.',
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
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
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _nextFixture(
    BuildContext context,
    FixtureMatch? fixture,
    Map<String, String> names,
  ) {
    final homeName =
        names[fixture?.homeTeamId] ?? fixture?.homeTeamId ?? 'TBD';
    final awayName =
        names[fixture?.awayTeamId] ?? fixture?.awayTeamId ?? 'TBD';

    return Glass(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Coming Up Next',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              if (fixture != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius:
                        BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Round ${fixture.roundNumber}',
                    style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
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
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  child: Text(
                    'VS',
                    style: TextStyle(
                      color: Colors.cyanAccent,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    awayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            )
          else
            const Center(
              child: Text(
                'No upcoming fixtures.',
                style: TextStyle(
                  color: Colors.white38,
                ),
              ),
            ),
          const SizedBox(height: 20),
          const Divider(color: Colors.white10),
          Align(
            alignment: Alignment.center,
            child: TextButton(
              onPressed: fixture != null
                  ? () => context.push(
                        '/leagues/${widget.leagueId}/matches/${fixture.id}',
                      )
                  : null,
              child: const Text(
                'FULL MATCH PREVIEW',
                style: TextStyle(
                  color: Colors.cyanAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pill(String text, Color c) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: c.withOpacity(0.1),
        border: Border.all(color: c.withOpacity(0.2)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: c,
          fontSize: 11,
        ),
      ),
    );
  }

  /// Generate Swiss knockouts:
  /// - 1–8: direct Round of 16
  /// - 9–24: Play-off (16 teams -> 8 winners)
  /// Uses TournamentController.seedSwissKnockouts and saves via saveKnockoutMatches.
  Future<void> _generateSwissKnockouts(
    BuildContext context,
    League league,
    List<Team> teams,
    List<FixtureMatch> fixtures,
  ) async {
    if (league.format != LeagueFormat.uclSwiss) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This action is only for Swiss leagues.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Do not overwrite existing bracket.
    final existing =
        await _repo.getKnockoutMatches(league.id);
    if (existing.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Knockout bracket already generated.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Compute final Swiss standings from current results.
    final swissStandings = StandingsCalculator.calculate(
      teams: teams,
      matches: fixtures,
    );

    if (swissStandings.length < 16) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'At least 16 teams are required to generate Swiss knockouts.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final koMatches =
        TournamentController.seedSwissKnockouts(
      leagueId: league.id,
      swissStandings: swissStandings,
    );

    if (koMatches.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Failed to seed knockout bracket from Swiss standings.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    await _repo.saveKnockoutMatches(
      league.id,
      koMatches,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Knockout bracket generated (Play-off + Round of 16).',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Generate UCL Group knockouts:
  /// - Takes top 2 from each group
  /// - Seeds Round of 16, QF, SF, Final, 3rd Place
  /// Now requires at least one played group match before seeding.
  Future<void> _generateGroupKnockouts(
    BuildContext context,
    League league,
  ) async {
    if (league.format != LeagueFormat.uclGroup) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This action is only for UCL Group leagues.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Do not overwrite existing bracket.
    final existing =
        await _repo.getKnockoutMatches(league.id);
    if (existing.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Knockout bracket already generated.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final teams = await _repo.getTeams(league.id);
    final matches = await _repo.getMatches(league.id);

    // Require at least one played group match in the league.
    final anyPlayedGroupMatch = matches.any(
      (m) => m.groupId != null && m.isPlayed,
    );
    if (!anyPlayedGroupMatch) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'You must play some group matches before generating the knockout bracket.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Build group standings using only played group matches.
    final playedGroupMatches = matches
        .where((m) => m.groupId != null && m.isPlayed)
        .toList();

    final groupIds = playedGroupMatches
        .map((m) => m.groupId)
        .whereType<String>()
        .map((g) => g.trim())
        .where((g) => g.isNotEmpty)
        .toSet();

    final groupStandings = <String, List<StandingsRow>>{};

    for (final groupId in groupIds) {
      final groupMatches = playedGroupMatches
          .where((m) => m.groupId == groupId)
          .toList();
      if (groupMatches.isEmpty) continue;

      final teamIds = <String>{};
      for (final m in groupMatches) {
        teamIds.add(m.homeTeamId);
        teamIds.add(m.awayTeamId);
      }
      final groupTeams =
          teams.where((t) => teamIds.contains(t.id)).toList();
      if (groupTeams.isEmpty) continue;

      final rows = StandingsCalculator.calculate(
        teams: groupTeams,
        matches: groupMatches,
      );

      groupStandings[groupId] = rows;
    }

    if (groupStandings.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No group standings available to seed knockouts.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final koMatches =
        TournamentController.seedKnockoutsFromGroups(
      leagueId: league.id,
      groupStandings: groupStandings,
    );

    if (koMatches.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Failed to seed knockout bracket from group standings.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    await _repo.saveKnockoutMatches(
      league.id,
      koMatches,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Knockout bracket generated from group standings.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
