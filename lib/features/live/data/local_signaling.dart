import 'dart:async';
import 'dart:convert';
import 'dart:io';

typedef JsonMap = Map<String, dynamic>;

class LocalSignalingServer {
  LocalSignalingServer({required this.port, required this.matchId});

  final int port;
  final String matchId;

  HttpServer? _server;
  WebSocket? _viewer;

  final _viewerMessages = StreamController<JsonMap>.broadcast();
  Stream<JsonMap> get viewerMessages => _viewerMessages.stream;

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

      if (_viewer != null) {
        ws.add(jsonEncode({
          'type': 'error',
          'message': 'A viewer is already connected to this host.',
        }));
        await ws.close();
        return;
      }

      _viewer = ws;
      viewerCount.value = 1;

      ws.listen(
        (data) {
          try {
            final msg = jsonDecode(data.toString()) as Map<String, dynamic>;
            _viewerMessages.add(msg);
          } catch (_) {
            // ignore bad messages
          }
        },
        onDone: () {
          if (_viewer == ws) _viewer = null;
          viewerCount.value = 0;
        },
        onError: (_) {
          if (_viewer == ws) _viewer = null;
          viewerCount.value = 0;
        },
        cancelOnError: true,
      );
    });
  }

  bool get hasViewer => _viewer != null;

  void sendToViewer(JsonMap msg) {
    final ws = _viewer;
    if (ws == null) return;
    ws.add(jsonEncode(msg));
  }

  Future<void> stop() async {
    viewerCount.value = 0;

    try {
      await _viewer?.close();
    } catch (_) {}
    _viewer = null;

    try {
      await _server?.close(force: true);
    } catch (_) {}
    _server = null;

    await _viewerMessages.close();
  }
}

class LocalSignalingClient {
  LocalSignalingClient({required this.host, required this.port, required this.matchId});

  final String host;
  final int port;
  final String matchId;

  WebSocket? _ws;
  final _messages = StreamController<JsonMap>.broadcast();
  Stream<JsonMap> get messages => _messages.stream;

  bool get isConnected => _ws != null;

  Future<void> connect() async {
    if (_ws != null) return;
    final url = 'ws://$host:$port';
    _ws = await WebSocket.connect(url);

    _ws!.listen(
      (data) {
        try {
          final msg = jsonDecode(data.toString()) as Map<String, dynamic>;
          _messages.add(msg);
        } catch (_) {
          // ignore
        }
      },
      onDone: () => _cleanup(),
      onError: (_) => _cleanup(),
      cancelOnError: true,
    );

    send({'type': 'viewer-hello', 'matchId': matchId});
  }

  void send(JsonMap msg) {
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
