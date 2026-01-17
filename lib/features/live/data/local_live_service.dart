import 'local_webrtc_host.dart';
import 'local_webrtc_viewer.dart';

class LocalLiveService {
  LocalLiveService._();
  static final LocalLiveService instance = LocalLiveService._();

  LocalLiveHostSession? _host;
  LocalLiveViewerSession? _viewer;

  LocalLiveHostSession? get activeHost => _host;
  LocalLiveViewerSession? get activeViewer => _viewer;

  Future<LocalLiveHostSession> startHostSession({
    required String liveMatchId,
    int port = 8765,
  }) async {
    await stopHostSession(liveMatchId: liveMatchId);

    final host = LocalLiveHostSession(liveMatchId: liveMatchId, port: port);
    _host = host;
    await host.start();
    return host;
  }

  Future<void> stopHostSession({required String liveMatchId}) async {
    final host = _host;
    if (host == null) return;
    if (host.liveMatchId != liveMatchId) return;

    await host.stop();
    _host = null;
  }

  Future<LocalLiveViewerSession> joinViewerSession({
    required String liveMatchId,
    required String host,
    required int port,
  }) async {
    await leaveViewerSession(liveMatchId: liveMatchId);

    final viewer = LocalLiveViewerSession(
      liveMatchId: liveMatchId,
      host: host,
      port: port,
    );
    _viewer = viewer;
    await viewer.connect();
    return viewer;
  }

  Future<void> leaveViewerSession({required String liveMatchId}) async {
    final viewer = _viewer;
    if (viewer == null) return;
    if (viewer.liveMatchId != liveMatchId) return;

    await viewer.disconnect();
    _viewer = null;
  }

  // Placeholder for future: send chat/events via data channel.
  Future<void> sendLiveEvent({
    required String liveMatchId,
    required Map<String, dynamic> event,
  }) async {
    // Not implemented (yet). Keep API for compatibility with MainActivity channel idea.
  }
}
