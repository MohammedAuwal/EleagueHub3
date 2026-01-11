/// Represents a team within a specific league in eSportlyic.
///
/// This model is league-scoped:
/// - A team belongs to ONE league
/// - Team IDs are globally unique
/// - Safe for Classic, UCL Group, and Swiss formats
///
/// Includes offline-first sync metadata (Last Write Wins).
class Team {
  final String id;
  final String leagueId;
  final String name;

  /// Offline + remote sync metadata
  final int updatedAtMs;
  final int version;

  const Team({
    required this.id,
    required this.leagueId,
    required this.name,
    required this.updatedAtMs,
    required this.version,
  });

  /// Creates a new Team with modified fields.
  Team copyWith({
    String? id,
    String? leagueId,
    String? name,
    int? updatedAtMs,
    int? version,
  }) {
    return Team(
      id: id ?? this.id,
      leagueId: leagueId ?? this.leagueId,
      name: name ?? this.name,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      version: version ?? this.version,
    );
  }

  /// Serialize for remote database storage.
  Map<String, dynamic> toRemoteMap() => {
        'id': id,
        'leagueId': leagueId,
        'name': name,
        'updatedAtMs': updatedAtMs,
        'version': version,
      };

  /// Deserialize from remote database.
  static Team fromRemoteMap(Map<String, dynamic> map) {
    return Team(
      id: map['id'] as String,
      leagueId: map['leagueId'] as String,
      name: map['name'] as String,
      updatedAtMs: (map['updatedAtMs'] as num).toInt(),
      version: (map['version'] as num).toInt(),
    );
  }

  /// Equality based on stable identity (important for Riverpod & UI diffing)
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Team && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
