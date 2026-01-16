import 'dart:async';
import 'package:flutter/services.dart';

import '../domain/live_session.dart';

/// Platform channel name for local-live integration.
const _channelName = 'local_live';

class LocalLiveService {
  LocalLiveService._();

  static final LocalLiveService instance = LocalLiveService._();

  final MethodChannel _channel = const MethodChannel(_channelName);

  Future<LiveSession> startHostSession({
    required String leagueId,
    required String matchId,
    required String liveMatchId,
  }) async {
    await _channel.invokeMethod('startHostSession', {
      'leagueId': leagueId,
      'matchId': matchId,
      'liveMatchId': liveMatchId,
    });

    return LiveSession(
      liveMatchId: liveMatchId,
      leagueId: leagueId,
      matchId: matchId,
      isHost: true,
    );
  }

  Future<void> stopHostSession(String liveMatchId) async {
    await _channel.invokeMethod('stopHostSession', {
      'liveMatchId': liveMatchId,
    });
  }

  Future<LiveSession> joinViewerSession({
    required String liveMatchId,
  }) async {
    await _channel.invokeMethod('joinViewerSession', {
      'liveMatchId': liveMatchId,
    });

    return LiveSession(
      liveMatchId: liveMatchId,
      leagueId: '',
      matchId: liveMatchId,
      isHost: false,
    );
  }

  Future<void> leaveViewerSession(String liveMatchId) async {
    await _channel.invokeMethod('leaveViewerSession', {
      'liveMatchId': liveMatchId,
    });
  }

  Future<void> sendLiveEvent({
    required String liveMatchId,
    required Map<String, dynamic> event,
  }) async {
    await _channel.invokeMethod('sendLiveEvent', {
      'liveMatchId': liveMatchId,
      'event': event,
    });
  }

  final StreamController<Map<String, dynamic>> _eventsController =
      StreamController.broadcast();

  Stream<Map<String, dynamic>> get liveEvents =>
      _eventsController.stream;

  void handleIncomingEvent(Map<String, dynamic> event) {
    _eventsController.add(event);
  }
}
