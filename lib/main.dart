import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/app/app.dart';
import 'core/persistence/prefs_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // We initialize the service here exactly like your current code
  final prefs = await PreferencesService.create();

  runApp(
    ProviderScope(
      overrides: [
        // We keep the provider name we standardized earlier
        prefsServiceProvider.overrideWithValue(prefs),
      ],
      // We go straight to EleagueHubApp because it now handles its own theme init
      child: const EleagueHubApp(),
    ),
  );
}
