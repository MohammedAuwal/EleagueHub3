import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../persistence/prefs_service.dart';

class ThemeState {
  const ThemeState({required this.mode});
  final ThemeMode mode;
  ThemeState copyWith({ThemeMode? mode}) => ThemeState(mode: mode ?? this.mode);
}

final themeControllerProvider = NotifierProvider<ThemeController, ThemeState>(ThemeController.new);

class ThemeController extends Notifier<ThemeState> {
  @override
  ThemeState build() {
    final prefs = ref.watch(prefsServiceProvider);
    final savedMode = prefs.getThemeMode();
    
    final initialMode = switch (savedMode) {
      'dark' => ThemeMode.dark,
      'light' => ThemeMode.light,
      _ => ThemeMode.system,
    };
    return ThemeState(mode: initialMode);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(mode: mode);
    await ref.read(prefsServiceProvider).setThemeMode(mode.name);
  }

  Future<void> toggleLightDark(BuildContext context) async {
    // FIX: Mandatory wildcard (_) for Dart 3.5+ exhaustiveness
    final effectiveBrightness = switch (state.mode) {
      ThemeMode.light => Brightness.light,
      ThemeMode.dark => Brightness.dark,
      _ => MediaQuery.platformBrightnessOf(context),
    };

    final next = effectiveBrightness == Brightness.dark
        ? ThemeMode.light
        : ThemeMode.dark;
    
    await setThemeMode(next);
  }
}
