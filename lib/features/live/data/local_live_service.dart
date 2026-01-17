import 'local_discovery.dart';
import 'local_webrtc_host.dart';
import 'local_webrtc_viewer.dart';

class LocalLiveService {
  LocalLiveService._();
  static final LocalLiveService instance = LocalLiveService._();

  LocalLiveHostSession? _host;

  // NOTE: Viewer is now often managed directly by LiveViewScreen because
  // it may connect to TWO hosts (home + away). We still keep old API for single-viewer.
  LocalLiveViewerSession? _viewer;

  LocalLiveHostSession? get activeHost => _host;
  LocalLiveViewerSession? get activeViewer => _viewer;

  Future<LocalLiveHostSession> startHostSession({
    required String liveMatchId,
    int port = 8765,

    /// Optional broadcast labels for discovery UI
    String? homeName,
    String? awayName,

    /// Optional host side hint (home/away)
    LiveHostSide side = LiveHostSide.unknown,
  }) async {
    await stopHostSession(liveMatchId: liveMatchId);

    final host = LocalLiveHostSession(
      liveMatchId: liveMatchId,
      port: port,
      homeName: homeName,
      awayName: awayName,
      side: side,
    );
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

  /// Legacy single-viewer join (still used in some flows).
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

  /// Host-side broadcast (chat/reactions from host UI).
  void broadcastHostEvent({
    required String liveMatchId,
    required Map<String, dynamic> event,
  }) {
    final host = _host;
    if (host == null) return;
    if (host.liveMatchId != liveMatchId) return;

    host.broadcastEvent(event);
  }
}
