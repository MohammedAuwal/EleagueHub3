// lib/core/services/connectivity_service.dart
import 'package:flutter/foundation.dart';
// If using connectivity_plus, uncomment and add to pubspec.yaml:
import 'package:connectivity_plus/connectivity_plus.dart'; // Added for real connectivity checks

class ConnectivityService {
  // Private constructor for singleton pattern
  ConnectivityService._privateConstructor();

  // The single instance of the ConnectivityService
  static final ConnectivityService _instance = ConnectivityService._privateConstructor();

  // Getter to access the singleton instance
  static ConnectivityService get instance => _instance;

  // ValueNotifier to hold and notify listeners about the connectivity status.
  // Initialize with true assuming online, or run an initial check.
  final ValueNotifier<bool> isConnected = ValueNotifier<bool>(true);

  // Added flag to ensure initialize is only called once
  bool _initialized = false;

  void initialize() {
    if (_initialized) return; // Prevent multiple initializations
    _initialized = true;

    // --- Start: Real Connectivity Check using connectivity_plus ---
    // Initial check
    Connectivity().checkConnectivity().then((result) {
      if (result == ConnectivityResult.none) {
        isConnected.value = false;
      } else {
        isConnected.value = true;
      }
    });

    // Listen to connectivity changes
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (result == ConnectivityResult.none) {
        isConnected.value = false;
      } else {
        isConnected.value = true;
      }
    });
    // --- End: Real Connectivity Check ---

    // --- Start: Your new listener logic ---
    isConnected.addListener(() {
      if (isConnected.value) {
        print("Back Online! Triggering Vice-Versa Sync...");
        // This is where we call our logic to upload 'isSynced = 0' matches
        // Example: mySyncService.startOfflineDataUpload();
      } else {
        print("App is offline.");
      }
    });
    // --- End: Your new listener logic ---
  }

  // For testing purposes, a method to manually change connectivity status
  void setConnectivityStatus(bool status) {
    isConnected.value = status;
  }
}
