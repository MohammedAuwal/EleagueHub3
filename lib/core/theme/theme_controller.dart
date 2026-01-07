import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../persistence/preferences_service.dart';

final themeControllerProvider =
    NotifierProvider<ThemeController, ThemeState>(ThemeController.new);

class ThemeState {
  const ThemeState({required this.mode});
  final ThemeMode mode;

  ThemeState copyWith({ThemeMode? mode}) => ThemeState(mode: mode ?? this.mode);
}

class ThemeController extends Notifier<ThemeState> {
  ThemeController({required PreferencesService prefs, required ThemeMode initial})
      : _prefs = prefs,
        _initial = initial;

  final PreferencesService _prefs;
  final ThemeMode _initial;

  @override
  ThemeState build() {
    return ThemeState(mode: _initial);
  }

  Future<void> setMode(ThemeMode mode) async {
    state = state.copyWith(mode: mode);
    await _prefs.saveThemeMode(mode);
  }

  Future<void> toggleLightDark(BuildContext context) async {
    // Toggle between light and dark, respecting current effective brightness
    final effectiveBrightness = switch (state.mode) {
      ThemeMode.system => MediaQuery.platformBrightnessOf(context),
      ThemeMode.light => Brightness.light,
      ThemeMode.dark => Brightness.dark,
    };

    final next = effectiveBrightness == Brightness.dark
        ? ThemeMode.light
        : ThemeMode.dark;
    await setMode(next);
  }
}
