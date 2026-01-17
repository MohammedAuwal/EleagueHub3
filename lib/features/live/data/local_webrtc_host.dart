import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:permission_handler/permission_handler.dart';

import 'local_discovery.dart';
import 'local_lan_ip.dart';
import 'local_signaling.dart';

enum LocalLiveHostState {
  idle,
  starting,
  waitingForViewers,
  connected,
  stopped,
  error,
}

class LocalLiveHostSession {
  LocalLiveHostSession({
    required this.liveMatchId,
    required this.port,
  });

  final String liveMatchId;
  final int port;

  final ValueNotifier<LocalLiveHostState> state =
      ValueNotifier<LocalLiveHostState>(LocalLiveHostState.idle);

  final ValueNotifier<String?> error = ValueNotifier<String?>(null);
  final ValueNotifier<int> viewerCount = ValueNotifier<int>(0);
  final ValueNotifier<String?> hostIp = ValueNotifier<String?>(null);

  /// Host preview renderers
  final RTCVideoRenderer screenRenderer = RTCVideoRenderer();
  final RTCVideoRenderer cameraRenderer = RTCVideoRenderer();

  final _events = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get events => _events.stream;

  LocalSignalingServer? _server;
  StreamSubscription? _serverSub;

  LocalLiveDiscoveryBroadcaster? _broadcaster;

  MediaStream? _screenStream;
  MediaStream? _cameraStream;

  final Map<String, _ViewerPeer> _peers = {}; // viewerId -> peer

  Future<void> start() async {
    if (_server != null) return;

    state.value = LocalLiveHostState.starting;
    error.value = null;

    try {
      await screenRenderer.initialize();
      await cameraRenderer.initialize();

      final statuses = await [
        Permission.camera,
        Permission.microphone,
      ].request();

      final denied = statuses.entries.where((e) => !e.value.isGranted).toList();
      if (denied.isNotEmpty) {
        throw Exception('Permissions denied: ${denied.map((e) => e.key).join(', ')}');
      }

      hostIp.value = await LocalLanIp.findLocalIpv4();

      // Start signaling server
      _server = LocalSignalingServer(port: port, matchId: liveMatchId);
      await _server!.start();

      _serverSub = _server!.messages.listen(_onSignalMessage);

      _server!.viewerCount.addListener(() {
        viewerCount.value = _server!.viewerCount.value;
      });

      // Start LAN discovery broadcaster
      _broadcaster = LocalLiveDiscoveryBroadcaster(
        matchId: liveMatchId,
        port: port,
      );
      await _broadcaster!.start();

      // Capture streams
      _screenStream = await navigator.mediaDevices.getDisplayMedia({
        'video': true,
        'audio': false,
      });

      _cameraStream = await navigator.mediaDevices.getUserMedia({
        'audio': true, // mic only
        'video': {
          'facingMode': 'user',
          'width': 640,
          'height': 480,
          'frameRate': 30,
        },
      });

      screenRenderer.srcObject = _screenStream;
      cameraRenderer.srcObject = _cameraStream;

      state.value = LocalLiveHostState.waitingForViewers;
    } catch (e) {
      state.value = LocalLiveHostState.error;
      error.value = e.toString();
      await stop();
      rethrow;
    }
  }

  Future<void> _onSignalMessage(JsonMap msg) async {
    final type = msg['type']?.toString();
    final viewerId = msg['viewerId']?.toString();

    if (type == 'viewer-connected') {
      // Nothing to do yet; we wait for viewer-hello already handled in signaling.
      return;
    }

    if (type == 'viewer-disconnected') {
      if (viewerId == null) return;
      await _removeViewer(viewerId);
      return;
    }

    if (viewerId == null) return;

    if (type == 'answer') {
      final peer = _peers[viewerId];
      final sdp = msg['sdp'] as String?;
      if (peer == null || sdp == null) return;

      await peer.pc.setRemoteDescription(RTCSessionDescription(sdp, 'answer'));
      return;
    }

    if (type == 'candidate') {
      final peer = _peers[viewerId];
      final c = msg['candidate'] as Map?;
      if (peer == null || c == null) return;

      await peer.pc.addCandidate(
        RTCIceCandidate(
          c['candidate'] as String?,
          c['sdpMid'] as String?,
          (c['sdpMLineIndex'] as num?)?.toInt(),
        ),
      );
      return;
    }

    // We treat hello-ack as server -> client only; ignore here.
  }

