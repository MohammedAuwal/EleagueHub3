import 'dart:io';

import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class ForegroundStreamingService {
  static const _ch = MethodChannel('local_live');

  /// Start foreground service so the app keeps running while user switches to game.
  static Future<void> start({
    required String matchId,
    String? title,
    String? text,
  }) async {
    if (!Platform.isAndroid) return;

    // Android 13+ needs notification permission for foreground-service notification.
    // Some devices will crash/deny startForeground without it.
    final notif = await Permission.notification.status;
    if (!notif.isGranted) {
      await Permission.notification.request();
    }

    await _ch.invokeMethod('startForegroundStreamingService', {
      'title': title ?? 'Live match: $matchId',
      'text': text ?? 'Streaming screen + camera is active',
    });
  }

  static Future<void> stop() async {
    if (!Platform.isAndroid) return;
    await _ch.invokeMethod('stopForegroundStreamingService');
  }
}
