import 'league_format.dart';
import 'league_settings.dart';

class League {
  final String id;
  final String name;
  final LeagueFormat format;
  final LeaguePrivacy privacy;
  final String region;
  final int maxTeams;
  final String season;
  final String organizerUserId; // Renamed from ownerId to fix repo error
  final String code;
  final LeagueSettings settings;
  final int updatedAtMs;
  final int version;

  const League({
    required this.id,
    required this.name,
    required this.format,
    required this.privacy,
    required this.region,
    required this.maxTeams,
    required this.season,
    required this.organizerUserId,
    required this.code,
    required this.settings,
    required this.updatedAtMs,
    required this.version,
  });

  bool get isPrivate => privacy == LeaguePrivacy.private;

  static League fromRemoteMap(Map<String, dynamic> map) {
    return League(
      id: map['id'] as String,
      name: map['name'] as String,
      format: LeagueFormatX.fromInt((map['format'] as num).toInt()),
      privacy: (map['isPrivate'] == 1 || map['isPrivate'] == true) 
          ? LeaguePrivacy.private : LeaguePrivacy.public,
      region: map['region'] as String? ?? 'Global',
      maxTeams: (map['maxTeams'] as num?)?.toInt() ?? 20,
      season: map['season'] as String? ?? '2026',
      organizerUserId: map['organizerUserId'] as String? ?? '',
      code: map['code'] as String? ?? '',
      settings: LeagueSettings.fromMap((map['settings'] as Map).cast<String, dynamic>()),
      updatedAtMs: (map['updatedAtMs'] as num?)?.toInt() ?? 0,
      version: (map['version'] as num?)?.toInt() ?? 1,
    );
  }
}
