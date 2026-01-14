import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/persistence/prefs_service.dart';
import '../../../core/widgets/glass.dart';
import '../../../core/widgets/glass_scaffold.dart';
import '../../../core/widgets/section_header.dart';
import '../data/leagues_repository_local.dart';
import '../domain/logic/tournament_controller.dart';
import '../models/knockout_match.dart';
import '../models/team.dart';
import '../models/enums.dart';

class AdminKnockoutScoreMgmtScreen extends ConsumerStatefulWidget {
  final String leagueId;

  const AdminKnockoutScoreMgmtScreen({
    super.key,
    required this.leagueId,
  });

  @override
  ConsumerState<AdminKnockoutScoreMgmtScreen> createState() =>
      _AdminKnockoutScoreMgmtScreenState();
}

class _AdminKnockoutScoreMgmtScreenState
    extends ConsumerState<AdminKnockoutScoreMgmtScreen> {
  late LocalLeaguesRepository _repo;
  bool _isLoading = true;
  List<KnockoutMatch> _matches = [];
  Map<String, String> _teamNames = {};

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
    final matches = await _repo.getKnockoutMatches(widget.leagueId);

    // Keep a stable order: by roundName, then by id
    matches.sort((a, b) {
      final ai = _roundOrder.indexOf(a.roundName);
      final bi = _roundOrder.indexOf(b.roundName);
      if (ai != bi) {
        if (ai == -1) return 1;
        if (bi == -1) return -1;
        return ai.compareTo(bi);
      }
      return a.id.compareTo(b.id);
    });

    if (!mounted) return;
    setState(() {
      _matches = matches;
      _teamNames = {for (final t in teams) t.id: t.name};
      _isLoading = false;
    });
  }

  Future<void> _updateScore(
    KnockoutMatch match,
    int hScore,
    int aScore,
  ) async {
    final updatedMatch = match.copyWith(
      homeScore: hScore,
      awayScore: aScore,
      status: MatchStatus.completed,
    );

    // Apply to local list.
    final all = [..._matches];
    final idx = all.indexWhere((m) => m.id == match.id);
    if (idx != -1) {
      all[idx] = updatedMatch;
    } else {
      all.add(updatedMatch);
    }

    // Let TournamentController auto-advance winners.
    final advanced = TournamentController.processMatchResult(
      completedMatch: updatedMatch,
      allMatches: all,
    );

    await _repo.saveKnockoutMatches(widget.leagueId, advanced);

    if (!mounted) return;
    setState(() {
      _matches = advanced;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Knockout score updated'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.cyan,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isTablet = width > 700;

    return GlassScaffold(
      appBar: AppBar(
        title: const Text('Knockout Score Management'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(color: Colors.cyanAccent),
            )
          : Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isTablet ? 1000 : 600,
                ),
                child: Column(
                  children: [
                    const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16),
                      child: SectionHeader(
                          'Update Knockout Results'),
                    ),
                    const SizedBox(height: 4),
                    const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Update scores for Play-off, Round of 16, and beyond.\n'
                        'Winners automatically advance to the next round.',
                        style: TextStyle(
                          color: Colors.white38,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: _matches.isEmpty
                          ? const Center(
                              child: Text(
                                'No knockout matches found.\n'
                                'Generate the bracket from the league details screen first.',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 13,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            )
                          : _buildGroupedList(),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildGroupedList() {
    // Group by roundName
    final byRound = <String, List<KnockoutMatch>>{};
    for (final m in _matches) {
      byRound.putIfAbsent(m.roundName, () => []).add(m);
    }

    final rounds = byRound.keys.toList()
      ..sort((a, b) {
        final ai = _roundOrder.indexOf(a);
        final bi = _roundOrder.indexOf(b);
        if (ai == -1 && bi == -1) return a.compareTo(b);
        if (ai == -1) return 1;
        if (bi == -1) return -1;
        return ai.compareTo(bi);
      });

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: rounds.length,
      itemBuilder: (context, idx) {
        final roundName = rounds[idx];
        final ms = byRound[roundName]!;
        return Padding(
          padding: EdgeInsets.only(
            bottom: idx == rounds.length - 1 ? 0 : 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                roundName,
                style: const TextStyle(
                  color: Colors.cyanAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              for (final m in ms)
                Padding(
                  padding:
                      const EdgeInsets.only(bottom: 8),
                  child: _ScoreEntryTile(
                    match: m,
                    homeName:
                        _teamNames[m.homeTeamId ?? ''] ??
                            (m.homeTeamId ?? 'TBD'),
                    awayName:
                        _teamNames[m.awayTeamId ?? ''] ??
                            (m.awayTeamId ?? 'TBD'),
                    onSave: (h, a) => _updateScore(m, h, a),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _ScoreEntryTile extends StatefulWidget {
  final KnockoutMatch match;
  final String homeName;
  final String awayName;
  final Function(int, int) onSave;

  const _ScoreEntryTile({
    super.key,
    required this.match,
    required this.homeName,
    required this.awayName,
    required this.onSave,
  });

  @override
  State<_ScoreEntryTile> createState() => _ScoreEntryTileState();
}

class _ScoreEntryTileState extends State<_ScoreEntryTile> {
  late int _homeScore;
  late int _awayScore;

  @override
  void initState() {
    super.initState();
    _homeScore = widget.match.homeScore ?? 0;
    _awayScore = widget.match.awayScore ?? 0;
  }

  bool get _isCompleted =>
      widget.match.status == MatchStatus.completed;

  void _incHome() => setState(() => _homeScore++);
  void _decHome() => setState(() {
        if (_homeScore > 0) _homeScore--;
      });

  void _incAway() => setState(() => _awayScore++);
  void _decAway() => setState(() {
        if (_awayScore > 0) _awayScore--;
      });

  @override
  Widget build(BuildContext context) {
    return Glass(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.homeName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  "VS",
                  style: TextStyle(
                    color: Colors.white24,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  widget.awayName,
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _isCompleted
                      ? Colors.cyanAccent
                          .withOpacity(0.12)
                      : Colors.white.withOpacity(0.04),
                  borderRadius:
                      BorderRadius.circular(999),
                ),
                child: Text(
                  _isCompleted
                      ? 'Completed'
                      : 'Pending',
                  style: TextStyle(
                    color: _isCompleted
                        ? Colors.cyanAccent
                        : Colors.white54,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              _scoreStepper(
                value: _homeScore,
                onInc: _incHome,
                onDec: _decHome,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 24,
                ),
                child: Text(
                  ":",
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 24,
                  ),
                ),
              ),
              _scoreStepper(
                value: _awayScore,
                onInc: _incAway,
                onDec: _decAway,
              ),
              const SizedBox(width: 24),
              IconButton.filled(
                onPressed: () {
                  widget.onSave(_homeScore, _awayScore);
                  FocusScope.of(context).unfocus();
                },
                style: IconButton.styleFrom(
                  backgroundColor:
                      Colors.cyanAccent.withOpacity(0.2),
                  foregroundColor:
                      Colors.cyanAccent,
                ),
                icon: const Icon(Icons.done_all,
                    size: 24),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _scoreStepper({
    required int value,
    required VoidCallback onInc,
    required VoidCallback onDec,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius:
            BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      padding:
          const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _stepperButton(
            icon: Icons.remove,
            onPressed: value > 0 ? onDec : null,
            enabled: value > 0,
          ),
          const SizedBox(width: 6),
          SizedBox(
            width: 28,
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 6),
          _stepperButton(
            icon: Icons.add,
            onPressed: onInc,
            enabled: true,
          ),
        ],
      ),
    );
  }

  Widget _stepperButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required bool enabled,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius:
          BorderRadius.circular(20),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: enabled
              ? Colors.cyanAccent.withOpacity(0.08)
              : Colors.white.withOpacity(0.02),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 18,
          color: enabled
              ? Colors.cyanAccent
              : Colors.white24,
        ),
      ),
    );
  }
}
