import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../../../core/widgets/glass.dart';
import '../../../core/widgets/glass_scaffold.dart';
import '../data/live_quality.dart';
import '../data/local_discovery.dart';
import '../data/local_live_service.dart';
import '../data/local_webrtc_host.dart';
import '../data/local_webrtc_viewer.dart';
import 'battery_optimization_guide.dart';

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
    this.initialHomeScore,
    this.initialAwayScore,
  });

  final String matchId;
  final bool isHost;

  /// Viewer only: initial host IP
  final String? hostAddress;

  final int? port;

  final String? homeName;
  final String? awayName;

  /// Host: 'home'|'away'|'unknown'
  /// Viewer: initial host side hint if joining from discovery
  final String? hostSide;

  final int? initialHomeScore;
  final int? initialAwayScore;

  @override
  State<LiveViewScreen> createState() => _LiveViewScreenState();
}

class _LiveViewScreenState extends State<LiveViewScreen> {
  final _chat = TextEditingController();
  final _messages = <String>['Welcome to the live match.'];

  LocalLiveHostSession? _hostSession;
  StreamSubscription? _hostEventsSub;

  LocalLiveViewerSession? _homeViewer;
  LocalLiveViewerSession? _awayViewer;
  StreamSubscription? _homeEventsSub;
  StreamSubscription? _awayEventsSub;

  final _discovery = LocalLiveDiscoveryListener();
  VoidCallback? _discoveryListener;

  bool _busy = false;
  String? _errorText;

  bool _chatMinimized = false;
  _PrimarySide _primary = _PrimarySide.home;

  // Overlay state
  int _homeScore = 0;
  int _awayScore = 0;
  String? _toast;
  Timer? _toastTimer;

  // Host controls
  LiveQualityPreset _quality = LiveQualityPreset.medium;
  bool _micOn = true;

  int get _port => widget.port ?? 8765;

  String get _homeLabel =>
      (widget.homeName?.trim().isNotEmpty == true) ? widget.homeName!.trim() : 'HOME';
  String get _awayLabel =>
      (widget.awayName?.trim().isNotEmpty == true) ? widget.awayName!.trim() : 'AWAY';

  LiveHostSide get _mySide => parseLiveHostSide(widget.hostSide);

