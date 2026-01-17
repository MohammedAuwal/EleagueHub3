import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../../../core/widgets/glass.dart';
import '../../../core/widgets/glass_scaffold.dart';
import '../data/local_discovery.dart';
import '../data/local_live_service.dart';
import '../data/local_webrtc_host.dart';
import '../data/local_webrtc_viewer.dart';

enum _PrimarySide { home, away }

class LiveViewScreen extends StatefulWidget {
  const LiveViewScreen({
    super.key,
    required this.matchId,
    required this.isHost,
    this.hostAddress,
    this.port,
    this.homeName,
    this.awayName,
    this.hostSide,
  });

  final String matchId;
  final bool isHost;

  /// Viewer only: initial host IP
  final String? hostAddress;

  final int? port;

  /// Optional match labels (for gamer UI)
  final String? homeName;
  final String? awayName;

  /// Host only: 'home'|'away'|'unknown'
  final String? hostSide;

  @override
  State<LiveViewScreen> createState() => _LiveViewScreenState();
}

class _LiveViewScreenState extends State<LiveViewScreen> {
  final _chat = TextEditingController();
  final _messages = <String>['Welcome to the live match.'];

  LocalLiveHostSession? _hostSession;
  StreamSubscription? _hostEventsSub;

  // Viewer can connect to BOTH players
  LocalLiveViewerSession? _homeViewer;
  LocalLiveViewerSession? _awayViewer;
  StreamSubscription? _homeEventsSub;
  StreamSubscription? _awayEventsSub;

  final _discovery = LocalLiveDiscoveryListener();
  VoidCallback? _discoveryListener;

  bool _busy = false;
  String? _errorText;

  _PrimarySide _primary = _PrimarySide.home;

  int get _port => widget.port ?? 8765;

  String get _homeLabel => (widget.homeName?.trim().isNotEmpty == true) ? widget.homeName!.trim() : 'HOME';
  String get _awayLabel => (widget.awayName?.trim().isNotEmpty == true) ? widget.awayName!.trim() : 'AWAY';

  LiveHostSide get _mySide => parseLiveHostSide(widget.hostSide);

