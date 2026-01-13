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
  ConsumerState<AdminScoreMgmtScreen> createState() => _AdminScoreMgmtScreenState();
}

class _AdminScoreMgmtScreenState extends ConsumerState<AdminScoreMgmtScreen> {
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
    
    if (!mounted) return;
    setState(() {
      _matches = matches;
      _teamNames = { for (var t in teams) t.id: t.name };
      _isLoading = false;
    });
  }

  Future<void> _updateScore(FixtureMatch match, int hScore, int aScore) async {
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
          ? const Center(child: CircularProgressIndicator(color: Colors.cyanAccent))
          : Center(
              child: ConstrainedBox(
                // Limit width to 500 on phones to prevent the "stretched" look from your screenshot
                constraints: BoxConstraints(maxWidth: isTablet ? 1000 : 500),
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: SectionHeader('Update Match Results'),
                    ),
                    Expanded(
                      child: _matches.isEmpty
                          ? const Center(child: Text("No matches to manage", style: TextStyle(color: Colors.white38)))
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _matches.length,
                              itemBuilder: (context, index) {
                                final match = _matches[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _ScoreEntryTile(
                                    key: ValueKey(match.id),
                                    match: match,
                                    homeName: _teamNames[match.homeTeamId] ?? "Home",
                                    awayName: _teamNames[match.awayTeamId] ?? "Away",
                                    onSave: (h, a) => _updateScore(match, h, a),
                                  ),
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
    required this.onSave
  });

  @override
  State<_ScoreEntryTile> createState() => _ScoreEntryTileState();
}

class _ScoreEntryTileState extends State<_ScoreEntryTile> {
  late TextEditingController _hController;
  late TextEditingController _aController;

  @override
  void initState() {
    super.initState();
    _hController = TextEditingController(text: widget.match.homeScore?.toString() ?? '0');
    _aController = TextEditingController(text: widget.match.awayScore?.toString() ?? '0');
  }

  @override
  void dispose() {
    _hController.dispose();
    _aController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Glass(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.homeName, 
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), 
                  overflow: TextOverflow.ellipsis
                )
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text("VS", style: TextStyle(color: Colors.white24, fontSize: 12, fontWeight: FontWeight.w900)),
              ),
              Expanded(
                child: Text(
                  widget.awayName, 
                  textAlign: TextAlign.end, 
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), 
                  overflow: TextOverflow.ellipsis
                )
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _scoreField(_hController),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text(":", style: TextStyle(color: Colors.white38, fontSize: 24)),
              ),
              _scoreField(_aController),
              const SizedBox(width: 24),
              IconButton.filled(
                onPressed: () {
                  final h = int.tryParse(_hController.text) ?? 0;
                  final a = int.tryParse(_aController.text) ?? 0;
                  widget.onSave(h, a);
                  FocusScope.of(context).unfocus();
                },
                style: IconButton.styleFrom(
                  backgroundColor: Colors.cyanAccent.withOpacity(0.2),
                  foregroundColor: Colors.cyanAccent,
                ),
                icon: const Icon(Icons.done_all, size: 24),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _scoreField(TextEditingController controller) {
    return SizedBox(
      width: 60,
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          filled: true,
          fillColor: Colors.white.withOpacity(0.05),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white10),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.cyanAccent),
          ),
        ),
      ),
    );
  }
}
