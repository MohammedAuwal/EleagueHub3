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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _repo = LocalLeaguesRepository(ref.read(prefsServiceProvider));
    _loadMatches();
  }

  Future<void> _loadMatches() async {
    setState(() => _isLoading = true);
    // Fetch real fixtures from your local storage
    final matches = await _repo.getMatches(widget.leagueId);
    setState(() {
      _matches = matches;
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
        const SnackBar(content: Text("Score Updated Locally")),
      );
      _loadMatches();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      appBar: AppBar(
        title: const Text("Score Management"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.cyanAccent))
          : Column(
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
                            return _ScoreEntryTile(
                              match: match,
                              onSave: (h, a) => _updateScore(match, h, a),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}

class _ScoreEntryTile extends StatefulWidget {
  final FixtureMatch match;
  final Function(int, int) onSave;

  const _ScoreEntryTile({required this.match, required this.onSave});

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
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Glass(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: Text(widget.match.homeTeamId, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                const Text(" VS ", style: TextStyle(color: Colors.white24)),
                Expanded(child: Text(widget.match.awayTeamId, textAlign: TextAlign.end, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
              ],
            ),
            const Divider(color: Colors.white10, height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _scoreField(_hController),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text("-", style: TextStyle(color: Colors.white, fontSize: 24)),
                ),
                _scoreField(_aController),
                const SizedBox(width: 20),
                IconButton(
                  onPressed: () {
                    final h = int.tryParse(_hController.text) ?? 0;
                    final a = int.tryParse(_aController.text) ?? 0;
                    widget.onSave(h, a);
                  },
                  icon: const Icon(Icons.check_circle, color: Colors.cyanAccent, size: 32),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _scoreField(TextEditingController controller) {
    return SizedBox(
      width: 50,
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        decoration: const InputDecoration(
          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.cyanAccent)),
        ),
      ),
    );
  }
}
