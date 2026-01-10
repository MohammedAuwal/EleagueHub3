import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/app/app.dart';
import 'core/persistence/prefs_service.dart';

Future<void> main() async {
  // 1. Critical for Release Mode stability
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // 2. Initialize SharedPreferences with a timeout/error catch
    final prefs = await PreferencesService.create();

    runApp(
      ProviderScope(
        overrides: [
          prefsServiceProvider.overrideWithValue(prefs),
        ],
        child: const EleagueHubApp(),
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
