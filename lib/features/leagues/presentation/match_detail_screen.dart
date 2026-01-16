import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/persistence/prefs_service.dart';
import '../../../core/widgets/glass.dart';
import '../../../core/widgets/glass_scaffold.dart';
import '../../../core/widgets/status_badge.dart';
import '../data/leagues_repository_local.dart';
import '../models/fixture_match.dart';
import '../../live/data/local_live_service.dart';

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
  ConsumerState<MatchDetailScreen> createState() =>
      _MatchDetailScreenState();
}

class _MatchDetailScreenState
    extends ConsumerState<MatchDetailScreen> {
  late final LocalLeaguesRepository _repo;
  final _note = TextEditingController();
  final _reason = TextEditingController();
  bool _busy = false;
  String _status = 'Pending';

  String get _liveMatchId => widget.matchId; // For now, Live ID == matchId

  @override
  void initState() {
    super.initState();
    _repo = widget.repository ??
        LocalLeaguesRepository(ref.read(prefsServiceProvider));
    // TODO: optionally load real status from fixture if needed.
  }

  @override
  void dispose() {
    _note.dispose();
    _reason.dispose();
    super.dispose();
  }

  Future<void> _startLocalLive() async {
    if (_busy) return;
    setState(() => _busy = true);

    try {
      await LocalLiveService.instance.startHostSession(
        leagueId: widget.leagueId,
        matchId: widget.matchId,
        liveMatchId: _liveMatchId,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start local live: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      if (mounted) setState(() => _busy = false);
      return;
    }

    if (!mounted) return;
    setState(() => _busy = false);

    // extra: true => host mode
    context.push('/live/view/$_liveMatchId', extra: true);
  }

  Future<void> _copyLiveId() async {
    await Clipboard.setData(
      ClipboardData(text: _liveMatchId),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Live Match ID copied: $_liveMatchId'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide =
        MediaQuery.of(context).size.width > 600;

    return GlassScaffold(
      appBar: AppBar(
        title: const Text('Match Details'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isWide ? 700 : 500,
            ),
            child: ListView(
              padding:
                  const EdgeInsets.fromLTRB(16, 12, 16, 16),
              children: [
                _buildHeader(context),
                const SizedBox(height: 16),
                _buildLiveSection(context),
                const SizedBox(height: 16),
                const Center(
                  child: Text(
                    "Scoring managed via Admin Panel",
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Glass(
      padding: const EdgeInsets.all(16),
      borderRadius: 20,
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Match ID: ${widget.matchId}',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
            ),
          ),
          StatusBadge(_status),
        ],
      ),
    );
  }

  Widget _buildLiveSection(BuildContext context) {
    return Glass(
      padding: const EdgeInsets.all(16),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'Live Match',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Host this match locally and share the Live Match ID '
            'so others on your Wi‑Fi can watch in real time.',
            style: TextStyle(
              color: Colors.white38,
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.tag,
                size: 18,
                color: Colors.white60,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _liveMatchId,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Copy Live Match ID',
                onPressed: _copyLiveId,
                icon: const Icon(
                  Icons.copy,
                  size: 18,
                  color: Colors.cyanAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _busy ? null : _startLocalLive,
              icon: _busy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.black,
                      ),
                    )
                  : const Icon(Icons.play_circle_fill),
              label: Text(
                _busy ? 'STARTING...' : 'START LOCAL LIVE',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Viewers: Connect to your hotspot or same Wi‑Fi, then '
            'enter this Live Match ID on the Join Live screen to watch.',
            style: TextStyle(
              color: Colors.white30,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