  @override
  void initState() {
    super.initState();

    _homeScore = widget.initialHomeScore ?? 0;
    _awayScore = widget.initialAwayScore ?? 0;

    if (!widget.isHost) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await _startInitialViewer();
        await _startDiscoveryForOtherSide();
      });
    }
  }

  @override
  void dispose() {
    _toastTimer?.cancel();
    _toastTimer = null;

    _chat.dispose();
    _hostEventsSub?.cancel();
    _homeEventsSub?.cancel();
    _awayEventsSub?.cancel();
    _stopDiscovery();
    _stopAll();
    super.dispose();
  }

  void _showToast(String text) {
    _toastTimer?.cancel();
    setState(() => _toast = text);
    _toastTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _toast = null);
    });
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
        quality: _quality,
      );

      // Apply mic state
      await s.setMicEnabled(_micOn);

      _hostEventsSub?.cancel();
      _hostEventsSub = s.events.listen(_onLiveEvent);

      setState(() => _hostSession = s);

      _showToast('Broadcast started • ${qualityLabel(_quality)}');
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

    // If join screen passed side, use it; otherwise assume home
    final initialSide = parseLiveHostSide(widget.hostSide);
    final slot = (initialSide == LiveHostSide.away) ? _PrimarySide.away : _PrimarySide.home;

    setState(() {
      _busy = true;
      _errorText = null;
      _primary = slot;
    });

    try {
      final v = LocalLiveViewerSession(
        liveMatchId: widget.matchId,
        host: host,
        port: _port,
      );
      await v.connect();

      if (slot == _PrimarySide.home) {
        _homeEventsSub?.cancel();
        _homeEventsSub = v.events.listen(_onLiveEvent);
        _homeViewer = v;
      } else {
        _awayEventsSub?.cancel();
        _awayEventsSub = v.events.listen(_onLiveEvent);
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

      for (final h in list) {
        final endpoint = '${h.hostIp}:${h.port}';
        final homeEndpoint = _homeViewer == null ? null : '${_homeViewer!.host}:${_homeViewer!.port}';
        final awayEndpoint = _awayViewer == null ? null : '${_awayViewer!.host}:${_awayViewer!.port}';
        if (endpoint == homeEndpoint || endpoint == awayEndpoint) continue;

        if (h.side == LiveHostSide.home && _homeViewer == null) {
          _connectHome(h.hostIp, h.port);
        } else if (h.side == LiveHostSide.away && _awayViewer == null) {
          _connectAway(h.hostIp, h.port);
        } else if (h.side == LiveHostSide.unknown) {
          // only fill missing slot
          if (_homeViewer == null) _connectHome(h.hostIp, h.port);
          if (_awayViewer == null) _connectAway(h.hostIp, h.port);
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
      _homeEventsSub = v.events.listen(_onLiveEvent);
      if (!mounted) return;
      setState(() => _homeViewer = v);
      _showToast('Home connected');
    } catch (_) {}
  }

  Future<void> _connectAway(String hostIp, int port) async {
    if (_awayViewer != null) return;
    try {
      final v = LocalLiveViewerSession(liveMatchId: widget.matchId, host: hostIp, port: port);
      await v.connect();
      _awayEventsSub?.cancel();
      _awayEventsSub = v.events.listen(_onLiveEvent);
      if (!mounted) return;
      setState(() => _awayViewer = v);
      _showToast('Away connected');
    } catch (_) {}
  }

  void _onLiveEvent(Map<String, dynamic> evt) {
    final kind = (evt['kind'] ?? '').toString();

    if (kind == 'score') {
      final hs = evt['home'];
      final as = evt['away'];
      final h = (hs is int) ? hs : int.tryParse('$hs');
      final a = (as is int) ? as : int.tryParse('$as');
      if (h != null && a != null) {
        setState(() {
          _homeScore = h;
          _awayScore = a;
        });
        _showToast('Score: $_homeScore - $_awayScore');
      }
      return;
    }

    if (kind == 'mic') {
      final enabled = evt['enabled'] == true;
      _showToast(enabled ? 'Mic ON' : 'Mic OFF');
      return;
    }

    // keep chat events
    if (kind == 'chat') {
      final txt = (evt['text'] ?? '').toString();
      final from = evt['from']?.toString();
      setState(() => _messages.add(from == null ? txt : '$from: $txt'));
      return;
    }

    if (kind == 'reaction') {
      final from = evt['from']?.toString() ?? 'Viewer';
      final r = (evt['reaction'] ?? '').toString();
      setState(() => _messages.add('$from reacted: $r'));
      _showToast(r);
      return;
    }

    // fallback: show it as message
    setState(() => _messages.add('Event: $evt'));
  }

  void _broadcastScore() {
    final now = DateTime.now().millisecondsSinceEpoch;
    LocalLiveService.instance.broadcastHostEvent(
      liveMatchId: widget.matchId,
      event: {
        'kind': 'score',
        'home': _homeScore,
        'away': _awayScore,
        'ts': now,
        'from': 'HOST',
      },
    );
  }

  void _changeScore({required int dHome, required int dAway}) {
    setState(() {
      _homeScore = (_homeScore + dHome).clamp(0, 999999);
      _awayScore = (_awayScore + dAway).clamp(0, 999999);
    });
    _broadcastScore();
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 700;

    return GlassScaffold(
      appBar: AppBar(
        title: Text(widget.isHost ? 'Host Live • ${widget.matchId}' : 'Live • $_homeLabel vs $_awayLabel'),
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
            minimized: false,
            onToggleMinimize: () {},
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
    // keep controls tappable + chat minimize
    final inset = MediaQuery.of(context).viewInsets.bottom;

    final chatHeight = _chatMinimized ? 64.0 : 220.0;
    const controlsReserved = 220.0;
    const gap = 12.0;

    return Stack(
      children: [
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.all(0).copyWith(
              bottom: chatHeight + controlsReserved + (gap * 2) + inset,
            ),
            child: _buildStreamArea(context),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: chatHeight + gap + inset,
          child: _buildControls(context),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: inset,
          height: chatHeight,
          child: _ChatOverlay(
            minimized: _chatMinimized,
            onToggleMinimize: () => setState(() => _chatMinimized = !_chatMinimized),
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
            // Quality preset (applies on start)
            Row(
              children: [
                const Text('Quality:', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w700)),
                const SizedBox(width: 10),
                DropdownButton<LiveQualityPreset>(
                  value: _quality,
                  dropdownColor: Colors.black87,
                  onChanged: started
                      ? null
                      : (v) {
                          if (v == null) return;
                          setState(() => _quality = v);
                        },
                  items: LiveQualityPreset.values
                      .map(
                        (p) => DropdownMenuItem(
                          value: p,
                          child: Text(qualityLabel(p), style: const TextStyle(color: Colors.white)),
                        ),
                      )
                      .toList(),
                ),
                const Spacer(),
                Row(
                  children: [
                    const Text('Mic', style: TextStyle(color: Colors.white70)),
                    Switch(
                      value: _micOn,
                      onChanged: (v) async {
                        setState(() => _micOn = v);
                        if (_hostSession != null) {
                          await _hostSession!.setMicEnabled(v);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 8),

            if (started) ...[
              ValueListenableBuilder<String?>(
                valueListenable: host.hostIp,
                builder: (_, ip, __) => Text(
                  'Host: ${(ip ?? '...')}:${_port} • side: ${liveHostSideToWire(_mySide)}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
              const SizedBox(height: 8),
            ],

            // Start/Stop
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

            const SizedBox(height: 10),

            // Score controls (host)
            Text('Score: $_homeLabel $_homeScore  -  $_awayScore $_awayLabel',
                style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: () => _changeScore(dHome: 1, dAway: 0),
                    child: Text('+ $_homeLabel'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: () => _changeScore(dHome: 0, dAway: 1),
                    child: Text('+ $_awayLabel'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _changeScore(dHome: -1, dAway: 0),
                    child: Text('- $_homeLabel'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _changeScore(dHome: 0, dAway: -1),
                    child: Text('- $_awayLabel'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () {
                setState(() {
                  _homeScore = 0;
                  _awayScore = 0;
                });
                _broadcastScore();
              },
              child: const Text('Reset Score'),
            ),

            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () => BatteryOptimizationGuide.show(context),
              icon: const Icon(Icons.battery_alert_outlined),
              label: const Text('Battery / Background Help'),
            ),

            if (started)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'If you change Quality, stop + start again to apply.',
                  style: const TextStyle(color: Colors.white38, fontSize: 11),
                ),
              ),
          ],
        ),
      );
    }

    // Viewer controls + status
    final homeOk = _homeViewer != null;
    final awayOk = _awayViewer != null;

    return Glass(
      borderRadius: 18,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Room: $_homeLabel ${homeOk ? "✓" : "…"}  |  $_awayLabel ${awayOk ? "✓" : "…"}',
            style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _busy
                ? null
                : () async {
                    setState(() => _busy = true);
                    await _stopAll();
                    if (mounted) setState(() => _busy = false);
                    if (mounted) Navigator.maybePop(context);
                  },
            icon: const Icon(Icons.logout),
            label: const Text('Leave'),
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
        matchTitle: '$_homeLabel vs $_awayLabel',
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
        homeScore: _homeScore,
        awayScore: _awayScore,
        toast: _toast,
      );
    }

    // Viewer mode
    final primaryScreen = (_primary == _PrimarySide.home)
        ? _homeViewer?.screenRenderer
        : _awayViewer?.screenRenderer;

    return _GamerStreamLayout(
      matchTitle: '$_homeLabel vs $_awayLabel',
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
      homeScore: _homeScore,
      awayScore: _awayScore,
      toast: _toast,
    );
  }

  void _send() {
    final txt = _chat.text.trim();
    if (txt.isEmpty) return;
    _chat.clear();

    if (!widget.isHost) {
      final v = _homeViewer ?? _awayViewer;
      v?.sendChat(txt);
      return;
    }

    final evt = {
      'kind': 'chat',
      'text': txt,
      'from': 'HOST',
      'ts': DateTime.now().millisecondsSinceEpoch,
    };
    setState(() => _messages.add('HOST: $txt'));
    LocalLiveService.instance.broadcastHostEvent(liveMatchId: widget.matchId, event: evt);
  }

  void _react(String reactionLabel) {
    if (!widget.isHost) {
      final v = _homeViewer ?? _awayViewer;
      v?.sendReaction(reactionLabel);
      return;
    }

    final evt = {
      'kind': 'reaction',
      'reaction': reactionLabel,
      'from': 'HOST',
      'ts': DateTime.now().millisecondsSinceEpoch,
    };
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
    required this.homeScore,
    required this.awayScore,
    required this.toast,
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

  final int homeScore;
  final int awayScore;

  final String? toast;

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

          // Top center title
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
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),

          // Scoreboard overlay (bottom center)
          Positioned(
            left: 10,
            right: 10,
            bottom: 10,
            child: Opacity(
              opacity: 0.92,
              child: Glass(
                borderRadius: 999,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        leftLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '$homeScore  -  $awayScore',
                      style: const TextStyle(
                        color: Colors.cyanAccent,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        rightLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Toast overlay
          if (toast != null)
            Positioned(
              top: 58,
              left: 90,
              right: 90,
              child: Glass(
                borderRadius: 999,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: Text(
                  toast!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                ),
              ),
            ),

          // Cams
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
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
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
    required this.minimized,
    required this.onToggleMinimize,
    required this.messages,
    required this.chatController,
    required this.onSend,
    required this.onReaction,
  });

  final bool minimized;
  final VoidCallback onToggleMinimize;

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
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Chat',
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ),
              IconButton(
                tooltip: minimized ? 'Expand chat' : 'Minimize chat',
                onPressed: onToggleMinimize,
                icon: Icon(
                  minimized ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          if (!minimized) ...[
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
        ],
      ),
    );
  }
}
