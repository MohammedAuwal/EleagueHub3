import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/glass.dart';
import '../../../core/widgets/glass_scaffold.dart';
import '../../../core/widgets/status_badge.dart';

class MatchDetailScreen extends ConsumerStatefulWidget {
  const MatchDetailScreen({
    super.key,
    required this.leagueId,
    required this.matchId,
    this.repository,
  });

  final String leagueId;
  final String matchId;

  /// Kept for compatibility with your older code; not used in this screen right now.
  final dynamic repository;

  @override
  ConsumerState<MatchDetailScreen> createState() => _MatchDetailScreenState();
}

class _MatchDetailScreenState extends ConsumerState<MatchDetailScreen> {
  final _note = TextEditingController();
  final _reason = TextEditingController();

  bool _busy = false;
  String _status = 'Pending';

  /// For now, Live ID == matchId
  String get _liveMatchId => widget.matchId;

  @override
  void dispose() {
    _note.dispose();
    _reason.dispose();
    super.dispose();
  }

  Future<void> _startLocalLive() async {
    if (_busy) return;

    // IMPORTANT CHANGE:
    // Old flow tried to call:
    //   LocalLiveService.startHostSession(leagueId/matchId/liveMatchId)
    // But the new WebRTC host start happens inside LiveViewScreen.
    //
    // So from match details we just navigate to the host live screen.
    const port = 8765;

    setState(() => _busy = true);

    if (!mounted) return;
    setState(() => _busy = false);

    // New routing expects a Map extra:
    // { isHost: true, port: 8765 }
    context.push(
      '/live/view/$_liveMatchId',
      extra: {
        'isHost': true,
        'port': port,
      },
    );
  }

  Future<void> _copyLiveId() async {
    await Clipboard.setData(ClipboardData(text: _liveMatchId));
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
    final isWide = MediaQuery.of(context).size.width > 600;

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
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
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
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Live Match (Local Wi‑Fi)',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Host this match locally on your Wi‑Fi/hotspot.\n'
            'Viewers can join via Auto‑Discovery on the Join Live screen (recommended), '
            'or manually using your Host IP + Port shown on the host screen.',
            style: TextStyle(
              color: Colors.white38,
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.tag, size: 18, color: Colors.white60),
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
                _busy ? 'OPENING...' : 'OPEN HOST LIVE',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Tip: On the host live screen press “Start Broadcast” to begin screen + front camera sharing.',
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
