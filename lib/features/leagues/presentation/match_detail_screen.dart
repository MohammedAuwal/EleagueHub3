import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/persistence/prefs_service.dart';
import '../../../core/widgets/glass.dart';
import '../../../core/widgets/glass_scaffold.dart';
import '../../../core/widgets/status_badge.dart';
import "../data/leagues_repository_local.dart";
import '../models/fixture_match.dart';

class MatchDetailScreen extends ConsumerStatefulWidget {
  const MatchDetailScreen({
    super.key,
    required this.leagueId,
    required this.matchId,
    this.repository,
  });

  final String leagueId;
  final String matchId;
  final LocalLeaguesRepository? repository;

  @override
  ConsumerState<MatchDetailScreen> createState() => _MatchDetailScreenState();
}

class _MatchDetailScreenState extends ConsumerState<MatchDetailScreen> {
  late final LocalLeaguesRepository _repo;
  final _note = TextEditingController();
  final _reason = TextEditingController();
  bool _busy = false;
  String _status = 'Pending';

  @override
  void initState() {
    super.initState();
    _repo = widget.repository ?? LocalLeaguesRepository(ref.read(prefsServiceProvider));
  }

  @override
  void dispose() {
    _note.dispose();
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      appBar: AppBar(title: const Text('Match Details')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        children: [
          _buildHeader(context),
          const SizedBox(height: 12),
          const Center(child: Text("Scoring managed via Admin Panel", style: TextStyle(color: Colors.white38))),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Glass(
      child: Row(
        children: [
          Expanded(
            child: Text(
              widget.matchId,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
          ),
          StatusBadge(_status),
        ],
      ),
    );
  }
}
