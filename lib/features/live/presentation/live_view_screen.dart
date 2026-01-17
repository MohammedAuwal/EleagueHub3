import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../../../core/widgets/glass.dart';
import '../../../core/widgets/glass_scaffold.dart';
import '../data/local_live_service.dart';
import '../data/local_webrtc_host.dart';
import '../data/local_webrtc_viewer.dart';

class LiveViewScreen extends StatefulWidget {
  const LiveViewScreen({
    super.key,
    required this.matchId,
    required this.isHost,
    this.hostAddress,
    this.port,
  });

  final String matchId;
  final bool isHost;

  /// Viewer only
  final String? hostAddress;

  /// Host/viewer
  final int? port;

  @override
  State<LiveViewScreen> createState() => _LiveViewScreenState();
}

class _LiveViewScreenState extends State<LiveViewScreen> {
  final _chat = TextEditingController();
  final _messages = <String>['Welcome to the live match.'];

  LocalLiveHostSession? _hostSession;
  LocalLiveViewerSession? _viewerSession;

  StreamSubscription? _hostEventsSub;
  StreamSubscription? _viewerEventsSub;

  bool _busy = false;
  String? _errorText;

  int get _port => widget.port ?? 8765;

  @override
  void initState() {
    super.initState();

    if (!widget.isHost) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _startViewer());
    }
  }

  @override
  void dispose() {
    _chat.dispose();
    _hostEventsSub?.cancel();
    _viewerEventsSub?.cancel();
    _stopAll();
    super.dispose();
  }

  Future<void> _stopAll() async {
    if (widget.isHost) {
      await LocalLiveService.instance.stopHostSession(liveMatchId: widget.matchId);
    } else {
      await LocalLiveService.instance.leaveViewerSession(liveMatchId: widget.matchId);
    }
  }

  Future<void> _startHost() async {
    setState(() {
      _busy = true;
      _errorText = null;
    });

    try {
      final s = await LocalLiveService.instance.startHostSession(
        liveMatchId: widget.matchId,
        port: _port,
      );

      _hostEventsSub?.cancel();
      _hostEventsSub = s.events.listen((evt) {
        _appendEvent(evt);
      });

      setState(() => _hostSession = s);
    } catch (e) {
      setState(() => _errorText = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _startViewer() async {
    final host = widget.hostAddress?.trim();
    if (host == null || host.isEmpty) {
      setState(() => _errorText = 'Missing host IP. Go back and enter host IP/port (or use Auto‑Discovery).');
      return;
    }

    setState(() {
      _busy = true;
      _errorText = null;
    });

    try {
      final v = await LocalLiveService.instance.joinViewerSession(
        liveMatchId: widget.matchId,
        host: host,
        port: _port,
      );

      _viewerEventsSub?.cancel();
      _viewerEventsSub = v.events.listen((evt) {
        _appendEvent(evt);
      });

      setState(() => _viewerSession = v);
    } catch (e) {
      setState(() => _errorText = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _appendEvent(Map<String, dynamic> evt) {
    final kind = evt['kind']?.toString();
    final from = evt['from']?.toString();

    String line;
    if (kind == 'chat') {
      final txt = evt['text']?.toString() ?? '';
      line = (from == null) ? txt : '$from: $txt';
    } else if (kind == 'reaction') {
      final r = evt['reaction']?.toString() ?? '';
      line = (from == null) ? 'Reaction: $r' : '$from reacted: $r';
    } else {
      line = 'Event: $evt';
    }

    if (!mounted) return;
    setState(() => _messages.add(line));
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 700;

    return GlassScaffold(
      appBar: AppBar(
        title: Text(
          widget.isHost ? 'Host Live • ${widget.matchId}' : 'Live Match • ${widget.matchId}',
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (widget.isHost)
            IconButton(
              tooltip: 'Copy host connection info',
              onPressed: (_hostSession?.hostIp.value == null)
                  ? null
                  : () {
                      final ip = _hostSession!.hostIp.value!;
                      final txt = 'Host: $ip:${_port}\nMatch: ${widget.matchId}';
                      Clipboard.setData(ClipboardData(text: txt));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Copied host info')),
                      );
                    },
              icon: const Icon(Icons.copy),
            ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: isWide ? _buildWideLayout(context) : _buildMobileLayout(context),
        ),
      ),
    );
  }

  Widget _buildWideLayout(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Column(
            children: [
              Expanded(child: _buildStreamArea(context)),
              const SizedBox(height: 12),
              _buildControls(context),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: _ChatOverlay(
            messages: _messages,
            chatController: _chat,
            onSend: _send,
            onReaction: _react,
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 180),
          child: Column(
            children: [
              Expanded(child: _buildStreamArea(context)),
              const SizedBox(height: 12),
              _buildControls(context),
            ],
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _ChatOverlay(
            messages: _messages,
            chatController: _chat,
            onSend: _send,
            onReaction: _react,
          ),
        ),
      ],
    );
  }

  Widget _buildControls(BuildContext context) {
    if (_errorText != null) {
      return Glass(
        borderRadius: 18,
        padding: const EdgeInsets.all(12),
        child: Text('Error: $_errorText', style: const TextStyle(color: Colors.redAccent)),
      );
    }

    if (widget.isHost) {
      final host = _hostSession;
      final started = host != null;

      return Glass(
        borderRadius: 18,
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (started) ...[
              ValueListenableBuilder<String?>(
                valueListenable: host.hostIp,
                builder: (_, ip, __) {
                  return Text(
                    'Host address: ${(ip ?? '...')}:${_port}',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  );
                },
              ),
              const SizedBox(height: 6),
              const Text(
                'Auto‑Discovery ON (LAN broadcast). Viewers should see you in Join screen.',
                style: TextStyle(color: Colors.white38, fontSize: 11),
              ),
              const SizedBox(height: 10),
            ],
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _busy ? null : (started ? null : _startHost),
                    icon: const Icon(Icons.cast),
                    label: Text(_busy ? 'Starting...' : (started ? 'Broadcasting' : 'Start Broadcast')),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _busy
                        ? null
                        : () async {
                            setState(() => _busy = true);
                            await LocalLiveService.instance.stopHostSession(liveMatchId: widget.matchId);
                            if (mounted) {
                              setState(() {
                                _hostSession = null;
                                _busy = false;
                              });
                            }
                          },
                    icon: const Icon(Icons.stop),
                    label: const Text('Stop'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (started)
              ValueListenableBuilder<int>(
                valueListenable: host.viewerCount,
                builder: (_, c, __) => Text(
                  'Viewers connected: $c',
                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ),
          ],
        ),
      );
    }

    final viewer = _viewerSession;
    final connected = viewer != null;

    return Glass(
      borderRadius: 18,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: FilledButton.icon(
              onPressed: _busy ? null : (connected ? null : _startViewer),
              icon: const Icon(Icons.play_circle_fill),
              label: Text(_busy ? 'Connecting...' : (connected ? 'Connected' : 'Connect')),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _busy
                  ? null
                  : () async {
                      setState(() => _busy = true);
                      await LocalLiveService.instance.leaveViewerSession(liveMatchId: widget.matchId);
                      if (mounted) {
                        setState(() {
                          _viewerSession = null;
                          _busy = false;
                        });
                      }
                    },
              icon: const Icon(Icons.logout),
              label: const Text('Leave'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreamArea(BuildContext context) {
    final host = _hostSession;
    final viewer = _viewerSession;

    RTCVideoRenderer? screenR;
    RTCVideoRenderer? camR;

    if (widget.isHost && host != null) {
      screenR = host.screenRenderer;
      camR = host.cameraRenderer;
    } else if (!widget.isHost && viewer != null) {
      screenR = viewer.screenRenderer;
      camR = viewer.cameraRenderer;
    }

    return Glass(
      borderRadius: 24,
      padding: const EdgeInsets.all(12),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Container(
                color: Colors.black.withOpacity(0.35),
                child: (screenR != null && screenR.srcObject != null)
                    ? RTCVideoView(
                        screenR,
                        objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,
                      )
                    : Center(
                        child: Text(
                          widget.isHost
                              ? 'Press Start Broadcast.\nScreen permission popup will appear.'
                              : 'Connecting...\nIf blank: check Wi‑Fi + host.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.white70),
                        ),
                      ),
              ),
            ),
          ),

          // PiP camera
          Positioned(
            right: 12,
            bottom: 12,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: 140,
                height: 190,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  border: Border.all(color: Colors.white24),
                ),
                child: (camR != null && camR.srcObject != null)
                    ? RTCVideoView(
                        camR,
                        mirror: widget.isHost,
                        objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                      )
                    : const Center(
                        child: Text('Camera', style: TextStyle(color: Colors.white54)),
                      ),
              ),
            ),
          ),

          // Match ID badge
          Positioned(
            top: 8,
            left: 8,
            child: Glass(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              borderRadius: 999,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.tag, size: 14, color: Colors.white60),
                  const SizedBox(width: 6),
                  Text(
                    widget.matchId,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _send() {
    final txt = _chat.text.trim();
    if (txt.isEmpty) return;

    _chat.clear();

    if (widget.isHost) {
      // Host sends to viewers and also sees it locally
      final evt = {'kind': 'chat', 'text': txt, 'from': 'HOST'};
      setState(() => _messages.add('HOST: $txt'));
      LocalLiveService.instance.broadcastHostEvent(liveMatchId: widget.matchId, event: evt);
      return;
    }

    final v = _viewerSession;
    if (v == null) return;
    v.sendChat(txt);
  }

  void _react(String reactionLabel) {
    if (widget.isHost) {
      final evt = {'kind': 'reaction', 'reaction': reactionLabel, 'from': 'HOST'};
      setState(() => _messages.add('HOST reacted: $reactionLabel'));
      LocalLiveService.instance.broadcastHostEvent(liveMatchId: widget.matchId, event: evt);
      return;
    }

    final v = _viewerSession;
    if (v == null) return;
    v.sendReaction(reactionLabel);
  }
}

class _ChatOverlay extends StatelessWidget {
  const _ChatOverlay({
    required this.messages,
    required this.chatController,
    required this.onSend,
    required this.onReaction,
  });

  final List<String> messages;
  final TextEditingController chatController;
  final VoidCallback onSend;
  final void Function(String) onReaction;

  @override
  Widget build(BuildContext context) {
    return Glass(
      padding: const EdgeInsets.all(12),
      borderRadius: 22,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 120,
            child: ListView.builder(
              reverse: true,
              itemCount: messages.length,
              itemBuilder: (context, i) {
                final msg = messages[messages.length - 1 - i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    msg,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              ...[
                ('GG', Icons.emoji_events_outlined),
                ('Wow', Icons.flash_on_outlined),
                ('Clutch', Icons.local_fire_department_outlined),
              ].map(
                (e) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: IconButton(
                    onPressed: () => onReaction(e.$1),
                    icon: Icon(e.$2, size: 20),
                    color: Colors.cyanAccent,
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: chatController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(hintText: 'Type a message'),
                  onSubmitted: (_) => onSend(),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(onPressed: onSend, child: const Text('Send')),
            ],
          ),
        ],
      ),
    );
  }
}
