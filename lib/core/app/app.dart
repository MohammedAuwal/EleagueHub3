import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../routing/app_router.dart';
import '../theme/app_theme.dart';
import '../theme/theme_controller.dart';

class EleagueHubApp extends ConsumerWidget {
  const EleagueHubApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Keep watching the theme mode
    final mode = ref.watch(themeControllerProvider).mode;

    return MaterialApp.router(
      title: 'EleagueHub',
      debugShowCheckedModeBanner: false,
      themeMode: mode,
      theme: AppTheme.skyTheme(),
      darkTheme: AppTheme.navyTheme(),
      // Point directly to the global variable from app_router.dart
      routerConfig: appRouter, 
      builder: (context, child) {
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