  Future<void> addViewerIfNeeded(String viewerId) async {
    if (_peers.containsKey(viewerId)) return;

    final server = _server;
    if (server == null) return;

    final pc = await createPeerConnection({
      'sdpSemantics': 'unified-plan',
      'iceServers': <Map<String, dynamic>>[],
    });

    final peer = _ViewerPeer(viewerId: viewerId, pc: pc);
    _peers[viewerId] = peer;

    pc.onIceCandidate = (c) {
      if (c.candidate == null) return;
      server.sendToViewer(viewerId, {
        'type': 'candidate',
        'candidate': {
          'candidate': c.candidate,
          'sdpMid': c.sdpMid,
          'sdpMLineIndex': c.sdpMLineIndex,
        },
        'matchId': liveMatchId,
      });
    };

    pc.onConnectionState = (s) {
      if (s == RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
        state.value = LocalLiveHostState.connected;
      }
      if (s == RTCPeerConnectionState.RTCPeerConnectionStateFailed ||
          s == RTCPeerConnectionState.RTCPeerConnectionStateDisconnected ||
          s == RTCPeerConnectionState.RTCPeerConnectionStateClosed) {
        _removeViewer(viewerId);
      }
    };

    // Data channel per viewer (events/chat)
    final dc = await pc.createDataChannel(
      'events',
      RTCDataChannelInit()..ordered = true,
    );
    peer.eventsChannel = dc;

    dc.onDataChannelState = (s) {
      if (s == RTCDataChannelState.RTCDataChannelOpen) {
        _sendTrackMappingToViewer(viewerId);
      }
    };

    dc.onMessage = (m) {
      _onViewerDataChannelMessage(viewerId, m.text);
    };

    // Add tracks to this viewer peer connection
    final screenStream = _screenStream;
    final cameraStream = _cameraStream;
    if (screenStream != null) {
      for (final t in screenStream.getVideoTracks()) {
        pc.addTrack(t, screenStream);
      }
    }
    if (cameraStream != null) {
      for (final t in cameraStream.getVideoTracks()) {
        pc.addTrack(t, cameraStream);
      }
      for (final t in cameraStream.getAudioTracks()) {
        pc.addTrack(t, cameraStream);
      }
    }

    // Create offer and send it to this viewer
    final offer = await pc.createOffer({
      'offerToReceiveAudio': false,
      'offerToReceiveVideo': false,
    });
    await pc.setLocalDescription(offer);

    server.sendToViewer(viewerId, {
      'type': 'offer',
      'sdp': offer.sdp,
      'matchId': liveMatchId,
    });
  }

  void _onViewerDataChannelMessage(String viewerId, String text) {
    // Viewer -> Host events (chat/reaction)
    try {
      final msg = jsonDecode(text) as Map<String, dynamic>;
      if (msg['type'] == 'event') {
        final event = (msg['event'] as Map?)?.cast<String, dynamic>();
        if (event == null) return;

        final enriched = <String, dynamic>{
          ...event,
          'from': viewerId,
          'ts': DateTime.now().millisecondsSinceEpoch,
        };

        // Emit locally for host UI
        _events.add(enriched);

        // Broadcast to all viewers (including sender)
        broadcastEvent(enriched);
      }
    } catch (_) {
      // ignore
    }
  }

  void _sendTrackMappingToViewer(String viewerId) {
    final screenTrackId = _screenStream?.getVideoTracks().isNotEmpty == true
        ? _screenStream!.getVideoTracks().first.id
        : null;

    final cameraTrackId = _cameraStream?.getVideoTracks().isNotEmpty == true
        ? _cameraStream!.getVideoTracks().first.id
        : null;

    if (screenTrackId == null || cameraTrackId == null) return;

    final payload = jsonEncode({
      'type': 'tracks',
      'screenVideoTrackId': screenTrackId,
      'cameraVideoTrackId': cameraTrackId,
    });

    _peers[viewerId]?.eventsChannel?.send(RTCDataChannelMessage(payload));
  }

  /// Host can call this too (e.g. send chat/reaction from host UI).
  void broadcastEvent(Map<String, dynamic> event) {
    final payload = jsonEncode({'type': 'event', 'event': event});
    for (final peer in _peers.values) {
      final dc = peer.eventsChannel;
      if (dc == null) continue;
      if (dc.state != RTCDataChannelState.RTCDataChannelOpen) continue;
      try {
        dc.send(RTCDataChannelMessage(payload));
      } catch (_) {}
    }
  }

  Future<void> _removeViewer(String viewerId) async {
    final peer = _peers.remove(viewerId);
    if (peer == null) return;

    try {
      await peer.eventsChannel?.close();
    } catch (_) {}

    try {
      await peer.pc.close();
    } catch (_) {}

    viewerCount.value = _peers.length;
  }

  Future<void> stop() async {
    state.value = LocalLiveHostState.stopped;

    try {
      await _serverSub?.cancel();
    } catch (_) {}
    _serverSub = null;

    for (final id in _peers.keys.toList()) {
      await _removeViewer(id);
    }
    _peers.clear();

    try {
      await _broadcaster?.stop();
    } catch (_) {}
    _broadcaster = null;

    try {
      await _screenStream?.dispose();
    } catch (_) {}
    _screenStream = null;

    try {
      await _cameraStream?.dispose();
    } catch (_) {}
    _cameraStream = null;

    screenRenderer.srcObject = null;
    cameraRenderer.srcObject = null;

    try {
      await screenRenderer.dispose();
    } catch (_) {}
    try {
      await cameraRenderer.dispose();
    } catch (_) {}

    try {
      await _server?.stop();
    } catch (_) {}
    _server = null;

    try {
      await _events.close();
    } catch (_) {}
  }
}

class _ViewerPeer {
  _ViewerPeer({required this.viewerId, required this.pc});

  final String viewerId;
  final RTCPeerConnection pc;
  RTCDataChannel? eventsChannel;
}
