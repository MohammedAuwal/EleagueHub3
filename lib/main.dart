import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/app/app.dart';
import 'core/persistence/prefs_service.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'core/services/connectivity_service.dart';
import 'core/widgets/offline_banner.dart';
import 'core/services/notification_service.dart';

Future<void> main() async {
  // Initialize Flutter engine
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Load persisted preferences
    final prefs = await PreferencesService.create();

    // Connectivity & notifications
    ConnectivityService.instance.initialize();
    await NotificationService().init();

    runApp(
      ProviderScope(
        overrides: [
          prefsServiceProvider.overrideWithValue(prefs),
        ],
        child: const AppRoot(),
      ),
    );
  } catch (e) {
    // Fallback in case of startup error
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text(
            'Fatal Start Error: $e',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
    ));
  }
}

class AppRoot extends ConsumerWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch theme mode from ThemeController
    final themeMode = ref.watch(themeControllerProvider).mode;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'eSportlyic',

      // =========================
      // THEME CONFIGURATION
      // =========================
      themeMode: themeMode,
      theme: AppTheme.skyTheme(),      // Sky (light) theme
      darkTheme: AppTheme.navyTheme(), // Navy (dark) theme

      // =========================
      // CONNECTIVITY WRAPPER
      // =========================
      builder: (context, child) {
        return Stack(
          children: [
            if (child != null) child,
            ValueListenableBuilder<bool>(
              valueListenable:
                  ConnectivityService.instance.isConnected,
              builder: (context, online, _) {
                return online
                    ? const SizedBox.shrink()
                    : const OfflineBanner();
              },
            ),
          ],
        );
      },

      // =========================
      // APP ENTRY
      // =========================
      home: const EleagueHubApp(),
    );
  }
}
