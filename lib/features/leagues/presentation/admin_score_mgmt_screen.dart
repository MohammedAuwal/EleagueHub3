import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/persistence/prefs_service.dart';
import '../../../core/widgets/glass.dart';
import '../../../core/widgets/glass_scaffold.dart';
import '../../../core/widgets/section_header.dart';
import '../data/leagues_repository_local.dart';
import '../models/fixture_match.dart';
import '../models/enums.dart';

class AdminScoreMgmtScreen extends ConsumerStatefulWidget {
  final String leagueId;
  const AdminScoreMgmtScreen({super.key, required this.leagueId});

  @override
  ConsumerState<AdminScoreMgmtScreen> createState() =>
      _AdminScoreMgmtScreenState();
}

class _AdminScoreMgmtScreenState
    extends ConsumerState<AdminScoreMgmtScreen> {
  late LocalLeaguesRepository _repo;
  List<FixtureMatch> _matches = [];
  Map<String, String> _teamNames = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _repo = LocalLeaguesRepository(ref.read(prefsServiceProvider));
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    // Fetch both matches and teams to resolve names
    final matches = await _repo.getMatches(widget.leagueId);
    final teams = await _repo.getTeams(widget.leagueId);

    // Sort so that pending/unplayed matches come first, completed go to bottom.
    matches.sort((a, b) {
      final aPlayed = a.status == MatchStatus.completed;
      final bPlayed = b.status == MatchStatus.completed;

      if (aPlayed != bPlayed) {
        // false (pending) before true (completed)
        return aPlayed ? 1 : -1;
      }

      // Secondary sort: by id for deterministic ordering
      return a.id.compareTo(b.id);
    });

    if (!mounted) return;
    setState(() {
      _matches = matches;
      _teamNames = {for (var t in teams) t.id: t.name};
      _isLoading = false;
    });
  }

  Future<void> _updateScore(
    FixtureMatch match,
    int hScore,
    int aScore,
  ) async {
    final updatedMatch = match.copyWith(
      homeScore: hScore,
      awayScore: aScore,
      status: MatchStatus.completed,
      updatedAtMs: DateTime.now().millisecondsSinceEpoch,
    );

    await _repo.saveMatches(widget.leagueId, [updatedMatch]);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Score Updated Successfully"),
          backgroundColor: Colors.cyan,
          behavior: SnackBarBehavior.floating,
        ),
      );
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isTablet = width > 700;

    return GlassScaffold(
      appBar: AppBar(
        title: const Text("Score Management"),
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
                // Limit width on phones to prevent a "stretched" look
                constraints: BoxConstraints(
                  maxWidth: isTablet ? 1000 : 500,
                ),
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: SectionHeader('Update Match Results'),
                    ),
                    const SizedBox(height: 4),
                    const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: Text(
                        'Tap + / - to adjust each team\'s score.\n'
                        'Pending matches are listed first; completed go to the bottom.',
                        style: TextStyle(
                          color: Colors.white30,
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
                                "No matches to manage",
                                style: TextStyle(color: Colors.white38),
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.all(16),
                              itemCount: _matches.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final match = _matches[index];
                                return _ScoreEntryTile(
                                  key: ValueKey(match.id),
                                  match: match,
                                  homeName: _teamNames[match.homeTeamId] ??
                                      "Home",
                                  awayName: _teamNames[match.awayTeamId] ??
                                      "Away",
                                  onSave: (h, a) =>
                                      _updateScore(match, h, a),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _ScoreEntryTile extends StatefulWidget {
  final FixtureMatch match;
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
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Teams + status pill
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
                padding: EdgeInsets.symmetric(horizontal: 8),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _isCompleted
                      ? Colors.cyanAccent.withOpacity(0.12)
                      : Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  _isCompleted ? 'Completed' : 'Pending',
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
          // Score stepper row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _scoreStepper(
                value: _homeScore,
                onInc: _incHome,
                onDec: _decHome,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
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
                  backgroundColor: Colors.cyanAccent.withOpacity(0.2),
                  foregroundColor: Colors.cyanAccent,
                ),
                icon: const Icon(Icons.done_all, size: 24),
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
        borderRadius: BorderRadius.circular(12),
        border: const BorderSide(color: Colors.white10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
      borderRadius: BorderRadius.circular(20),
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
          color: enabled ? Colors.cyanAccent : Colors.white24,
        ),
      ),
    );
  }
}
