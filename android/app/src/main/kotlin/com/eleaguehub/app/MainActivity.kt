package com.eleaguehub.app

import android.os.Bundle
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

private const val LOCAL_LIVE_CHANNEL = "local_live"

class MainActivity : FlutterActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            LOCAL_LIVE_CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "startHostSession" -> {
                    val leagueId = call.argument<String>("leagueId")
                    val matchId = call.argument<String>("matchId")
                    val liveMatchId = call.argument<String>("liveMatchId")
                    Log.i("LocalLive", "startHostSession leagueId=$leagueId matchId=$matchId liveMatchId=$liveMatchId")

                    // TODO: Implement:
                    // - Request MediaProjection permission
                    // - Start screen capture
                    // - Start LAN server / WebRTC host for this liveMatchId

                    result.success(null)
                }
                "stopHostSession" -> {
                    val liveMatchId = call.argument<String>("liveMatchId")
                    Log.i("LocalLive", "stopHostSession liveMatchId=$liveMatchId")

                    // TODO: Implement:
                    // - Stop screen capture
                    // - Stop LAN server / WebRTC host for this liveMatchId

                    result.success(null)
                }
                "joinViewerSession" -> {
                    val liveMatchId = call.argument<String>("liveMatchId")
                    Log.i("LocalLive", "joinViewerSession liveMatchId=$liveMatchId")

                    // TODO: Implement:
                    // - Discover / connect to host on same LAN/hotspot
                    // - Subscribe to host's stream for this liveMatchId

                    result.success(null)
                }
                "leaveViewerSession" -> {
                    val liveMatchId = call.argument<String>("liveMatchId")
                    Log.i("LocalLive", "leaveViewerSession liveMatchId=$liveMatchId")

                    // TODO: Implement:
                    // - Disconnect viewer from host stream

                    result.success(null)
                }
                "sendLiveEvent" -> {
                    val liveMatchId = call.argument<String>("liveMatchId")
                    val event = call.argument<Map<String, Any?>>("event")
                    Log.i("LocalLive", "sendLiveEvent liveMatchId=$liveMatchId event=$event")

                    // TODO: Implement:
                    // - Broadcast this event to all connected viewers
                    //   (e.g. via your LAN connection / WebRTC data channel)

                    result.success(null)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}
