import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/persistence/prefs_service.dart';
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

    return Scaffold(
      backgroundColor: const Color(0xFF000428),
      appBar: AppBar(
        title: const Text('UCL Knockout Stage'),
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
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.cyanAccent,
              ),
            )
          : _matches.isEmpty
              ? const Center(
                  child: Text(
                    'No knockout bracket generated yet.',
                    style: TextStyle(color: Colors.white70),
                  ),
                )
              : InteractiveViewer(
                  constrained: false,
                  boundaryMargin: const EdgeInsets.all(100),
                  minScale: 0.3,
                  maxScale: 2.0,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var i = 0; i < roundNames.length; i++) ...[
                        _buildRoundColumn(
                          roundNames[i],
                          rounds[roundNames[i]]!,
                        ),
                        if (i < roundNames.length - 1)
                          _buildBracketConnector(),
                      ],
                    ],
                  ),
                ),
    );
  }

  Widget _buildRoundColumn(
    String title,
    List<KnockoutMatch> roundMatches,
  ) {
    // Keep matches stable
    final matches = [...roundMatches];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        for (final m in matches) _buildMatchCard(m),
      ],
    );
  }

  Widget _buildMatchCard(KnockoutMatch match) {
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

    return Container(
      width: 220,
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTeamRow(homeName, homeScore, isHomeWinner),
          const Divider(color: Colors.white24),
          _buildTeamRow(awayName, awayScore, isAwayWinner),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              match.status == MatchStatus.completed
                  ? "Completed"
                  : "Scheduled",
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 10,
              ),
            ),
          ),
        ],
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
          style: const TextStyle(color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildBracketConnector() {
    return Container(
      width: 40,
      height: 2,
      color: Colors.white24,
    );
  }
}
