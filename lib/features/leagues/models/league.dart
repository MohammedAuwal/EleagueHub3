import 'league_format.dart';
import 'league_settings.dart';

/// The core League entity for eSportlyic.
/// 
/// This model represents a single league instance, whether it is 
/// a Classic League or a UCL League. It includes sync metadata
/// (updatedAtMs and version) to handle offline-first data.
class League {
  final String id;
  final String code; // The 8-digit join code
  final String name;
  final LeagueFormat format;
  final String organizerUserId;

  final LeagueSettings settings;

  /// Local + remote sync metadata (Last Write Wins - LWW)
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

  /// Creates a copy of the League with updated fields.
  League copyWith({
    String? id,
    String? code,
    String? name,
    LeagueFormat? format,
    String? organizerUserId,
    LeagueSettings? settings,
    int? updatedAtMs,
    int? version,
  }) {
    return League(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      format: format ?? this.format,
      organizerUserId: organizerUserId ?? this.organizerUserId,
      settings: settings ?? this.settings,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      version: version ?? this.version,
    );
  }

  /// Converts the League object into a Map for remote database storage.
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

  /// Factory to create a League object from a remote database Map.
  static League fromRemoteMap(Map<String, dynamic> map) {
    return League(
      id: map['id'] as String,
      code: map['code'] as String,
      name: map['name'] as String,
      format: LeagueFormat.fromInt((map['format'] as num).toInt()),
      organizerUserId: map['organizerUserId'] as String,
      settings: LeagueSettings.fromMap((map['settings'] as Map).cast<String, dynamic>()),
      updatedAtMs: (map['updatedAtMs'] as num).toInt(),
      version: (map['version'] as num).toInt(),
    );
  }
}
