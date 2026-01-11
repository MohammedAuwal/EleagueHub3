import 'league_format.dart';
import 'league_settings.dart';

class League {
  final String id;
  final String code;
  final String name;
  final LeagueFormat format;
  final String organizerUserId;
  final LeagueSettings settings;
  final int updatedAtMs;
  final int version;

  const League({
    required this.id,
    required this.code,
    required this.name,
    required this.format,
    required this.organizerUserId,
    required this.settings,
    required this.updatedAtMs,
    required this.version,
  });

  Map<String, dynamic> toRemoteMap() => {
        'id': id,
        'code': code,
        'name': name,
        'format': format.index,
        'organizerUserId': organizerUserId,
        'settings': settings.toMap(),
        'updatedAtMs': updatedAtMs,
        'version': version,
      };

  static League fromRemoteMap(Map<String, dynamic> map) {
    return League(
      id: map['id'] as String,
      code: map['code'] as String,
      name: map['name'] as String,
      // Fixed: Using the extension's static method
      format: LeagueFormatX.fromInt((map['format'] as num).toInt()),
      organizerUserId: map['organizerUserId'] as String,
      settings: LeagueSettings.fromMap((map['settings'] as Map).cast<String, dynamic>()),
      updatedAtMs: (map['updatedAtMs'] as num).toInt(),
      version: (map['version'] as num).toInt(),
    );
  }
}
