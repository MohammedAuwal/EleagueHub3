import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final prefsServiceProvider = Provider<PreferencesService>((ref) {
  throw UnimplementedError('Override this in main()');
});

class PreferencesService {
  PreferencesService._(this._sp);
  final SharedPreferences _sp;

  static const _kThemeMode = 'theme_mode';

  static Future<PreferencesService> create() async {
    final sp = await SharedPreferences.getInstance();
    return PreferencesService._(sp);
  }

  /// Generic List helpers used by repositories
  List<String> getStringList(String key) => _sp.getStringList(key) ?? [];
  
  Future<void> setStringList(String key, List<String> value) async {
    await _sp.setStringList(key, value);
  }

  /// Theme persistence
  String? getThemeMode() => _sp.getString(_kThemeMode);
  Future<void> setThemeMode(String mode) async {
    await _sp.setString(_kThemeMode, mode);
  }

  /// Notification persistence
  Future<void> saveNotificationPrefs({
    required bool enabled,
    required bool marketing,
    required bool matchReminders,
  }) async {
    await _sp.setBool('notifications_enabled', enabled);
    await _sp.setBool('notifications_marketing', marketing);
    await _sp.setBool('notifications_match_reminders', matchReminders);
  }
}
