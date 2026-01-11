import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Riverpod provider for PreferencesService
final prefsServiceProvider = Provider<PreferencesService>((ref) {
  throw UnimplementedError(
      'PreferencesService must be overridden in main() with PreferencesService.create().');
});

/// Wrapper around SharedPreferences for app-level settings
class PreferencesService {
  PreferencesService._(this._sp);

  final SharedPreferences _sp;

  // Keys
  static const _kThemeMode = 'theme_mode';
  static const _kNotificationsEnabled = 'notifications_enabled';
  static const _kMarketingEnabled = 'notifications_marketing';
  static const _kMatchRemindersEnabled = 'notifications_match_reminders';

  /// Initialize SharedPreferences instance
  static Future<PreferencesService> create() async {
    final sp = await SharedPreferences.getInstance();
    return PreferencesService._(sp);
  }

  /// =====================
  /// Theme persistence
  /// =====================

  /// Get stored theme mode ('light' or 'dark')
  String? getThemeMode() => _sp.getString(_kThemeMode);

  /// Save theme mode
  Future<void> setThemeMode(String mode) async {
    await _sp.setString(_kThemeMode, mode);
  }

  /// =====================
  /// Notifications
  /// =====================

  Future<Map<String, bool>> loadNotificationPrefs() async {
    return {
      'enabled': _sp.getBool(_kNotificationsEnabled) ?? true,
      'marketing': _sp.getBool(_kMarketingEnabled) ?? false,
      'matchReminders': _sp.getBool(_kMatchRemindersEnabled) ?? true,
    };
  }

  Future<void> saveNotificationPrefs({
    required bool enabled,
    required bool marketing,
    required bool matchReminders,
  }) async {
    await _sp.setBool(_kNotificationsEnabled, enabled);
    await _sp.setBool(_kMarketingEnabled, marketing);
    await _sp.setBool(_kMatchRemindersEnabled, matchReminders);
  }
}
