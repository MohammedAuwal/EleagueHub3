import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// Offline-first user identity.
///
/// Assumption:
/// - App may not have auth wired into this feature.
/// - We generate and persist a device-local stable userId.
/// - If your app already has auth, swap this implementation by providing
///   your own userId into the repository/providers.
class CurrentUser {
  static const _kKey = 'leagues.currentUserId';

  static Future<String> getOrCreateUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_kKey);
    if (existing != null && existing.isNotEmpty) return existing;
    final id = const Uuid().v4();
    await prefs.setString(_kKey, id);
    return id;
  }
}
