import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/app/app.dart';
import 'core/persistence/prefs_service.dart';
import 'core/theme/theme_controller.dart';
import 'core/services/connectivity_service.dart';
import 'widgets/offline_banner.dart';

Future<void> main() async {
  // 1. Critical for stability and native plugin initialization
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // 2. Load Services
    final prefs = await PreferencesService.create();
    ConnectivityService.instance.initialize();

    runApp(
      ProviderScope(
        overrides: [
          prefsServiceProvider.overrideWithValue(prefs),
        ],
        child: const AppRoot(),
      ),
    );
  } catch (e) {
    runApp(MaterialApp(home: Scaffold(body: Center(child: Text('Fatal Start Error: $e')))));
  }
}

class AppRoot extends ConsumerWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 3. Watch the theme state from our Riverpod controller
    final themeMode = ref.watch(themeControllerProvider).mode;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EleagueHub 3',
      
      // Theme Configuration
      themeMode: themeMode,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: Colors.cyan,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.cyan,
        scaffoldBackgroundColor: Colors.black,
      ),

      // 4. Connectivity & Main App Wrapper
      builder: (context, child) {
        return Stack(
          children: [
            child!, // The main app content (EleagueHubApp)
            
            // Global Connectivity Overlay
            ValueListenableBuilder<bool>(
              valueListenable: ConnectivityService.instance.isConnected,
              builder: (context, online, _) {
                return online ? const SizedBox.shrink() : const OfflineBanner();
              },
            ),
          ],
        );
      },
      home: const EleagueHubApp(),
    );
  }
}
