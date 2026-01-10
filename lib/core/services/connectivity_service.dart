import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class ConnectivityService {
  ConnectivityService._internal();
  static final ConnectivityService instance = ConnectivityService._internal();

  final ValueNotifier<bool> isConnected = ValueNotifier(true);

  void initialize() {
    // connectivity_plus 6.0.0+ returns a List<ConnectivityResult>
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      // If the list contains 'none', or is empty, we are offline
      final hasConnection = results.isNotEmpty && !results.contains(ConnectivityResult.none);
      isConnected.value = hasConnection;
    });
  }
}
