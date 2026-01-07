import 'package:eleaguehub/core/app/app.dart';
import 'package:eleaguehub/core/persistence/prefs_service.dart';
import 'package:eleaguehub/core/theme/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await PrefsService.create();
  runApp(
    ProviderScope(
      overrides: [
        prefsServiceProvider.overrideWithValue(prefs),
      ],
      child: const EleagueHubAppBootstrap(),
    ),
  );
}

class EleagueHubAppBootstrap extends ConsumerStatefulWidget {
  const EleagueHubAppBootstrap({super.key});

  @override
  ConsumerState<EleagueHubAppBootstrap> createState() =>
      _EleagueHubAppBootstrapState();
}

class _EleagueHubAppBootstrapState
    extends ConsumerState<EleagueHubAppBootstrap> {
  @override
  void initState() {
    super.initState();
    // Initialize theme from persisted value or system brightness.
    Future.microtask(() => ref.read(themeControllerProvider.notifier).init());
  }

  @override
  Widget build(BuildContext context) {
    return const EleagueHubApp();
  }
}
