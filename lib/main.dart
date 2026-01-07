import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/persistence/preferences_service.dart';
import 'core/theme/theme_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await PreferencesService.create();
  final initialThemeMode = await prefs.loadThemeMode();

  runApp(
    ProviderScope(
      overrides: [
        preferencesServiceProvider.overrideWithValue(prefs),
        themeControllerProvider.overrideWith(
          (ref) => ThemeController(
            prefs: ref.read(preferencesServiceProvider),
            initial: initialThemeMode,
          ),
        ),
      ],
      child: const EleagueHubApp(),
    ),
  );
}
