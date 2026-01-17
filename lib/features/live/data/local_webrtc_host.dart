import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:permission_handler/permission_handler.dart';

import 'local_lan_ip.dart';
import 'local_signaling.dart';

enum LocalLiveHostState {
  idle,
  starting,
  waitingForViewer,
  negotiating,
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

  final RTCVideoRenderer screenRenderer = RTCVideoRenderer();
  final RTCVideoRenderer cameraRenderer = RTCVideoRenderer();

  LocalSignalingServer? _server;
  RTCPeerConnection? _pc;

  MediaStream? _screenStream;
  MediaStream? _cameraStream;

  RTCDataChannel? _dataChannel;

  StreamSubscription? _serverSub;

  Future<void> start() async {
    if (_server != null) return;

    state.value = LocalLiveHostState.starting;
    error.value = null;

    try {
      await screenRenderer.initialize();
      await cameraRenderer.initialize();

      // Runtime permissions (camera + mic). Screen permission will be requested by getDisplayMedia().
      final statuses = await [
        Permission.camera,
        Permission.microphone,
      ].request();

      final denied = statuses.entries.where((e) => !e.value.isGranted).toList();
      if (denied.isNotEmpty) {
        throw Exception('Permissions denied: ${denied.map((e) => e.key).join(', ')}');
      }

      hostIp.value = await LocalLanIp.findLocalIpv4();

      _server = LocalSignalingServer(port: port, matchId: liveMatchId);
      await _server!.start();

      viewerCount.value = 0;
      _server!.viewerCount.addListener(() {
        viewerCount.value = _server!.viewerCount.value;
      });

      _serverSub = _server!.viewerMessages.listen(_onViewerSignal);

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

      // Create peer connection
      _pc = await createPeerConnection({
        'sdpSemantics': 'unified-plan',
        'iceServers': <Map<String, dynamic>>[],
      });

      _pc!.onIceCandidate = (c) {
        if (c.candidate == null) return;
        _server?.sendToViewer({
          'type': 'candidate',
          'candidate': {
            'candidate': c.candidate,
            'sdpMid': c.sdpMid,
            'sdpMLineIndex': c.sdpMLineIndex,
          },
          'matchId': liveMatchId,
        });
      };

      _pc!.onConnectionState = (s) {
        if (s == RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
          state.value = LocalLiveHostState.connected;
        }
      };

      // Data channel (for track mapping + later chat/events)
      _dataChannel = await _pc!.createDataChannel(
        'events',
        RTCDataChannelInit()..ordered = true,
      );

      _dataChannel!.onDataChannelState = (s) {
        if (s == RTCDataChannelState.RTCDataChannelOpen) {
          _sendTrackMapping();
        }
      };

      // Add tracks: screen video + camera video + mic audio
      for (final t in _screenStream!.getVideoTracks()) {
        await _pc!.addTrack(t, _screenStream!);
      }
      for (final t in _cameraStream!.getVideoTracks()) {
        await _pc!.addTrack(t, _cameraStream!);
      }
      for (final t in _cameraStream!.getAudioTracks()) {
        await _pc!.addTrack(t, _cameraStream!);
      }

      state.value = LocalLiveHostState.waitingForViewer;
    } catch (e) {
      state.value = LocalLiveHostState.error;
      error.value = e.toString();
      await stop();
      rethrow;
    }
  }

  Future<void> _onViewerSignal(JsonMap msg) async {
    final type = msg['type'];
    if (type == 'viewer-hello') {
      if (msg['matchId'] != liveMatchId) return;
      await _negotiateOffer();
      return;
    }

    if (type == 'answer') {
      final sdp = msg['sdp'] as String?;
      if (sdp == null) return;
      await _pc?.setRemoteDescription(
        RTCSessionDescription(sdp, 'answer'),
      );
      return;
    }

    if (type == 'candidate') {
      final c = msg['candidate'] as Map?;
      if (c == null) return;
      await _pc?.addCandidate(
        RTCIceCandidate(
          c['candidate'] as String?,
          c['sdpMid'] as String?,
          (c['sdpMLineIndex'] as num?)?.toInt(),
        ),
      );
      return;
    }
  }

  Future<void> _negotiateOffer() async {
    final pc = _pc;
    final server = _server;
    if (pc == null || server == null) return;

    state.value = LocalLiveHostState.negotiating;

    final offer = await pc.createOffer({
      'offerToReceiveAudio': false,
      'offerToReceiveVideo': false,
    });

    await pc.setLocalDescription(offer);

    server.sendToViewer({
      'type': 'offer',
      'sdp': offer.sdp,
      'matchId': liveMatchId,
    });
  }

  void _sendTrackMapping() {
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

    _dataChannel?.send(RTCDataChannelMessage(payload));
  }

  Future<void> stop() async {
    state.value = LocalLiveHostState.stopped;

    try {
      await _serverSub?.cancel();
    } catch (_) {}
    _serverSub = null;

    try {
      await _dataChannel?.close();
    } catch (_) {}
    _dataChannel = null;

    try {
      await _pc?.close();
    } catch (_) {}
    _pc = null;

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
  }
}
