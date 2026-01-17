import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';

typedef JsonMap = Map<String, dynamic>;

String _randId() {
  final r = Random.secure();
  const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
  return List.generate(10, (_) => chars[r.nextInt(chars.length)]).join();
}

class LocalSignalingServer {
  LocalSignalingServer({required this.port, required this.matchId});

  final int port;
  final String matchId;

  HttpServer? _server;

  final Map<String, WebSocket> _viewers = {}; // viewerId -> ws
  final Map<WebSocket, String> _wsToViewerId = {}; // ws -> viewerId

  final _messages = StreamController<JsonMap>.broadcast();
  Stream<JsonMap> get messages => _messages.stream;

  final ValueNotifier<int> viewerCount = ValueNotifier<int>(0);

  Future<void> start() async {
    if (_server != null) return;

    _server = await HttpServer.bind(InternetAddress.anyIPv4, port);
    _server!.listen((req) async {
      if (!WebSocketTransformer.isUpgradeRequest(req)) {
        req.response.statusCode = HttpStatus.badRequest;
        await req.response.close();
        return;
      }

      final ws = await WebSocketTransformer.upgrade(req);

      ws.listen(
        (data) => _onWsMessage(ws, data),
        onDone: () => _onWsClosed(ws),
        onError: (_) => _onWsClosed(ws),
        cancelOnError: true,
      );
    });
  }

  void _onWsMessage(WebSocket ws, dynamic data) {
    try {
      final msg = jsonDecode(data.toString()) as Map<String, dynamic>;
      final type = msg['type']?.toString();

      if (type == 'viewer-hello') {
        if (msg['matchId']?.toString() != matchId) {
          ws.add(jsonEncode({'type': 'error', 'message': 'Wrong matchId'}));
          ws.close();
          return;
        }

        var viewerId = msg['viewerId']?.toString();
        if (viewerId == null || viewerId.isEmpty) viewerId = _randId();

        _viewers[viewerId] = ws;
        _wsToViewerId[ws] = viewerId;
        viewerCount.value = _viewers.length;

        ws.add(jsonEncode({'type': 'hello-ack', 'viewerId': viewerId, 'matchId': matchId}));

        // Important: tell host logic a viewer connected
        _messages.add({'type': 'viewer-connected', 'viewerId': viewerId, 'matchId': matchId});
        return;
      }

      final viewerId = _wsToViewerId[ws];
      if (viewerId == null) return;

      msg['viewerId'] = viewerId;
      msg['matchId'] = matchId;
      _messages.add(msg);
    } catch (_) {
      // ignore
    }
  }

  void _onWsClosed(WebSocket ws) {
    final viewerId = _wsToViewerId.remove(ws);
    if (viewerId != null) {
      _viewers.remove(viewerId);
      viewerCount.value = _viewers.length;
      _messages.add({'type': 'viewer-disconnected', 'viewerId': viewerId, 'matchId': matchId});
    }
  }

  void sendToViewer(String viewerId, JsonMap msg) {
    final ws = _viewers[viewerId];
    if (ws == null) return;
    ws.add(jsonEncode(msg));
  }

  Future<void> stop() async {
    viewerCount.value = 0;

    for (final ws in _viewers.values) {
      try {
        await ws.close();
      } catch (_) {}
    }
    _viewers.clear();
    _wsToViewerId.clear();

    try {
      await _server?.close(force: true);
    } catch (_) {}
    _server = null;

    await _messages.close();
  }
}

class LocalSignalingClient {
  LocalSignalingClient({
    required this.host,
    required this.port,
    required this.matchId,
    required this.viewerId,
  });

  final String host;
  final int port;
  final String matchId;
  final String viewerId;

  WebSocket? _ws;

  final _messages = StreamController<JsonMap>.broadcast();
  Stream<JsonMap> get messages => _messages.stream;

  Future<void> connect() async {
    if (_ws != null) return;
    final url = 'ws://$host:$port';
    _ws = await WebSocket.connect(url);

    _ws!.listen(
      (data) {
        try {
          final msg = jsonDecode(data.toString()) as Map<String, dynamic>;
          _messages.add(msg);
        } catch (_) {}
      },
      onDone: () => _cleanup(),
      onError: (_) => _cleanup(),
      cancelOnError: true,
    );

    send({'type': 'viewer-hello'});
  }

  void send(JsonMap msg) {
    msg['viewerId'] = viewerId;
    msg['matchId'] = matchId;
    _ws?.add(jsonEncode(msg));
  }

  Future<void> close() async {
    try {
      await _ws?.close();
    } catch (_) {}
    _cleanup();
    await _messages.close();
  }

  void _cleanup() {
    _ws = null;
  }
}
