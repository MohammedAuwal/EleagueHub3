import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/persistence/prefs_service.dart';
import '../../../core/widgets/glass.dart';
import '../../../core/widgets/glass_scaffold.dart';
import '../data/leagues_repository_local.dart';
import '../models/knockout_match.dart';
import '../models/team.dart';
import '../models/enums.dart';

class KnockoutBracketScreen extends ConsumerStatefulWidget {
  final String leagueId;

  const KnockoutBracketScreen({
    super.key,
    required this.leagueId,
  });

  @override
  ConsumerState<KnockoutBracketScreen> createState() =>
      _KnockoutBracketScreenState();
}

class _KnockoutBracketScreenState
    extends ConsumerState<KnockoutBracketScreen> {
  late LocalLeaguesRepository _repo;
  bool _isLoading = true;
  List<KnockoutMatch> _matches = [];
  Map<String, Team> _teamsById = {};

  static const _roundOrder = <String>[
    'Play-off',
    'Round of 16',
    'Quarter Finals',
    'Semi Finals',
    'Final',
    '3rd Place',
  ];

  @override
  void initState() {
    super.initState();
    _repo = LocalLeaguesRepository(ref.read(prefsServiceProvider));
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final teams = await _repo.getTeams(widget.leagueId);
    final koMatches = await _repo.getKnockoutMatches(widget.leagueId);

    if (!mounted) return;
    setState(() {
      _teamsById = {for (final t in teams) t.id: t};
      _matches = koMatches;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Group matches by roundName
    final rounds = <String, List<KnockoutMatch>>{};
    for (var m in _matches) {
      rounds.putIfAbsent(m.roundName, () => []).add(m);
    }

    // Sort rounds in logical order
    final roundNames = rounds.keys.toList()
      ..sort((a, b) {
        final ai = _roundOrder.indexOf(a);
        final bi = _roundOrder.indexOf(b);
        if (ai == -1 && bi == -1) {
          return a.compareTo(b);
        }
        if (ai == -1) return 1;
        if (bi == -1) return -1;
        return ai.compareTo(bi);
      });

    return GlassScaffold(
      appBar: AppBar(
        title: const Text('Knockout Bracket'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
            tooltip: 'Reload bracket',
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.cyanAccent,
                ),
              )
            : Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: _matches.isEmpty
                        ? Glass(
                            padding: const EdgeInsets.all(24),
                            borderRadius: 20,
                            child: const Center(
                              child: Text(
                                'No knockout bracket generated yet.\n'
                                'Generate it from the league details screen.',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        : Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                'UCL Knockout Stage',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 20,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Matches loaded: ${_matches.length}',
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Play-off, Round of 16, Quarter-finals, Semi-finals and Final\n'
                                'Pinch & drag to explore the full bracket.',
                                style: TextStyle(
                                  color: Colors.white38,
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Expanded(
                                child: Glass(
                                  borderRadius: 20,
                                  padding: const EdgeInsets.all(12),
                                  child: InteractiveViewer(
                                    constrained: false,
                                    boundaryMargin:
                                        const EdgeInsets.all(100),
                                    minScale: 0.4,
                                    maxScale: 1.8,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        for (var i = 0;
                                            i < roundNames.length;
                                            i++) ...[
                                          _buildRoundColumn(
                                            context,
                                            roundNames[i],
                                            rounds[roundNames[i]]!,
                                          ),
                                          if (i <
                                              roundNames.length - 1)
                                            _buildBracketConnector(),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildRoundColumn(
    BuildContext context,
    String title,
    List<KnockoutMatch> roundMatches,
  ) {
    // Keep matches stable
    final matches = [...roundMatches];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin:
              const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white10),
          ),
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.cyanAccent,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 8),
        for (final m in matches) _buildMatchCard(context, m),
      ],
    );
  }

  Widget _buildMatchCard(BuildContext context, KnockoutMatch match) {
    final homeTeam = match.homeTeamId != null
        ? _teamsById[match.homeTeamId]
        : null;
    final awayTeam = match.awayTeamId != null
        ? _teamsById[match.awayTeamId]
        : null;

    final homeName = homeTeam?.name ?? (match.homeTeamId ?? 'TBD');
    final awayName = awayTeam?.name ?? (match.awayTeamId ?? 'TBD');

    final homeScore = match.homeScore?.toString() ?? "-";
    final awayScore = match.awayScore?.toString() ?? "-";

    final isHomeWinner = match.homeScore != null &&
        match.awayScore != null &&
        match.homeScore! > match.awayScore!;
    final isAwayWinner = match.homeScore != null &&
        match.awayScore != null &&
        match.awayScore! > match.homeScore!;

    final bool isCompleted =
        match.status == MatchStatus.completed;

    final Color statusColor = isCompleted
        ? Colors.cyanAccent.withOpacity(0.1)
        : Colors.white.withOpacity(0.03);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 6,
      ),
      child: Glass(
        borderRadius: 16,
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.stretch,
          children: [
            _buildTeamRow(
              homeName,
              homeScore,
              isHomeWinner,
            ),
            const Divider(
              color: Colors.white24,
              height: 14,
            ),
            _buildTeamRow(
              awayName,
              awayScore,
              isAwayWinner,
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: Colors.white24,
                    width: 0.5,
                  ),
                ),
                child: Text(
                  isCompleted ? 'Completed' : 'Scheduled',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamRow(
    String name,
    String score,
    bool isWinner,
  ) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            name,
            style: TextStyle(
              color: isWinner
                  ? Colors.cyanAccent
                  : Colors.white,
              fontWeight:
                  isWinner ? FontWeight.bold : FontWeight.normal,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          score,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildBracketConnector() {
    return Container(
      width: 40,
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: Colors.white24,
    );
  }
}
