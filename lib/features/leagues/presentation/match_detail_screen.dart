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
  ConsumerState<MatchDetailScreen> createState() =>
      _MatchDetailScreenState();
}

class _MatchDetailScreenState
    extends ConsumerState<MatchDetailScreen> {
  bool _busy = false;
  String _status = 'Pending';

  /// For now, Live ID == matchId.
  String get _liveMatchId => widget.matchId;

  Future<void> _startLocalLive() async {
    if (_busy) return;

    // For the current design, WebRTC host start happens inside LiveViewScreen.
    // From here we just navigate to host live view with extra data.
    const port = 8765;
    setState(() => _busy = true);

    if (!mounted) return;
    setState(() => _busy = false);

    context.push(
      '/live/view/$_liveMatchId',
      extra: {
        'isHost': true,
        'port': port,
      },
    );
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
                _buildAdminInfo(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Top header with match ID and status badge.
  Widget _buildHeader(BuildContext context) {
    return Glass(
      padding: const EdgeInsets.all(16),
      borderRadius: 20,
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Match ID\n${widget.matchId}',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1.3,
                  ),
            ),
          ),
          StatusBadge(_status),
        ],
      ),
    );
  }

  /// Live Match section: Live ID + copy + host live button.
  Widget _buildLiveSection(BuildContext context) {
    return Glass(
      padding: const EdgeInsets.all(16),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
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
            'Viewers can join using this Live Match ID on the Join Live screen.',
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
                _busy ? 'OPENING...' : 'OPEN HOST LIVE',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Tip: On the host live screen you will see your Host IP and Port.\n'
            'Viewers on the same Wi‑Fi/hotspot can join using this ID.',
            style: TextStyle(
              color: Colors.white30,
              fontSize: 11,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  /// Info card about scoring / admin.
  Widget _buildAdminInfo(BuildContext context) {
    return Glass(
      padding: const EdgeInsets.all(16),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: const [
          Text(
            'Match Scoring',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Scores and official results are managed from the Admin Score '
            'Management screen, not from this page.',
            style: TextStyle(
              color: Colors.white38,
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