  @override
  void initState() {
    super.initState();

    if (!widget.isHost) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await _startInitialViewer();
        await _startDiscoveryForOtherSide();
      });
    }
  }

  @override
  void dispose() {
    _chat.dispose();
    _hostEventsSub?.cancel();
    _homeEventsSub?.cancel();
    _awayEventsSub?.cancel();
    _stopDiscovery();
    _stopAll();
    super.dispose();
  }

  Future<void> _stopAll() async {
    if (widget.isHost) {
      await LocalLiveService.instance.stopHostSession(liveMatchId: widget.matchId);
      return;
    }

    try {
      await _homeViewer?.disconnect();
    } catch (_) {}
    try {
      await _awayViewer?.disconnect();
    } catch (_) {}
    _homeViewer = null;
    _awayViewer = null;
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
        homeName: widget.homeName,
        awayName: widget.awayName,
        side: _mySide,
      );

      _hostEventsSub?.cancel();
      _hostEventsSub = s.events.listen(_appendEvent);

      setState(() => _hostSession = s);
    } catch (e) {
      setState(() => _errorText = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _startInitialViewer() async {
    final host = widget.hostAddress?.trim();
    if (host == null || host.isEmpty) {
      setState(() => _errorText = 'Missing host IP. Go back and join from discovery/manual connect.');
      return;
    }

    // If join screen passed side, use it; otherwise assume home as default.
    final initialSide = parseLiveHostSide(widget.hostSide);
    final target = (initialSide == LiveHostSide.away) ? _PrimarySide.away : _PrimarySide.home;

    setState(() {
      _busy = true;
      _errorText = null;
      _primary = target;
    });

    try {
      final v = LocalLiveViewerSession(
        liveMatchId: widget.matchId,
        host: host,
        port: _port,
      );
      await v.connect();

      if (target == _PrimarySide.home) {
        _homeEventsSub?.cancel();
        _homeEventsSub = v.events.listen(_appendEvent);
        _homeViewer = v;
      } else {
        _awayEventsSub?.cancel();
        _awayEventsSub = v.events.listen(_appendEvent);
        _awayViewer = v;
      }

      if (mounted) setState(() {});
    } catch (e) {
      setState(() => _errorText = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _startDiscoveryForOtherSide() async {
    await _discovery.start();

    _discoveryListener = () {
      final list = _discovery.hosts.value.where((h) => h.matchId == widget.matchId).toList();
      if (list.isEmpty) return;

      // We already connected to one host; connect to the other when seen.
      for (final h in list) {
        final side = h.side;

        // If host broadcasts its side, map properly.
        if (side == LiveHostSide.home && _homeViewer == null) {
          _connectHome(h.hostIp, h.port);
        } else if (side == LiveHostSide.away && _awayViewer == null) {
          _connectAway(h.hostIp, h.port);
        } else if (side == LiveHostSide.unknown) {
          // If unknown, connect it to the missing slot (best effort).
          if (_homeViewer == null) {
            _connectHome(h.hostIp, h.port);
          } else if (_awayViewer == null) {
            _connectAway(h.hostIp, h.port);
          }
        }
      }
    };

    _discovery.hosts.addListener(_discoveryListener!);
  }

  void _stopDiscovery() {
    if (_discoveryListener != null) {
      _discovery.hosts.removeListener(_discoveryListener!);
      _discoveryListener = null;
    }
    _discovery.stop();
  }

  Future<void> _connectHome(String hostIp, int port) async {
    if (_homeViewer != null) return;
    try {
      final v = LocalLiveViewerSession(liveMatchId: widget.matchId, host: hostIp, port: port);
      await v.connect();
      _homeEventsSub?.cancel();
      _homeEventsSub = v.events.listen(_appendEvent);
      if (!mounted) return;
      setState(() => _homeViewer = v);
    } catch (_) {}
  }

  Future<void> _connectAway(String hostIp, int port) async {
    if (_awayViewer != null) return;
    try {
      final v = LocalLiveViewerSession(liveMatchId: widget.matchId, host: hostIp, port: port);
      await v.connect();
      _awayEventsSub?.cancel();
      _awayEventsSub = v.events.listen(_appendEvent);
      if (!mounted) return;
      setState(() => _awayViewer = v);
    } catch (_) {}
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
        title: Text(widget.isHost ? 'Host Live • ${widget.matchId}' : 'Live • ${_homeLabel} vs ${_awayLabel}'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (widget.isHost)
            IconButton(
              tooltip: 'Copy host info',
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
                builder: (_, ip, __) => Text(
                  'Host address: ${(ip ?? '...')}:${_port} • side: ${liveHostSideToWire(_mySide)}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
              const SizedBox(height: 8),
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
                            if (mounted) setState(() => _busy = false);
                            setState(() => _hostSession = null);
                          },
                    icon: const Icon(Icons.stop),
                    label: const Text('Stop'),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Glass(
      borderRadius: 18,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: FilledButton.icon(
              onPressed: _busy
                  ? null
                  : () async {
                      setState(() => _busy = true);
                      await _stopAll();
                      if (mounted) setState(() => _busy = false);
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
    // Host preview
    if (widget.isHost && _hostSession != null) {
      final host = _hostSession!;
      final mySide = _mySide;

      final leftCam = (mySide == LiveHostSide.away) ? null : host.cameraRenderer;
      final rightCam = (mySide == LiveHostSide.home) ? null : host.cameraRenderer;

      return _GamerStreamLayout(
        matchTitle: '${_homeLabel} vs ${_awayLabel}',
        screenRenderer: host.screenRenderer,
        camLeft: leftCam,
        camRight: rightCam,
        leftLabel: _homeLabel,
        rightLabel: _awayLabel,
        leftHint: (mySide == LiveHostSide.away) ? 'Waiting…' : null,
        rightHint: (mySide == LiveHostSide.home) ? 'Waiting…' : null,
        primary: _primary,
        onTapLeft: () => setState(() => _primary = _PrimarySide.home),
        onTapRight: () => setState(() => _primary = _PrimarySide.away),
      );
    }

    // Viewer mode
    final primaryScreen = (_primary == _PrimarySide.home)
        ? _homeViewer?.screenRenderer
        : _awayViewer?.screenRenderer;

    return _GamerStreamLayout(
      matchTitle: '${_homeLabel} vs ${_awayLabel}',
      screenRenderer: primaryScreen,
      camLeft: _homeViewer?.cameraRenderer,
      camRight: _awayViewer?.cameraRenderer,
      leftLabel: _homeLabel,
      rightLabel: _awayLabel,
      leftHint: (_homeViewer == null) ? 'Waiting…' : null,
      rightHint: (_awayViewer == null) ? 'Waiting…' : null,
      primary: _primary,
      onTapLeft: () => setState(() => _primary = _PrimarySide.home),
      onTapRight: () => setState(() => _primary = _PrimarySide.away),
    );
  }

  void _send() {
    final txt = _chat.text.trim();
    if (txt.isEmpty) return;
    _chat.clear();

    // Viewer: always send to HOME host if present (so chat is consistent)
    if (!widget.isHost) {
      final v = _homeViewer ?? _awayViewer;
      v?.sendChat(txt);
      return;
    }

    // Host
    final evt = {'kind': 'chat', 'text': txt, 'from': 'HOST'};
    setState(() => _messages.add('HOST: $txt'));
    LocalLiveService.instance.broadcastHostEvent(liveMatchId: widget.matchId, event: evt);
  }

  void _react(String reactionLabel) {
    if (!widget.isHost) {
      final v = _homeViewer ?? _awayViewer;
      v?.sendReaction(reactionLabel);
      return;
    }

    final evt = {'kind': 'reaction', 'reaction': reactionLabel, 'from': 'HOST'};
    setState(() => _messages.add('HOST reacted: $reactionLabel'));
    LocalLiveService.instance.broadcastHostEvent(liveMatchId: widget.matchId, event: evt);
  }
}

class _GamerStreamLayout extends StatelessWidget {
  const _GamerStreamLayout({
    required this.matchTitle,
    required this.screenRenderer,
    required this.camLeft,
    required this.camRight,
    required this.leftLabel,
    required this.rightLabel,
    required this.leftHint,
    required this.rightHint,
    required this.primary,
    required this.onTapLeft,
    required this.onTapRight,
  });

  final String matchTitle;

  final RTCVideoRenderer? screenRenderer;
  final RTCVideoRenderer? camLeft;
  final RTCVideoRenderer? camRight;

  final String leftLabel;
  final String rightLabel;
  final String? leftHint;
  final String? rightHint;

  final _PrimarySide primary;
  final VoidCallback onTapLeft;
  final VoidCallback onTapRight;

  @override
  Widget build(BuildContext context) {
    final hasScreen = screenRenderer != null && screenRenderer!.srcObject != null;

    return Glass(
      borderRadius: 24,
      padding: const EdgeInsets.all(10),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Container(
                color: Colors.black.withOpacity(0.35),
                child: hasScreen
                    ? RTCVideoView(
                        screenRenderer!,
                        objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,
                      )
                    : Center(
                        child: Text(
                          'Waiting for screen…',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.white70),
                        ),
                      ),
              ),
            ),
          ),

          // Top center match title (subtle)
          Positioned(
            top: 10,
            left: 92,
            right: 92,
            child: Opacity(
              opacity: 0.9,
              child: Glass(
                borderRadius: 999,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: Text(
                  matchTitle,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),

          // Circular cams
          Positioned(
            top: 10,
            left: 10,
            child: _CircularCam(
              label: leftLabel,
              renderer: camLeft,
              hint: leftHint,
              selected: primary == _PrimarySide.home,
              onTap: onTapLeft,
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: _CircularCam(
              label: rightLabel,
              renderer: camRight,
              hint: rightHint,
              selected: primary == _PrimarySide.away,
              onTap: onTapRight,
            ),
          ),
        ],
      ),
    );
  }
}

class _CircularCam extends StatelessWidget {
  const _CircularCam({
    required this.label,
    required this.renderer,
    required this.selected,
    required this.onTap,
    this.hint,
  });

  final String label;
  final RTCVideoRenderer? renderer;
  final bool selected;
  final VoidCallback onTap;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final ready = renderer != null && renderer!.srcObject != null;

    return Opacity(
      opacity: 0.86,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? Colors.cyanAccent.withOpacity(0.95) : Colors.white24,
                  width: 2,
                ),
                color: Colors.black.withOpacity(0.35),
              ),
              child: ClipOval(
                child: ready
                    ? RTCVideoView(
                        renderer!,
                        objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                      )
                    : Center(
                        child: Text(
                          hint ?? '…',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white54, fontSize: 11),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.30),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.white24),
              ),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
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
