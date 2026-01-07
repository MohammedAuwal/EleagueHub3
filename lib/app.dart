import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';

class EleagueHubApp extends ConsumerWidget {
  const EleagueHubApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeControllerProvider).mode;
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'EleagueHub',
      debugShowCheckedModeBanner: false,
      themeMode: mode,
      theme: AppTheme.skyTheme(),
      darkTheme: AppTheme.navyTheme(),
      routerConfig: router,
      builder: (context, child) {
        // Respect system text scaling; also prevent extreme scale from breaking UI.
        final mq = MediaQuery.of(context);
        final clampedScale = mq.textScaler.clamp(
          minScaleFactor: 0.9,
          maxScaleFactor: 1.3,
        );
        return MediaQuery(
          data: mq.copyWith(textScaler: clampedScale),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
