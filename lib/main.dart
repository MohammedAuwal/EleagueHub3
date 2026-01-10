import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Your existing imports
import 'core/app/app.dart';
import 'core/persistence/prefs_service.dart';

// Import the ConnectivityService and OfflineBanner from their respective files
// Make sure these files exist in your project:
import 'core/services/connectivity_service.dart'; // Create this file
import 'widgets/offline_banner.dart';           // Create this file

Future<void> main() async {
  // 1. Critical for Release Mode stability
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // 2. Initialize SharedPreferences with a timeout/error catch
    final prefs = await PreferencesService.create();

    // Initialize ConnectivityService here, as it now has an important listener
    ConnectivityService.instance.initialize(); 

    runApp(
      ProviderScope(
        overrides: [
          prefsServiceProvider.overrideWithValue(prefs),
        ],
        child: MaterialApp( // Use MaterialApp here to provide global app structure, theme, etc.
          debugShowCheckedModeBanner: false, // Good practice for release builds
          home: ValueListenableBuilder<bool>(
            valueListenable: ConnectivityService.instance.isConnected,
            builder: (context, online, child) {
              return Scaffold( // Scaffold provides the basic visual structure for the screen
                body: Column(
                  children: [
                    // The glass banner, conditionally shown at the top
                    if (!online) const OfflineBanner(),
                    // The rest of your application, taking up the remaining space
                    Expanded(
                      child: const EleagueHubApp(), // Your main application content
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  } catch (e) {
    // 3. Prevent the "Blink" - show a simple error if the app fails to start
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Startup Error: $e', style: const TextStyle(color: Colors.red)),
          ),
        ),
      ),
    );
  }
}
