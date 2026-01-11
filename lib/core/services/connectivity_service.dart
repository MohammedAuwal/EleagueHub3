import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Global connectivity service
/// - Handles online/offline state
/// - Safe for app-wide usage
/// - Compatible with connectivity_plus 6.x
class ConnectivityService {
  ConnectivityService._internal();

  static final ConnectivityService instance =
      ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();

  /// True when device has an active network
  final ValueNotifier<bool> isConnected = ValueNotifier<bool>(true);

  StreamSubscription<List<ConnectivityResult>>? _subscription;

  /// Must be called once (e.g. in main.dart)
  Future<void> initialize() async {
    // Check initial connectivity state
    final results = await _connectivity.checkConnectivity();
    _updateStatus(results);

    // Listen for changes
    _subscription = _connectivity.onConnectivityChanged.listen(_updateStatus);
  }

  void _updateStatus(List<ConnectivityResult> results) {
    final hasConnection =
        results.isNotEmpty && !results.contains(ConnectivityResult.none);

    if (isConnected.value != hasConnection) {
      isConnected.value = hasConnection;
    }
  }

  /// Call only on app shutdown (usually not needed)
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }
}
